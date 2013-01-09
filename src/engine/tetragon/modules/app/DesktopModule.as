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
package tetragon.modules.app
{
	import tetragon.command.env.ShutdownApplicationCommand;
	import tetragon.data.Config;
	import tetragon.env.desktop.ScreenshotGrabber;
	import tetragon.env.desktop.WindowBoundsManager;
	import tetragon.file.writers.LogFileWriter;
	import tetragon.input.KeyMode;
	import tetragon.modules.IModule;
	import tetragon.modules.IModuleInfo;
	import tetragon.modules.Module;

	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.NativeWindowBoundsEvent;
	
	
	/**
	 * Persistent assist class for AIR desktop builds.
	 */
	public final class DesktopModule extends Module implements IModule
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _defaultFramerate:Number;
		/** @private */
		private var _screenshotGrabber:ScreenshotGrabber;
		/** @private */
		private var _logFileWriter:LogFileWriter;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init():void
		{
			if (main.registry.config.getBoolean(Config.SCREENSHOTS_ENABLED))
			{
				_screenshotGrabber = new ScreenshotGrabber(main.stage);
				main.keyInputManager.assignEngineKey("screenshot", _screenshotGrabber.saveScreenshot, KeyMode.UP);
			}
			
			if (main.console && main.registry.config.getBoolean(Config.LOGFILE_ENABLED))
			{
				_logFileWriter = new LogFileWriter();
				main.console.logSignal.add(onLog);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			/* We listen to CLOSING from both the stage and the UI. If the user closes the
			 * app through the taskbar, Event.CLOSING is emitted from the stage. Otherwise,
			 * it could be emitted from TitleBarConrols. */
			main.contextView.addEventListener(Event.CLOSING, onApplicationClosing);
			
			if (NativeWindow.isSupported)
			{
				stage.nativeWindow.addEventListener(Event.CLOSING, onApplicationClosing);
				stage.nativeWindow.addEventListener(Event.CLOSE, onApplicationClose);
				stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, onWindowBoundsChanged);
				stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onWindowBoundsChanged);
				stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			}
			
			/* Check if application should use framerate throttling while the app
			 * is unfocussed or minimized. */
			if (registry.config.getNumber(Config.ENV_BG_FRAMERATE) > -1)
			{
				_defaultFramerate = stage.frameRate;
				var na:NativeApplication = NativeApplication.nativeApplication;
				na.addEventListener(Event.DEACTIVATE, onDeactivate);
				na.addEventListener(Event.ACTIVATE, onActivate);
			}
		}
		
		
		override public function dispose():void
		{
			super.dispose();
			if (_logFileWriter) _logFileWriter.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public static function get defaultID():String
		{
			return "desktopModule";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get moduleInfo():IModuleInfo
		{
			return new DesktopModuleInfo();
		}
		
		
		/**
		 * A reference to the screenshot grabber, if it's available, otherwise null.
		 */
		public function get screenshotGrabber():ScreenshotGrabber
		{
			return _screenshotGrabber;
		}
		
		
		/**
		 * A reference to the logfile writer, if it's available, otherwise null.
		 */
		public function get logFileWriter():LogFileWriter
		{
			return _logFileWriter;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onApplicationClosing(e:Event):void
		{
			e.preventDefault();
			main.commandManager.execute(new ShutdownApplicationCommand());
		}
		
		
		private function onApplicationClose(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function onWindowBoundsChanged(e:NativeWindowBoundsEvent):void 
		{
			/* Store window bounds if window was moved or resized */
			// TODO Not good like this! The event is dispatched continously while dragging!
			//WindowBoundsManager.instance.storeWindowBounds();
		}
		
		
		private function onFullScreen(e:FullScreenEvent):void
		{
			if (!e.fullScreen)
			{
				WindowBoundsManager.instance.recallWindowBounds(main.baseWindow, "base");
				/* In case user hit ESC to exit fullscreen, set correct state! */
				// TODO To be changed! Fullscreen state should not be stored in app.ini
				// but in user settings file!
				//_main.config.useFullscreen = false;
				WindowBoundsManager.instance.storeWindowBounds(main.baseWindow, "base");
			}
		}
		
		
		private function onDeactivate(e:Event):void 
		{
			var f:Number = registry.config.getNumber(Config.ENV_BG_FRAMERATE);
			if (f < 0.01) f = 0.01;
			else if (f > 1000) f = 1000;
			stage.frameRate = f;
		}
		
		
		private function onActivate(e:Event):void 
		{
			stage.frameRate = _defaultFramerate;
		}
		
		
		private function onLog(text:String):void
		{
			_logFileWriter.append(text);
		}
	}
}
