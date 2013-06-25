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
package tetragon.core.file
{
	import tetragon.core.file.types.BinaryFile;
	import tetragon.core.file.types.IFile;
	import tetragon.core.file.types.TextFile;
	import tetragon.core.signals.Signal;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	public class FileWriter
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _file:IFile;
		/** @private */
		protected var _directory:File;
		/** @private */
		protected var _stream:FileStream;
		/** @private */
		protected var _writing:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _fileProgressSignal:Signal;
		/** @private */
		protected var _fileCompleteSignal:Signal;
		/** @private */
		protected var _fileIOErrorSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function FileWriter()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Writes the specified file to disk.
		 * 
		 * @param file The file to write.
		 * @return true if the write operation has been started successfully, false if not,
		 *         e.g. the File writer is currently writing or a security error occured.
		 */
		public function write(file:IFile, directory:String = "documents"):Boolean
		{
			return openFile(file, directory, FileMode.WRITE);
		}
		
		
		public function append(file:IFile, directory:String = "documents"):Boolean
		{
			return openFile(file, directory, FileMode.APPEND);
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			removerEventListeners();
			removerSignalListeners();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get fileProgressSignal():Signal
		{
			if (!_fileProgressSignal) _fileProgressSignal = new Signal();
			return _fileProgressSignal;
		}
		
		
		public function get fileCompleteSignal():Signal
		{
			if (!_fileCompleteSignal) _fileCompleteSignal = new Signal();
			return _fileCompleteSignal;
		}
		
		
		public function get fileIOErrorSignal():Signal
		{
			if (!_fileIOErrorSignal) _fileIOErrorSignal = new Signal();
			return _fileIOErrorSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onStreamOutputProgress(e:OutputProgressEvent):void
		{
			if (_fileProgressSignal) _fileProgressSignal.dispatch(e.bytesPending, e.bytesTotal);
		}
		
		
		private function onStreamError(e:IOErrorEvent):void
		{
			_writing = false;
			removerEventListeners();
			_file.errorMessage = e.text;
			if (_fileIOErrorSignal) _fileIOErrorSignal.dispatch(_file);
		}
		
		
		private function onStreamClose(e:Event):void
		{
			_writing = false;
			removerEventListeners();
			if (_fileCompleteSignal) _fileCompleteSignal.dispatch(_file);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function removerEventListeners():void
		{
			if (!_stream) return;
			_stream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onStreamOutputProgress);
			_stream.removeEventListener(IOErrorEvent.IO_ERROR, onStreamError);
			_stream.removeEventListener(Event.CLOSE, onStreamClose);
		}
		
		
		/**
		 * @private
		 */
		protected function removerSignalListeners():void
		{
			if (_fileProgressSignal) _fileProgressSignal.removeAll();
			if (_fileCompleteSignal) _fileCompleteSignal.removeAll();
			if (_fileIOErrorSignal) _fileIOErrorSignal.removeAll();
		}
		
		
		/**
		 * @private
		 */
		protected function openFile(file:IFile, directory:String, mode:String):Boolean
		{
			if (_writing || !file) return false;
			
			switch (directory)
			{
				case Directory.DOCUMENTS:
					_directory = File.documentsDirectory;
					break;
				case Directory.USER:
					_directory = File.userDirectory;
					break;
				case Directory.DESKTOP:
					_directory = File.desktopDirectory;
					break;
				case Directory.APPLICATION_STORAGE:
					_directory = File.applicationStorageDirectory;
					break;
				case Directory.APPLICATION:
					_directory = File.applicationDirectory;
					break;
				default:
					_directory = null;
			}
			
			if (_directory)
			{
				_file = file;
				_directory = _directory.resolvePath(_file.path);
				directory = _directory.nativePath;
			}
			if (!_directory)
			{
				dispatchError("Not a valid write path: " + directory);
				return false;
			}
			
			_writing = true;
			
			_stream = new FileStream();
			_stream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onStreamOutputProgress);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, onStreamError);
			_stream.addEventListener(Event.CLOSE, onStreamClose);
			_stream.openAsync(_directory, mode);
			
			try
			{
				if (file is TextFile)
					_stream.writeUTFBytes((file as TextFile).contentAsString);
				else
					_stream.writeBytes((file as BinaryFile).contentAsBytes);
			}
			catch (err:Error)
			{
				dispatchError(err.message);
				return false;
			}
			
			_stream.close();
			return true;
		}
		
		
		/**
		 * @private
		 */
		protected function dispatchError(message:String):void
		{
			onStreamError(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, message));
		}
	}
}
