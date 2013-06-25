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
package tetragon.util.color
{
	/**
	 * A utility class containing predefined colors and methods converting between different
	 * color representations.
	 */
	public final class ColorUtil
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const WHITE:uint		= 0xFFFFFF;
		public static const SILVER:uint		= 0xc0c0c0;
		public static const GRAY:uint		= 0x808080;
		public static const BLACK:uint		= 0x000000;
		public static const RED:uint		= 0xFF0000;
		public static const MAROON:uint		= 0x800000;
		public static const YELLOW:uint		= 0xFFFF00;
		public static const OLIVE:uint		= 0x808000;
		public static const LIME:uint		= 0x00FF00;
		public static const GREEN:uint		= 0x008000;
		public static const AQUA:uint		= 0x00FFFF;
		public static const TEAL:uint		= 0x008080;
		public static const BLUE:uint		= 0x0000FF;
		public static const NAVY:uint		= 0x000080;
		public static const FUCHSIA:uint	= 0xFF00FF;
		public static const PURPLE:uint		= 0x800080;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the alpha part of an ARGB color (0 - 255).
		 * 
		 * @param color
		 * @return int
		 */
		public static function getAlpha(color:uint):int
		{
			return (color >> 24) & 0xFF;
		}
		
		
		/**
		 * Returns the red part of an (A)RGB color (0 - 255).
		 * 
		 * @param color
		 * @return int
		 */
		public static function getRed(color:uint):int
		{
			return (color >> 16) & 0xFF;
		}
		
		
		/**
		 * Returns the green part of an (A)RGB color (0 - 255).
		 * 
		 * @param color
		 * @return int
		 */
		public static function getGreen(color:uint):int
		{
			return (color >> 8) & 0xFF;
		}
		
		
		/**
		 * Returns the blue part of an (A)RGB color (0 - 255).
		 * 
		 * @param color
		 * @return int
		 */
		public static function getBlue(color:uint):int
		{
			return  color & 0xFF;
		}
		
		
		/**
		 * Creates an RGB color, stored in an unsigned integer. Channels are expected
		 * in the range 0 - 255.
		 * 
		 * @param red
		 * @param green
		 * @param blue
		 * @return uint
		 */
		public static function rgb(red:int, green:int, blue:int):uint
		{
			return (red << 16) | (green << 8) | blue;
		}
		
		
		/**
		 * Creates an ARGB color, stored in an unsigned integer. Channels are expected
		 * in the range 0 - 255.
		 * 
		 * @param alpha
		 * @param red
		 * @param green
		 * @param blue
		 * @return uint
		 */
		public static function argb(alpha:int, red:int, green:int, blue:int):uint
		{
			return (alpha << 24) | (red << 16) | (green << 8) | blue;
		}
		
		
		/**
		 * @param color
		 * @param alpha
		 * @return uint
		 */
		public static function colorWithAlphaFromColor(color:uint, alpha:Number):uint
		{
			return color | ((alpha * 0xFF) << 24);
		}
	}
}
