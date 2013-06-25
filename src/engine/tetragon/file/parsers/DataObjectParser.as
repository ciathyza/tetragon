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
	import tetragon.ClassRegistry;
	import tetragon.Main;
	import tetragon.core.types.KeyValuePair;
	import tetragon.debug.Log;
	import tetragon.file.resource.ResourceIDType;
	
	
	/**
	 * The base class for data parsers that can parse data objects, entities and data
	 * object lists.
	 */
	public class DataObjectParser extends DataParser
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _classRegistry:ClassRegistry;
		/** @private */
		protected var _referencedIDs:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function DataObjectParser()
		{
			_classRegistry = Main.instance.classRegistry;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * If the parsed data contains any referenced IDs they will be mapped into
		 * this object for using them with referenced resource loading.
		 */
		public function get referencedIDs():Object
		{
			return _referencedIDs;
		}
		
		
		/**
		 * Child class access only!
		 */
		protected function get classRegistry():ClassRegistry
		{
			return _classRegistry;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Parses a property from an XML into a key-value pair.
		 * 
		 * @param p The property XML object.
		 * @return A KeyValuePair object with the key being the name of the property
		 *         XML object and the value either a String containing the content
		 *         of the XML object, a complex datatype object or null.
		 */
		protected function parseProperty(p:XML):KeyValuePair
		{
			const key:String = p.name();
			const value:String = p.toString();
			
			/* Check if property has a complex type assigned. */
			var ctype:String = p.@ctype;
			if (ctype && ctype.length > 0)
			{
				var clazz:Class = classRegistry.getComplexTypeClass(ctype);
				var obj:Object = null;
				if (clazz)
				{
					obj = new clazz();
					obj = parseComplexTypeParams(obj, value);
				}
				else
				{
					Log.error("Could not create complex type class. Class for ctype \""
						+ ctype + "\" was not mapped.", this);
				}
				return new KeyValuePair(key, obj);
			}
			
			return new KeyValuePair(key, value);
		}
		
		
		/**
		 * Checks if the given key is a referenced resource ID and if necessary
		 * modifies the key and stores the referenced ID in the referencedIDs map
		 * so that the ref'ed resource can be loaded automatically later.
		 * 
		 * @param key The resource ID property key to check.
		 * @param value The resource property's value.
		 * @return A KeyValuePair object.
		 */
		protected function checkReferencedID(key:String, value:*):KeyValuePair
		{
			if (value is String && key.substr(-2) == ResourceIDType.ID)
			{
				if (value != null && value != "")
				{
					if (!_referencedIDs) _referencedIDs = {};
					/* Check if the referenced ID has two parts. */
					if ((value as String).indexOf(ResourceIDType.DIVIDER) != -1)
					{
						var a:Array = (value as String).split(ResourceIDType.DIVIDER);
						var refID:String = a[0];
						value = a[1];
						_referencedIDs[refID] = key;
					}
					else
					{
						_referencedIDs[value] = key;
					}
				}
			}
			return new KeyValuePair(key, value);
		}
		
		
		/**
		 * Parses a parameter string for a complex data type.
		 * 
		 * @param type The complex datatype object.
		 * @param params A string of params that get parsed into the object.
		 * @return The complex datatype object with params parsed into it.
		 */
		protected static function parseComplexTypeParams(type:Object, params:String):Object
		{
			const len:int = params.length;
			var quotesCount:int = 0;
			var isInsideQuotes:Boolean = false;
			var current:String;
			var segment:String = "";
			var segments:Array = [];
			
			for (var i:int = 0; i < len; i++)
			{
				current = params.charAt(i);
				
				/* Check if we're inside quotes. */
				if (current == "\"")
				{
					quotesCount++;
					if (quotesCount == 1)
					{
						isInsideQuotes = true;
					}
					else if (quotesCount == 2)
					{
						quotesCount = 0;
						isInsideQuotes = false;
					}
				}
				
				/* Remove all whitespace unless we're inside quotes. */
				if (isInsideQuotes || current != " ")
				{
					segment += current;
				}
				
				/* Split the string where comma occurs, but not inside quotes. */
				if (!isInsideQuotes && current == ",")
				{
					/* Remove last char from segment which must be a comma. */
					segment = segment.substr(0, segment.length - 1);
					segments.push(segment);
					segment = "";
				}
				
				/* Last segment needs to be added extra. */
				if (i == len - 1)
				{
					segments.push(segment);
				}
			}
			
			/* Parse Array objects. */
			if (type is Array)
			{
				for each (segment in segments)
				{
					(type as Array).push(segment);
				}
			}
			/* Parse any other objects that must be made up of key-value pairs. */
			else
			{
				/* Loop through segments and split them into property and value. */
				for each (segment in segments)
				{
					var a:Array = segment.split(":");
					var p:String = a[0];
					var v:String = a[1];
					
					/* If value is wrapped into quotes we need to remove these. */
					if (v.charAt(0) == "\"" && v.charAt(v.length - 1) == "\"")
					{
						v = v.substr(1, v.length - 2);
					}
					
					if (type.hasOwnProperty(p))
					{
						if (v == "") type[p] = null;
						else type[p] = v;
					}
					else
					{
						Log.warn("DataObjectParser: Tried to set a non-existing property <"
							+ p + "> in complex type " + type + ".");
					}
				}
			}
			
			return type;
		}
	}
}
