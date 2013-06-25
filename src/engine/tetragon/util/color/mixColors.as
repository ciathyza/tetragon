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
	 * Mixes two colors and returns the hexadecimal color value of the result.
	 * 
	 * @param color1 bottom color.
	 * @param color2 top color.
	 * @param alpha Alpha value (0.0 - 1.0) of color2.
	 * @return uint
	 */
    public function mixColors(color1:uint, color2:uint, alpha:Number):uint
	{
		return (((color2 >> 16 & 0xFF) * (1 - alpha) + (color1 >> 16 & 0xFF) * alpha) << 16)
			+ (((color2 >> 8 & 0xFF) * (1 - alpha) + (color1 >> 8 & 0xFF) * alpha) << 8)
			+ ((color2 & 0xFF) * (1 - alpha) + (color1 & 0xFF) * alpha);
	}
}
