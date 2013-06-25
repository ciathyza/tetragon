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

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	
	/**
	 * A special bulk file for loading sound files.
	 */
	public class BulkSoundFile extends BulkFile implements IBulkFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _sound:Sound;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new BulkSoundFile instance.
		 * 
		 * @param file The file to be wrapped into the BulkSoundFile.
		 */
		public function BulkSoundFile(file:IFile)
		{
			super(file);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function load(useAbsoluteFilePath:Boolean, preventCaching:Boolean):void
		{
			if (_loading) return;
			
			_loading = true;
			_status = BulkFile.STATUS_PROGRESSING;
			
			_sound = new Sound();
			_sound.addEventListener(Event.OPEN, onOpen);
			_sound.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_sound.addEventListener(Event.COMPLETE, onFileComplete);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			var r:URLRequest = BulkFile.createURLRequest(_file.path, useAbsoluteFilePath,
				preventCaching);
			
			try
			{
				_sound.load(r);
			}
			catch (err:Error)
			{
				onIOError(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, err.message));
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return "[BulkSoundFile, path=" + _file.path + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function onFileComplete(e:Event):void
		{
			_status = BulkFile.STATUS_LOADED;
			_loading = false;
			removeEventListeners();
			_file.completeSignal.addOnce(onFileReady);
			_file.content = _sound;
			_sound = null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function removeEventListeners():void
		{
			if (!_sound) return;
			_sound.removeEventListener(Event.OPEN, onOpen);
			_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_sound.removeEventListener(Event.COMPLETE, onFileComplete);
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
	}
}
