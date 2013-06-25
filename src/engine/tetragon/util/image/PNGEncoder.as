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
package tetragon.util.image
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;


	public final class PNGEncoder implements IImageEncoder
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private static var _crcTable:Vector.<uint>;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Created a PNG image from the specified BitmapData
		 *
		 * @param image The BitmapData that will be converted into the PNG format.
		 * @return a ByteArray representing the PNG encoded image data.
		 */
		public function encode(image:BitmapData):ByteArray
		{
			// Create output byte array
			var png:ByteArray = new ByteArray();
			
			// Write PNG signature
			png.writeUnsignedInt(0x89504e47);
			png.writeUnsignedInt(0x0D0A1A0A);
			
			// Build IHDR chunk
			var IHDR:ByteArray = new ByteArray();
			IHDR.writeInt(image.width);
			IHDR.writeInt(image.height);
			IHDR.writeUnsignedInt(0x08060000);
			
			// 32bit RGBA
			IHDR.writeByte(0);
			writeChunk(png, 0x49484452, IHDR);
			
			// Build IDAT chunk
			var IDAT:ByteArray = new ByteArray();
			
			for (var i:int = 0; i < image.height; i++)
			{
				// no filter
				IDAT.writeByte(0);
				var p:uint;
				var j:int;
				
				if (!image.transparent)
				{
					for (j = 0; j < image.width; j++)
					{
						p = image.getPixel(j, i);
						IDAT.writeUnsignedInt(uint(((p & 0xFFFFFF) << 8) | 0xFF));
					}
				}
				else
				{
					for (j = 0; j < image.width; j++)
					{
						p = image.getPixel32(j, i);
						IDAT.writeUnsignedInt(uint(((p & 0xFFFFFF) << 8) | (p >>> 24)));
					}
				}
			}
			
			IDAT.compress();
			writeChunk(png, 0x49444154, IDAT);
			
			// Build IEND chunk
			writeChunk(png, 0x49454E44, null);
			
			return png;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private static function writeChunk(png:ByteArray, type:uint, data:ByteArray):void
		{
			if (!_crcTable) createCRCTable();
			
			var len:uint = (data) ? data.length : 0;
			png.writeUnsignedInt(len);
			var p:uint = png.position;
			png.writeUnsignedInt(type);
			if (data) png.writeBytes(data);
			var e:uint = png.position;
			png.position = p;
			var c:uint = 0xffffffff;
			
			for (var i:int = 0; i < (e - p); i++)
			{
				c = uint(_crcTable[(c ^ png.readUnsignedByte()) & uint(0xff)] ^ uint(c >>> 8));
			}
			
			c = uint(c ^ uint(0xffffffff));
			png.position = e;
			png.writeUnsignedInt(c);
		}
		
		
		private static function createCRCTable():void
		{
			_crcTable = new Vector.<uint>(256, true);
			for (var n:uint = 0; n < 256; n++)
			{
				var c:uint = n;
				for (var k:uint = 0; k < 8; k++)
				{
					if (c & 1) c = uint(uint(0xedb88320) ^ uint(c >>> 1));
					else c = uint(c >>> 1);
				}
				_crcTable[n] = c;
			}
		}
	}
}
