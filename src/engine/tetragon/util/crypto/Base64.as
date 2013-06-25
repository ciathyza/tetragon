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
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	
	/**
	 * A utility class that allows for encoding data to base64 and decoding of base64-
	 * encoded data back to it's binary form. This class offers several comfortable
	 * methods to encode and decode from various data types and is faster than Adobe's
	 * corelib Base64 implementation.
	 * 
	 * @author hexagonstar
	 */
	public final class Base64
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private static var encodeChars:Vector.<int>;
		private static var decodeChars:Vector.<int>;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Encodes bytes into a base64-encoded string and returns the resulting data
		 * as a ByteArray.
		 * 
		 * @param bytes The binary data to encode into base64 data.
		 * @return The base64-encoded data as a ByteArray.
		 */
		public static function encode(bytes:ByteArray):ByteArray
		{
			if (!encodeChars) createCharTables();
			
			var out:ByteArray = new ByteArray();
			out.length = (2 + bytes.length - ((bytes.length + 2) % 3)) * 4 / 3;
			
			var i:int = 0;
			var r:int = bytes.length % 3;
			var len:int = bytes.length - r;
			var c:int;
			
			while (i < len)
			{
				c = bytes[i++] << 16 | bytes[i++] << 8 | bytes[i++];
				c = (encodeChars[c >>> 18] << 24) | (encodeChars[c >>> 12 & 0x3f] << 16)
					| (encodeChars[c >>> 6 & 0x3f] << 8) | encodeChars[c & 0x3f];

				// Optimization: On older and slower computer, do one write Int instead
				// of 4 write byte: 1.5 to 0.71 ms
				out.writeInt(c);
				//﻿out.writeByte(_encodeChars[c >> 18] );
				//﻿out.writeByte(_encodeChars[c >> 12 & 0x3f]);
				//﻿out.writeByte(_encodeChars[c >> 6 & 0x3f]);
				//﻿out.writeByte(_encodeChars[c & 0x3f]);﻿  ﻿  
			}
			
			if (r == 1)
			{
				c = bytes[i];
				c = (encodeChars[c >>> 2] << 24) | (encodeChars[(c & 0x03) << 4] << 16)
					| 61 << 8 | 61;
				out.writeInt(c);
			}
			else if (r == 2)
			{
				c = bytes[i++] << 8 | bytes[i];
				c = (encodeChars[c >>> 10] << 24) | (encodeChars[c >>> 4 & 0x3f] << 16)
					| (encodeChars[(c & 0x0f) << 2] << 8) | 61;
				out.writeInt(c);
			}
			
			out.position = 0;
			return out;
		}
		
		
		/**
		 * Encodes bytes into a base64-encoded string. This method returns a
		 * String instead of a ByteArray.
		 * 
		 * @param bytes The binary data to encode into a base64 String.
		 * @return The base64-encoded string.
		 */
		public static function encodeToString(data:*):String
		{
			if (data == null) return null;
			var bytes:ByteArray;
			if (data is String)
			{
				bytes = new ByteArray();
				bytes.writeUTFBytes(data);
			}
			else if (data is ByteArray)
			{
				bytes = data;
			}
			else
			{
				return null;
			}
			var out:ByteArray = encode(bytes);
			return out.readUTFBytes(out.length);
		}
		
		
		/**
		 * Encodes a String object to a base64-encoded string. Instead of a
		 * ByteArray this method takes a String as the parameter.
		 * 
		 * @param string The string to encode to base64.
		 * @param string A base64-encoded string as a ByteArray.
		 */
		public static function encodeFromString(string:String):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(string);
			return encode(bytes);
		}
		
		
		/**
		 * Encodes a BitmapData object to a base64-encoded ByteArray.
		 * 
		 * @param bitmapData The BitmapData object to encode as base64.
		 * @return A base64-encoded ByteArray.
		 */
		public static function encodeFromBitmapData(bitmapData:BitmapData):ByteArray
		{
			if (!bitmapData) return null;
			var bytes:ByteArray = bitmapData.getPixels(bitmapData.rect);
			bytes.writeShort(bitmapData.width);
			bytes.writeShort(bitmapData.height);
			bytes.writeBoolean(bitmapData.transparent);
			bytes.compress();
			return encode(bytes);
		}
		
		
		/**
		 * Decodes a base64-encoded string back into binary data.
		 * 
		 * @param bytes A ByteArray of base64-encoded data.
		 * @return A Bytearray that contains the decoded data.
		 */
		public static function decode(bytes:ByteArray):ByteArray
		{
			if (!encodeChars) createCharTables();
			
			var c1:int;
			var c2:int;
			var c3:int;
			var c4:int;
			var i:int = 0;
			var len:int = bytes.length;
			var out:ByteArray = new ByteArray();
			
			while (i < len)
			{
				do
				{
					c1 = decodeChars[bytes[i++]];
				}
				while (i < len && c1 == -1);
				if (c1 == -1) break;
				
				do
				{
					c2 = decodeChars[bytes[i++]];
				}
				while (i < len && c2 == -1);
				if (c2 == -1) break;
				out.writeByte((c1 << 2) | ((c2 & 0x30) >> 4));
				
				do
				{
					c3 = bytes[i++];
					if (c3 == 61) return out;

					c3 = decodeChars[c3];
				}
				while (i < len && c3 == -1);
				if (c3 == -1) break;
				out.writeByte(((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2));
				
				do
				{
					c4 = bytes[i++];
					if (c4 == 61) return out;
					c4 = decodeChars[c4];
				}
				while (i < len && c4 == -1);
				if (c4 == -1) break;
				out.writeByte(((c3 & 0x03) << 6) | c4);
			}
			
			return out;
		}
		
		
		/**
		 * Decodes base64-encoded data to a String object. Instead of
		 * returning a ByteArray this method returns a String. The specified
		 * data must be either of type String or of type ByteArray.
		 * 
		 * @param data The base64-erncoded data to decode, as String or ByteArray.
		 * @return The decoded string.
		 */
		public static function decodeToString(data:*):String
		{
			if (data == null) return null;
			var bytes:ByteArray;
			if (data is String) bytes = decodeFromString(data);
			else if (data is ByteArray) bytes = data;
			else return null;
			return bytes.readUTFBytes(bytes.length);
		}
		
		
		/**
		 * Decodes base64-encoded image data to a BitmapData object. The specified
		 * data must be either of type String or of type ByteArray.
		 * 
		 * @param data Image data to decode, as String or ByteArray.
		 * @return A BitmapData object of the decoded image data.
		 */
		public static function decodeToBitmapData(data:*):BitmapData
		{
			if (data == null) return null;
			var bytes:ByteArray;
			if (data is String) bytes = decodeFromString(data);
			else if (data is ByteArray) bytes = data;
			else return null;
			
			bytes.uncompress();
			if (bytes.length < 6)
			{
				throw new Error("Base64: Image parameter in decoded bytes are invalid.");
				return null;
			}
			
			bytes.position = bytes.length - 1;
			var transparent:Boolean = bytes.readBoolean();
			bytes.position = bytes.length - 3;
			var height:int = bytes.readShort();
			bytes.position = bytes.length - 5;
			var width:int = bytes.readShort();
			bytes.position = 0;
			var imageBytes:ByteArray = new ByteArray();
			bytes.readBytes(imageBytes, 0, bytes.length - 5);
			var bmp:BitmapData = new BitmapData(width, height, transparent, 0);
			bmp.setPixels(new Rectangle(0, 0, width, height), imageBytes);
			return bmp;
		}
		
		
		/**
		 * Decodes a base64-encoded string back into binary data. Instead of a
		 * ByteArray this method takes a String as the parameter.
		 * 
		 * @param string A String of base64-encoded data.
		 * @return A Bytearray that contains the decoded data.
		 */
		public static function decodeFromString(string:String):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(string);
			return decode(bytes);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private static function createCharTables():void
		{
			encodeChars = new Vector.<int>(64, true);
			var chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
			for (var i:int = 0; i < 64; i++)
			{
				encodeChars[i] = chars.charCodeAt(i);
			}
			
			decodeChars = new Vector.<int>();
			decodeChars.push(	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, 62, -1, -1, -1, 63, 52, 53,
								54, 55, 56, 57, 58, 59, 60, 61, -1, -1,
								-1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6,
								7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
								18, 19, 20, 21, 22, 23, 24, 25, -1, -1,
								-1, -1, -1, -1, 26, 27, 28, 29, 30, 31,
								32, 33, 34, 35, 36, 37, 38, 39, 40, 41,
								42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
								-1, -1, -1, -1, -1 - 1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
								-1, -1, -1);
		}
	}
}
