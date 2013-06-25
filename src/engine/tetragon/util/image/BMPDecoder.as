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
package tetragon.util.image
{
	import flash.display.BitmapData;
	import flash.errors.IOError;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	
	/**
	 * Utility class used to decode BMP files.
	 */
	public final class BMPDecoder
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const BITMAP_HEADER_TYPE:String = "BM";
		private static const BITMAP_FILE_HEADER_SIZE:int = 14;
		private static const BITMAP_CORE_HEADER_SIZE:int = 12;
		private static const BITMAP_INFO_HEADER_SIZE:int = 40;
		private static const COMP_RGB:int = 0;
		private static const COMP_RLE8:int = 1;
		private static const COMP_RLE4:int = 2;
		private static const COMP_BITFIELDS:int = 3;
		private static const BIT1:int = 1;
		private static const BIT4:int = 4;
		private static const BIT8:int = 8;
		private static const BIT16:int = 16;
		private static const BIT24:int = 24;
		private static const BIT32:int = 32;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var bytes:ByteArray;
		private var palette:Array;
		private var bd:BitmapData;
		private var nFileSize:uint;
		private var nReserved1:uint;
		private var nReserved2:uint;
		private var nOffbits:uint;
		private var nInfoSize:uint;
		private var nWidth:int;
		private var nHeight:int;
		private var nPlains:uint;
		private var nBitsPerPixel:uint;
		private var nCompression:uint;
		private var nSizeImage:uint;
		private var nXPixPerMeter:int;
		private var nYPixPerMeter:int;
		private var nColorUsed:uint;
		private var nColorImportant:uint;
		private var nRMask:uint;
		private var nGMask:uint;
		private var nBMask:uint;
		private var nRPos:uint;
		private var nGPos:uint;
		private var nBPos:uint;
		private var nRMax:uint;
		private var nGMax:uint;
		private var nBMax:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BMPDecoder()
		{
			nRPos = 0;
			nGPos = 0;
			nBPos = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * decode
		 *
		 * @param BMP file ByteArray
		 */
		public function decode(data:ByteArray):BitmapData
		{
			bytes = data;
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 0;
			readFileHeader();
			nInfoSize = bytes.readUnsignedInt();
			
			switch (nInfoSize)
			{
				case BITMAP_CORE_HEADER_SIZE:
					readCoreHeader();
					break;
				case BITMAP_INFO_HEADER_SIZE:
					readInfoHeader();
					break;
				default:
					readExtendedInfoHeader();
					break;
			}
			
			bd = new BitmapData(nWidth, nHeight);
			
			switch (nBitsPerPixel)
			{
				case BIT1:
					readColorPalette();
					decode1BitBMP();
					break;
				case BIT4:
					readColorPalette();
					if (nCompression == COMP_RLE4) decode4bitRLE();
					else decode4BitBMP();
					break;
				case BIT8:
					readColorPalette();
					if (nCompression == COMP_RLE8) decode8BitRLE();
					else decode8BitBMP();
					break;
				case BIT16:
					readBitFields();
					checkColorMask();
					decode16BitBMP();
					break;
				case BIT24:
					decode24BitBMP();
					break;
				case BIT32:
					readBitFields();
					checkColorMask();
					decode32BitBMP();
					break;
				default:
					throw new VerifyError("BMPDecoder: Invalid bits per pixel: " + nBitsPerPixel);
			}
			
			return bd;
		}
		
		
		/**
		 * print information
		 */
		public function dump():String
		{
			var s:String = "---- FILE HEADER ----"
				+ "\nnFileSize: " + nFileSize
				+ "\nnReserved1: " + nReserved1
				+ "\nnReserved2: " + nReserved2
				+ "\nnOffbits: " + nOffbits
				+ "\n---- INFO HEADER ----"
				+ "\nnWidth: " + nWidth
				+ "\nnHeight: " + nHeight
				+ "\nnPlains: " + nPlains
				+ "\nnBitsPerPixel: " + nBitsPerPixel;
			if (nInfoSize >= 40)
			{
				s += "\nnCompression: " + nCompression
					+ "\nnSizeImage: " + nSizeImage
					+ "\nnXPixPerMeter: " + nXPixPerMeter
					+ "\nnYPixPerMeter: " + nYPixPerMeter
					+ "\nnColorUsed: " + nColorUsed
					+ "\nnColorUsed: " + nColorImportant;
			}
			if (nInfoSize >= 52)
			{
				s += "\nnRMask: " + nRMask.toString(2)
					+ "\nnGMask: " + nGMask.toString(2)
					+ "\nnBMask: " + nBMask.toString(2);
			}
			return s;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * read BITMAP FILE HEADER
		 */
		private function readFileHeader():void
		{
			var fileHeader:ByteArray = new ByteArray();
			fileHeader.endian = Endian.LITTLE_ENDIAN;
			try
			{
				bytes.readBytes(fileHeader, 0, BITMAP_FILE_HEADER_SIZE);
				if (fileHeader.readUTFBytes(2) != BITMAP_HEADER_TYPE)
				{
					throw new VerifyError("BMPDecoder: Invalid bitmap header type.");
				}
				nFileSize = fileHeader.readUnsignedInt();
				nReserved1 = fileHeader.readUnsignedShort();
				nReserved2 = fileHeader.readUnsignedShort();
				nOffbits = fileHeader.readUnsignedInt();
			}
			catch (e:IOError)
			{
				throw new VerifyError("BMPDecoder: Invalid file header.");
			}
		}
		
		
		/**
		 * read BITMAP CORE HEADER
		 */
		private function readCoreHeader():void
		{
			var coreHeader:ByteArray = new ByteArray();
			coreHeader.endian = Endian.LITTLE_ENDIAN;
			try
			{
				bytes.readBytes(coreHeader, 0, BITMAP_CORE_HEADER_SIZE - 4);
				nWidth = coreHeader.readShort();
				nHeight = coreHeader.readShort();
				nPlains = coreHeader.readUnsignedShort();
				nBitsPerPixel = coreHeader.readUnsignedShort();
			}
			catch (e:IOError)
			{
				throw new VerifyError("BMPDecoder: Invalid core header.");
			}
		}
		
		
		/**
		 * read BITMAP INFO HEADER
		 */
		private function readInfoHeader():void
		{
			var infoHeader:ByteArray = new ByteArray();
			infoHeader.endian = Endian.LITTLE_ENDIAN;
			try
			{
				bytes.readBytes(infoHeader, 0, BITMAP_INFO_HEADER_SIZE - 4);
				nWidth = infoHeader.readInt();
				nHeight = infoHeader.readInt();
				nPlains = infoHeader.readUnsignedShort();
				nBitsPerPixel = infoHeader.readUnsignedShort();
				nCompression = infoHeader.readUnsignedInt();
				nSizeImage = infoHeader.readUnsignedInt();
				nXPixPerMeter = infoHeader.readInt();
				nYPixPerMeter = infoHeader.readInt();
				nColorUsed = infoHeader.readUnsignedInt();
				nColorImportant = infoHeader.readUnsignedInt();
			}
			catch (e:IOError)
			{
				throw new VerifyError("BMPDecoder: Invalid info header.");
			}
		}
		
		
		/**
		 * read the extend info of BITMAP INFO HEADER
		 */
		private function readExtendedInfoHeader():void
		{
			var infoHeader:ByteArray = new ByteArray();
			infoHeader.endian = Endian.LITTLE_ENDIAN;
			try
			{
				bytes.readBytes(infoHeader, 0, nInfoSize - 4);
				nWidth = infoHeader.readInt();
				nHeight = infoHeader.readInt();
				nPlains = infoHeader.readUnsignedShort();
				nBitsPerPixel = infoHeader.readUnsignedShort();
				nCompression = infoHeader.readUnsignedInt();
				nSizeImage = infoHeader.readUnsignedInt();
				nXPixPerMeter = infoHeader.readInt();
				nYPixPerMeter = infoHeader.readInt();
				nColorUsed = infoHeader.readUnsignedInt();
				nColorImportant = infoHeader.readUnsignedInt();
				if (infoHeader.bytesAvailable >= 4) nRMask = infoHeader.readUnsignedInt();
				if (infoHeader.bytesAvailable >= 4) nGMask = infoHeader.readUnsignedInt();
				if (infoHeader.bytesAvailable >= 4) nBMask = infoHeader.readUnsignedInt();
			}
			catch (e:IOError)
			{
				throw new VerifyError("BMPDecoder: Invalid info header.");
			}
		}
		
		
		/**
		 * read bitfields
		 */
		private function readBitFields():void
		{
			if (nCompression == COMP_RGB)
			{
				if (nBitsPerPixel == BIT16)
				{
					// RGB555
					nRMask = 0x00007c00;
					nGMask = 0x000003e0;
					nBMask = 0x0000001f;
				}
				else
				{
					// RGB888;
					nRMask = 0x00ff0000;
					nGMask = 0x0000ff00;
					nBMask = 0x000000ff;
				}
			}
			else if ((nCompression == COMP_BITFIELDS) && (nInfoSize < 52))
			{
				try
				{
					nRMask = bytes.readUnsignedInt();
					nGMask = bytes.readUnsignedInt();
					nBMask = bytes.readUnsignedInt();
				}
				catch (e:IOError)
				{
					throw new VerifyError("BMPDecoder: Invalid bit fields.");
				}
			}
		}
		
		
		/**
		 * read color palette
		 */
		private function readColorPalette():void
		{
			var len:uint = (nColorUsed > 0) ? nColorUsed : Math.pow(2, nBitsPerPixel);
			palette = new Array(len);
			for (var i:uint = 0; i < len; ++i)
			{
				palette[i] = bytes.readUnsignedInt();
			}
		}
		
		
		/**
		 * decode 1 bit BMP
		 */
		private function decode1BitBMP():void
		{
			var x:int;
			var y:int;
			var i:int;
			var col:int;
			var buf:ByteArray = new ByteArray();
			var line:int = nWidth / 8;
			if (line % 4 > 0)
			{
				line = ((line / 4 | 0) + 1) * 4;
			}
			try
			{
				for (y = nHeight - 1; y >= 0; --y)
				{
					buf.length = 0;
					bytes.readBytes(buf, 0, line);
					for (x = 0; x < nWidth; x += 8)
					{
						col = buf.readUnsignedByte();
						for (i = 0; i < 8; ++i)
						{
							bd.setPixel(x + i, y, palette[col >> (7 - i) & 0x01]);
						}
					}
				}
			}
			catch (e:IOError)
			{
				throw new VerifyError("BMPDecoder: Invalid image data.");
			}
		}
		
		
		/**
		 * decode 4bit RLE
		 */
		private function decode4bitRLE():void
		{
			var x:int;
			var y:int;
			var i:int;
			var n:int;
			var col:int;
			var data:uint;
			var buf:ByteArray = new ByteArray();
			try
			{
				for (y = nHeight - 1; y >= 0; --y)
				{
					buf.length = 0;
					while (bytes.bytesAvailable > 0)
					{
						n = bytes.readUnsignedByte();
						if (n > 0)
						{
							// encode data
							data = bytes.readUnsignedByte();
							for (i = 0; i < n / 2; ++i)
							{
								buf.writeByte(data);
							}
						}
						else
						{
							n = bytes.readUnsignedByte();
							if (n > 0)
							{
								// abs mode
								bytes.readBytes(buf, buf.length, n / 2);
								buf.position += n / 2;
								if (n / 2 + 1 >> 1 << 1 != n / 2)
								{
									bytes.readUnsignedByte();
								}
							}
							else
							{
								// EOL
								break;
							}
						}
					}
					buf.position = 0;
					for (x = 0; x < nWidth; x += 2)
					{
						col = buf.readUnsignedByte();
						bd.setPixel(x, y, palette[col >> 4]);
						bd.setPixel(x + 1, y, palette[col & 0x0f]);
					}
				}
			}
			catch (e:IOError)
			{
				throw new VerifyError("BMPDecoder: Invalid image data.");
			}
		}
		
		
		/**
		 * decode 4bit (no Compression)
		 */
		private function decode4BitBMP():void
		{
			var x:int;
			var y:int;
			var i:int;
			var col:int;
			var buf:ByteArray = new ByteArray();
			var line:int = nWidth / 2;
			if ( line % 4 > 0 )
			{
				line = ( ( line / 4 | 0 ) + 1 ) * 4;
			}
			try
			{
				for ( y = nHeight - 1; y >= 0; --y )
				{
					buf.length = 0;
					bytes.readBytes(buf, 0, line);
					for ( x = 0; x < nWidth; x += 2 )
					{
						col = buf.readUnsignedByte();
						bd.setPixel(x, y, palette[ col >> 4 ]);
						bd.setPixel(x + 1, y, palette[ col & 0x0f ]);
					}
				}
			}
			catch ( e:IOError )
			{
				throw new VerifyError("BMPDecoder: Invalid image data.");
			}
		}


		/**
		 * decode 8bit( RLE Compression )
		 */
		private function decode8BitRLE():void
		{
			var x:int;
			var y:int;
			var i:int;
			var n:int;
			var col:int;
			var data:uint;
			var buf:ByteArray = new ByteArray();
			try
			{
				for ( y = nHeight - 1; y >= 0; --y )
				{
					buf.length = 0;
					while ( bytes.bytesAvailable > 0 )
					{
						n = bytes.readUnsignedByte();
						if ( n > 0 )
						{
							// encode data
							data = bytes.readUnsignedByte();
							for ( i = 0; i < n; ++i )
							{
								buf.writeByte(data);
							}
						}
						else
						{
							n = bytes.readUnsignedByte();
							if ( n > 0 )
							{
								// abs mode data
								bytes.readBytes(buf, buf.length, n);
								buf.position += n;
								if ( n + 1 >> 1 << 1 != n )
								{
									bytes.readUnsignedByte();
								}
							}
							else
							{
								// EOL
								break;
							}
						}
					}
					buf.position = 0;
					for ( x = 0; x < nWidth; ++x )
					{
						bd.setPixel(x, y, palette[ buf.readUnsignedByte() ]);
					}
				}
			}
			catch ( e:IOError )
			{
				throw new VerifyError("BMPDecoder: Invalid image data.");
			}
		}


		/**
		 * decode 8bit(no Compression)
		 */
		private function decode8BitBMP():void
		{
			var x:int;
			var y:int;
			var i:int;
			var col:int;
			var buf:ByteArray = new ByteArray();
			var line:int = nWidth;
			if ( line % 4 > 0 )
			{
				line = ( ( line / 4 | 0 ) + 1 ) * 4;
			}
			try
			{
				for ( y = nHeight - 1; y >= 0; --y )
				{
					buf.length = 0;
					bytes.readBytes(buf, 0, line);
					for ( x = 0; x < nWidth; ++x )
					{
						bd.setPixel(x, y, palette[ buf.readUnsignedByte() ]);
					}
				}
			}
			catch ( e:IOError )
			{
				throw new VerifyError("BMPDecoder: Invalid image data.");
			}
		}


		/**
		 * decode 16bit
		 */
		private function decode16BitBMP():void
		{
			var x:int;
			var y:int;
			var col:int;
			try
			{
				for ( y = nHeight - 1; y >= 0; --y )
				{
					for ( x = 0; x < nWidth; ++x )
					{
						col = bytes.readUnsignedShort();
						bd.setPixel(x, y, ( ( ( col & nRMask ) >> nRPos ) * 0xff / nRMax << 16 ) + ( ( ( col & nGMask ) >> nGPos ) * 0xff / nGMax << 8 ) + ( ( ( col & nBMask ) >> nBPos ) * 0xff / nBMax << 0 ));
					}
				}
			}
			catch ( e:IOError )
			{
				throw new VerifyError("BMPDecoder: Invalid image data.");
				throw new VerifyError("invalid image data");
			}
		}


		/**
		 * decode 24bit BMP
		 */
		private function decode24BitBMP():void
		{
			var x:int;
			var y:int;
			var col:int;
			var buf:ByteArray = new ByteArray();
			var line:int = nWidth * 3;
			if ( line % 4 > 0 )
			{
				line = ( ( line / 4 | 0 ) + 1 ) * 4;
			}
			try
			{
				for ( y = nHeight - 1; y >= 0; --y )
				{
					buf.length = 0;
					bytes.readBytes(buf, 0, line);
					for ( x = 0; x < nWidth; ++x )
					{
						bd.setPixel(x, y, buf.readUnsignedByte() + ( buf.readUnsignedByte() << 8 ) + ( buf.readUnsignedByte() << 16 ));
					}
				}
			}
			catch ( e:IOError )
			{
				throw new VerifyError("invalid image data");
			}
		}


		/**
		 * decode 32bit BMP
		 */
		private function decode32BitBMP():void
		{
			var x:int;
			var y:int;
			var col:int;
			try
			{
				for ( y = nHeight - 1; y >= 0; --y )
				{
					for ( x = 0; x < nWidth; ++x )
					{
						col = bytes.readUnsignedInt();
						bd.setPixel(x, y, ( ( ( col & nRMask ) >> nRPos ) * 0xff / nRMax << 16 ) + ( ( ( col & nGMask ) >> nGPos ) * 0xff / nGMax << 8 ) + ( ( ( col & nBMask ) >> nBPos ) * 0xff / nBMax << 0 ));
					}
				}
			}
			catch ( e:IOError )
			{
				throw new VerifyError("invalid image data");
			}
		}


		/**
		 * check color mask
		 */
		private function checkColorMask():void
		{
			if ( ( nRMask & nGMask ) | ( nGMask & nBMask ) | ( nBMask & nRMask ) )
			{
				throw new VerifyError("invalid bit fields");
			}
			while ( ( ( nRMask >> nRPos ) & 0x00000001 ) == 0 )
			{
				nRPos++;
			}
			while ( ( ( nGMask >> nGPos ) & 0x00000001 ) == 0 )
			{
				nGPos++;
			}
			while ( ( ( nBMask >> nBPos ) & 0x00000001 ) == 0 )
			{
				nBPos++;
			}
			nRMax = nRMask >> nRPos;
			nGMax = nGMask >> nGPos;
			nBMax = nBMask >> nBPos;
		}
	}
}
