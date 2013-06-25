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
package tetragon.util.number
{
	/**
	 * Generates a random float (number). If called without the optional min, max
	 * arguments randomFloat() returns a peudo-random float between 0 and Number.MAX_VALUE.
	 * If you want a random number between 5 and 15, for example, (inclusive) use
	 * randomFloat(5, 15). Parameter order is insignificant, the return will always be
	 * between the lowest and highest value.
	 * 
	 * @param min The lowest possible value to return.
	 * @param max The highest possible value to return.
	 * @return A pseudo random number between min and max.
	 */
	public function randomFloat(min:Number = 0, max:Number = Number.MAX_VALUE):Number
	{
		if (min == max) return min;
		else if (min < max) return Math.random() * (max - min) + min;
		else return Math.random() * (min - max) + max;
	}
}
