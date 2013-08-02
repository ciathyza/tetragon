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
	 * The application's global config model. Access this object via Registry!
	 */
	public final class Config implements IRegistryObject
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/* Logging settings */
		public static const LOGGING_ENABLED:String					= "loggingEnabled";
		public static const LOGFILE_ENABLED:String					= "logFileEnabled";
		public static const LOGGING_FILTER_LEVEL:String				= "loggingFilterLevel";
		public static const LOGGING_VERBOSE:String					= "loggingVerbose";
		
		/* Console settings */
		public static const CONSOLE_ENABLED:String					= "consoleEnabled";
		public static const CONSOLE_AUTO_OPEN_LEVEL:String			= "consoleAutoOpenLevel";
		public static const CONSOLE_TWEEN:String					= "consoleTween";
		public static const CONSOLE_MONOCHROME:String				= "consoleMonochrome";
		public static const CONSOLE_SIZE:String						= "consoleSize";
		public static const CONSOLE_TRANSPARENCY:String				= "consoleTransparency";
		public static const CONSOLE_FONT_SIZE:String				= "consoleFontSize";
		public static const CONSOLE_MAX_BUFFERSIZE:String			= "consoleMaxBufferSize";
		public static const CONSOLE_INPUT_BACKBUFFERSIZE:String		= "consoleInputBackBufferSize";
		public static const CONSOLE_COLORS:String					= "consoleColors";
		
		/* StatsMonitor settings */
		public static const STATSMONITOR_ENABLED:String				= "statsMonitorEnabled";
		public static const STATSMONITOR_AUTO_OPEN:String			= "statsMonitorAutoOpen";
		public static const STATSMONITOR_POLL_INTERVAL:String		= "statsMonitorPollInterval";
		public static const STATSMONITOR_POSITION:String			= "statsMonitorPosition";
		public static const STATSMONITOR_COLORS:String				= "statsMonitorColors";
		
		/* Screenshots settings */
		public static const SCREENSHOTS_ENABLED:String				= "screenshotsEnabled";
		public static const SCREENSHOTS_AS_JPG:String				= "screenshotsAsJPG";
		public static const SCREENSHOTS_JPG_QUALITY:String			= "screenshotsJPGQuality";
		
		/* Locale settings */
		public static const LOCALE_DEFAULT:String					= "localeDefault";
		public static const LOCALE_CURRENT:String					= "localeCurrent";
		
		/* File IO settings */
		public static const IO_USE_ABSOLUTE_FILEPATH:String			= "ioUseAbsoluteFilePath";
		public static const IO_BASE_PATH:String						= "ioBasePath";
		public static const IO_LOAD_CONNECTIONS:String				= "ioLoadConnections";
		public static const IO_LOAD_RETRIES:String					= "ioLoadRetries";
		public static const IO_PREVENT_FILE_CACHING:String			= "ioPreventFileCaching";
		public static const IO_ZIP_STREAM_BUFFERSIZE:String			= "ioZipStreamBufferSize";
		
		public static const FILENAME_ENGINECONFIG:String			= "filenameEngineConfig";
		public static const FILENAME_KEYBINDINGS:String				= "filenameKeyBindings";
		public static const FILENAME_RESOURCEINDEX:String			= "filenameResourceIndex";
		
		/* Application sub-folder settings */
		public static const RESOURCE_FOLDER:String					= "resourceFolder";
		public static const ICONS_FOLDER:String						= "iconsFolder";
		public static const EXTRA_FOLDER:String						= "extraFolder";
		
		/* User folder settings */
		public static const USER_DATA_FOLDER:String					= "userDataFolder";
		public static const USER_SAVEGAMES_FOLDER:String			= "userSaveGamesFolder";
		public static const USER_SCREENSHOTS_FOLDER:String			= "userScreenshotsFolder";
		public static const USER_CONFIG_FOLDER:String				= "userConfigFolder";
		public static const USER_LOGS_FOLDER:String					= "userLogsFolder";
		public static const USER_MODS_FOLDER:String					= "userModsFolder";
		public static const USER_RESOURCES_FOLDER:String			= "userResourcesFolder";
		
		/* Update settings */
		public static const UPDATE_ENABLED:String					= "updateEnabled";
		public static const UPDATE_URL:String						= "updateURL";
		public static const UPDATE_CHECK_AUTO:String				= "updateCheckAuto";
		public static const UPDATE_CHECK_INTERVAL:String			= "updateCheckInterval";
		public static const UPDATE_CHECK_TIMEOUT:String				= "updateCheckTimeOut";
		
		/* Environment-related settings */
		public static const ENV_START_FULLSCREEN:String				= "envStartFullscreen";
		public static const ENV_SCALE_FULLSCREEN:String				= "envScaleFullscreen";
		public static const ENV_BG_FRAMERATE:String					= "envBGFrameRate";
		
		/* Domain Locker settings */
		public static const ALLOWED_DOMAINS:String					= "allowedDomains";
		
		/* Render settings */
		public static const HARDWARE_RENDERING_ENABLED:String		= "hardwareRenderingEnabled";
		
		
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
		 * Adds a config key-value pair to the config map. If a config is already
		 * mapped with the given key it will be overwritten.
		 * 
		 * @param key
		 * @param value
		 */
		public function setProperty(key:String, value:Object):void
		{
			//Log.debug("Set config property key=" + key + ", value=" + value, this);
			_map[key] = value;
		}
		
		
		/**
		 * Gets a mapped config property untyped.
		 */
		public function getProperty(key:String):*
		{
			return _map[key];
		}
		
		
		/**
		 * Gets a mapped config property as String.
		 */
		public function getString(key:String):String
		{
			return _map[key];
		}
		
		
		/**
		 * Gets a mapped config property as Number.
		 */
		public function getNumber(key:String):Number
		{
			return _map[key];
		}
		
		
		/**
		 * Gets a mapped config property as Boolean.
		 */
		public function getBoolean(key:String):Boolean
		{
			return _map[key];
		}
		
		
		/**
		 * Gets a mapped config property as Array.
		 */
		public function getArray(key:String):Array
		{
			if (_map[key] && _map[key] is Array) return _map[key];
			return null;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "Config";
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
