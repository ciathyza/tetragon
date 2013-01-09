/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package tetragon.view
{
	import tetragon.Main;
	import tetragon.data.Settings;
	import tetragon.debug.Log;
	import tetragon.file.resource.Resource;
	import tetragon.input.MouseSignal;
	import tetragon.view.loadprogress.LoadProgressDisplay;

	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.tween.Tween;
	import com.hexagonstar.tween.TweenVars;
	import com.hexagonstar.util.string.TabularText;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.utils.setTimeout;
	
	
	/**
	 * Manages the creation, opening and closing as well as updating of screens.
	 */
	public final class ScreenManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		
		/** @private */
		private var _screenContainer:Sprite;
		/** @private */
		private var _screenClasses:Object;
		/** @private */
		private var _currentScreenClass:Class;
		/** @private */
		private var _currentScreen:Screen;
		/** @private */
		private var _nextScreen:DisplayObject;
		/** @private */
		private var _tweenVars:TweenVars;
		
		/** @private */
		private var _loadProgressDisplay:LoadProgressDisplay;
		/** @private */
		private var _loadedResourceCount:uint;
		/** @private */
		private var _failedResourceCount:uint;
		
		/** @private */
		private var _background:DisplayObject;
		
		/** @private */
		private var _screenWidth:int;
		/** @private */
		private var _screenHeight:int;
		/** @private */
		private var _screenScale:Number = 1.0;
		
		/** @private */
		private var _screenOpenDelay:Number = 0.2;
		/** @private */
		private var _screenCloseDelay:Number = 0.2;
		/** @private */
		private var _tweenDuration:Number = 0.4;
		/** @private */
		private var _fastDuration:Number = 0.2;
		/** @private */
		private var _backupDuration:Number;
		/** @private */
		private var _backupOpenDelay:Number;
		/** @private */
		private var _backupCloseDelay:Number;
		
		/** @private */
		private var _isSwitching:Boolean;
		/** @private */
		private var _isAutoStart:Boolean;
		/** @private */
		private var _isScreenLoaded:Boolean;
		/** @private */
		private var _tweenBackground:Boolean = true;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		public var screenInitSignal:Signal;
		/** @private */
		public var screenCreatedSignal:Signal;
		/** @private */
		public var screenOpenedSignal:Signal;
		/** @private */
		public var screenCloseSignal:Signal;
		/** @private */
		public var screenUnloadedSignal:Signal;
		
		/** @private */
		private var _stageResizeSignal:Signal;
		/** @private */
		private var _mouseSignal:MouseSignal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new ScreenManager instance.
		 * 
		 */
		public function ScreenManager()
		{
			_main = Main.instance;
			
			_screenClasses = {};
			_backupDuration = _tweenDuration;
			_backupOpenDelay = _screenOpenDelay;
			_backupCloseDelay = _screenCloseDelay;
			
			screenInitSignal = new Signal();
			screenCreatedSignal = new Signal();
			screenOpenedSignal = new Signal();
			screenCloseSignal = new Signal();
			screenUnloadedSignal = new Signal();
			_stageResizeSignal = new Signal();
			
			_tweenVars = new TweenVars();
			
			_screenContainer = new Sprite();
			_main.contextView.addChild(_screenContainer);
			
			onStageResize(null);
			_main.stage.addEventListener(Event.RESIZE, onStageResize);
			_main.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenToggle);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a screen class for use with the screen manager.
		 * 
		 * @param screenID Unique ID of the screen.
		 * @param screenClass The screen's class.
		 */
		public function registerScreen(screenID:String, screenClass:Class):void
		{
			_screenClasses[screenID] = screenClass;
		}
		
		
		/**
		 * Starts the screen manager.
		 */
		public function start():void
		{
			var settings:Settings = _main.registry.settings;
			var showSplashScreen:Boolean = settings.getBoolean(Settings.SHOW_SPLASH_SCREEN);
			var splashScreenID:String = settings.getString(Settings.SPLASH_SCREEN_ID);
			var initialScreenID:String = settings.getString(Settings.INITIAL_SCREEN_ID);
			
			if (showSplashScreen && splashScreenID != null && splashScreenID.length > 0)
			{
				openScreen(splashScreenID);
			}
			else if (initialScreenID != null && initialScreenID.length > 0)
			{
				openScreen(initialScreenID);
			}
			else
			{
				Log.fatal("Cannot open initial screen! No initial screen ID defined.", this);
			}
		}
		
		
		/**
		 * Opens the screen of the specified ID. Any currently opened screen is closed
		 * before the new screen is opened. The screen needs to implement IScreen.
		 * 
		 * @param screenID The ID of the screen.
		 * @param autoStart Determines if the screen should automatically be started once it
		 *        has been finished opening. If this is true the screen manager
		 *        automatically calls the start() method on the screen after it has been
		 *        opened.
		 * @param fastTransition If true the screen closing/opening tween will be faster for
		 *        this time the next screen is opened. Useful for when screens should close
		 *        and open faster because of user interaction.
		 */
		public function openScreen(screenID:String, autoStart:Boolean = true,
			fastTransition:Boolean = false):void
		{
			_isAutoStart = false;
			var screenClass:Class = _screenClasses[screenID];
			
			if (screenClass == null)
			{
				Log.error("Could not open screen with ID \"" + screenID
					+ "\" because no screen class with this ID has been registered.", this);
				return;
			}
			
			/* If the specified screen is already open, only update it! */
			if (_currentScreenClass == screenClass)
			{
				updateScreen();
				return;
			}
			
			var s:DisplayObject = new screenClass();
			if (s is Screen)
			{
				verbose("Initializing screen \"" + screenID + "\" ...");
				var screen:Screen = s as Screen;
				screen.id = screenID;
				screenInitSignal.dispatch(screen);
				
				_isSwitching = true;
				_isAutoStart = autoStart;
				_currentScreenClass = screenClass;
				_nextScreen = screen;
				
				if (fastTransition)
				{
					fastTransitionOnNext();
				}
				
				/* Only change screen alpha if we're actually using tweens! */
				if (_tweenDuration > 0)
				{
					_nextScreen.alpha = 0;
				}
				
				_screenContainer.addChild(_nextScreen);
				closeLastScreen();
			}
			else
			{
				Log.fatal("Tried to open screen with ID \"" + screenID
					+ "\" which is not of type Screen (" + screenClass + ").", this);
			}
		}
		
		
		/**
		 * Updates the currently opened screen.
		 */
		public function updateScreen():void
		{
			if (_currentScreen && !_isSwitching)
			{
				_currentScreen.update();
				verbose("Updated " + _currentScreen.toString());
			}
		}
		
		
		/**
		 * Closes the currently opened screen. This is normally not necessary unless
		 * you need a situation where no screens should be on the stage.
		 * 
		 * @param noTween If true, closes the screen quickly without using a tween.
		 */
		public function closeScreen(noTween:Boolean = false):void
		{
			if (!_currentScreen) return;
			_nextScreen = null;
			closeLastScreen(noTween);
		}
		
		
		/**
		 * If called the next opening screen will open with a fast tween transition.
		 */
		public function fastTransitionOnNext():void
		{
			_backupDuration = _tweenDuration;
			_backupOpenDelay = _screenOpenDelay;
			_backupCloseDelay = _screenCloseDelay;
			_tweenDuration = _fastDuration;
			_screenOpenDelay = _screenCloseDelay = 0;
		}
		
		
		/**
		 * Returns a list of all registered screens.
		 */
		public function dumpScreenList():String
		{
			var initialScreenID:String = _main.registry.settings.getString("initialScreenID");
			var t:TabularText = new TabularText(4, true, "  ", null, "  ", 100, ["ID", "CLASS",
				"CURRENT", "INITIAL"]);
			for (var id:String in _screenClasses)
			{
				var clazz:Class = _screenClasses[id];
				var current:String = _currentScreen is clazz ? "true" : "";
				var initial:String = id == initialScreenID ? "true" : "";
				t.add([id, clazz, current, initial]);
			}
			return toString() + "\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of ScreenManager.
		 * 
		 * @return A String Representation of ScreenManager.
		 */
		public function toString():String
		{
			return "ScreenManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the currently opened screen.
		 */
		public function get currentScreen():Screen
		{
			return _currentScreen;
		}
		
		
		/**
		 * The duration (in seconds) that the ScreenManager will use to tween in/out
		 * screens. If set to 0 the ScreenManager will completely ignore tweening.
		 * 
		 * @default 0.4
		 */
		public function get tweenDuration():Number
		{
			return _tweenDuration;
		}
		public function set tweenDuration(v:Number):void
		{
			if (v < 0) v = 0;
			_tweenDuration = _backupDuration = v;
		}
		
		
		/**
		 * The duration (in seconds) that the ScreenManager will use to tween in/out
		 * screens after calling the fastTransitionOnNext() method. If set to 0 the
		 * ScreenManager will completely ignore tweening.
		 * 
		 * @default 0.2
		 */
		public function get fastDuration():Number
		{
			return _fastDuration;
		}
		public function set fastDuration(v:Number):void
		{
			if (v < 0) v = 0;
			_fastDuration = v;
		}
		
		
		/**
		 * A delay (in seconds) that the screen manager waits before opening a screen.
		 * This can be used to make transitions less abrupt.
		 * 
		 * @default 0.2
		 */
		public function get screenOpenDelay():Number
		{
			return _screenOpenDelay;
		}
		public function set screenOpenDelay(v:Number):void
		{
			if (v < 0) v = 0;
			_screenOpenDelay = v;
		}
		
		
		/**
		 * A delay (in seconds) that the screen manager waits before closing an opened screen.
		 * This can be used to make transitions less abrupt.
		 * 
		 * @default 0.2
		 */
		public function get screenCloseDelay():Number
		{
			return _screenCloseDelay;
		}
		public function set screenCloseDelay(v:Number):void
		{
			if (v < 0) v = 0;
			_screenCloseDelay = v;
		}
		
		
		/**
		 * The unscaled screen width. This always reflects stage.stageWidth.
		 */
		public function get screenWidth():int
		{
			return _screenWidth;
		}
		
		
		/**
		 * The unscaled screen height. This always reflects stage.stageHeight.
		 */
		public function get screenHeight():int
		{
			return _screenHeight;
		}
		
		
		/**
		 * The horizontal center of the screen container. This value takes the
		 * screen scaling into account.
		 */
		public function get hCenter():int
		{
			return (_screenWidth / _screenScale) * 0.5;
		}
		
		
		/**
		 * The vertical center of the screen container. This value takes the
		 * screen scaling into account.
		 */
		public function get vCenter():int
		{
			return (_screenHeight / _screenScale) * 0.5;
		}
		
		
		/**
		 * Allows to set the scaling of the screen container. Changing this value affects
		 * the scaling of all screens. The minimum allowed value is 0.
		 * 
		 * @default 1.0
		 */
		public function get screenScale():Number
		{
			return _screenScale;
		}
		public function set screenScale(v:Number):void
		{
			if (v == _screenScale || v < 0) return;
			_screenScale = v;
			_screenContainer.scaleX = _screenContainer.scaleY = _screenScale;
		}
		
		
		/**
		 * The display object container that acts as a wrapper for any screens.
		 */
		public function get screenContainer():Sprite
		{
			return _screenContainer;
		}
		
		
		/**
		 * Allows to set a display object as a background that is used to underlay any
		 * screens that are being opened. This property can be used to set an image
		 * or any other display object as a backdrop which is shown behind screens.
		 */
		public function get background():DisplayObject
		{
			return _background;
		}
		public function set background(v:DisplayObject):void
		{
			if (v == _background) return;
			if (!v || _background)
			{
				_screenContainer.removeChild(_background);
				_background = null;
			}
			if (v)
			{
				_background = v;
				_background.alpha = 0;
				_screenContainer.addChild(_background);
				if (_screenContainer.getChildAt(0) != _background)
				{
					_screenContainer.swapChildren(_background, _screenContainer.getChildAt(0));
				}
			}
		}
		
		
		/**
		 * If a screen background is used it is normally tweened in and out whenever
		 * a screen is tweened in and out. Setting this property to false instead
		 * keeps the background unaffected by screen tweens.
		 * 
		 * <p>The proptery only affects tweening out of the screen. A background, if
		 * available, will always tween in, regardless whether tweenBackground is
		 * true or false.</p>
		 * 
		 * @default true
		 */
		public function get tweenBackground():Boolean
		{
			return _tweenBackground;
		}
		public function set tweenBackground(v:Boolean):void
		{
			_tweenBackground = v;
		}
		
		
		/**
		 * Allows to set a bitmap filter that applies to all screens managed by the screen
		 * manager.
		 */
		public function get filter():BitmapFilter
		{
			if (!_screenContainer.filters || _screenContainer.filters.length == 0) return null;
			return _screenContainer.filters[0];
		}
		public function set filter(v:BitmapFilter):void
		{
			if (!v) _screenContainer.filters = null;
			else _screenContainer.filters = [v];
		}
		
		
		/**
		 * A signal that can be listened to for notifications if the stage is resized.
		 */
		public function get stageResizeSignal():Signal
		{
			return _stageResizeSignal;
		}
		
		
		public function get mouseSignal():MouseSignal
		{
			if (!_mouseSignal)
			{
				_mouseSignal = new MouseSignal();
				_screenContainer.addEventListener(MouseEvent.CLICK, onScreenClick);
			}
			return _mouseSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onStageResize(e:Event):void
		{
			_screenWidth = _main.contextView.stage.stageWidth;
			_screenHeight = _main.contextView.stage.stageHeight;
			//TabularText.calculateLineWidth(_screenWidth, 7);
			_stageResizeSignal.dispatch();
		}
		
		
		private function onFullScreenToggle(e:FullScreenEvent):void
		{
			_stageResizeSignal.dispatch();
		}
		
		
		private function onScreenClick(e:MouseEvent):void
		{
			_mouseSignal.dispatch(MouseSignal.CLICK, null);
		}
		
		
		/**
		 * Invoked while a screen is loading.
		 * @private
		 */
		private function onScreenLoadProgress(progress:BulkProgress):void
		{
			if (!_loadProgressDisplay) return;
			_loadProgressDisplay.update(progress);
		}
		
		
		/**
		 * Invoked if a resource has loaded.
		 * @private
		 */
		private function onResourceLoaded(loadedResource:Resource):void
		{
			++_loadedResourceCount;
			if (!_loadProgressDisplay) return;
			_loadProgressDisplay.loadedCount = _loadedResourceCount;
		}
		
		
		/**
		 * Invoked if a resource failed loading.
		 * @private
		 */
		private function onScreenLoadError(failedResource:Resource):void
		{
			++_failedResourceCount;
			if (!_loadProgressDisplay) return;
			_loadProgressDisplay.failedCount = _failedResourceCount;
			
			/* If all resources failed loading, still call onScreenLoaded() or we
			 * would be stuck forever in the load display! */
			if (_loadProgressDisplay.allFailed)
			{
				onScreenLoaded();
			}
		}
		
		
		/**
		 * Invoked after a screen's resources have been loaded.
		 * @private
		 */
		private function onScreenLoaded():void
		{
			/* Prevent accidentally calling handler twice in case of load errors! */
			if (_isScreenLoaded) return;
			_isScreenLoaded = true;
			
			_currentScreen.loadProgressSignal.remove(onScreenLoadProgress);
			_currentScreen.resourceLoadedSignal.remove(onResourceLoaded);
			_currentScreen.loadErrorSignal.remove(onScreenLoadError);
			_currentScreen.screenCreatedSignal.addOnce(onScreenCreated);
			_currentScreen.createScreen();
		}
		
		
		/**
		 * Invoked after a screen has been created, i.e. after the screen's children have
		 * been created, registered and added to the screen.
		 * @private
		 */
		private function onScreenCreated():void
		{
			if (!_currentScreen)
			{
				/* this should not happen unless you quickly repeat app init in the CLI! */
				Log.warn("onScreenOpened: screen is null.", this);
				return;
			}
			
			screenCreatedSignal.dispatch(_currentScreen);
			
			/* Disable screen view objects while fading in. */
			_currentScreen.setInitialEnabledState(false);
			
			/* Screen is created and child objects have been created, time to lay out
			 * children and update any screen text. */
			_currentScreen.update();
			
			if (_loadProgressDisplay)
			{
				_loadProgressDisplay.update();
				if (_loadProgressDisplay.waitForUserInput)
				{
					_loadProgressDisplay.userInputSignal.addOnce(onLoadProgressDisplayUserInput);
				}
				else
				{
					onLoadProgressDisplayUserInput();
				}
			}
			else
			{
				showCurrentScreen();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onLoadProgressDisplayUserInput():void
		{
			_tweenVars.reset();
			_tweenVars.setProperty("alpha", 0.0);
			_tweenVars.onComplete = function():void
			{
				_screenContainer.removeChild(_loadProgressDisplay);
				_loadProgressDisplay.dispose();
				_loadProgressDisplay = null;
				showCurrentScreen();
			};
			
			Tween.to(_loadProgressDisplay, 0.4, _tweenVars);
		}
		
		
		private function onTweenInUpdate():void
		{
			if (!_background || _background.alpha == 1.0) return;
			_background.alpha = _currentScreen.alpha;
		}
		
		
		private function onTweenOutUpdate():void
		{
			if (!_background || !_tweenBackground || _background.alpha == 0.0) return;
			_background.alpha = _currentScreen.alpha;
		}
		
		
		private function onTweenInComplete():void
		{
			if (_background && _tweenBackground) _background.alpha = 1.0;
			
			_tweenDuration = _backupDuration;
			_screenOpenDelay = _backupOpenDelay;
			_screenCloseDelay = _backupCloseDelay;
			
			if (!_currentScreen)
			{
				/* this should not happen unless you quickly repeat app init in the CLI! */
				Log.warn("onTweenInComplete: screen is null", this);
				return;
			}
			
			verbose("Opened " + _currentScreen.toString());
			screenOpenedSignal.dispatch(_currentScreen);
			
			/* Everythings' done, screen is faded in! Let's grant user interaction
			 * (but only if autoEnable is allowed!). */
			if (_currentScreen.autoEnable)
			{
				_currentScreen.setInitialEnabledState(true);
			}
			
			/* If autoStart, now is the time to call start on the screen. */
			if (_isAutoStart)
			{
				_isAutoStart = false;
				_main.contextView.stage.focus = _currentScreen;
				_currentScreen.start();
			}
		}
		
		
		private function onTweenOutComplete():void
		{
			if (_background && _tweenBackground) _background.alpha = 0.0;
			_screenContainer.removeChild(_currentScreen);
			_currentScreen.screenUnloadedSignal.addOnce(onScreenUnloaded);
			_currentScreen.unloadScreen();
		}
		
		
		private function onScreenUnloaded(unloadedScreen:Screen):void
		{
			verbose("Closed " + _currentScreen.toString());
			_currentScreen = null;
			screenUnloadedSignal.dispatch(unloadedScreen);
			openNextScreen();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function closeLastScreen(noTween:Boolean = false):void
		{
			if (_currentScreen)
			{
				_currentScreen.setInitialEnabledState(false);
				screenCloseSignal.dispatch(_currentScreen);
				
				if (noTween)
				{
					onTweenOutComplete();
					return;
				}
				
				if (_tweenDuration > 0)
				{
					/* Tween out current screen. */
					_tweenVars.reset();
					_tweenVars.setProperty("alpha", 0.0);
					_tweenVars.onUpdate = onTweenOutUpdate;
					_tweenVars.onComplete = onTweenOutComplete;
					_tweenVars.delay = _screenCloseDelay;
					Tween.to(_currentScreen, _tweenDuration, _tweenVars);
				}
				else
				{
					setTimeout(onTweenOutComplete, _screenCloseDelay * 1000);
				}
			}
			else
			{
				openNextScreen();
			}
		}
		
		
		private function openNextScreen():void
		{
			if (!_nextScreen) return;
			setTimeout(function():void
			{
				_isScreenLoaded = false;
				_loadedResourceCount = 0;
				_failedResourceCount = 0;
				_currentScreen = _nextScreen as Screen;
				_currentScreen.focusRect = false;
				_currentScreen.screenLoadedSignal.addOnce(onScreenLoaded);
				
				verbose("Loading " + _currentScreen.toString() + " ("
					+ _currentScreen.resourceCount + " resources) ...");
				
				/* We only need the load progress display if we actually got resources
				 * and if the resources haven't been already loaded/failed before. */
				if (_currentScreen.resourceCount > 0 && !_currentScreen.resourcesAlreadyLoaded)
				{
					_loadProgressDisplay = _currentScreen.loadProgressDisplay;
				}
				
				if (_loadProgressDisplay)
				{
					_loadProgressDisplay.totalCount = _currentScreen.resourceCount;
					_loadProgressDisplay.alpha = 0;
					_screenContainer.addChild(_loadProgressDisplay);
					
					_tweenVars.reset();
					_tweenVars.setProperty("alpha", 1.0);
					Tween.to(_loadProgressDisplay, 0.4, _tweenVars);
					
					_currentScreen.loadProgressSignal.add(onScreenLoadProgress);
					_currentScreen.resourceLoadedSignal.add(onResourceLoaded);
					_currentScreen.loadErrorSignal.add(onScreenLoadError);
					_currentScreen.loadScreen();
				}
				else
				{
					_currentScreen.loadScreen();
				}
			}, _screenOpenDelay * 1000);
		}
		
		
		/**
		 * @private
		 */
		private function showCurrentScreen():void
		{
			_isSwitching = false;
			if (_tweenDuration > 0)
			{
				/* Tween in next screen. */
				_tweenVars.reset();
				_tweenVars.setProperty("alpha", 1.0);
				_tweenVars.onUpdate = onTweenInUpdate;
				_tweenVars.onComplete = onTweenInComplete;
				Tween.to(_currentScreen, _tweenDuration, _tweenVars);
			}
			else
			{
				onTweenInComplete();
			}
		}
		
		
		/**
		 * @private
		 */
		private function verbose(message:String):void
		{
			Log.verbose(message, this);
		}
	}
}
