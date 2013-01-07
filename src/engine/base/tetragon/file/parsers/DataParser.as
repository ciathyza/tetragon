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
package tetragon.file.parsers
{
	import tetragon.debug.Log;

	import com.hexagonstar.util.reflection.getClassName;
	import com.hexagonstar.util.string.createStringVector;
	import com.hexagonstar.util.string.unwrapString;

	import flash.system.System;
	
	
	/**
	 * Abstract base class for XML-based data parsers.
	 */
	public class DataParser
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _xml:XML;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the parser.
		 */
		public function dispose():void
		{
			System.disposeXML(_xml);
			_xml = null;
		}
		
		
		/**
		 * Returns a string representation of the object.
		 * 
		 * @return A string representation of the object.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function warn(message:String):void
		{
			Log.warn(message, this);
		}
		
		
		/**
		 * @private
		 */
		protected function error(message:String):void
		{
			Log.error(message, this);
		}
		
		
		/**
		 * Extracts the value that is stored under an XML node name or XML attribute name
		 * specified with the xml and name arguments. The xml parameter can be an object
		 * of type XML or XMLList.
		 * 
		 * @param xml The XML or XMLList on that to find 'name'.
		 * @param name The node or attribute name on the specified XML.
		 * @return The extracted value.
		 */
		protected static function extractString(xml:*, name:String = null):String
		{
			if (name != null)
			{
				var v:String = xml[name];
				if (v && v.length > 0) return v;
				return null;
			}
			return String(xml);
		}
		
		
		/**
		 * Extracts and unwraps text from an XML object.
		 * 
		 * @param xml The XML from which to extract.
		 * @param name The node or attribute name on the specified XML.
		 * @return The extracted text.
		 */
		protected static function extractText(xml:*, name:String = null):String
		{
			return unwrapString(extractString(xml, name));
		}
		
		
		/**
		 * Extracts a number from an XML object.
		 * 
		 * @param xml The XML from which to extract.
		 * @param name The node or attribute name on the specified XML.
		 * @return The extracted number.
		 */
		protected static function extractNumber(xml:*, name:String):Number
		{
			return Number(extractString(xml, name));
		}
		
		
		/**
		 * Extracts a boolean from an XML object.
		 * 
		 * @param xml The XML from which to extract.
		 * @param name The node or attribute name on the specified XML.
		 * @return The extracted boolean.
		 */
		protected static function extractBoolean(xml:*, name:String):Boolean
		{
			return parseBoolean(extractString(xml, name));
		}
		
		
		/**
		 * Extracts a color value from an XML object.
		 * 
		 * @param xml The XML from which to extract.
		 * @param name The node or attribute name on the specified XML.
		 * @return The extracted color value.
		 */
		protected static function extractColorValue(xml:*, name:String):uint
		{
			return parseColorValue(extractString(xml, name));
		}
		
		
		/**
		 * Extracts untyped data from an XML object.
		 * 
		 * @param xml The XML from which to extract.
		 * @param name The node or attribute name on the specified XML.
		 * @return The extracted data.
		 */
		protected static function extractUntyped(xml:*, name:String = null):*
		{
			var s:String = extractString(xml, name);
			if (s != null && s == "") return null;
			return s;
		}
		
		
		/**
		 * Extracts an array from an XML object. The XML must be a sequence of values
		 * separated by comma, e.g. john, foo, mary, jane. Values itself may not contain
		 * spaces.
		 * 
		 * @param xml The XML from which to extract.
		 * @param name The node or attribute name on the specified XML.
		 * @return The extracted array.
		 */
		protected static function extractArray(xml:*, name:String = null):Array
		{
			var s:String = extractString(xml, name);
			if (s == null || s.length < 1) return null;
			s = s.split(" ").join("");
			return s.split(",");
		}
		
		
		/**
		 * Parses a string made of IDs into a String Vector. The IDs in the string must
		 * be separated by commata.
		 * 
		 * @param string The string to parse ID values from.
		 * @return A Vector with string values.
		 */
		protected static function parseIDString(string:String):Vector.<String>
		{
			if (string == null || string.length == 0) return null;
			string = string.split(" ").join("");
			return createStringVector(string.split(","));
		}
		
		
		/**
		 * Parses a boolean string. If the specified string is 'true' the method
		 * returns true or if the string is 'false' or any other value it returns
		 * false. The string can be lowercase, uppercase or mixed case.
		 * 
		 * @param string The string to convert into a boolean.
		 * @return either true or false.
		 */
		protected static function parseBoolean(string:String):Boolean
		{
			if (string == null) return false;
			if (string.toLowerCase() == "true") return true;
			return false;
		}
		
		
		/**
		 * Parses a string color value. The specified string needs to contain
		 * a hexadecimal color value either starting with a '#' or only consist
		 * of a hexadecimal value.
		 * 
		 * @param string A String with a hexadecimal color value, e.g. #FF00FF.
		 * @return The color value as a uint typed number.
		 */
		protected static function parseColorValue(string:String):uint
		{
			if (string == null) return 0;
			if (string.substr(0, 1) == "#")
				string = string.substr(1, string.length - 1);
			else if (string.substr(0, 2).toLocaleLowerCase() == "0x")
				string = string.substr(2, string.length - 1);
			var r:uint = uint("0x" + string);
			return r;
		}
		
		
		/**
		 * Trims whitespace from the start and end of the specified string.
		 * 
		 * @param s The string to trim.
		 * @return The trimmed string.
		 */
		protected static function trim(s:String):String
		{
			return s.replace(/^[ \t]+|[ \t]+$/g, "");
		}
	}
}
