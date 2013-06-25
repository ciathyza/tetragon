/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.types
{
	import tetragon.core.exception.IndexOutOfBoundsException;
	import tetragon.util.color.colorHexToRGB;
	
	
	/**
	 * A Palette object can store a list of color values and their names.
	 */
	public class Palette
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _name:String;
		protected var _colors:Vector.<PaletteColor>;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param name Optional name for the color palette.
		 */
		public function Palette(name:String = null)
		{
			_name = name;
			_colors = new Vector.<PaletteColor>();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Generates a random palette object.
		 * 
		 * @param numColors Number of colors.
		 * @return Palette object.
		 */
		public static function createRandomPalette(numColors:int = 16):Palette
		{
			if (numColors < 1) return null;
			var p:Palette = new Palette("Random Palette");
			for (var i:uint = 0; i < numColors; i++)
			{
				p.addColor(Math.random() * 0xFFFFFF, "Color" + i);
			}
			return p;
		}
		
		
		/**
		 * Adds a new color to the palette.
		 * 
		 * @param value
		 * @param name
		 */
		public function addColor(value:uint, name:String = null):void
		{
			_colors.push(new PaletteColor(value, name));
		}
		
		
		/**
		 * Removes a color from the palette.
		 * 
		 * @param index
		 * @return Either the PaletteColor object of the removed color or null.
		 */
		public function removeColor(index:uint):PaletteColor
		{
			if (index > _colors.length - 1) return null;
			return _colors.splice(index, 1)[0];
		}
		
		
		/**
		 * Returns the PaletteColor object that is at the specified index.
		 * 
		 * @param index
		 * @return PaletteColor object.
		 */
		public function getColor(index:uint):PaletteColor
		{
			if (index > _colors.length - 1) return indexOutOfBounds("getColor", index);
			return _colors[index];
		}
		
		
		/**
		 * Returns the color value that is at the specified index.
		 * 
		 * @param index
		 * @return uint color value.
		 */
		public function getColorValue(index:uint):uint
		{
			if (index > _colors.length - 1) return indexOutOfBounds("getColorValue", index);
			return _colors[index].value;
		}
		
		
		/**
		 * Returns a random color value from the palette.
		 */
		public function getRandomColorValue():uint
		{
			return _colors[uint(Math.random() * _colors.length)].value;
		}
		
		
		/**
		 * Returns the color name that is at the specified index.
		 * 
		 * @param index
		 * @return String color name.
		 */
		public function getColorName(index:uint):String
		{
			if (index > _colors.length - 1) return indexOutOfBounds("getColorName", index);
			return _colors[index].name;
		}
		
		
		/**
		 * Returns a RGB object of the color that is at the specified index.
		 * 
		 * @param index
		 * @return RGB object.
		 */
		public function getRGB(index:uint):RGB
		{
			if (index > _colors.length - 1) return indexOutOfBounds("getRGB", index);
			return colorHexToRGB(_colors[index].value);
		}
		
		
		/**
		 * Returns an array with uint color values from the palette.
		 * 
		 * @return An array with uint color values from the palette.
		 */
		public function toArray():Array
		{
			var a:Array = new Array(length);
			for (var i:uint = 0; i < _colors.length; i++)
			{
				a[i] = _colors[i].value;
			}
			return a;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[Palette]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The name of the color palette.
		 */
		public function get name():String
		{
			return _name;
		}
		public function set name(v:String):void
		{
			_name = v;
		}
		
		
		/**
		 * The length of the color palette.
		 */
		public function get length():uint
		{
			return _colors.length;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function indexOutOfBounds(method:String, index:uint):*
		{
			throw new IndexOutOfBoundsException(toString() + "." + method + ": The index "
				+ index + " is out of bounds.");
			return null;
		}
	}
}
