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
package tetragon.core.file.types
{
	import tetragon.core.constants.Status;
	import tetragon.core.constants.ZipConstants;
	import tetragon.core.file.FileTypes;
	import tetragon.util.compr.Inflate;
	import tetragon.util.string.TabularText;

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	
	/**
	 * The ZipFile represents an archive of compressed files. It can be used to load a zip
	 * file into memory and unpack it's contents or to create a zip file object to which
	 * data is added and compressed so it can later be stored to disk.<br>
	 * 
	 * <p>NOTE: This class does not allow to use the same instance for both loading and
	 * creation of zip files, i.e. you cannot load a zip file from disk and then add new
	 * data to it. You have to use two different ZipFile objects for this.</p><br>
	 * 
	 * <b>Limitations:</b>
	 * <ul>
	 *     <li>No Encyption support</li>
	 *     <li>Standard ASCII character file paths only</li>
	 *     <li>Deflate compression and Store methods only</li>
	 * </ul>
	 * 
	 * @see com.hexagonstar.file.types.IFile
	 * @see com.hexagonstar.file.types.ZipEntry
	 * @see com.hexagonstar.file.types.ZipGenerator
	 */
	public class ZipFile extends BinaryFile implements IFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _fileList:Array;
		/** @private */
		private var _fileTable:Dictionary;
		/** @private */
		private var _locOffsetTable:Dictionary;
		/** @private */
		private var _fileCount:uint;
		/** @private */
		private var _hasLoadedData:Boolean;
		
		/** @private */
		private var _generator:ZipGenerator;
		/** @private */
		private var _autoCompression:Boolean;
		/** @private */
		private var _comment:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param path The path of the file that this ZipFile object is used for.
		 * @param id An optional ID for the file.
		 * @param priority Optional load priority for the file. Used for loading with the
		 *            BulkLoader.
		 * @param weight Optional weight for the file. Used for weighted loading with the
		 *            BulkLoader.
		 * @param callback An optional callback method that can be associated with the file.
		 * @param params An optional array of parameters that can be associated with the file.
		 * @param comment Optional text used as the zip file's comment, only used for zip
		 *            generation.
		 */
		public function ZipFile(path:String = null, id:String = null, priority:Number = NaN,
			weight:int = 1, callback:Function = null, params:Array = null, comment:String = null)
		{
			super(path, id, priority, weight, callback, params);
			
			_comment = comment;
			
			_content = new ByteArray();
			_content.endian = Endian.LITTLE_ENDIAN;
			
			_fileList = [];
			_fileTable = new Dictionary();
			_locOffsetTable = new Dictionary();
			_hasLoadedData = false;
			
			_autoCompression = true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Gets the file object that is contained in the zip file under the specified path as
		 * an instance of a file type class that implements IFile. Use this method to quickly
		 * obtain a packed file from the zip file in it's correctly typed File class.<br>
		 * 
		 * <p>The type of the resulting file is determined by the file extension of the file's
		 * path (see <code>FileTypes</code> class for a list of default extensions). The
		 * resulting file contains the unpacked data from the zipped file that is stored under
		 * the path in the zip file.</p><br>
		 * 
		 * <p>If the specified path is not found in the zip file or the specified path's entry
		 * is a directory, <code>null</code> is returned. If the path was found in the zip
		 * file but it's extension is not known, a BinaryFile is created by default.</p><br>
		 * 
		 * <p>This method returns an object of type IFile. However as it cannot be assured
		 * that the file's data is fully loaded after the method returns, you should instead
		 * listen to the <code>FileIOEvent.COMPLETE</code> event broadcasted by this class
		 * which is fired after the file has been fully loaded. The event then contains a
		 * reference to the loaded file.</p>
		 * 
		 * @see com.hexagonstar.file.FileTypes
		 * @see com.hexagonstar.file.types.IFile
		 * 
		 * @param path The path of a file stored inside the zip file of which a new instance
		 *            of type IFile should be loaded. The path must be relative and exacrly
		 *            match that of the file stored inside the zip.
		 * 
		 * @return An object of type IFile or <code>null</code>.
		 */
		public function getFile(path:String):IFile
		{
			var e:ZipEntry = getEntry(path);
			if (!e || e.isDirectory) return null;
			
			var f:IFile;
			var ext:String = path.substring(path.lastIndexOf(".") + 1).toLowerCase();
			var clazz:Class = FileTypes.getFileClass(ext);
			if (!clazz) clazz = BinaryFile;
			
			try
			{
				f = new clazz(path);
			}
			catch (err:Error)
			{
				error("getFile: Error trying to instantiate file class (" + err.message + ").");
				return null;
			}
			
			if (f)
			{
				f.bytesLoaded = e.size;
				f.completeSignal.addOnce(onFileReady);
				f.contentAsBytes = getData(path);
			}
			
			return f;
		}
		
		
		/**
		 * Gets a ByteArray with the uncompressed data from the file that is contained in the
		 * ZipFile under the specified path.<br>
		 * 
		 * <p>If the requested data is compressed with an unsupported algorythm (i.e. not
		 * Deflate and not Stored), <code>null</code> is returned. You can check the
		 * <code>valid</code> and <code>status</code> properties to check for any errors.</p>
		 * 
		 * @param path The path of a file contained inside the zip file from which the
		 *            uncompressed data should be returned.
		 * @return A byte array, or <code>null</code> if the requested file was not found
		 *         inside the zip file.
		 */
		public function getData(path:String):ByteArray
		{
			var e:ZipEntry = getEntry(path);
			if (!e || e.isDirectory) return null;
			
			/* Extra field for local file header may not match one in central directory header */
			_content.position = _locOffsetTable[e.path] + ZipConstants.LOCHDR - 2;
			
			/* Extra length */
			var len:uint = _content.readShort();
			_content.position += e.path.length + len;
			var b1:ByteArray = new ByteArray();
			
			/* Read compressed data */
			if (e.compressedSize > 0)
			{
				_content.readBytes(b1, 0, e.compressedSize);
			}
			
			switch (e.compressionMethod)
			{
				case ZipConstants.STORE:
					return b1;
					break;
				case ZipConstants.DEFLATE:
					var b2:ByteArray = new ByteArray();
					new Inflate().process(b1, b2);
					return b2;
					break;
				default:
					error("getData: The compression method used by the zip entry <"
						+ e.path + "> is not supported. The zip file class only"
						+ " supports STORE and DEFLATE compression methods.");
			}
			
			return null;
		}
		
		
		/**
		 * Returns the zip entry that is stored in the zip file under the specified path. If
		 * there is no entry stored under the path, <code>null</code> is returned instead.
		 * 
		 * @see com.hexagonstar.file.types.ZipEntry
		 * 
		 * @param path The path of the zip entry. May contain directory components separated
		 *            by slashes ("/").
		 * @return The zip entry, or <code>null</code> if no entry with that path exists in
		 *         the zip.
		 */
		public function getEntry(path:String):ZipEntry
		{
			return _fileTable[path];
		}
		
		
		/**
		 * Adds a new entry for storing data inside the ZipFile. This operation adds a newly
		 * created ZipEntry object with the specified path and data to the ZipFile.<br>
		 * 
		 * <p>Note that this operation only works on a fresh ZipFile instance into that no
		 * data has been loaded before.</p>
		 * 
		 * @see com.hexagonstar.file.types.ZipEntry
		 * 
		 * @param path The path under which to store the file data inside the ZipFile.
		 * @param data The file data to be compressed or stored.
		 * @return <code>true</code> if the file entry was added successfully,
		 *         <code>false</code> if not.
		 */
		public function addFile(path:String, data:ByteArray):Boolean
		{
			return addEntry(new ZipEntry(path, data, this));
		}
		
		
		/**
		 * Adds a new entry for storing an empty folder in the ZipFile. This operation adds a
		 * newly created ZipEntry object to the ZipFile that represents a folder which
		 * contains no files.<br>
		 * 
		 * <p>An empty folder is recognized by having a path that ends with a slash ("/") on
		 * the right side. If the given path doesn't end with a slash this method will add one
		 * automatically to the end of the string.</p>
		 * 
		 * @see com.hexagonstar.file.types.ZipEntry
		 * 
		 * @param path The path under which to store the empty folder inside the ZipFile.
		 * @return <code>true</code> if the file entry was added successfully,
		 *         <code>false</code> if not.
		 */
		public function addFolder(path:String):Boolean
		{
			if (path.charAt(_path.length - 1) != "/") path += "/";
			return addEntry(new ZipEntry(path, null, this));
		}
		
		
		/**
		 * Adds a new entry for storing data inside the zip file provided by the specified zip
		 * entry. This operation should be used to quickly copy a zip entry object from one
		 * zip file to a new zip file since no data is contained in a zip entry object which
		 * was not obtained from a zip file. For creating completely new zip files with new
		 * data use the addFile method.
		 * 
		 * @see com.hexagonstar.file.types.ZipEntry
		 * 
		 * @param file The ZipEntry to add to the ZipFile.
		 * @return <code>true</code> if the entry was added successfully, <code>false</code>
		 *         if not.
		 */
		public function addEntry(file:ZipEntry):Boolean
		{
			/* No go if we already got content loaded from a file or the ZipFile has
			 * been finalized (which would mean we have to store the central dir buffer
			 * separately and attach it back on anytime a file. */
			if (_hasLoadedData || (_generator && _generator.finalized))
			{
				return false;
			}
			
			/* Only instantiate when first needed. */
			if (!_generator)
			{
				_generator = new ZipGenerator(this, _content, _fileList, _autoCompression);
			}
			
			return _generator.addEntry(file);
		}
		
		
		/**
		 * Finalizes the ZipFile after zip entries were added manually. You must call this
		 * method after all zip entries were added to generate a valid zip format that can be
		 * stored as a standard zip file. After calling this method yuo cannot add any more
		 * entries to this zip file.<br>
		 * 
		 * <p>A call to this method has no effect if the zip file was loaded or contains no
		 * zip entries.</p>
		 */
		public function finalize():void
		{
			if (_hasLoadedData || _fileList.length < 1) return;
			if (!_generator) return;
			if (_generator.finalized) return;

			_generator.finalize(_comment);
		}
		
		
		/**
		 * Generates a formatted string output of the zip file's content list.
		 * 
		 * @param colMaxLength Max. length of a text column in the resulting string.
		 * @return A string dump of the zip's contents.
		 */
		public function dump(colMaxLength:int = 40):String
		{
			var ct:TabularText = new TabularText(5, false, null, null, null, colMaxLength,
				["PATH", "SIZE", "PACKED", "RATIO", "CRC32"]);
			for (var i:int = 0; i < _fileList.length; i++)
			{
				var f:ZipEntry = _fileList[i];
				var r:Number = f.ratio;
				var p:String = r + (ZipFile.isInteger(r) ? ".0" : "") + "%";
				ct.add([f.path, f.size, f.compressedSize, p, f.crc32hex]);
			}
			return ct.toString();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get fileTypeID():int
		{
			return FileTypeIndex.ZIP_FILE_ID;
		}
		
		
		/**
		 * An array of ZipEntry objects with all zip entries contained in this zip file.
		 * 
		 * @see com.hexagonstar.file.types.ZipEntry
		 */
		public function get entries():Array
		{
			return _fileList;
		}
		
		
		/**
		 * The number of zipped files in this zip file. This does not include folders,
		 * Use <code>folderCount</code> to get the amount of folders in the ZipFile.
		 */
		public function get fileCount():int
		{
			var c:int = 0;
			for each (var f:ZipEntry in _fileList)
			{
				if (!f.isDirectory) c++;
			}
			return c;
		}
		
		
		/**
		 * The number of empty folders that are contained in this zip file.
		 */
		public function get folderCount():int
		{
			var c:int = 0;
			for each (var f:ZipEntry in _fileList)
			{
				if (f.isDirectory) c++;
			}
			return c;
		}
		
		
		/**
		 * The uncompressed size of the zip file.
		 */
		override public function get bytesLoaded():Number
		{
			var s:Number = 0;
			for (var i:int = 0; i < _fileList.length; i++)
			{
				s += ZipEntry(_fileList[i]).size;
			}
			return s;
		}
		/** @private */
		override public function set bytesLoaded(v:Number):void
		{
			/* should not be able to set the size, which is
			 * calculated from the zipped files inside it! */
		}
		
		
		/**
		 * The size of the compressed zip file.
		 */
		public function get compressedSize():Number
		{
			return _bytesLoaded;
		}
		/** @private */
		public function set compressedSize(v:Number):void
		{
			_bytesLoaded = v;
		}
		
		
		/**
		 * The compression ratio of the zip file in percent.
		 */
		public function get ratio():Number
		{
			return ZipFile.round((compressedSize / bytesLoaded) * 100, 1);
		}
		
		
		/**
		 * Determines if 'intelligent' compression is used. If this property is
		 * <code>true</code> the zip file will only compress the data of an added entry if
		 * it's compressed size is smaller than it's uncompressed size. If it's resulting
		 * compressed size turns out to be larger or equal to it's uncompressed size, the data
		 * will only be stored. <p>If set to <code>false</code>, any added data is compressed
		 * regardless of it's resulting size.</p>
		 */
		public function get autoCompression():Boolean
		{
			return _autoCompression;
		}
		public function set autoCompression(v:Boolean):void
		{
			_autoCompression = v;
		}
		
		
		/**
		 * Sets the content data of the zip file. This is used by a loader to provide the
		 * loaded zip data.
		 */
		override public function set contentAsBytes(v:ByteArray):void
		{
			try
			{
				_content.writeBytes(v);
				_content.position = 0;
				_valid = true;
				_status = Status.OK;
			}
			catch (err:Error)
			{
				_valid = false;
				_status = err.message;
			}
			
			if (_valid)
			{
				/* Process compressed content */
				_hasLoadedData = true;
				readCEN();
			}
			
			complete();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after a requested, zipped file has received it's content data.
		 * @private
		 */
		private function onFileReady(f:IFile):void
		{
			_completeSignal.dispatch(f);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Reads the central directory of a zip file and fills the file list array.
		 * This is called exactly once when first needed.
		 * 
		 * @private
		 * @return true if successful, false if errors occured.
		 */
		private function readCEN():Boolean
		{
			readEND();
			
			for (var i:int = 0; i < _fileCount; i++)
			{
				var tmp:ByteArray = new ByteArray();
				tmp.endian = Endian.LITTLE_ENDIAN;
				_content.readBytes(tmp, 0, ZipConstants.CENHDR);
				
				var sig:uint = tmp.readUnsignedInt();
				if (sig != ZipConstants.CENSIG)
				{
					error("Invalid CEN header in zip file <" + path + "> (bad signature: 0x"
						+ sig.toString(16) + ").");
					return false;
				}
				
				/* Handle filename */
				tmp.position = ZipConstants.CENNAM;
				
				var len:uint = tmp.readUnsignedShort();
				if (len == 0)
				{
					error("Missing zip entry file path in zip file <" + path + ">.");
					return false;
				}
				
				var e:ZipEntry = new ZipEntry(_content.readUTFBytes(len), null, this);
				
				/* Handle extra field */
				len = tmp.readUnsignedShort();
				e.extra = new ByteArray();
				
				/* Handle file comment */
				if (len > 0) _content.readBytes(e.extra, 0, len);
				_content.position += tmp.readUnsignedShort();
				
				/* Now get the remaining fields for the entry */
				tmp.position = ZipConstants.CENVER;
				e.version = tmp.readUnsignedShort();
				e.flag = tmp.readUnsignedShort();
				if ((e.flag & 1) == 1)
				{
					error("Encrypted zip entry not supported in zip file <" + path + ">.");
					return false;
				}
				e.compressionMethod = tmp.readUnsignedShort();
				e.dostime = tmp.readUnsignedInt();
				e.crc32 = tmp.readUnsignedInt();
				e.compressedSize = tmp.readUnsignedInt();
				e.size = tmp.readUnsignedInt();
				
				/* Add to file list and table */
				_fileList.push(e);
				_fileTable[e.path] = e;
				
				/* Loc offset */
				tmp.position = ZipConstants.CENOFF;
				_locOffsetTable[e.path] = tmp.readUnsignedInt();
			}
			
			return true;
		}
		
		
		/**
		 * Reads the total number of zip entries in the central dir and positions
		 * the buffer at the start of the central directory.
		 * 
		 * @private
		 */
		private function readEND():void
		{
			var end:uint = findEND();
			if (end > 0)
			{
				var b:ByteArray = new ByteArray();
				b.endian = Endian.LITTLE_ENDIAN;
				
				_content.position = end;
				_content.readBytes(b, 0, ZipConstants.ENDHDR);
				b.position = ZipConstants.ENDTOT;
				_fileCount = b.readUnsignedShort();
				b.position = ZipConstants.ENDOFF;
				_content.position = b.readUnsignedInt();
			}
		}
		
		
		/**
		 * Find the end of central directory record.
		 * -----------------------------------------------------
		 * end of central dir signature    4 bytes  (0x06054b50)
		 * number of this disk             2 bytes
		 * number of the disk with the
		 * start of the central directory  2 bytes
		 * total number of entries in the
		 * central directory on this disk  2 bytes
		 * total number of entries in
		 * the central directory           2 bytes
		 * size of the central directory   4 bytes
		 * offset of start of central
		 * directory with respect to
		 * the starting disk number        4 bytes
		 * .ZIP file comment length        2 bytes
		 * .ZIP file comment       (variable size)
		 * 
		 * @private
		 */
		private function findEND():uint
		{
			var i:uint = _content.length - ZipConstants.ENDHDR;
			var n:uint = Math.max(0, i - ZipConstants.MAXCMT);
			
			for (i; i >= n; i--)
			{
				if (i < 1) break;
				/* Quick check that the byte is 'P' */
				if (_content[i] != 0x50) continue;
				_content.position = i;
				if (_content.readUnsignedInt() == ZipConstants.ENDSIG)
				{
					return i;
				}
			}
			
			error("Could not find END header of zip file <" + path + ">.");
			return 0;
		}
		
		
		/**
		 * Used by ZipGenerator.
		 * @private
		 */
		internal function setStatus(valid:Boolean, status:String):void
		{
			_valid = valid;
			_status = status;
		}
		
		
		/**
		 * @private
		 */
		internal function error(msg:String):void
		{
			_valid = false;
			_status = msg;
		}
		
		
		/**
		 * @private
		 */
		protected static function round(value:Number, decimals:int = 0):Number
		{
			var p:Number = Math.pow(10, decimals);
			return Math.round(value * p) / p;
		}
		
		
		/**
		 * @private
		 */
		public static function isInteger(value:Number):Boolean 
		{
			return (value % 1) == 0;
		}
	}
}
