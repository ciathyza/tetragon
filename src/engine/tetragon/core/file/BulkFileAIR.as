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
package tetragon.core.file
{
	import tetragon.core.file.types.IFile;
	import tetragon.core.signals.Signal;
	import tetragon.debug.Log;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	
	/**
	 * A bulk file that uses the AIR file loading API.
	 * 
	 * @see com.hexagonstar.file.BulkLoader
	 * @see com.hexagonstar.file.BulkSoundFile
	 * @see com.hexagonstar.file.types.IFile
	 */
	public class BulkFileAIR implements IBulkFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _file:IFile;
		/** @private */
		protected var _loader:File;
		/** @private */
		protected var _retryCount:int;
		/** @private */
		protected var _status:String;
		/** @private */
		protected var _loading:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _fileOpenSignal:Signal;
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
		 * Creates a new bulk file instance.
		 * 
		 * @param file The file to be wrapped into the bulk file.
		 */
		public function BulkFileAIR(file:IFile)
		{
			_file = file;
			_status = BulkFile.STATUS_INITIALIZED;
			_retryCount = 0;
			_loading = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function load(useAbsoluteFilePath:Boolean, preventCaching:Boolean):void
		{
			if (_loading) return;
			
			_loading = true;
			_status = BulkFile.STATUS_PROGRESSING;
			
			_loader = new File();
			
			/* TODO This check works for now but might need improvement later! */
			try
			{
				_loader.nativePath = _file.path;
			}
			catch (err1:Error)
			{
				Log.error("Could not set the nativePath for File to " + _file.path
					+ " (Error was: " + err1.message + ").", this);
				onIOError(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, err1.message));
				return;
			}
			
			_loader.addEventListener(Event.OPEN, onOpen);
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.addEventListener(Event.COMPLETE, onFileComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			try
			{
				_loader.load();
			}
			catch (err2:Error)
			{
				onIOError(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, err2.message));
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			removeEventListeners();
			removerSignalListeners();
			_loader = null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return "[BulkFileAIR, path=" + _file.path + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get loading():Boolean
		{
			return _loading;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get file():IFile
		{
			return _file;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get priority():Number
		{
			return _file.priority;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get weight():int
		{
			return _file.weight;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get callback():Function
		{
			return _file.callback;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get params():Array
		{
			return _file.params;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get status():String
		{
			return _status;
		}
		public function set status(v:String):void
		{
			_status = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get retryCount():int
		{
			return _retryCount;
		}
		public function set retryCount(v:int):void
		{
			_retryCount = (v < 0) ? 0 : (v > int.MAX_VALUE) ? int.MAX_VALUE : v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get bytesLoaded():uint
		{
			return _file.bytesLoaded;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get bytesTotal():uint
		{
			return _file.bytesTotal;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get percentLoaded():Number
		{
			return _file.percentLoaded;
		}
		
		
		/**
		 * Signal that is dispatched when a bulk file has been opened.
		 * Listener signature: <code>onBulkFileOpen(bf:IBulkFile):void</code>
		 */
		public function get fileOpenSignal():Signal
		{
			if (!_fileOpenSignal) _fileOpenSignal = new Signal();
			return _fileOpenSignal;
		}
		
		
		/**
		 * Listener signature: <code>onBulkFileProgress(bf:IBulkFile):void</code>
		 */
		public function get fileProgressSignal():Signal
		{
			if (!_fileProgressSignal) _fileProgressSignal = new Signal();
			return _fileProgressSignal;
		}
		
		
		/**
		 * Listener signature: <code>onBulkFileLoaded(bf:IBulkFile):void</code>
		 */
		public function get fileCompleteSignal():Signal
		{
			if (!_fileCompleteSignal) _fileCompleteSignal = new Signal();
			return _fileCompleteSignal;
		}
		
		
		/**
		 * Not used for AIR! Returns null!
		 */
		public function get fileHTTPStatusSignal():Signal
		{
			return null;
		}
		
		
		/**
		 * Listener signature: <code>onBulkFileIOError(bf:IBulkFile):void</code>
		 */
		public function get fileIOErrorSignal():Signal
		{
			if (!_fileIOErrorSignal) _fileIOErrorSignal = new Signal();
			return _fileIOErrorSignal;
		}
		
		
		/**
		 * Not used for AIR! Returns null!
		 */
		public function get fileSecurityErrorSignal():Signal
		{
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onOpen(e:Event):void
		{
			if (_fileOpenSignal) _fileOpenSignal.dispatch(this);
		}
		
		
		/**
		 * @private
		 */
		protected function onProgress(e:ProgressEvent):void
		{
			_file.bytesLoaded = e.bytesLoaded;
			_file.bytesTotal = e.bytesTotal;
			if (_fileProgressSignal) _fileProgressSignal.dispatch(this);
		}
		
		
		/**
		 * @private
		 */
		protected function onFileComplete(e:Event):void
		{
			_status = BulkFile.STATUS_LOADED;
			_loading = false;
			removeEventListeners();
			_file.completeSignal.addOnce(onFileReady);
			_file.content = _loader.data;
		}
		
		
		/**
		 * @private
		 */
		protected function onFileReady(file:IFile):void 
		{
			if (_fileCompleteSignal) _fileCompleteSignal.dispatch(this);
		}
		
		
		/**
		 * @private
		 */
		protected function onIOError(e:IOErrorEvent):void
		{
			_status = BulkFile.STATUS_ERROR;
			_loading = false;
			removeEventListeners();
			_file.errorMessage = e.text;
			if (_fileIOErrorSignal) _fileIOErrorSignal.dispatch(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function removeEventListeners():void
		{
			if (!_loader) return;
			_loader.removeEventListener(Event.OPEN, onOpen);
			_loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.removeEventListener(Event.COMPLETE, onFileComplete);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		
		/**
		 * @private
		 */
		protected function removerSignalListeners():void
		{
			if (_fileOpenSignal) _fileOpenSignal.removeAll();
			if (_fileProgressSignal) _fileProgressSignal.removeAll();
			if (_fileCompleteSignal) _fileCompleteSignal.removeAll();
			if (_fileIOErrorSignal) _fileIOErrorSignal.removeAll();
		}
	}
}
