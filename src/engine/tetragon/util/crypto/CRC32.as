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
	
	
	public final class CRC32
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _table:Vector.<uint>;
		/** @private */
		private static var _bytes:ByteArray;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Calculates a CRC-32 checksum over a ByteArray.
		 * 
		 * @see http://www.w3.org/TR/PNG/#D-CRCAppendix
		 * 
		 * @param data 
		 * @param start
		 * @param len
		 * @return CRC-32 checksum
		 */
		public static function hash(data:ByteArray, start:uint = 0, len:uint = 0):uint
		{
			if (!_table) createCRCTable();
			
			if (start >= data.length) start = data.length;
			if (len == 0) len = data.length - start;
			if (len + start > data.length) len = data.length - start;
			
			var i:uint = start;
			var c:uint = 0xFFFFFFFF;
			
			while (i < len)
			{
				c = _table[(c ^ data[i]) & 0xFF] ^ (c >>> 8);
				++i;
			}
			
			return (c ^ 0xFFFFFFFF);
		}
		
		
		/**
		 * Calculates a CRC-32 checksum over a String.
		 * 
		 * @param string
		 * @return CRC-32 checksum as hexadecimal String.
		 */
		public static function stringHash(string:String):String
		{
			if (!_bytes) _bytes = new ByteArray();
			
			_bytes.position = 0;
			_bytes.writeUTFBytes(string);
			
			return hash(_bytes, 0, string.length).toString(16);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a checksum table needed for CRC checksum generation.
		 * 
		 * @private
		 * @return Vector with uints.
		 */
		private static function createCRCTable():void
		{
			var t:Vector.<uint> = new Vector.<uint>(256, true);
			for (var i:uint = 0; i < 256; i++)
			{
				var c:uint = i;
				for (var j:uint = 0; j < 8; j++)
				{
					if (c & 1)
					{
						c = 0xEDB88320 ^ (c >>> 1);
					}
					else
					{
						c >>>= 1;
					}
				}
				t[i] = c;
			}
			_table = t;
		}
	}
}
