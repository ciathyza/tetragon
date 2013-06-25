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
package tetragon.core.file.types
{
	import flash.utils.ByteArray;
	
	
	/**
	 * A zip entry represents a file that is contained inside a loaded or generated zip
	 * file. The ZipFile class and the ZipLoader class use zip entries to manage the files
	 * that are packed inside the zip file they've opened.<br>
	 * 
	 * <p>You normally don't need to use this class directly unless you want to add zip
	 * entries manually to a new ZipFile object.</p>
	 * 
	 * @see com.hexagonstar.file.types.ZipFile
	 * @see com.hexagonstar.file.ZipLoader
	 */
	public class ZipEntry
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _path:String;
		/** @private */
		private var _data:ByteArray;
		/** @private */
		private var _zipFile:ZipFile;
		
		/** @private */
		private var _size:Number;
		/** @private */
		private var _compressedSize:Number;
		/** @private */
		private var _crc:uint;
		/** @private */
		private var _method:int;
		/** @private */
		private var _extra:ByteArray;
		/** @private */
		private var _comment:String;
		
		/** @private */
		public var dostime:uint;
		/** @private */
		public var flag:uint;		// bit flags
		/** @private */
		public var version:uint;	// version needed to extract
		/** @private */
		public var offset:uint;		// offset of loc header
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of ZipEntry.
		 * 
		 * @param path The path of the zip entry.
		 * @param data The content data of the zip entry. Only needs to be set if this file is
		 *            created manually. For any zip entry that is fetched from a loaded zip
		 *            file the zip file will care about providing the data.
		 * @param zipFile A reference to the zip file to which this file belongs. This is used
		 *            by the ZipFile class.
		 */
		public function ZipEntry(path:String, data:ByteArray = null, zipFile:ZipFile = null)
		{
			_path = path;
			_data = data;
			_zipFile = zipFile;
			
			_size = NaN;
			_compressedSize = NaN;
			_method = -1;
			dostime = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The path of the zip entry.
		 */
		public function get path():String
		{
			return _path;
		}
		
		
		/**
		 * The time of last modification of the entry, or -1 if unknown.
		 */
		public function get time():Number
		{
			var d:Date = new Date(((dostime >> 25) & 0x7f) + 1980, ((dostime >> 21) & 0x0f) - 1,
				(dostime >> 16) & 0x1f, (dostime >> 11) & 0x1f, (dostime >> 5) & 0x3f,
				(dostime & 0x1f) << 1);
			return d.time;
		}
		public function set time(v:Number):void
		{
			var d:Date = new Date(v);
			dostime = (d.fullYear - 1980 & 0x7f) << 25 | (d.month + 1) << 21 | d.day << 16
				| d.hours << 11 | d.minutes << 5 | d.seconds >> 1;
		}
		
		
		/**
		 * The size of the zip entry's uncompressed data.
		 */
		public function get size():Number
		{
			return _size;
		}
		public function set size(v:Number):void
		{
			_size = v;
		}
		
		
		/**
		 * The size of the zip entry's compressed data.
		 */
		public function get compressedSize():Number
		{
			return _compressedSize;
		}
		public function set compressedSize(v:Number):void
		{
			_compressedSize = v;
		}
		
		
		/**
		 * The compression ratio of the zip entry in percent. The ratio represents by how much
		 * percent a zip entry could be compressed. The higher this value, the more the data
		 * is compressed.
		 */
		public function get ratio():Number
		{
			if (isDirectory) return 0;
			if (_compressedSize + _size == 0) return 0;
			var r:Number = ZipEntry.round((100 - (_compressedSize / _size) * 100), 1);
			if (r < 0) return 0;
			return r;
		}
		
		
		/**
		 * The CRC32 checksum of the zip entry's uncompressed data.
		 */
		public function get crc32():uint
		{
			return _crc;
		}
		public function set crc32(v:uint):void
		{
			_crc = v;
		}
		
		
		/**
		 * A convenience getter to return the CRC32 checksum as a hexadecimal string.
		 */
		public function get crc32hex():String
		{
			return _crc.toString(16).toUpperCase();
		}
		
		
		/**
		 * The zip entry's compression method. Only DEFLATE and STORE are supported.
		 */
		public function get compressionMethod():int
		{
			return _method;
		}
		public function set compressionMethod(v:int):void
		{
			_method = v;
		}
		
		
		/**
		 * The zip entry's extra data.
		 */
		public function get extra():ByteArray
		{
			return _extra;
		}
		public function set extra(v:ByteArray):void
		{
			_extra = v;
		}
		
		
		/**
		 * The zip entry's comment data.
		 */
		public function get comment():String
		{
			return _comment;
		}
		public function set comment(v:String):void
		{
			_comment = v;
		}
		
		
		/**
		 * The content data of the zip entry.
		 */
		public function get data():ByteArray
		{
			/* The zip entry has it's own data. */
			if (_data) return _data;
			/* The zip entry is loaded from a zip file and it's data is stored in the zip file */
			if (_zipFile) return _zipFile.getData(_path);
			return null;
		}
		
		
		/**
		 * Determines if the zip entry is an empty directory stored in the container zip file.
		 * This is solely determined by the path string, a trailing slash "/" marks an empty
		 * directory.
		 */
		public function get isDirectory():Boolean
		{
			return _path.charAt(_path.length - 1) == "/";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected static function round(value:Number, decimals:int = 0):Number
		{
			var p:Number = Math.pow(10, decimals);
			return Math.round(value * p) / p;
		}
	}
}
