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
package tetragon.file.resource
{
	import tetragon.util.string.TabularText;

	
	/**
	 * A Hashmap that stores strings.
	 */
	public final class StringIndex
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _strings:Object;
		/** @private */
		private var _size:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function StringIndex()
		{
			clear();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a string to the string index.
		 * 
		 * @param id ID of the string.
		 * @param string The text content of the string.
		 * @param resource The resource that the string belongs to.
		 */
		public function add(id:String, string:String, resource:Resource):void
		{
			if (_strings[id] == null) _size++;
			else delete _strings[id];
			_strings[id] = string;
			
			if (resource.content == null) resource.setContent([]);
			(resource.content as Array).push(id);
		}
		
		
		/**
		 * Checks whether the string index contains the string of the specified ID.
		 * 
		 * @param stringID ID of the string to check.
		 * @return true or false.
		 */
		public function contains(stringID:String):Boolean
		{
			return _strings[stringID] != null;
		}
		
		
		/**
		 * Returns the text content of the specified stringID. If the string is not found
		 * in the string index a placeholder string is being returned.
		 * 
		 * @param stringID The ID of the string.
		 * @return The string text.
		 */
		public function getString(stringID:String):String
		{
			var s:String = _strings[stringID];
			if (s == null) return "[MISSING:" + stringID + "]";
			return s;
		}
		
		
		/**
		 * Obsolete!
		 * 
		 * @param stringID
		 */
		public function get(stringID:String):String
		{
			return getString(stringID);
		}
		
		
		/**
		 * Removes a string from the string index.
		 * 
		 * @param stringID ID of the string to remove.
		 */
		public function remove(stringID:String):void
		{
			if (_strings[stringID])
			{
				_strings[stringID] = null;
				delete _strings[stringID];
				_size--;
			}
		}
		
		
		/**
		 * Removes all strings from the string index that are stored by any of the IDs
		 * in the specified array. Used by the resource manager to unload strings when
		 * a text resource is unloaded.
		 * 
		 * @param stringIDs An array of string IDs.
		 */
		public function removeStrings(stringIDs:Array):void
		{
			for each (var id:String in stringIDs)
			{
				remove(id);
			}
		}
		
		
		/**
		 * Removes all strings from the string index.
		 */
		public function removeAll():void
		{
			for (var id:String in _strings)
			{
				remove(id);
			}
		}
		
		
		/**
		 * Clears the string index.
		 */
		public function clear():void
		{
			_strings = {};
			_size = 0;
		}
		
		
		/**
		 * Returns an array of all strings.
		 * 
		 * @return An array that contains all strings.
		 */
		public function toArray():Array
		{
			var a:Array = [];
			for each (var s:String in _strings)
			{
				a.push(s);
			}
			return a;
		}
		
		
		/**
		 * Returns a hashmap of all strings, mapped by their ID.
		 * 
		 * @return An hashmap that contains all strings.
		 */
		public function toMap():Object
		{
			var map:Object = {};
			for (var key:String in _strings)
			{
				map[key] = _strings[key];
			}
			return map;
		}
		
		
		/**
		 * Returns a string dump of all mapped strings.
		 * 
		 * @return A string dump of all mapped strings.
		 */
		public function dump():String
		{
			var t:TabularText = new TabularText(2, true, "  ", null, "  ", 0, ["ID", "STRING"]);
			for (var s:String in _strings)
			{
				t.add([s, _strings[s]]);
			}
			return toString() + " (size: " + _size + ")\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "StringIndex";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The number of strings mapped in the string index.
		 */
		public function get size():int
		{
			return _size;
		}
	}
}
