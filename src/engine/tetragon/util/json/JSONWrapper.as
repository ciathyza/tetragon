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
package tetragon.util.json
{
	import tetragon.BuildType;
	import tetragon.Main;
	import tetragon.debug.Log;
	import tetragon.util.env.getRuntimeVersion;
	
	
	/**
	 * A common provider for the JSON API that uses the lecacy JSON API for Flash Player 10
	 * builds and the new native JSON API for AIR builds and Flash Player 11 builds.
	 */
	public final class JSONWrapper
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _initialized:Boolean;
		/** @private */
		private static var _nativeAPIAvailable:Boolean;
		/** @private */
		private static var _enforceLegacy:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Accepts a JSON-formatted String and returns an Actionscript Object that represents
		 * that value. JSON objects, arrays, strings, numbers, booleans, and null map to
		 * corresponding Actionscript values.
		 * 
		 * @param text The JSON string to be parsed.
		 * @param reviver (Optional) A function that transforms each key/value pair that is parsed.
		 *        This option is available in AIR builds and for Flash Player 11+!
		 */
		public static function parse(text:String, reviver:Function = null):*
		{
			if (!_initialized) init();
			
			if (_nativeAPIAvailable)
			{
				var obj:*;
				try
				{
					obj = JSON.parse(text, reviver);
				}
				catch (err:Error)
				{
					Log.warn("JSONWrapper: Could not parse JSON data with native JSON API! Falling back on legacy JSON API. (Error was: " + err.message + ")");
					obj = null;
				}
				if (obj) return obj;
			}
			
			try
			{
				obj = LegacyJSON.decode(text);
			}
			catch (err2:Error)
			{
				Log.error("JSONWrapper: Could not parse JSON data with legacy JSON API! (Error was: " + err2.message + ")");
			}
			
			if (obj != null) return obj;
			return null;
		}
		
		
		/**
		 * Returns a String, in JSON format, that represents an Actionscript value. The
		 * stringify method can take three parameters.
		 * 
		 * @param value The ActionScript value to be converted into a JSON string.
		 * @param replacer (Optional) A function or an array that transforms or filters
		 *        key/value pairs in the stringify output.
		 *        This option is available in AIR builds and for Flash Player 11+!
		 * @param space (Optional) A string or number that controls added white space in the
		 *        returned String.
		 *        This option is available in AIR builds and for Flash Player 11+!
		 */
		public static function stringify(value:Object, replacer:* = null, space:* = null):String
		{
			if (!_initialized) init();
			
			if (_nativeAPIAvailable)
			{
				var obj:String;
				try
				{
					obj = JSON.stringify(value, replacer, space);
				}
				catch (err:Error)
				{
					Log.warn("JSONWrapper: Could not stringify JSON data with native JSON API! Falling back on legacy JSON API. (Error was: " + err.message + ")");
					obj = null;
				}
				if (obj) return obj;
			}
			
			return LegacyJSON.encode(value);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		static public function get nativeAPIAvailable():Boolean
		{
			return _nativeAPIAvailable;
		}
		
		
		/**
		 * If true enforces the use of Legacy JSON En/Decoder.
		 */
		public static function get enforceLegacy():Boolean
		{
			return _enforceLegacy;
		}
		public static function set enforceLegacy(v:Boolean):void
		{
			_enforceLegacy = v;
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private static function init():void
		{
			if (_enforceLegacy)
			{
				_nativeAPIAvailable = false;
				_initialized = true;
				return;
			}
			
			/* AIR 3.0 and Flash Player v11+ support native JSON API. */
			if (Main.instance.appInfo.buildType != BuildType.WEB
				|| getRuntimeVersion().major >= 11)
			{
				_nativeAPIAvailable = true;
			}
			else
			{
				_nativeAPIAvailable = false;
			}
			_initialized = true;
		}
	}
}
