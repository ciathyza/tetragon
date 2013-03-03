/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package tetragon.view
{
	import tetragon.Main;
	import tetragon.data.Settings;
	import tetragon.debug.Console;
	import tetragon.debug.Log;
	import tetragon.debug.StatsMonitor;
	import tetragon.file.resource.Resource;
	import tetragon.input.MouseSignal;
	import tetragon.view.loadprogress.LoadProgressDisplay;
	import tetragon.view.stage3d.Stage3DEvent;
	import tetragon.view.stage3d.Stage3DProxy;

	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.tween.Tween;
	import com.hexagonstar.tween.TweenVars;
	import com.hexagonstar.util.string.TabularText;

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	
	
	/**
	 * Manages the creation, opening and closing as well as updating of screens.
	 *
	 * @author Hexagon
	 */
	public class ScreenManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _main:Main;
		private var _stage:Stage;
		private var _contextView:DisplayObjectContainer;
		private var _nativeViewContainer:Sprite;
		
		private var _utilityContainer:Sprite;
		private var _console:Console;
		private var _statsMonitor:StatsMonitor;
		
		private var _stage3DProxy:Stage3DProxy;
		private var _stage3D:Stage3D;
		private var _context3D:Context3D;
		
		private var _screenClasses:Object;
		private var _currentScreenClass:Class;
		private var _currentScreen:Screen;
		private var _nextScreen:Screen;
		
		private var _screenWidth:int;
		private var _screenHeight:int;
		private var _screenScale:Number = 1.0;
		
		private var _loadProgressDisplay:LoadProgressDisplay;
		private var _loadedResourceCount:uint;
		private var _failedResourceCount:uint;
		
		private var _tweenVars:TweenVars;
		private var _screenOpenDelay:Number = 0.2;
		private var _screenCloseDelay:Number = 0.2;
		private var _tweenDuration:Number = 0.4;
		private var _fastDuration:Number = 0.2;
		private var _backupDuration:Number;
		private var _backupOpenDelay:Number;
		private var _backupCloseDelay:Number;
		
		private var _initialized:Boolean;
		private var _debugFacilitiesInitialized:Boolean;
		private var _switching:Boolean;
		private var _screenAutoStart:Boolean;
		private var _screenLoaded:Boolean;
		
		private var _enableErrorChecking:Boolean;
		private var _handleLostContext:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _context3DCreatedSignal:Signal;
		/** @private */
		private var _screenInitSignal:Signal;
		/** @private */
		private var _screenCreatedSignal:Signal;
		/** @private */
		private var _screenOpenedSignal:Signal;
		/** @private */
		private var _screenCloseSignal:Signal;
		/** @private */
		private var _screenUnloadedSignal:Signal;
		/** @private */
		private var _stageResizeSignal:Signal;
		/** @private */
		private var _mouseSignal:MouseSignal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ScreenManager()
		{
			_main = Main.instance;
			_stage = _main.stage;
			_contextView = _main.contextView;
			_stage3DProxy = _main.stage3DManager.getFreeStage3DProxy();
			_stage3D = _stage3DProxy.stage3D;
			
			_screenClasses = {};
			_tweenVars = new TweenVars();
			
			_screenInitSignal = new Signal();
			_screenCreatedSignal = new Signal();
			_screenOpenedSignal = new Signal();
			_screenCloseSignal = new Signal();
			_screenUnloadedSignal = new Signal();
			_stageResizeSignal = new Signal();
			
			_nativeViewContainer = new Sprite();
			_nativeViewContainer.focusRect = false;
			_contextView.addChild(_nativeViewContainer);
			
			_stage3D.addEventListener(ErrorEvent.ERROR, onStage3DError, false, 10);
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated, false, 10);
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_RECREATED, onContextRecreated);
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_DISPOSED, onContextDisposed);
			
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
			_screenAutoStart = false;
			var screenClass:Class = _screenClasses[screenID];
			
			if (screenClass == null)
			{
				showOnScreenError("Fatal Error: Could not open screen with ID \"" + screenID
					+ "\" because no screen class with this ID has been registered.");
				return;
			}
			
			/* If the specified screen is already open, only update it! */
			if (_currentScreenClass == screenClass)
			{
				updateScreen();
				return;
			}
			
			var s:* = new screenClass();
			if (s is Screen)
			{
				verbose("Initializing screen \"" + screenID + "\" ...");
				var screen:Screen = s as Screen;
				screen.id = screenID;
				_screenInitSignal.dispatch(screen);
				
				_switching = true;
				_screenAutoStart = autoStart;
				_currentScreenClass = screenClass;
				_nextScreen = screen;
				
				if (fastTransition)
				{
					fastTransitionOnNext();
				}
				
				/* Only change screen alpha if we're actually using tweens! */
				if (_tweenDuration > 0)
				{
					//_nextScreen.alpha = 0;
				}
				
				_nativeViewContainer.addChild(_nextScreen);
				closePreviousScreen();
			}
			else
			{
				showOnScreenError("Fatal Error: Tried to open screen with ID \"" + screenID
					+ "\" which is not of type Screen.");
			}
		}
		
		
		/**
		 * Updates the currently opened screen.
		 */
		public function updateScreen():void
		{
			if (_currentScreen && !_switching)
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
			closePreviousScreen(noTween);
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
		 * Initializes the screen manager by requesting a Stage3D context and readying other
		 * required facilities for managing screens. Called automatically by the engine!
		 * 
		 * @private
		 */
		public function init():void
		{
			if (_initialized) return;
			_initialized = true;
			_stage3DProxy.requestContext3D();
		}
		
		
		/**
		 * @private
		 */
		public function createDebugFacilities(createConsole:Boolean, createStats:Boolean):void
		{
			/* Allow this method to be called only once by the setup phase! Additional
			 * calls to this method should have no effect! */
			if (_debugFacilitiesInitialized) return;
			_debugFacilitiesInitialized = true;
			
			if (!_console && createConsole)
			{
				if (!_utilityContainer)
				{
					_utilityContainer = new Sprite();
					_contextView.addChild(_utilityContainer);
				}
				_console = new Console(_utilityContainer);
				_console.init();
			}
			
			if (!_statsMonitor && createStats)
			{
				if (!_utilityContainer)
				{
					_utilityContainer = new Sprite();
					_contextView.addChild(_utilityContainer);
				}
				_statsMonitor = new StatsMonitor(_utilityContainer);
			}
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
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the currently opened screen.
		 */
		public function get currentScreen():Screen
		{
			return _currentScreen;
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
			_nativeViewContainer.scaleX = _nativeViewContainer.scaleY = _screenScale;
		}
		
		
		/**
		 * The display object container that acts as the wrapper for native display views.
		 */
		public function get nativeViewContainer():Sprite
		{
			return _nativeViewContainer;
		}
		
		
		/**
		 * Indicates if the app should automatically recover from a lost device context. On
		 * some systems, an upcoming screensaver or entering sleep mode may invalidate the
		 * render context. This setting indicates if the app should recover from such
		 * incidents. Beware that this has a huge impact on memory consumption! It is
		 * recommended to enable this setting on Android and Windows, but to deactivate it on
		 * iOS and Mac OS X.
		 * 
		 * @default false
		 */
		public function get handleLostContext():Boolean
		{
			return _handleLostContext;
		}
		public function set handleLostContext(v:Boolean):void
		{
			_handleLostContext = v;
		}
		
		
		/**
		 * Indicates if Stage3D render methods will report errors. Activate only when needed,
		 * as this has a negative impact on performance.
		 * 
		 * @default false
		 */
		public function get enableErrorChecking():Boolean
		{
			return _enableErrorChecking;
		}
		public function set enableErrorChecking(v:Boolean):void
		{
			_enableErrorChecking = v;
			if (_context3D) _context3D.enableErrorChecking = v;
		}
		
		
		/**
		 * A reference to the console.
		 */
		public function get console():Console
		{
			return _console;
		}


		/**
		 * A reference to the stats monitor.
		 */
		public function get statsMonitor():StatsMonitor
		{
			return _statsMonitor;
		}
		
		
		/**
		 * Dispatched when the Context3D has been created and is ready for use. The signal
		 * broadcasts a reference of the Context3D as it's parameter.
		 */
		public function get context3DCreatedSignal():Signal
		{
			if (!_context3DCreatedSignal) _context3DCreatedSignal = new Signal();
			return _context3DCreatedSignal;
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
				_nativeViewContainer.addEventListener(MouseEvent.CLICK, onScreenClick);
			}
			return _mouseSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onStage3DError(e:ErrorEvent):void
		{
			if (e.errorID == 3702)
			{
				showOnScreenError("Stage3D Error: This application is not correctly embedded"
					+ " (wrong wmode value).");
			}
			else
			{
				showOnScreenError("Stage3D Error: " + e.text);
			}
		}
		
		
		/**
		 * @private
		 */
		private function onContextCreated(e:Stage3DEvent):void
		{
			if (!_handleLostContext && _context3D)
			{
				e.stopImmediatePropagation();
				showOnScreenError("Fatal Error: The application lost the device context!");
			}
			else
			{
				initializeContext3D();
				openInitialScreen();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onContextRecreated(e:Stage3DEvent):void
		{
			Log.debug("The Context3D has been recreated.", this);
		}
		
		
		/**
		 * @private
		 */
		private function onContextDisposed(e:Stage3DEvent):void
		{
			Log.debug("The Context3D has been disposed.", this);
		}
		
		
		/**
		 * @private
		 */
		private function onStageResize(e:Event):void
		{
			_screenWidth = _main.contextView.stage.stageWidth;
			_screenHeight = _main.contextView.stage.stageHeight;
			_stageResizeSignal.dispatch();
		}
		
		
		/**
		 * @private
		 */
		private function onFullScreenToggle(e:FullScreenEvent):void
		{
			_stageResizeSignal.dispatch();
		}
		
		
		/**
		 * @private
		 */
		private function onScreenClick(e:MouseEvent):void
		{
			if (_mouseSignal) _mouseSignal.dispatch(MouseSignal.CLICK, null);
		}
		
		
		/**
		 * @private
		 */
		private function onTweenInUpdate():void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onTweenInComplete():void
		{
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
			_screenOpenedSignal.dispatch(_currentScreen);
			
			/* Everythings' done, screen is faded in! Let's grant user interaction
			 * (but only if autoEnable is allowed!). */
			if (_currentScreen.autoEnable)
			{
				_currentScreen.setInitialEnabledState(true);
			}
			
			_stage.focus = _nativeViewContainer;
			
			/* If autoStart, now is the time to call start on the screen. */
			if (_screenAutoStart)
			{
				_screenAutoStart = false;
				_currentScreen.start();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onTweenOutUpdate():void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onTweenOutComplete():void
		{
			_nativeViewContainer.removeChild(_currentScreen);
			_currentScreen.screenUnloadedSignal.addOnce(onScreenUnloaded);
			_currentScreen.unloadScreen();
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
			if (_screenLoaded) return;
			_screenLoaded = true;
			
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
			
			_screenCreatedSignal.dispatch(_currentScreen);
			
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
				_nativeViewContainer.removeChild(_loadProgressDisplay);
				_loadProgressDisplay.dispose();
				_loadProgressDisplay = null;
				showCurrentScreen();
			};
			
			Tween.to(_loadProgressDisplay, 0.4, _tweenVars);
		}
		
		
		/**
		 * @private
		 */
		private function onScreenUnloaded(unloadedScreen:Screen):void
		{
			verbose("Closed " + _currentScreen.toString());
			_currentScreen = null;
			_screenUnloadedSignal.dispatch(unloadedScreen);
			openNextScreen();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function initializeContext3D():void
		{
			_context3D = _stage3D.context3D;
			_context3D.enableErrorChecking = _enableErrorChecking;
			verbose("Context3D initialized. Display Driver: " + _context3D.driverInfo);
			if (_context3DCreatedSignal) _context3DCreatedSignal.dispatch(_context3D);
		}
		
		
		/**
		 * @private
		 */
		private function openInitialScreen():void
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
				showOnScreenError("Fatal Error: Cannot open initial screen because no initial"
					+ " screen ID has been defined!");
			}
		}
		
		
		/**
		 * @private
		 */
		private function closePreviousScreen(noTween:Boolean = false):void
		{
			if (_currentScreen)
			{
				_currentScreen.setInitialEnabledState(false);
				_screenCloseSignal.dispatch(_currentScreen);
				
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
		
		
		/**
		 * @private
		 */
		private function openNextScreen():void
		{
			if (!_nextScreen) return;
			setTimeout(function():void
			{
				_screenLoaded = false;
				_loadedResourceCount = 0;
				_failedResourceCount = 0;
				_currentScreen = _nextScreen as Screen;
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
					_loadProgressDisplay.alpha = 0.0;
					_nativeViewContainer.addChild(_loadProgressDisplay);
					
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
			_switching = false;
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
		 * Removes all child views from the view container that are part of the
		 * specified screen.
		 * 
		 * @private
		 */
		//private function removeScreenChildren(screen:Screen):void
		//{
		//}
		
		
		/**
		 * @private
		 */
		private function showOnScreenError(message:String):void
		{
			Log.fatal(message, this);
			var tf:TextField = new TextField();
			var format:TextFormat = new TextFormat("Verdana", 14, 0xFFFFFF);
			format.align = TextFormatAlign.CENTER;
			tf.defaultTextFormat = format;
			tf.wordWrap = true;
			tf.width = _stage.stageWidth * 0.75;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.text = message;
			tf.x = int((_stage.stageWidth - tf.width) * 0.5);
			tf.y = int((_stage.stageHeight - tf.height) * 0.5);
			tf.background = true;
			tf.backgroundColor = 0x440000;
			if (_nativeViewContainer) _nativeViewContainer.addChild(tf);
			else _contextView.addChild(tf);
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
