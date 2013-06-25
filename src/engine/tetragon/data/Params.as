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
	 * A data object that contains parameters which are being fetched from parameters
	 * from the HTML/PHP file that embeds the SWF file. Only used for web-based builds.
	 */
	public final class Params
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const SKIP_PRELOADER:String			= "skipPreloader";
		public static const IGNORE_INI_FILE:String			= "ignoreIniFile";
		public static const IGNORE_KEYBINDINGS_FILE:String	= "ignoreKeyBindingsFile";
		public static const IGNORE_LOCALE_FILE:String		= "ignoreLocaleFile";
		public static const USE_ABSOLUTE_FILE_PATH:String	= "useAbsoluteFilePath";
		public static const LOGGING_VERBOSE:String			= "loggingVerbose";
		public static const BASE_PATH:String				= "basePath";
		public static const LOCALE:String					= "locale";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _map:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Params()
		{
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the model data.
		 */
		public function init():void
		{
			_map = {};
			
			/* Map default param values. */
			_map[SKIP_PRELOADER] = false;
			_map[IGNORE_INI_FILE] = false;
			_map[IGNORE_KEYBINDINGS_FILE] = false;
			_map[IGNORE_LOCALE_FILE] = false;
			_map[USE_ABSOLUTE_FILE_PATH] = false;
			_map[LOGGING_VERBOSE] = false;
			_map[BASE_PATH] = null;
			_map[LOCALE] = null;
		}
		
		
		/**
		 * Used to retrieve a specific param value.
		 * 
		 * @param id
		 * @return Param value.
		 */
		public function getParam(id:String):*
		{
			return _map[id];
		}
		
		
		/**
		 * Can be used to set a specific param value.
		 * 
		 * @param key
		 * @param value
		 */
		public function setParam(key:String, value:*):void
		{
			_map[key] = value;
		}
		
		
		/**
		 * Parses a params object.
		 * 
		 * @param params An object of params.
		 */
		public function parse(params:Object):void
		{
			for (var id:String in params)
			{
				var p:* = params[id];
				/* Special treatment for Booleans that are seen as Strings. */
				if (p is String)
				{
					var s:String = (p as String).toLowerCase();
					if (s == "false") _map[id] = false;
					else if (s == "true") _map[id] = true;
					else _map[id] = p;
				}
				else
				{
					_map[id] = p;
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
			return "Params";
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
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A map with the raw, Flash vars.
		 */
		public function get map():Object
		{
			return _map;
		}
	}
}
