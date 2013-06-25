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
	public final class Elastic
	{
		private static const PI2:Number = Math.PI * 2;
		private static const ASIN:Function = Math.asin;
		private static const SIN:Function = Math.sin;
		private static const POW:Function = Math.pow;
		
		
		public static function easeIn(t:Number, b:Number, c:Number, d:Number, a:Number = 0, p:Number = 0):Number
		{
			var s:Number;
			if (t == 0) return b;
			if ((t /= d) == 1) return b + c;
			if (!p) p = d * .3;
			if (!a || (c > 0 && a < c) || (c < 0 && a < -c))
			{
				a = c;
				s = p / 4;
			}
			else s = p / PI2 * ASIN(c / a);
			return -(a * POW(2, 10 * (t -= 1)) * SIN((t * d - s) * PI2 / p)) + b;
		}
		
		
		public static function easeOut(t:Number, b:Number, c:Number, d:Number, a:Number = 0, p:Number = 0):Number
		{
			var s:Number;
			if (t == 0) return b;
			if ((t /= d) == 1) return b + c;
			if (!p) p = d * .3;
			if (!a || (c > 0 && a < c) || (c < 0 && a < -c))
			{
				a = c;
				s = p / 4;
			}
			else s = p / PI2 * ASIN(c / a);
			return (a * POW(2, -10 * t) * SIN((t * d - s) * PI2 / p) + c + b);
		}
		
		
		public static function easeInOut(t:Number, b:Number, c:Number, d:Number, a:Number = 0, p:Number = 0):Number
		{
			var s:Number;
			if (t == 0) return b;
			if ((t /= d * 0.5) == 2) return b + c;
			if (!p) p = d * (.3 * 1.5);
			if (!a || (c > 0 && a < c) || (c < 0 && a < -c))
			{
				a = c;
				s = p / 4;
			}
			else s = p / PI2 * ASIN(c / a);
			if (t < 1) return -.5 * (a * POW(2, 10 * (t -= 1)) * SIN((t * d - s) * PI2 / p)) + b;
			return a * POW(2, -10 * (t -= 1)) * SIN((t * d - s) * PI2 / p) * .5 + c + b;
		}
	}
}
