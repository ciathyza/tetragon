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
	import tetragon.data.Config;
	import tetragon.data.Settings;
	import tetragon.debug.Console;
	import tetragon.debug.Log;
	import tetragon.debug.StatsMonitor;
	import tetragon.file.resource.Resource;
	import tetragon.input.MouseSignal;
	import tetragon.view.loadprogress.LoadProgressDisplay;
	import tetragon.view.render2d.core.Render2D;
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.filters.FragmentFilter2D;
	import tetragon.view.render2d.textures.Texture2D;
	import tetragon.view.stage3d.Stage3DProxy;
	import tetragon.view.stage3d.Stage3DSignal;

	import com.hexagonstar.display.shape.RectangleShape;
	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.tween.Tween;
	import com.hexagonstar.tween.TweenVars;
	import com.hexagonstar.util.number.average;
	import com.hexagonstar.util.string.TabularText;
	import com.hexagonstar.util.time.CallLater;

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
		private var _render2D:Render2D;
		private var _nativeViewContainer:Sprite;
		private var _screenCover:RectangleShape;
		
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
		
		private var _screenScale:Number = 1.0;
		
		private static var _referenceWidth:int;
		private static var _referenceHeight:int;
		private static var _screenWidth:int;
		private static var _screenHeight:int;
		private static var _scaleFactorX:Number;
		private static var _scaleFactorY:Number;
		
		private var _loadProgressDisplay:LoadProgressDisplay;
		private var _loadedResourceCount:uint;
		private var _failedResourceCount:uint;
		
		private var _fadeColor:uint;
		
		private var _tweenVars:TweenVars;
		private var _screenOpenDelay:Number = 0.2;
		private var _screenCloseDelay:Number = 0.2;
		private var _tweenDuration:Number = 0.2;
		private var _fastDuration:Number = 0.1;
		private var _backupDuration:Number;
		private var _backupOpenDelay:Number;
		private var _backupCloseDelay:Number;
		
		private var _initialized:Boolean;
		private var _started:Boolean;
		private var _debugFacilitiesInitialized:Boolean;
		private var _switching:Boolean;
		private var _screenAutoStart:Boolean;
		private var _screenLoaded:Boolean;
		private var _hardwareRenderingEnabled:Boolean;
		
		private var _enableErrorChecking:Boolean;
		
		private static var _handleLostContext:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _screenManagerReadySignal:Signal;
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
			_referenceWidth = _main.appInfo.referenceWidth;
			_referenceHeight = _main.appInfo.referenceHeight;
			
			onStageResize(null);
			
			_screenClasses = {};
			_tweenVars = new TweenVars();
			
			_backupDuration = _tweenDuration;
			_backupOpenDelay = _screenOpenDelay;
			_backupCloseDelay = _screenCloseDelay;
			
			_screenInitSignal = new Signal();
			_screenCreatedSignal = new Signal();
			_screenOpenedSignal = new Signal();
			_screenCloseSignal = new Signal();
			_screenUnloadedSignal = new Signal();
			_stageResizeSignal = new Signal();
			
			_nativeViewContainer = new Sprite();
			_nativeViewContainer.focusRect = false;
			_contextView.addChild(_nativeViewContainer);
			
			_fadeColor = _stage.color;
			
			_main.stage.addEventListener(Event.RESIZE, onStageResize);
			_main.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenToggle);
			_main.resourceManager.localeSwitchCompleteSignal.add(onLocaleSwitchComplete);
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
				if (_screenCover && _tweenDuration > 0)
				{
					_nextScreen.visible = false;
					_screenCover.alpha = 1.0;
					_nativeViewContainer.addChild(_screenCover);
				}
				
				_nativeViewContainer.addChildAt(_nextScreen, 0);
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
		 * @private
		 */
		public function showOnScreenError(message:String):void
		{
			Log.fatal(message, this);
			var tf:TextField = new TextField();
			var format:TextFormat = new TextFormat("Verdana", 16, 0xFFFFFF);
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
			
			_main.contextView.addChild(tf);
			//if (_nativeViewContainer) _nativeViewContainer.addChild(tf);
			//else _contextView.addChild(tf);
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
			
			Log.verbose("Initializing screen manager ...", this);
			
			var useScreenFades:Boolean = true;
			if (_main.registry.settings.hasProperty(Settings.USE_SCREEN_FADES))
			{
				useScreenFades = _main.registry.settings.getBoolean(Settings.USE_SCREEN_FADES);
			}
			if (useScreenFades)
			{
				_screenCover = new RectangleShape(_screenWidth, _screenHeight, _fadeColor, 1.0);
			}
			
			_hardwareRenderingEnabled = _main.registry.config.getBoolean(Config.HARDWARE_RENDERING_ENABLED);
			
			if (_hardwareRenderingEnabled)
			{
				_stage3DProxy = _main.stage3DManager.getFreeStage3DProxy();
				if (_stage3DProxy)
				{
					_stage3DProxy.width = _screenWidth;
					_stage3DProxy.height = _screenHeight;
					_stage3DProxy.color = _stage.color;
					_stage3DProxy.stage3DSignal.add(onStage3DSignal);
					_stage3D = _stage3DProxy.stage3D;
					_stage3D.addEventListener(ErrorEvent.ERROR, onStage3DError, false, 10);
					_stage3DProxy.requestContext3D();
				}
			}
			else
			{
				verbose("Hardware rendering is disabled.");
				if (_screenManagerReadySignal) _screenManagerReadySignal.dispatch(null);
			}
		}
		
		
		/**
		 * Starts the screen manager after it has been initialized.
		 */
		public function start():void
		{
			if (!_initialized || _started) return;
			_started = true;
			Log.verbose("Starting screen manager ...", this);
			openInitialScreen();
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			if (_currentScreen) _currentScreen.dispose();
			
			_main.stage.removeEventListener(Event.RESIZE, onStageResize);
			_main.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenToggle);
			
			if (_stage3D)
			{
				_stage3D.removeEventListener(ErrorEvent.ERROR, onStage3DError);
			}
			if (_stage3DProxy)
			{
				_stage3DProxy.stage3DSignal.remove(onStage3DSignal);
				_stage3DProxy.dispose();
			}
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
				_statsMonitor.setGameLoop(_main.gameLoop);
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
		 * The reference width of the application. This is the width of the project's
		 * default build size and the size after which all graphicals assets are being
		 * designed.
		 */
		public static function get referenceWidth():int
		{
			return _referenceWidth;
		}


		/**
		 * The reference height of the application. This is the width of the project's
		 * default build size and the size after which all graphicals assets are being
		 * designed.
		 */
		public static function get referenceHeight():int
		{
			return _referenceHeight;
		}
		
		
		/**
		 * The unscaled screen width. This always reflects stage.stageWidth.
		 */
		public static function get screenWidth():int
		{
			return _screenWidth;
		}
		
		
		/**
		 * The unscaled screen height. This always reflects stage.stageHeight.
		 */
		public static function get screenHeight():int
		{
			return _screenHeight;
		}
		
		
		/**
		 * The scale factor used to scale the width of the application if the build's
		 * width is not the same as the reference width. This value changes if the stage
		 * is resized.
		 */
		public static function get scaleFactorX():Number
		{
			return _scaleFactorX;
		}


		/**
		 * The scale factor used to scale the height of the application if the build's
		 * height is not the same as the reference height. This value changes if the stage
		 * is resized.
		 */
		public static function get scaleFactorY():Number
		{
			return _scaleFactorY;
		}
		
		
		/**
		 * The average scale factor.
		 */
		public static function get scaleFactor():Number
		{
			return average(_scaleFactorX, _scaleFactorY);
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
		 * The color to/from that the screen cover is faded during the transition between
		 * screens. The default is the same as the Flash stage color.
		 */
		public function get fadeColor():uint
		{
			return _fadeColor;
		}
		public function set fadeColor(v:uint):void
		{
			_fadeColor = v;
			if (_screenCover) _screenCover.fillColor = _fadeColor;
		}
		
		
		/**
		 * The display object container that acts as the wrapper for native display views.
		 */
		public function get nativeViewContainer():Sprite
		{
			return _nativeViewContainer;
		}
		
		
		/**
		 * The stage3DProxy that has been prepared by the screen manager. When Tetragon
		 * is ready for use, a context3D has already been created.
		 */
		public function get stage3DProxy():Stage3DProxy
		{
			return _stage3DProxy;
		}
		
		
		public function get context3D():Context3D
		{
			return _context3D;
		}
		
		
		public function get render2D():Render2D
		{
			if (!_render2D) _render2D = Render2D.instance;
			return _render2D;
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
		public static function get handleLostContext():Boolean
		{
			return _handleLostContext;
		}
		public static function set handleLostContext(v:Boolean):void
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
		 * Dispatched when the ScreenManager is ready. If Hardware Rendering is enabled it is
		 * dispatched after the Context3D has been created and is ready for use. Otherwise it
		 * is dispatched right after the screen manager was initialized. The signal
		 * broadcasts a reference of the Context3D as it's parameter.
		 */
		public function get screenManagerReadySignal():Signal
		{
			if (!_screenManagerReadySignal) _screenManagerReadySignal = new Signal();
			return _screenManagerReadySignal;
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
		private function onStage3DSignal(type:String):void
		{
			Log.verbose("onStage3DSignal:: type=" + type, this);
			
			switch (type)
			{
				case Stage3DSignal.CONTEXT3D_CREATED:
					if (!_handleLostContext && _context3D)
					{
						showOnScreenError("Fatal Error: The application lost the device context!");
					}
					else
					{
						initializeContext3D();
					}
					break;
				case Stage3DSignal.CONTEXT3D_RECREATED:
					Log.debug("The Context3D has been recreated.", this);
					break;
				case Stage3DSignal.CONTEXT3D_DISPOSED:
					Log.debug("The Context3D has been disposed.", this);
					break;
			}
		}
		
		
		/**
		 * @private
		 */
		private function onStageResize(e:Event):void
		{
			_screenWidth = _stage.stageWidth;
			_screenHeight = _stage.stageHeight;
			_scaleFactorX = _screenWidth / _referenceWidth;
			_scaleFactorY = _screenHeight / _referenceHeight;
			
			Log.verbose("onStageResize:: width=" + _screenWidth + " height=" + _screenHeight, this);
			
			if (_screenCover)
			{
				_screenCover.width = _screenWidth;
				_screenCover.height = _screenHeight;
			}
			
			// TODO Add support for scaling Stage3D correctly when toggling to fullscreen mode!
			if (_stage3DProxy)
			{
				_stage3DProxy.resize(_screenWidth, _screenHeight);
			}
			
			if (_stageResizeSignal) _stageResizeSignal.dispatch();
		}
		
		
		/**
		 * @private
		 */
		private function onFullScreenToggle(e:FullScreenEvent):void
		{
			onStageResize(null);
		}
		
		
		/**
		 * @private
		 */
		private function onLocaleSwitchComplete(locale:String):void
		{
			updateScreen();
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
		private function onScreenTweenInUpdate():void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onScreenTweenInComplete():void
		{
			_tweenDuration = _backupDuration;
			_screenOpenDelay = _backupOpenDelay;
			_screenCloseDelay = _backupCloseDelay;
			
			if (!_currentScreen)
			{
				/* this should not happen unless you quickly repeat app init in the CLI! */
				Log.warn("onScreenTweenInComplete: screen is null", this);
				return;
			}
			
			/* Remove screen cover from display list. */
			if (_screenCover && _nativeViewContainer.contains(_screenCover))
			{
				_nativeViewContainer.removeChild(_screenCover);
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
			if (_render2D) _render2D.purge();
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
			if (!progress) return;
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
				CallLater.add(showCurrentScreen);
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
				CallLater.add(showCurrentScreen);
			};
			
			Tween.to(_loadProgressDisplay, 0.4, _tweenVars);
		}
		
		
		/**
		 * @private
		 */
		private function onScreenUnloaded(unloadedScreen:Screen):void
		{
			verbose("Unloaded " + _currentScreen.toString());
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
			if (!_stage3D) return;
			
			_context3D = _stage3D.context3D;
			_context3D.enableErrorChecking = _enableErrorChecking;
			
			/* Set shortcuts to context in Render2D classes. */
			DisplayObject2D.context3D =
			RenderSupport2D.context3D =
			FragmentFilter2D.context3D =
			Texture2D.context3D = _context3D;
			
			verbose("Context3D initialized. Display Driver: " + _context3D.driverInfo);
			if (_screenManagerReadySignal) _screenManagerReadySignal.dispatch(_context3D);
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
				
				if (_screenCover && _tweenDuration > 0.0)
				{
					_screenCover.alpha = 0.0;
					/* Tween out current screen. */
					_tweenVars.reset();
					_tweenVars.setProperty("alpha", 1.0);
					_tweenVars.onUpdate = onTweenOutUpdate;
					_tweenVars.onComplete = onTweenOutComplete;
					_tweenVars.delay = _screenCloseDelay;
					Tween.to(_screenCover, _tweenDuration, _tweenVars);
				}
				else
				{
					var timeDelay:Number = _screenCloseDelay * 1000;
					if (isNaN(timeDelay))
					{
						Log.warn("closePreviousScreen:: Calculated timeDelay is invalid!", this);
						timeDelay = 300;
					}
					setTimeout(onTweenOutComplete, timeDelay);
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
			
			var timeDelay:Number = _screenOpenDelay * 1000;
			if (isNaN(timeDelay))
			{
				Log.warn("openNextScreen:: Calculated timeDelay is invalid!", this);
				timeDelay = 300;
			}
			
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
			}, timeDelay);
		}
		
		
		/**
		 * @private
		 */
		private function showCurrentScreen():void
		{
			_switching = false;
			if (_screenCover && _tweenDuration > 0.0)
			{
				/* Tween in next screen. */
				_tweenVars.reset();
				_tweenVars.setProperty("alpha", 0.0);
				_tweenVars.onUpdate = onScreenTweenInUpdate;
				_tweenVars.onComplete = onScreenTweenInComplete;
				_currentScreen.visible = true;
				Tween.to(_screenCover, _tweenDuration, _tweenVars);
			}
			else
			{
				onScreenTweenInComplete();
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
		private function verbose(message:String):void
		{
			Log.verbose(message, this);
		}
	}
}
