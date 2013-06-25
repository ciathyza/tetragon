/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package tetragon.util.hash
{
	/**
	 * Very fast murmur3 hash generator.
	 * 
	 * @param s String to hash.
	 * @param seed Seed for hashing.
	 * @return A hexadecimal hash string.
	 */
	public function murmur3(s:String, seed:uint = 0):String
	{
		var remainder:uint = s.length & 3; // key.length % 4
		var bytes:uint = s.length - remainder;
		var h1:uint = seed;
		var c1:uint = 0xcc9e2d51;
		var c2:uint = 0x1b873593;
		var i:uint = 0;
		var h1b:uint, c1b:uint, c2b:uint, k1:uint;
		
		while (i < bytes)
		{
			k1 = ((s.charCodeAt(i) & 0xff)) | ((s.charCodeAt(++i) & 0xff) << 8) | ((s.charCodeAt(++i) & 0xff) << 16) | ((s.charCodeAt(++i) & 0xff) << 24);
			++i;
			k1 = ((((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16))) & 0xffffffff;
			k1 = (k1 << 15) | (k1 >>> 17);
			k1 = ((((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16))) & 0xffffffff;
			h1 ^= k1;
			h1 = (h1 << 13) | (h1 >>> 19);
			h1b = ((((h1 & 0xffff) * 5) + ((((h1 >>> 16) * 5) & 0xffff) << 16))) & 0xffffffff;
			h1 = (((h1b & 0xffff) + 0x6b64) + ((((h1b >>> 16) + 0xe654) & 0xffff) << 16));
		}
		
		k1 = 0;
		
		switch (remainder)
		{
			case 3:
				k1 ^= (s.charCodeAt(i + 2) & 0xff) << 16;
			case 2:
				k1 ^= (s.charCodeAt(i + 1) & 0xff) << 8;
			case 1:
				k1 ^= (s.charCodeAt(i) & 0xff);
				k1 = (((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16)) & 0xffffffff;
				k1 = (k1 << 16) | (k1 >>> 16);
				k1 = (((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16)) & 0xffffffff;
				h1 ^= k1;
		}
		
		h1 ^= s.length;
		h1 ^= h1 >>> 16;
		h1 = (((h1 & 0xffff) * 0x85ebca6b) + ((((h1 >>> 16) * 0x85ebca6b) & 0xffff) << 16)) & 0xffffffff;
		h1 ^= h1 >>> 13;
		h1 = ((((h1 & 0xffff) * 0xc2b2ae35) + ((((h1 >>> 16) * 0xc2b2ae35) & 0xffff) << 16))) & 0xffffffff;
		h1 ^= h1 >>> 16;
		
		s = (h1 >>> 0).toString(16).toUpperCase();
		i = s.length;
		
		if (i == 10) return s;
		if (i == 9) return "0" + s;
		if (i == 8) return "00" + s;
		if (i == 7) return "000" + s;
		if (i == 6) return "0000" + s;
		if (i == 5) return "00000" + s;
		if (i == 4) return "000000" + s;
		if (i == 3) return "0000000" + s;
		return s;
	}
}
