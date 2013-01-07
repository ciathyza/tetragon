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
package tetragon.file.resource
{
	import tetragon.data.Config;
	import tetragon.debug.Log;

	import com.hexagonstar.file.ZipLoader;
	import com.hexagonstar.util.string.stringIsEmptyOrNull;

	import flash.filesystem.File;
	
	
	/**
	 * Provider for resources that are loaded from a packed (zipped) resource container file.
	 */
	public final class PackedResourceProvider extends ResourceProvider implements IResourceProvider
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _loader:ZipLoader;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function PackedResourceProvider(id:String = null)
		{
			super(id);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init(arg:* = null):Boolean
		{
			var path:String = _basePath + _resourceFolder;
			if (!stringIsEmptyOrNull(path)) path += "/" + arg;
			else path = arg;
			
			var zipFile:File = File.applicationDirectory.resolvePath(path);
			
			if (!zipFile.exists)
			{
				Log.error("The resource package file \"" + path + "\" could not be found!", this);
				return false;
			}
			
			ZipLoader.bufferSize = config.getNumber(Config.IO_ZIP_STREAM_BUFFERSIZE);
			//ZipLoader.bufferSize = 262144; // 256KB
			//ZipLoader.bufferSize = 1048576; // 1MB
			
			_loader = new ZipLoader(zipFile);
			_loader.distributedLoading = true;
			_loader.openSignal.add(onLoaderOpen);
			_loader.closeSignal.add(onLoaderClose);
			_loader.errorSignal.add(onLoaderError);
			
			return true;
		}
		
		
		/**
		 * Opens the PackedResourceProvider.
		 */
		public function open():void
		{
			if (_loader) _loader.open();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function loadResourceBulk(bulk:ResourceBulk):void
		{
			if (!_loader || !_loader.opened) return;
			super.loadResourceBulk(bulk);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_loader.openSignal.remove(onLoaderOpen);
			_loader.closeSignal.remove(onLoaderClose);
			_loader.errorSignal.remove(onLoaderError);
			_loader.fileOpenSignal.remove(onBulkFileOpen);
			_loader.fileProgressSignal.remove(onBulkFileProgress);
			_loader.fileCompleteSignal.remove(onBulkFileLoaded);
			_loader.fileIOErrorSignal.remove(onBulkFileError);
			_loader.fileSecurityErrorSignal.remove(onBulkFileError);
			_loader.allCompleteSignal.remove(onLoaderComplete);
			_loader.dispose();
			_loader = null;
			super.dispose();
		}
		
		
		/**
		 * @private
		 */
		public function dump():String
		{
			if (_loader && _loader.opened) return _loader.dump(80, true);
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The ID of the PackedResourceProvider. This reflects the name of the resource
		 * package file that this provider is used for.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onLoaderOpen():void
		{
			_loader.fileOpenSignal.add(onBulkFileOpen);
			_loader.fileProgressSignal.add(onBulkFileProgress);
			_loader.fileCompleteSignal.add(onBulkFileLoaded);
			_loader.fileIOErrorSignal.add(onBulkFileError);
			_loader.fileSecurityErrorSignal.add(onBulkFileError);
			_loader.allCompleteSignal.add(onLoaderComplete);
			Log.debug("Opened resource package \"" + _loader.filename + "\".", this);
			if (_openSignal) _openSignal.dispatch(this);
		}
		
		
		private function onLoaderClose():void
		{
			if (_closeSignal) _closeSignal.dispatch(this);
		}
		
		
		private function onLoaderError(message:String):void
		{
			Log.error(message, this);
			if (_errorSignal) _errorSignal.dispatch(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function reset():void
		{
			if (!_loader) return;
			if (_loader.loading) return;
			_loader.reset();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addBulkFile(bulkFile:ResourceBulkFile):void
		{
			/* If we get false returned by the zip load it is probably because the
			 * path is wrong, so mark the resource as failed (Otherwise we'd get stuck
			 * after such a resource). */
			if (!_loader.addFile(bulkFile.resourceLoader.file))
			{
				fail(bulkFile, "Resource file with ID \"" + bulkFile.resourceLoader.file.id
					+ "\" and path \"" + bulkFile.resourceLoader.file.path
					+ "\" was not added for loading to ZipLoader.");
				return;
			}
			super.addBulkFile(bulkFile);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function loadFiles():void
		{
			_loader.load();
		}
	}
}
