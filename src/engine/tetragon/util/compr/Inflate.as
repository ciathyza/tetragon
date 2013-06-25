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
package tetragon.util.compr
{
	import tetragon.core.exception.Exception;

	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	
	/**
	 * Inflater is used to decompress data that has been compressed according 
	 * to the "deflate" standard described in rfc1950.
	 */
	public final class Inflate
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const MAXBITS:int	= 15;
		private static const MAXLCODES:int	= 286;
		private static const MAXDCODES:int	= 30;
		private static const FIXLCODES:int	= 288;
		
		private static const LENS:Array = [3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258];
		private static const LEXT:Array = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0];
		private static const DISTS:Array = [1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577];
		private static const DEXT:Array = [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13];
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _inBuffer:ByteArray;
		private var _inCount:uint;
		private var _bitBuffer:int;
		private var _bitCount:int;
		private var _lenCodes:Codes;
		private var _distCodes:Codes;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Inflates the compressed stream to the output buffer.
		 * 
		 * @param input The input buffer to decompress.
		 * @param output The output buffer to which to write the inflated data.
		 * @return An error code.
		 */
		public function process(input:ByteArray, output:ByteArray):uint
		{
			_inBuffer = input;
			_inBuffer.endian = Endian.LITTLE_ENDIAN;
			_inCount = _bitBuffer = _bitCount = 0;
			
			var err:int = 0;
			do
			{
				var last:int = bits(1);
				var type:int = bits(2);
				
				if (type == 0)
				{
					stored(output);
				}
				else if (type == 3)
				{
					error("Invalid block type (type == 3).", -1);
				}
				else
				{
					_lenCodes = new Codes();
					_distCodes = new Codes();
					if (type == 1) constructFixedTables();
					else if (type == 2) err = constructDynamicTables();
					if (err != 0) return err;
					/* Decode data until end-of-block code. */
					err = codes(output);
				}
				/* Return with error */
				if (err != 0) break;
			}
			while (!last);
			return err;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function bits(need:int):int
		{
			/* bit accumulator (can use up to 20 bits). Load at least need bits into val */
			var val:int = _bitBuffer;
			while (_bitCount < need)
			{
				if (_inCount == _inBuffer.length)
				{
					error("Available inflate data did not terminate.", 2);
				}
				val |= _inBuffer[_inCount++] << _bitCount;
				_bitCount += 8; // load eight bits.
			}
			/* drop need bits and update buffer, always zero to seven bits left */
			_bitBuffer = val >> need;
			_bitCount -= need;
			/* return need bits, zeroing the bits above that */
			return val & ((1 << need) - 1);
		}
		
		
		/**
		 * @private
		 */
		private function construct(h:Codes, length:Array, n:int):int
		{
			var len:int;
			var offs:Array = []; // offsets in symbol table for each length
			
			// count number of codes of each length
			for (len = 0; len <= MAXBITS; len++)
			{
				h.count[len] = 0;
			}
			
			// assumes lengths are within bounds
			for (var symbol:int = 0; symbol < n; symbol++)
			{
				h.count[length[symbol]]++;
			}
			
			// no codes! complete, but decode() will fail
			if (h.count[0] == n) return 0;
			
			// check for an over-subscribed or incomplete set of lengths
			var left:int = 1;
			// one possible code of zero length
			for (len = 1; len <= MAXBITS; len++)
			{
				// one more bit, double codes left
				left <<= 1;
				left -= h.count[len];
				// deduct count from possible codes
				// over-subscribed--return negative
				if (left < 0) return left;
			}
			
			// left > 0 means incomplete
			// generate offsets into symbol table for each length for sorting
			offs[1] = 0;
			
			for (len = 1; len < MAXBITS; len++)
			{
				offs[len + 1] = offs[len] + h.count[len];
			}
			
			// put symbols in table sorted by length, by symbol order within each length
			for (symbol = 0; symbol < n; symbol++)
			{
				if (length[symbol] != 0) h.symbol[offs[length[symbol]]++] = symbol;
			}
			
			// return zero for complete set, positive for incomplete set
			return left;
		}
		
		
		/**
		 * @private
		 */
		private function decode(h:Codes):int
		{
			// len bits being decoded
			var code:int = 0;
			// first code of length len
			var first:int = 0;
			// index of first code of length len in symbol table
			var index:int = 0;

			for (var len:int = 1; len <= MAXBITS; len++)
			{
				// current number of bits in code
				// get next bit
				code |= bits(1);
				// number of codes of length len
				var count:int = h.count[len];
				
				// if length len, return symbol
				if (code < first + count)
				{
					return h.symbol[index + (code - first)];
				}
				
				// else update for next length
				index += count;
				first += count;
				first <<= 1;
				code <<= 1;
			}
			// ran out of codes
			return -9;
		}
		
		
		/**
		 * @private
		 */
		private function codes(buf:ByteArray):int
		{
			// decode literals and length/distance pairs
			do
			{
				var symbol:int = decode(_lenCodes);
				// invalid symbol
				if (symbol < 0) return symbol;

				if (symbol < 256)
				{
					// literal: symbol is the byte
					buf[buf.length] = symbol;
				}
				else if (symbol > 256)
				{
					// length
					// get and compute length
					symbol -= 257;
					if (symbol >= 29)
					{
						error("invalid literal/length or distance code in fixed or dynamic block.", -9);
					}
					
					// length for copy
					var len:int = LENS[symbol] + bits(LEXT[symbol]);
					
					// get and check distance
					symbol = decode(_distCodes);
					
					// invalid symbol
					if (symbol < 0) return symbol;

					// distance for copy
					var dist:uint = DISTS[symbol] + bits(DEXT[symbol]);
					if (dist > buf.length)
					{
						error("distance is too far back in fixed or dynamic block.", -10);
					}
					
					// copy length bytes from distance bytes back
					while (len--)
					{
						buf[buf.length] = buf[buf.length - dist];
					}
				}
			}
			// end of block symbol
			while (symbol != 256);

			// done with a valid fixed or dynamic block
			return 0;
		}
		
		
		/**
		 * @private
		 */
		private function stored(buf:ByteArray):void
		{
			// discard leftover bits from current byte (assumes s->bitcnt < 8)
			_bitBuffer = 0;
			_bitCount = 0;
			
			// get length and check against its one's complement
			if (_inCount + 4 > _inBuffer.length)
			{
				error("available inflate data did not terminate.", 2);
			}
			
			// length of stored block
			var len:uint = _inBuffer[_inCount++];
			len |= _inBuffer[_inCount++] << 8;
			
			if (_inBuffer[_inCount++] != (~len & 0xff) || _inBuffer[_inCount++] != ((~len >> 8) & 0xff))
			{
				error("stored block length did not match one's complement.", -2);
			}
			if (_inCount + len > _inBuffer.length)
			{
				error("available inflate data did not terminate.", 2);
			}
			
			// copy len bytes from in to out
			while (len--)
			{
				buf[buf.length] = _inBuffer[_inCount++];
			}
		}
		
		
		/**
		 * @private
		 */
		private function constructFixedTables():void
		{
			// literal/length table
			var lengths:Array = [];

			for (var symbol:int = 0; symbol < 144; symbol++)
				lengths[symbol] = 8;
			for (; symbol < 256; symbol++)
				lengths[symbol] = 9;
			for (; symbol < 280; symbol++)
				lengths[symbol] = 7;
			for (; symbol < FIXLCODES; symbol++)
				lengths[symbol] = 8;
			
			// distance table
			construct(_lenCodes, lengths, FIXLCODES);

			for (symbol = 0; symbol < MAXDCODES; symbol++)
			{
				lengths[symbol] = 5;
			}
			construct(_distCodes, lengths, MAXDCODES);
		}
		
		
		/**
		 * @private
		 */
		private function constructDynamicTables():int
		{
			// descriptor code lengths
			var lengths:Array = [];
			// permutation of code length codes
			var order:Array = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];
			// get number of lengths in each table, check lengths
			var nlen:int = bits(5) + 257;
			var ndist:int = bits(5) + 1;
			var ncode:int = bits(4) + 4;
			
			// number of lengths in descriptor
			if (nlen > MAXLCODES || ndist > MAXDCODES)
			{
				error("dynamic block code description: too many length or distance codes.", -3);
			}
			
			// read code length code lengths (really), missing lengths are zero
			for (var index:int = 0; index < ncode; index++)
				lengths[order[index]] = bits(3);
			for (; index < 19; index++)
				lengths[order[index]] = 0;
			
			// build huffman table for code lengths codes (use lencode temporarily)
			var err:int = construct(_lenCodes, lengths, 19);
			if (err != 0)
			{
				error("dynamic block code description: code lengths codes incomplete.", -4);
			}
			
			// read length/literal and distance code length tables
			index = 0;
			while (index < nlen + ndist)
			{
				// decoded value
				var symbol:int;
				// last length to repeat
				var len:int;

				symbol = decode(_lenCodes);
				
				if (symbol < 16)
				{
					// length in 0..15
					lengths[index++] = symbol;
				}
				else
				{
					// repeat instruction
					len = 0;
					// assume repeating zeros
					if (symbol == 16)
					{
						// repeat last length 3..6 times
						if (index == 0)
						{
							error("dynamic block code description: repeat lengths with no first length.", -5);
						}
						
						// last length
						len = lengths[index - 1];
						symbol = 3 + bits(2);
					}
					else if (symbol == 17)
					{
						symbol = 3 + bits(3); // repeat zero 3..10 times
					}
					else
					{
						symbol = 11 + bits(7);
					}
					// == 18, repeat zero 11..138 times

					if (index + symbol > nlen + ndist)
					{
						error("dynamic block code description: repeat more than specified lengths.", -6);
					}
					
					// repeat last or zero symbol times
					while (symbol--)
					{
						lengths[index++] = len;
					}
				}
			}
			
			// build huffman table for literal/length codes
			err = construct(_lenCodes, lengths, nlen);
			
			// only allow incomplete codes if just one code
			if (err < 0 || (err > 0 && nlen - _lenCodes.count[0] != 1))
			{
				error("dynamic block code description: invalid literal/length code lengths", -7);
			}
			
			// build huffman table for distance codes
			err = construct(_distCodes, lengths.slice(nlen), ndist);
			
			// only allow incomplete codes if just one code
			if (err < 0 || (err > 0 && ndist - _distCodes.count[0] != 1))
			{
				error("dynamic block code description: invalid distance code lengths", -8);
			}
			
			return err;
		}
		
		
		/**
		 * @private
		 */
		private function error(msg:String, id:*):void
		{
			throw new Exception("[Inflate] " + msg, id);
		}
	}
}


/**
 * @private
 */
final class Codes
{
	public var count:Array = [];
	public var symbol:Array = [];
}
