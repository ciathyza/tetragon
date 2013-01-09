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
package tetragon.env.settings
{
	import com.hexagonstar.util.string.TabularText;
	
	
	/**
	 * A data storage object for use with the LocalSettingsManager in that key-value
	 * pairs are stored that are meant to be stored persistenly to harddisk.
	 * 
	 * @see LocalSettingsManager
	 */
	public class LocalSettings
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _data:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new LocalSettings instance.
		 */
		public function LocalSettings()
		{
			_data = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Stores the specified value in the local settings object mapped under
		 * the specified key.
		 * 
		 * @example
		 * <pre>
		 *	var ls:LocalSettings = new LocalSettings();
		 *	ls.put("windowPosX", 200);
		 *	ls.put("windowPosY", 150);
		 *	ls.put("dataPath", "c:/user/documents/test/");
		 * </pre>
		 * 
		 * @param key The key under which to store the value.
		 * @param value The value to store.
		 */
		public function put(key:String, value:*):void
		{
			_data[key] = value;
		}
		
		
		/**
		 * Returns the settings value that is mapped with the specified key or
		 * null if the key was not found in the settings.
		 * 
		 * @param key The key under that the value is stored.
		 * @return The settings value or undefined.
		 */
		public function getValue(key:String):*
		{
			if (_data[key]) return _data[key];
			return null;
		}
		
		
		/**
		 * Returns a string dump of all stored key-value pairs.
		 */
		public function dump():String
		{
			var t:TabularText = new TabularText(2, true, "  ", null, "  ", 100, ["KEY", "VALUE"]);
			for (var s:String in _data)
			{
				var val:* = _data[s];
				if (val is String || val is Number || val is int || val is uint || val is Boolean)
				{
					t.add([s, val]);
				}
				else
				{
					for (var n:String in val)
					{
						t.add([s + "." + n, val[n]]);
					}
				}
			}
			return toString() + "\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[LocalSettings]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The data object in that setting key-value pairs are stored. Normally you don't
		 * need to use this property. It is used internally by the LocalSettingsManager.
		 * 
		 * @private
		 */
		internal function get data():Object
		{
			return _data;
		}
	}
}
