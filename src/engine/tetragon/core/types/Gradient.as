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
	import tetragon.core.exception.IllegalArgumentException;
	import tetragon.util.array.shuffleArray;

	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	
	
	/**
	 * A gradient data type that can automatically calculate alphas and ratios for
	 * a specified set of colors.
	 */
	public class Gradient
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _colors:Array;
		/** @private */
		protected var _ratios:Array;
		/** @private */
		protected var _alphas:Array;
		/** @private */
		protected var _rotation:Number = 90;
		/** @private */
		protected var _focalPointRatio:Number = 0;
		/** @private */
		protected var _type:String = GradientType.LINEAR;
		/** @private */
		protected var _spreadMethod:String = SpreadMethod.PAD;
		/** @private */
		protected var _interpolationMethod:String = InterpolationMethod.RGB;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param colors
		 * @param ratios
		 * @param alphas
		 */
		public function Gradient(colors:Array = null, ratios:Array = null, alphas:Array = null)
		{
			this.colors = colors;
			this.ratios = ratios;
			this.alphas = alphas;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Generates a random gradient object.
		 * 
		 * @param numColors Number of colors (min. 2, max. 15).
		 * @return Gradient object.
		 */
		public static function createRandomGradient(numColors:int = 15):Gradient
		{
			if (numColors < 2) numColors = 2;
			else if (numColors > 15) numColors = 15;
			var colors:Array = new Array(numColors);
			for (var i:uint = 0; i < numColors; i++)
			{
				colors[i] = Math.random() * 0xFFFFFF;
			}
			return new Gradient(colors);
		}
		
		
		/**
		 * Generates a gradient object from a specified color palette.
		 * 
		 * @param palette Palette must have at least two colors. If it has more than 15 colors,
		 *        the first 15 colors are used only.
		 * @param randomOrder If true, randomizes order of colors.
		 * @return Gradient object.
		 */
		public static function createGradientFromPalette(palette:Palette,
			randomOrder:Boolean = false):Gradient
		{
			if (!palette) return null;
			if (palette.length < 2)
			{
				throw new IllegalArgumentException("createGradientFromPalette():"
					+ " Palette must have at least two colors.");
				return null;
			}
			var colors:Array = palette.toArray();
			if (colors.length > 15) colors = colors.splice(14);
			if (randomOrder) colors = shuffleArray(colors);
			return new Gradient(colors);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[Gradient]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get colors():Array
		{
			return _colors;
		}
		public function set colors(v:Array):void
		{
			_colors = v;
		}
		
		
		public function get ratios():Array
		{
			return _ratios;
		}
		public function set ratios(v:Array):void
		{
			if (v) _ratios = v;
			else _ratios = generateRatios(_colors);
		}
		
		
		public function get alphas():Array
		{
			return _alphas;
		}
		public function set alphas(v:Array):void
		{
			if (v) _alphas = v;
			else _alphas = generateAlphas(_colors);
		}
		
		
		/**
		 * @default 90
		 */
		public function get rotation():Number
		{
			return _rotation;
		}
		public function set rotation(v:Number):void
		{
			_rotation = v;
		}
		
		
		/**
		 * @default 0
		 */
		public function get focalPointRatio():Number
		{
			return _focalPointRatio;
		}
		public function set focalPointRatio(v:Number):void
		{
			_focalPointRatio = v;
		}
		
		
		/**
		 * @default GradientType.LINEAR
		 */
		public function get type():String
		{
			return _type;
		}
		public function set type(v:String):void
		{
			_type = v;
		}
		
		
		/**
		 * @default SpreadMethod.PAD
		 */
		public function get spreadMethod():String
		{
			return _spreadMethod;
		}
		public function set spreadMethod(v:String):void
		{
			_spreadMethod = v;
		}
		
		
		/**
		 * @default InterpolationMethod.RGB
		 */
		public function get interpolationMethod():String
		{
			return _interpolationMethod;
		}
		public function set interpolationMethod(v:String):void
		{
			_interpolationMethod = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected static function generateRatios(colors:Array):Array
		{
			if (!colors) return null;
			var len:uint = colors.length;
			var seg:Number = 255 / (len - 1);
			var c:Number = 0;
			var ratios:Array = new Array(len);
			ratios[0] = 0;
			for (var i:uint = 1; i < len; i++)
			{
				c += seg;
				ratios[i] = int(c);
			}
			return ratios;
		}
		
		
		/**
		 * @private
		 */
		protected static function generateAlphas(colors:Array):Array
		{
			if (!colors) return null;
			var alphas:Array = new Array(colors.length);
			for (var i:uint = 0; i < alphas.length; i++)
			{
				alphas[i] = 1.0;
			}
			return alphas;
		}
	}
}
