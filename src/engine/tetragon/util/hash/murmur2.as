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
package tetragon.util.hash
{
	/**
	 * Very fast murmur2 hash generator.
	 * 
	 * @param s String to hash.
	 * @param seed Seed for hashing.
	 * @return A hexadecimal hash string.
	 */
	public function murmur2(s:String, seed:uint = 0):String
	{
		var l:int = s.length, h:uint = seed ^ l, i:uint = 0, k:uint;
		
		while (l >= 4)
		{
			k = ((s.charCodeAt(i) & 0xff)) | ((s.charCodeAt(++i) & 0xff) << 8) | ((s.charCodeAt(++i) & 0xff) << 16) | ((s.charCodeAt(++i) & 0xff) << 24);
			k = (((k & 0xffff) * 0x5BD1E995) + ((((k >>> 16) * 0x5BD1E995) & 0xffff) << 16));
			k ^= k >>> 24;
			k = (((k & 0xffff) * 0x5BD1E995) + ((((k >>> 16) * 0x5BD1E995) & 0xffff) << 16));
			h = (((h & 0xffff) * 0x5BD1E995) + ((((h >>> 16) * 0x5BD1E995) & 0xffff) << 16)) ^ k;
			l -= 4;
			++i;
		}
		
		switch (l)
		{
			case 3:
				h ^= (s.charCodeAt(i + 2) & 0xff) << 16;
			case 2:
				h ^= (s.charCodeAt(i + 1) & 0xff) << 8;
			case 1:
				h ^= (s.charCodeAt(i) & 0xff);
				h = (((h & 0xffff) * 0x5BD1E995) + ((((h >>> 16) * 0x5BD1E995) & 0xffff) << 16));
		}
		
		h ^= h >>> 13;
		h = (((h & 0xffff) * 0x5BD1E995) + ((((h >>> 16) * 0x5BD1E995) & 0xffff) << 16));
		h ^= h >>> 15;
		
		s = (h >>> 0).toString(16).toUpperCase();
		l = s.length;
		
		if (l == 8) return s;
		if (l == 7) return "0" + s;
		if (l == 6) return "00" + s;
		if (l == 5) return "000" + s;
		if (l == 4) return "0000" + s;
		if (l == 3) return "00000" + s;
		return s;
	}
}
