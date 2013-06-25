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
package tetragon.env.desktop
{
	import tetragon.Main;
	import tetragon.core.exception.SingletonException;
	import tetragon.debug.Log;
	import tetragon.env.settings.LocalSettingsManager;

	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.geom.Rectangle;
	
	
	/**
	 * Stores and recalls position and size for a given window.
	 */
	public class WindowBoundsManager
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static const FULLSCREEN:String = "fullscreen";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _instance:WindowBoundsManager;
		/** @private */
		private static var _singletonLock:Boolean = false;
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _settingsManager:LocalSettingsManager;
		/** @private */
		private var _screenWidth:int = 0;
		/** @private */
		private var _screenHeight:int = 0;
		/** @private */
		private var _windowChromeExtraWidth:Number = NaN;
		/** @private */
		private var _windowChromeExtraHeight:Number = NaN;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function WindowBoundsManager()
		{
			if (!_singletonLock) throw new SingletonException(this);
			
			_main = Main.instance;
			_settingsManager = _main.localSettingsManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Saves the window position and size.
		 */
		public function storeWindowBounds(window:NativeWindow, windowID:String):void
		{
			if (!window || !windowID || windowID.length < 1) return;
			var fs:Boolean = _main.isFullscreen;
			var wb:WindowBounds = new WindowBounds();
			wb.x = window.bounds.topLeft.x;
			wb.y = window.bounds.topLeft.y;
			wb.width = window.bounds.bottomRight.x - wb.x - _windowChromeExtraWidth;
			wb.height = window.bounds.bottomRight.y - wb.y - _windowChromeExtraHeight;
			
			/* Only store size and position if we're not in fullscreen! */
			if (!fs) _settingsManager.put(windowID, wb);
			
			_settingsManager.put(FULLSCREEN, fs);
			_settingsManager.store();
			
			Log.debug("Window bounds stored for \"" + windowID + "\" (x=" + wb.x
				+ " y=" + wb.y + " width=" + wb.width + " height=" + wb.height + " fullscreen="
				+ fs + ").", this);
		}
		
		
		/**
		 * Recalls the window position and size.
		 */
		public function recallWindowBounds(window:NativeWindow, windowID:String):WindowBounds
		{
			if (!window || !windowID || windowID.length < 1) return null;
			var o:Object = _settingsManager.recall(windowID);
			var wb:WindowBounds = new WindowBounds();
			if (o)
			{
				wb.x = window.x = o["x"];
				wb.y = window.y = o["y"];
				wb.width = window.width = o["width"];
				wb.height = window.height = o["height"];
			}
			else
			{
				wb.x = window.x;
				wb.y = window.y;
				wb.width = window.width;
				wb.height = window.height;
			}
			_main.stage.stageWidth = wb.width;
			_main.stage.stageHeight = wb.height;
			_main.stage.fullScreenSourceRect = new Rectangle(0, 0, wb.width, wb.height);
			return wb;
		}
		
		
		/**
		 * Resets the application's base window to it's default size.
		 */
		public function resetBaseWindow():void
		{
			updateScreenResolution();
			
			var w:NativeWindow = nativeWindow;
			w.width = _main.appInfo.defaultWidth + _windowChromeExtraWidth;
			w.height = _main.appInfo.defaultHeight + _windowChromeExtraHeight;
			
			/* If no window position has been stored yet (e.g. on first launch)
			 * let's either set position to 0 (if screen is smaller than window)
			 * or center the window on the screen (if screen is larger than window). */
			if (_screenWidth <= w.width) w.x = 0;
			else w.x = Math.round((_screenWidth / 2) - (w.width / 2));
			if (_screenHeight <= w.height) w.y = 0;
			else w.y = Math.round((_screenHeight / 2) - (w.height / 2));
			
			Log.debug("Reset base window bounds to x=" + w.x + " y=" + w.y
				+ ", width=" + w.width + " height=" + w.height, this);
		}
		
		
		/**
		 * Calculate the extra width and height of the system window's chrome.
		 */
		public function calculateWindowChromeExtra():void
		{
			if (isNaN(_windowChromeExtraWidth) && isNaN(_windowChromeExtraHeight))
			{
				var sw:int = _main.stage.stageWidth;
				var sh:int = _main.stage.stageHeight;
				_windowChromeExtraWidth = _main.appInfo.defaultWidth - sw;
				_windowChromeExtraHeight = _main.appInfo.defaultHeight - sh;
				Log.debug("Calculated window chrome extra: width=" + _windowChromeExtraWidth
					+ ", height=" + _windowChromeExtraHeight, this);
				if (sw > _main.appInfo.defaultWidth || sh > _main.appInfo.defaultHeight)
				{
					Log.warn("Your stage bounds are larger than the default bounds!"
						+ " This might mess up the window chrome extra bounds calculation.", this);
				}
			}
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "WindowBoundsManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the singleton instance of WindowBoundsManager.
		 */
		public static function get instance():WindowBoundsManager
		{
			if (_instance == null)
			{
				_singletonLock = true;
				_instance = new WindowBoundsManager();
				_singletonLock = false;
			}
			return _instance;
		}
		
		
		/**
		 * Returns a reference to the nativeWindow.
		 */
		public function get nativeWindow():NativeWindow
		{
			return _main.stage.nativeWindow;
		}
		
		
		public function get fullscreen():Boolean
		{
			return Boolean(_settingsManager.recall(FULLSCREEN));
		}
		
		
		public function get windowChromeExtraWidth():int
		{
			return _windowChromeExtraWidth;
		}
		
		
		public function get windowChromeExtraHeight():int
		{
			return _windowChromeExtraHeight;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function updateScreenResolution():void
		{
			_screenWidth = Screen.mainScreen.bounds.width;
			_screenHeight = Screen.mainScreen.bounds.height;
		}
	}
}
