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
package tetragon.util.crypto
{
	/**
	 * A fast SHA-1 hash generator.
	 */
	public final class SHA1
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static const CHARMAP:String = "0123456789ABCDEF";
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Generates a SHA-1 hash string from the specified string.
		 * 
		 * @param string String to generate hash from.
		 * @return A hexadecimal SHA-1 hash string.
		 */
		public static function hash(string:String):String
		{
			var a:Array = [];
			var l:uint = string.length * 8;
			var i:uint = 0;
			
			/* Convert string to binary format. */
			var mask:int = (1 << 8) - 1;
			while (i < l)
			{
				a[i >> 5] |= (string.charCodeAt(i / 8) & mask) << (32 - 8 - i % 32);
				i += 8;
			}
			
			var b1:int = 1732584193;
			var b2:int = -271733879;
			var b3:int = -1732584194;
			var b4:int = 271733878;
			var b5:int = -1009589776;
			var op:Array = [];
			
			a[l >> 5] |= 0x80 << (24 - l % 32);
			a[((l + 64 >> 9) << 4) + 15] = l;
			
			l = a.length;
			i = 0;
			while (i < l)
			{
				var s1:int = b1;
				var s2:int = b2;
				var s3:int = b3;
				var s4:int = b4;
				var s5:int = b5;
				
				for (var j:uint = 0; j < 80; ++j)
				{
					if (j < 16)
					{
						op[j] = a[i + j];
					}
					else
					{
						var n:int = op[j - 3] ^ op[j - 8] ^ op[j - 14] ^ op[j - 16];
						op[j] = (n << 1) | (n >>> (32 - 1));
					}
					
					b5 = b4;
					b4 = b3;
					b3 = (b2 << 30) | (b2 >>> (32 - 30));
					b2 = b1;
					b1 = safeAdd(safeAdd((b1 << 5) | (b1 >>> (32 - 5)),
						fmod(j, b2, b3, b4)),
						safeAdd(safeAdd(b5, op[j]), (j < 20) ? 0x5A827999 : (j < 40) ? 0x6ED9EBA1 : (j < 60) ? 0x8F1BBCDC : 0xCA62C1D6));
				}
				
				b1 = safeAdd(b1, s1);
				b2 = safeAdd(b2, s2);
				b3 = safeAdd(b3, s3);
				b4 = safeAdd(b4, s4);
				b5 = safeAdd(b5, s5);
				
				i += 16;
			}
			
			/* Convert binary to hex format. */
			string = "";
			a = [b1, b2, b3, b4, b5];
			i = 0;
			while (i++ < 20)
			{
				string += CHARMAP.charAt((a[i >> 2] >> ((3 - i % 4) * 8 + 4)) & 0xF)
						+ CHARMAP.charAt((a[i >> 2] >> ((3 - i % 4) * 8 )) & 0xF);
			}
			return string;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Perform the appropriate triplet combination function for the current iteration.
		 * @private
		 */
		private static function fmod(t:int, b:int, c:int, d:int):int
		{
			if (t < 20) return (b & c) | ((~b) & d);
			if (t < 40) return b ^ c ^ d;
			if (t < 60) return (b & c) | (b & d) | (c & d);
			return b ^ c ^ d;
		}
		
		
		/**
		 * @private
		 */
		private static function safeAdd(x:int, y:int):int
		{
			var lsw:uint = (x & 0xFFFF) + (y & 0xFFFF);
			return ((x >> 16) + (y >> 16) + (lsw >> 16) << 16) | (lsw & 0xFFFF);
		}
	}
}
