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
package tetragon.core.tween.easing
{
	public final class Bounce
	{
		public static function easeIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c - easeOut(d - t, 0, c, d) + b;
		}
		
		
		public static function easeOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if ((t /= d) < (1 / 2.75)) return c * (7.5625 * t * t) + b;
			else if (t < (2 / 2.75)) return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + b;
			else if (t < (2.5 / 2.75)) return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + b;
			else return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + b;
		}
		
		
		public static function easeInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if (t < d * 0.5) return easeIn(t * 2, 0, c, d) * .5 + b;
			else return easeOut(t * 2 - d, 0, c, d) * .5 + c * .5 + b;
		}
	}
}
