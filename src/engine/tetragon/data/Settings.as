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
package tetragon.data
{
	import tetragon.util.string.TabularText;
	
	
	/**
	 * A class that acts as the map for the application's settings.
	 */
	public final class Settings implements IRegistryObject
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const FRAME_RATE:String				= "frameRate";
		public static const SCREEN_SCALE:String				= "screenScale";
		public static const INITIAL_SCREEN_ID:String		= "initialScreenID";
		public static const SCREEN_MANAGER_ENABLED:String	= "screenManagerEnabled";
		public static const USE_SCREEN_FADES:String			= "useScreenFades";
		public static const THEME_ID:String					= "themeID";
		
		public static const SPLASH_SCREEN_ID:String			= "splashScreenID";
		public static const SPLASH_BACKGROUND_COLORS:String	= "splashBackgroundColors";
		public static const SPLASH_LOGO_COLOR:String		= "splashLogoColor";
		public static const SPLASH_SCREEN_WAIT_TIME:String	= "splashScreenWaitTime";
		public static const SHOW_SPLASH_SCREEN:String		= "showSplashScreen";
		public static const ALLOW_SPLASH_SABORT:String		= "allowSplashAbort";
		
		public static const USER_DATA_DIR:String			= "userDataDir";
		public static const USER_SAVEGAMES_DIR:String		= "userSaveGamesDir";
		public static const USER_SCREENSHOTS_DIR:String		= "userScreenshotsDir";
		public static const USER_CONFIG_DIR:String			= "userConfigDir";
		public static const USER_LOGS_DIR:String			= "userLogsDir";
		public static const USER_MODS_DIR:String			= "userModsDir";
		public static const USER_RESOURCES_DIR:String		= "userResourcesDir";
		
		public static const USER_CONFIG_FILE:String			= "userConfigFile";
		public static const USER_KEYBINDINGS_FILE:String	= "userKeyBindingsFile";
		public static const USER_SETTINGS_FILE:String		= "userSettingsFile";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _map:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function init():void
		{
			_map = {};
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function clear():void
		{
			init();
		}
		
		
		/**
		 * Sets a settings key-value pair to the settings map. If a setting is already
		 * mapped with the given key it will be overwritten.
		 * 
		 * @param key
		 * @param value
		 */
		public function setProperty(key:String, value:Object):void
		{
			//Log.debug("Added settings key=" + key + ", value=" + value, this);
			_map[key] = value;
		}
		
		
		/**
		 * Gets a mapped settings property as untyped.
		 */
		public function getProperty(key:String):*
		{
			return _map[key];
		}
		
		
		/**
		 * Gets a mapped settings property as String.
		 */
		public function getString(key:String):String
		{
			return _map[key];
		}
		
		
		/**
		 * Gets a mapped settings property as Number.
		 */
		public function getNumber(key:String):Number
		{
			return _map[key];
		}
		
		
		/**
		 * Gets a mapped settings property as Boolean.
		 */
		public function getBoolean(key:String):Boolean
		{
			return _map[key];
		}
		
		
		/**
		 * Gets a mapped settings property as Array.
		 */
		public function getArray(key:String):Array
		{
			if (_map[key] && _map[key] is Array) return _map[key];
			return null;
		}
		
		
		/**
		 * Checks if a property is existing in the settings.
		 */
		public function hasProperty(key:String):Boolean
		{
			return _map.hasOwnProperty(key);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "Settings";
		}
		
		
		/**
		 * Returns a string dump of the settings list.
		 */
		public function dump():String
		{
			var t:TabularText = new TabularText(2, true, "  ", null, "  ", 0, ["KEY", "VALUE"]);
			for (var key:String in _map)
			{
				t.add([key, _map[key]]);
			}
			return toString() + "\n" + t;
		}
	}
}
