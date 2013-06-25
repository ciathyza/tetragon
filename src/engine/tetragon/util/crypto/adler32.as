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
package tetragon.util.crypto
{
	import flash.utils.ByteArray;
	
	
	/**
	 * Calculates an Adler-32 checksum over a ByteArray
	 * 
	 * @see http://en.wikipedia.org/wiki/Adler-32#Example_implementation
	 * 
	 * @param data 
	 * @param len
	 * @param start
	 * @return Adler-32 checksum
	 */
	public function adler32(data:ByteArray, start:uint = 0, len:uint = 0):uint
	{
		if (start >= data.length) start = data.length;
		if (len == 0) len = data.length - start;
		if (len + start > data.length) len = data.length - start;

		var i:uint = start;
		var a:uint = 1;
		var b:uint = 0;

		while (i < (start + len))
		{
			a = (a + data[i]) % 65521;
			b = (a + b) % 65521;
			i++;
		}

		return (b << 16) | a;
	}
}
