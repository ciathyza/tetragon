package tetragon.env.update.au.core
{
	import tetragon.debug.Log;
	import tetragon.env.update.au.states.AUHSM;
	import tetragon.env.update.au.states.AUHSMEvent;
	import tetragon.env.update.au.utils.AUConstants;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	
	
	/** Dispatched as the UCF file is processed. */
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/** Dispatched when the UCF file is completely expanded. */
	[Event(name="complete", type="flash.events.Event")]
	
	/** 
	 * Dispatched if a validation error occurs while reading the UCF file.
	 * The following errors may be dispatched:
	 *
	 * - If the UCF file does not begin with the correct
	 *   4-byte signature (magic).
	 *
	 * - If the UCF file uses a feature, such as encryption,
	 *   not supported by this implementation.
	 *
	 * - If the UCF file is signed but the signature is not valid.
	 *   (Note: It is not an error if the signature is valid but the
	 *   the signer is not trusted.)
	 */
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	/** 
	 * Dispatch if an IO error occurs while reading the UCF file
	 * or writing an expanded file to disk.
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	/**
	 * Dispatched if unpackaging from an http or https URL. See 
	 * URLStream for further definition.
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	
	/**
	 * See URLStream for further definition.
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	
	/**
	 * UCFUnpackager can be used to unpackage the contents of a Univeral
	 * Container Format (UCF) file.
	 */
	public class AUUCFUnpackager extends AUHSM
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		// Types and methods for subclass-only access follow
		// Current state with respect to the UCF file.
		protected static const AT_START:uint = 0;
		protected static const AT_HEADER:uint = 1;
		protected static const AT_FILENAME:uint = 2;
		protected static const AT_EXTRA_FIELD:uint = 3;
		protected static const AT_DATA:uint = 4;
		protected static const AT_END:uint = 5;
		protected static const AT_ERROR:uint = 6;
		protected static const AT_COMPLETE:uint = 12;
		protected static const AT_ABORTED:uint = 13;
		
		// states for reading the central directory.
		protected static const AT_CDHEADER:uint = 7;
		protected static const AT_CDHEADERMAGIC:uint = 8;
		protected static const AT_CDFILENAME:uint = 9;
		protected static const AT_CDEXTRA_FIELD:uint = 10;
		protected static const AT_CDCOMMENT:uint = 11;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _identifier:String;
		private var _source:URLStream;
		
		// data about the file/Central Dir entry currently being read
		private var _generalPurposeBitFlags:uint;
		private var _compressionMethod:uint;
		private var _extraFieldLength:uint;
		private var _compressedSize:uint;
		private var _uncompressedSize:uint;
		private var _filenameLength:uint;
		private var _data:ByteArray;
		private var _path:String;
		private var _currentLFH:ByteArray;
		private var _isDirectory:Boolean;
		
		// data specific to central dir entries only.
		private var _fileCommentLength:uint;
		private var _fileRelativeOffset:uint;
		
		// Used to maintain a tree of directories seen.
		private var _root:Object = {};
		
		private var _mUCFParseState:uint = AT_START;
		private var _mFileCount:uint = 0;
		private var _mDir:File;
		private var _mValidator:Object = {};
		private var _mEnableSignatureValidation:Boolean = false;
		private var _mIsComplete:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUUCFUnpackager()
		{
			super(onInitialized);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Start unpackaging of the specified file.
		 */
		public function unpackageAsync(url:String):void
		{
			_identifier = url;
			transitionAsync(onUnpackaging);
		}


		/**
		 * Cancel any further processing. It is assumed the client will no longer access
		 * this data after calling cancel().
		 */
		public function cancel():void
		{
			if (_source && _source.connected)
			{
				_source.close();
				_mUCFParseState = AT_ABORTED;
			}
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			disposeURLStream();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "UCFUnpackager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get isComplete():Boolean
		{
			return _mIsComplete;
		}
		
		
		/** 
		 * If set, the directory in which the contents of the UCF file are written.
		 * If not set, the contents are not written to disk.
		 *
		 * If a directory is specified it must already exist. It need not be empty,
		 * but unpackaging will file if overwriting a file in the directory fails.
		 */
		public function set outputDirectory(v:File):void
		{
			_mDir = v;
		}
		public function get outputDirectory():File
		{
			return _mDir;
		}
		
		
		/**
		 * Enable/disable signature validation. Defaults to true. If set,
		 * the UCF file must be signed.
		 */
		public function set enableSignatureValidation(v:Boolean):void
		{
			_mEnableSignatureValidation = v;
		}
		
		
		protected function get ucfParseState():uint
		{
			return _mUCFParseState;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onInitialized(e:Event):void
		{
			// nop
		}
		
		
		private function onUnpackaging(e:Event):void
		{
			switch (e.type)
			{
				case AUHSMEvent.ENTER:
					Log.verbose("Unpackaging " + _identifier, this);
					_source = new URLStream();
					_source.endian = Endian.LITTLE_ENDIAN;
					_source.addEventListener(ProgressEvent.PROGRESS, dispatch);
					_source.addEventListener(HTTPStatusEvent.HTTP_STATUS, dispatch);
					_source.addEventListener(IOErrorEvent.IO_ERROR, dispatch);
					_source.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatch);
					_source.addEventListener(Event.COMPLETE, dispatch);
					_source.load(new URLRequest(_identifier));
					break;
				case ProgressEvent.PROGRESS:
					onData(e as ProgressEvent);
					break;
				case HTTPStatusEvent.HTTP_STATUS:
					dispatchEvent(e.clone());
					break;
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR:
					_mUCFParseState = AT_ERROR;
					dispatchEvent(e.clone());
					break;
				case Event.COMPLETE:
					onComplete(e);
					break;
			}
		}
		
		
		private function onTransComplete(e:Event):void
		{
			if (e.type != AUHSMEvent.ENTER) return;
			_mIsComplete = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private function onErrored(e:Event):void
		{
		}
		
		
		// TODO: Break into additional states. Code is old and pre-dates HSM.
		private function onData(e:ProgressEvent):void
		{
			// The underlying progress from the byte stream is the best estimate
			// we've got of work accomplished and remaining.
			// FIXME: This code needs to be hardened.
			dispatchEvent(e.clone());

			try
			{
				const HEADER_SIZE_BYTES:uint	= 30;
				const ZIP_LFH_MAGIC:uint		= 0x04034b50;
				const CDHEADER_SIZE_BYTES:uint	= 46;
				const ZIP_CDH_MAGIC:uint		= 0x02014b50;
				const ZIP_CDSIG_MAGIC:uint		= 0x06054b50;
				
				// When a data event is received we must process as much data as possible because it's possible
				// that this is the only or last data event we'll receive. However, we don't have to read every last
				// byte: if the stream stops in, say, the middle of a header, we can reasonably expect to receive
				// another data event. This would only not happen if the data stream is malformed; in that case
				// we'll know that when we get the complete event.

				var magic:uint;
				var filename:ByteArray;
				
				while (true)
				{
					switch (_mUCFParseState)
					{
						case AT_START:
						case AT_HEADER:
							if (_source.bytesAvailable < HEADER_SIZE_BYTES) return;
							_currentLFH = new ByteArray();
							_currentLFH.endian = Endian.LITTLE_ENDIAN;
							// Read the magic identifier first to determine where we are.
							_source.readBytes(_currentLFH, 0, 4);
							magic = _currentLFH.readUnsignedInt();
							if (ZIP_LFH_MAGIC != magic)
							{
								if (_mUCFParseState == AT_START)
								{
									fail("Not an AIR file.", AUConstants.ERROR_UCF_INVALID_AIR_FILE);
								}
								
								// Everything after the local file header we skip for now.
								// FIXME: Should be more rigorous; fail on unallowed sections.

								if (ZIP_CDH_MAGIC == magic)
								{
									_mUCFParseState = AT_CDHEADERMAGIC;
									break;
								}
								_mUCFParseState = AT_END;
								return;
							}
							
							_source.readBytes(_currentLFH, _currentLFH.length, HEADER_SIZE_BYTES - 4);
							// TODO: Check "version need to extract" field
							var versionNeededToExtract:uint = _currentLFH.readUnsignedShort();
							
							// If bit 3 is set, some header values are in the data
							// descriptor following the file instead of in the file.
							_generalPurposeBitFlags = _currentLFH.readUnsignedShort();
							if ((_generalPurposeBitFlags & 0xFFF9) != 0)
							{
								fail("File uses unsupported encryption or streaming features.",
									AUConstants.ERROR_UCF_INVALID_FLAGS);
							}
							
							_compressionMethod = _currentLFH.readUnsignedShort();
							var lastModTime:uint = _currentLFH.readUnsignedShort();
							var lastModDate:uint = _currentLFH.readUnsignedShort();
							var crc32:uint = _currentLFH.readUnsignedInt();
							_compressedSize = _currentLFH.readUnsignedInt();
							_uncompressedSize = _currentLFH.readUnsignedInt();
							_filenameLength = _currentLFH.readUnsignedShort();
							_extraFieldLength = _currentLFH.readUnsignedShort();
							
							if (_filenameLength == 0)
							{
								fail("One of the files has an empty (zero-length) name.",
									AUConstants.ERROR_UCF_INVALID_FILENAME);
							}
							// Fall through
							_mUCFParseState = AT_FILENAME;
							
						case AT_FILENAME:
							if (_source.bytesAvailable < _filenameLength) return;
							_source.readBytes(_currentLFH, _currentLFH.length, _filenameLength);
							filename = new ByteArray();
							_currentLFH.readBytes(filename, 0, _filenameLength);
							_path = filename.toString();
							
							/* Now that we have a file name, check some error conditions.
							 * First, make sure files are in a specific order. */
							if (_mFileCount == 0 && _path != "mimetype")
							{
								fail("Mimetype must be the first file.",
									AUConstants.ERROR_UCF_NO_MIMETYPE);
							}
							
							var DATA_DESCRIPTOR_FLAG:uint = 0x80;
							if (_generalPurposeBitFlags & DATA_DESCRIPTOR_FLAG)
							{
								fail("File " + _path + " uses a data descriptor field.",
									AUConstants.ERROR_UCF_INVALID_FLAGS);
							}
							
							var COMPRESSION_NONE:uint = 0;
							var COMPRESSION_DEFLATE:uint = 8;
							if (_compressionMethod != COMPRESSION_DEFLATE
								&& _compressionMethod != COMPRESSION_NONE)
							{
								fail("File " + _path + " uses an illegal compression method "
									+ _compressionMethod, AUConstants.ERROR_UCF_UNKNOWN_COMPRESSION);
							}
							
							/* A directory is defined to be an entry with a name ending in /.
							 * Once we know that, however, we strip of the the last / before
							 * doing a split. */
							_isDirectory = (_path.charAt(_path.length - 1) == "/");
							if (_isDirectory)
							{
								_path = _path.slice(0, _path.length - 1);
							}
							
							var elements:Array = _path.split("/");
							if (elements.length == 0)
							{
								fail("Package contains a file with an empty name.",
									AUConstants.ERROR_UCF_INVALID_FILENAME);
							}
							
							elements.filter(function(item:*, index:int, array:Array):Boolean
							{
								if (item == ".") fail("Filename " + _path + " contains a component of '.'", AUConstants.ERROR_UCF_INVALID_FILENAME);
								if (item == "..") fail("Filename " + _path + " contains a component of '..'", AUConstants.ERROR_UCF_INVALID_FILENAME);
								if (item == "") fail("Filename " + _path + " contains an empty component.", AUConstants.ERROR_UCF_INVALID_FILENAME);
								return true;
							});
							
							/* The name looks valid. Now figure out the list of parent directories
							 * for this file, if any. Then notify the listener of any new
							 * directories in this path. */
							var numParentDirs:int = (_isDirectory ? elements.length : elements.length - 1);
							var parent:Object = _root;
							var currentPath:Array = [];
							for (var i:uint = 0; i < numParentDirs; i++)
							{
								var element:String = elements[i];
								currentPath.push(element);
								if (parent[element] == null)
								{
									parent[element] = {};
									doDirectory(currentPath.join("/"));
								}
								parent = parent[element];
							}
							// Fall through, as before.
							_mUCFParseState = AT_EXTRA_FIELD;
						
						case AT_EXTRA_FIELD:
							if (_source.bytesAvailable < _extraFieldLength) return;
							// The extra field is discarded, but we still need to hash it.
							if (_extraFieldLength > 0)
							{
								_source.readBytes(_currentLFH, _currentLFH.length, _extraFieldLength);
							}
							// Fall through, as before
							_mUCFParseState = AT_DATA;
							
						case AT_DATA:
							var sizeToRead:uint = (_compressionMethod == 8 ? _compressedSize : _uncompressedSize);
							if (_source.bytesAvailable < sizeToRead) return;
							// Note that directory events are dispatched in the AT_FILENAME state, above.
							if (_isDirectory)
							{
								if (_uncompressedSize != 0)
								{
									fail("Directory entry " + _path + " has associated data.",
										AUConstants.ERROR_UCF_INVALID_FILENAME);
								}
								if (_mDir)
								{
									_mDir.resolvePath(_path).createDirectory();
								}
							}
							else
							{
								_data = new ByteArray();
								if (sizeToRead > 0)
								{
									_source.readBytes(_data, 0, sizeToRead);
									if (_compressionMethod == 8)
									{
										_data.uncompress(CompressionAlgorithm.DEFLATE);
									}
								}
								if (_mDir)
								{
									_data.position = 0;
									var fs:FileStream = new FileStream();
									fs.open(_mDir.resolvePath(_path), FileMode.WRITE);
									fs.writeBytes(_data);
									fs.close();
								}
								if (_mEnableSignatureValidation)
								{
									if (_path == "META-INF/signatures.xml")
									{
										_mValidator["signatures"] = _data;
									}
									else
									{
										_mValidator["addFile"](_path, _data);
									}
								}
								
								var shouldContinue:Boolean = doFile(_mFileCount, _path, _data);
								if (!shouldContinue)
								{
									_mUCFParseState = AT_ABORTED;
									break;
								}
							}
							// Back to the beginning
							_mFileCount++;
							_mUCFParseState = AT_HEADER;
							break;
						
						case AT_CDHEADER:
							if (_source.bytesAvailable < 4) return;
							_currentLFH = new ByteArray();
							_currentLFH.endian = Endian.LITTLE_ENDIAN;
							_source.readBytes(_currentLFH, 0, 4);
							magic = _currentLFH.readUnsignedInt();
							if (ZIP_CDH_MAGIC != magic)
							{
								// passed the last CD entry.
								_mUCFParseState = AT_END;
								return;
							}
							_mUCFParseState = AT_CDHEADERMAGIC;
							
						case AT_CDHEADERMAGIC:
							// at this point, we have read 4 bytes of the CD header.
							if (_source.bytesAvailable < CDHEADER_SIZE_BYTES - 4) return;
							_source.readBytes(_currentLFH, _currentLFH.length, CDHEADER_SIZE_BYTES - 4);
							// Don't really care about all the bytes after the CDH magic and
							// before "file name length" section, so skip those bytes.
							_currentLFH.position = _currentLFH.position + 24;
							_filenameLength = _currentLFH.readUnsignedShort();
							_extraFieldLength = _currentLFH.readUnsignedShort();
							_fileCommentLength = _currentLFH.readUnsignedShort();
							// Don't care about the bytes between fileCommentLength and relative offset
							// of local header, so skip those.
							_currentLFH.position = _currentLFH.position + 8;
							_fileRelativeOffset = _currentLFH.readUnsignedInt();
							_mUCFParseState = AT_CDFILENAME;
							
						case AT_CDFILENAME:
							// Same processing as in AT_FILENAME.
							if ( _source.bytesAvailable < _filenameLength ) return;
							_source.readBytes(_currentLFH, _currentLFH.length, _filenameLength);
							filename = new ByteArray();
							_currentLFH.readBytes(filename, 0, _filenameLength);
							_path = filename.toString();
							// TODO: do same error checks as in AT_FILENAME? skipping them for now.
							_mUCFParseState = AT_CDEXTRA_FIELD;
							
						case AT_CDEXTRA_FIELD:
							if (_source.bytesAvailable < _extraFieldLength) return;
							if (_extraFieldLength > 0)
							{
								// The extra field is discarded, but we still need to hash it.
								_source.readBytes(_currentLFH, _currentLFH.length, _extraFieldLength);
							}
							_mUCFParseState = AT_CDCOMMENT;
							
						case AT_CDCOMMENT:
							if (_source.bytesAvailable < _fileCommentLength) return;
							if (_fileCommentLength > 0)
							{
								// The extra field is discarded, but we still need to hash it.
								_source.readBytes(_currentLFH, _currentLFH.length, _fileCommentLength);
							}
							// Ready to read the next CD entry.
							_mUCFParseState = AT_CDHEADER;
							break;
							
						case AT_END:
							// We've passed all of the files but are still receiving data events. Ignore them.
							return;
							
						case AT_ABORTED:
							// Ignore everything until the read completes
							return;
							
						case AT_ERROR:
							// Something has already gone wrong, but we might receive more progress events
							// while waiting for the end. Ignore them.
							return;
					}
				}
			}
			catch (err:Error)
			{
				dispatchError(err);
			}
		}
		
		
		private function onComplete(e:Event):void
		{
			try
			{
				switch (_mUCFParseState)
				{
					// All is well
					case AT_END:
						doDone();
						_mUCFParseState = AT_COMPLETE;
						if (_mEnableSignatureValidation && _mValidator["packageSignatureStatus"] != 0)
						{
							Log.warn("onComplete:: Signature is not valid.", this);
							dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Signature is not valid."));
							transition(onErrored);
						}
						else
						{
							transition(onTransComplete);
						}
						break;
					case AT_ABORTED:
						_mIsComplete = true;
						dispatchEvent(new Event(Event.COMPLETE));
						break;
					case AT_ERROR:
						// We've already reported an error event.
						break;
					default:
						// We're in the middle of the stream but out of data. This is an error.
						fail("Truncated or corrupt.", AUConstants.ERROR_UCF_CORRUPT_AIR);
				}
			}
			catch (err:Error)
			{
				dispatchError(err);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Called during unpackaging each time a new file is processed. Subclasses may override
		 * this in order to take action on each file during unpackaging. If outputDirectory
		 * is set, the file will be written to outputDirectory *before* this method is called.
		 *
		 * If the method returns false, then the unpackager enters the AT_ABORTED state and
		 * further processing stops immediately. To continue processing, return true.
		 */
		protected function doFile(fileNumber:uint, path:String, data:ByteArray):Boolean
		{
			return true;
		}


		/**
		 * Called during unpackagin each time a new directory is processed. Sublcasses may
		 * override this in order to take action on each directory. If outputDirectory is set,
		 * the directory will have been created *before* this method is called.
		 */
		protected function doDirectory(path:String):void
		{
			// nop
		}


		/**
		 * Called when all processing is complete and the file has been successfully unpackaged.
		 */
		protected function doDone():void
		{
			// nop
		}
		
		
		private function dispatchError(error:Error):void
		{
			Log.warn(error.message, this);
			_mUCFParseState = AT_ERROR;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.message, error.errorID));
		}
		
		
		/**
		 * @private
		 */
		protected function disposeURLStream():void
		{
			if (!_source) return;
			_source.removeEventListener(ProgressEvent.PROGRESS, dispatch);
			_source.removeEventListener(HTTPStatusEvent.HTTP_STATUS, dispatch);
			_source.removeEventListener(IOErrorEvent.IO_ERROR, dispatch);
			_source.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatch);
			_source.removeEventListener(Event.COMPLETE, dispatch);
			_source = null;
		}
		
		
		protected function fail(message:String, errorID:int = 0, throwError:Boolean = true):void
		{
			var msg:String = toString() + ": " + message;
			Log.error(msg, this);
			if (throwError) throw new Error(msg, errorID);
		}
	}
}
