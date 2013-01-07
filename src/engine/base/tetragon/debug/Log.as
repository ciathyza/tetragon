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
package tetragon.debug
{
	import tetragon.Main;
	import tetragon.data.Config;

	import com.hexagonstar.util.debug.LogLevel;

	import flash.display.Stage;
	
	
	/**
	 * Provides the logging mechanism for tetragon. This class is used anywhere in the
	 * project code to send logging information to tetragon's internal console as well
	 * as to any external loggers.
	 * 
	 * @see Console
	 * @see ExternalLogAdapter
	 */
	public final class Log
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static var verboseLoggingEnabled:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _main:Main;
		/** @private */
		private static var _buffer:Array;
		/** @private */
		private static var _console:Console;
		/** @private */
		private static var _externalLog:ExternalLogAdapter;
		/** @private */
		private static var _flashTrace:Boolean;
		/** @private */
		private static var _enabled:Boolean = true;
		/** @private */
		private static var _initial:Boolean = true;
		/** @private */
		private static var _filterLevel:int = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Puts the logger into it's initial state.
		 */
		public static function init():void 
		{
			_initial = true;
			_buffer = null;
			
			if (Main.instance.appInfo.isDebug)
			{
				_externalLog = new ExternalLogAdapter();
			}
		}
		
		
		/**
		 * Readies the logger. Needs to be called before the Logger can be used.
		 */
		public static function ready(main:Main):void
		{
			_main = main;
			_console = _main.console;
			
			if (_console)
			{
				_console.clear();
				_console.clearInput();
			}
			
			filterLevel = _main.registry.config.getNumber(Config.LOGGING_FILTER_LEVEL);
			enabled = _main.registry.config.getBoolean(Config.LOGGING_ENABLED);
			
			Log.monitor(_main.contextView.stage);
		}
		
		
		/**
		 * Receives any logging data from the logger in the hexagonLib.
		 */
		public static function logByLevel(level:int, data:*):void
		{
			if (level < LogLevel.TRACE) level = LogLevel.TRACE;
			else if (level > LogLevel.FATAL) level = LogLevel.FATAL;
			
			switch (level)
			{
				case LogLevel.TRACE:
					trace(data);
					break;
				case LogLevel.DEBUG:
					debug(data);
					break;
				case LogLevel.INFO:
					info(data);
					break;
				case LogLevel.NOTICE:
					notice(data);
					break;
				case LogLevel.WARN:
					warn(data);
					break;
				case LogLevel.ERROR:
					error(data);
					break;
				case LogLevel.FATAL:
					fatal(data);
			}
		}
		
		
		/**
		 * Tells any external logger to monitor the application.
		 * 
		 * @param stage Stage object required for monitoring.
		 */
		public static function monitor(stage:Stage):void
		{
			if (_externalLog) _externalLog.monitor(stage);
		}
		
		
		/**
		 * Sends trace data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function trace(data:*, caller:Object = null, inverse:Boolean = false):void
		{
			if (_filterLevel > LogLevel.TRACE) return;
			if (_externalLog) _externalLog.trace(data);
			if (_flashTrace) FlashTrace.log(data, LogLevel.TRACE, caller);
			send(data, LogLevel.TRACE, caller, inverse);
		}
		
		
		/**
		 * Sends debug data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function debug(data:*, caller:Object = null, inverse:Boolean = false):void
		{
			if (_filterLevel > LogLevel.DEBUG) return;
			if (_externalLog) _externalLog.debug(data);
			if (_flashTrace) FlashTrace.log(data, LogLevel.DEBUG, caller);
			send(data, LogLevel.DEBUG, caller, inverse);
		}
		
		
		/**
		 * Sends verbose debug data to the logger. This method is mainly used by
		 * the engine to provide additional debug info that can be toggled on/off
		 * via the engine.ini.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function verbose(data:*, caller:Object = null, inverse:Boolean = false):void
		{
			if (!verboseLoggingEnabled) return;
			if (_externalLog) _externalLog.debug(data);
			if (_flashTrace) FlashTrace.log(data, LogLevel.DEBUG, caller);
			send(data, LogLevel.DEBUG, caller, inverse);
		}
		
		
		/**
		 * Sends info data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function info(data:*, caller:Object = null, inverse:Boolean = false):void
		{
			if (_filterLevel > LogLevel.INFO) return;
			if (_externalLog) _externalLog.info(data);
			if (_flashTrace) FlashTrace.log(data, LogLevel.INFO, caller);
			send(data, LogLevel.INFO, caller, inverse);
		}
		
		
		/**
		 * Sends notice data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function notice(data:*, caller:Object = null, inverse:Boolean = false):void
		{
			if (_filterLevel > LogLevel.NOTICE) return;
			if (_externalLog) _externalLog.notice(data);
			if (_flashTrace) FlashTrace.log(data, LogLevel.INFO, caller);
			send(data, LogLevel.NOTICE, caller, inverse);
		}
		
		
		/**
		 * Sends warn data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function warn(data:*, caller:Object = null, inverse:Boolean = false):void
		{
			if (_filterLevel > LogLevel.WARN) return;
			if (_externalLog) _externalLog.warn(data);
			if (_flashTrace) FlashTrace.log(data, LogLevel.WARN, caller);
			send(data, LogLevel.WARN, caller, inverse);
		}
		
		
		/**
		 * Sends error data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function error(data:*, caller:Object = null, inverse:Boolean = false):void
		{
			if (_filterLevel > LogLevel.ERROR) return;
			if (_externalLog) _externalLog.error(data);
			if (_flashTrace) FlashTrace.log(data, LogLevel.ERROR, caller);
			send(data, LogLevel.ERROR, caller, inverse);
		}
		
		
		/**
		 * Sends fatal data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function fatal(data:*, caller:Object = null, inverse:Boolean = false):void
		{
			if (_filterLevel > LogLevel.FATAL) return;
			if (_externalLog) _externalLog.fatal(data);
			if (_flashTrace) FlashTrace.log(data, LogLevel.FATAL, caller);
			send(data, LogLevel.FATAL, caller, inverse);
		}
		
		
		/**
		 * Sends a delimiter line to the console.
		 * 
		 * @param length Length of the line, in characters.
		 * @param level The filter level.
		 * @param inverse If true the output will be logged with inverse text.
		 */
		public static function delimiter(length:int = 20, level:int = 2, inverse:Boolean = false):void
		{
			send(Console.makeLine(length), level, null, inverse);
		}
		
		
		/**
		 * Sends a linefeed to the logger.
		 */
		public static function linefeed():void
		{
			if (_externalLog) _externalLog.trace("");
			send("", LogLevel.INFO);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines wether the logger and any external loggers are enabled or not.
		 */
		public static function get enabled():Boolean
		{
			return _enabled;
		}
		public static function set enabled(v:Boolean):void
		{
			if (v) Log.info("Logging enabled with filter level " + _filterLevel + ".");
			else Log.info("Logging disabled.");
			_enabled = v;
			if (_externalLog) _externalLog.enabled = v;
		}
		
		
		/**
		 * Determines the filter level of the logger and any external loggers.
		 */
		public static function get filterLevel():int
		{
			return _filterLevel;
		}
		public static function set filterLevel(v:int):void
		{
			_filterLevel = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * @param data
		 * @param level
		 * @param caller
		 * @param inverse
		 */
		private static function send(data:*, level:int, caller:Object = null,
			inverse:Boolean = false):void
		{
			if (!_enabled) return;
			
			/* Use initial buffer for any ouptut that is logged before
			 * the Logger is initialized. */
			if (!_main)
			{
				if (!_buffer) _buffer = [];
				_buffer.push({data: data, level: level, caller: caller});
				return;
			}
			
			if (_initial) Log.flushBuffer();
			
			if (caller)
			{
				if (caller is String) data = caller + ": " + data;
				else if (caller["toString"]) data = caller["toString"]() + ": " + data;
			}
			
			if (_console) _console.log(data, level, inverse);
		}
		
		
		/**
		 * @private
		 * 
		 * Empties initial buffer.
		 */
		private static function flushBuffer():void
		{
			_initial = false;
			if (!_buffer) return;
			for (var i:uint = 0; i < _buffer.length; i++)
			{
				var o:Object = _buffer[i];
				send(o["data"], o["level"], o["caller"]);
			}
			_buffer = null;
		}
	}
}


/**
 * @private
 */
final class FlashTrace
{
	public static function log(data:*, level:int, caller:Object):void
	{
		var c:String = caller ? caller + ": " : "";
		switch (level)
		{
			case 0: trace(" [TRACE] " + c + data); break;
			case 1: trace(" [DEBUG] " + c + data); break;
			case 2: trace("  [INFO] " + c + data); break;
			case 3: trace("[NOTICE] " + c + data); break;
			case 4: trace("  [WARN] " + c + data); break;
			case 5: trace(" [ERROR] " + c + data); break;
			case 6: trace(" [FATAL] " + c + data); break;
		}
	}
}
