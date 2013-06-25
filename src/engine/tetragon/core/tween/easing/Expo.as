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
	public final class Expo
	{
		private static const POW:Function = Math.pow;
		
		
		public static function easeIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return (t == 0) ? b : c * POW(2, 10 * (t / d - 1)) + b - c * 0.001;
		}
		
		
		public static function easeOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return (t == d) ? b + c : c * (-POW(2, -10 * t / d) + 1) + b;
		}
		
		
		public static function easeInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if (t == 0) return b;
			if (t == d) return b + c;
			if ((t /= d * 0.5) < 1) return c * 0.5 * POW(2, 10 * (t - 1)) + b;
			return c * 0.5 * (-POW(2, -10 * --t) + 2) + b;
		}
	}
}
