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
package tetragon.file.loaders
{
	import tetragon.BuildType;
	import tetragon.data.Config;
	import tetragon.debug.Log;

	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.file.types.TextFile;
	import com.hexagonstar.util.display.StageReference;

	import flash.events.Event;
	import flash.filesystem.File;
	
	
	/**
	 * File loader for loading ini files.
	 */
	public class IniFileLoader extends FileLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _useDefaultFilePath:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function IniFileLoader()
		{
			super();
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function addFile(filePath:String, fileID:String = null):void
		{
			if (!_loader || _loader.loading) return;
			_loader.addFile(new TextFile(filePath, fileID));
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initiates parsing of the loaded ini file into the model object.
		 */
		override public function onAllFilesComplete(file:IFile):void
		{
			super.onAllFilesComplete(file);
			_loader.reset();
			
			if (_useDefaultFilePath)
			{
				Log.verbose("Loaded \"" + file.id + "\" file from application path.", this);
			}
			
			if (file.valid)
			{
				parse(TextFile(file));
			}
			else
			{
				notifyError("File invalid or not found \"" + file.toString() + "\" ("
					+ file.status + ")");
			}
		}
		
		
		override public function onFileIOError(file:IFile):void
		{
			if (!_useDefaultFilePath)
			{
				Log.notice("Couldn't load \"" + file.path + "\" from user folder. Trying"
					+ " application path ...", this);
				_useDefaultFilePath = true;
				/* Delay by one frame because BulkLoader is still in use and cannot be reset. */
				StageReference.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			else
			{
				Log.warn("Couldn't load \"" + file.id + "\" file from application path ("
					+ file.path + ")!", this);
				notifyLoadError(file);
			}
		}
		
		
		protected function onEnterFrame(e:Event):void
		{
			StageReference.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if (_loader) _loader.reset();
			loadFromApplicationPath();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		protected function init():void
		{
			/* Abstract method! */
		}
		
		
		protected function loadFromApplicationPath():void
		{
			/* Abstract method! */
		}
		
		
		protected function getApplicationIniPathFor(filename:String):String
		{
			var path:String = main.appInfo.configFolder;
			if (path == null) path = "";
			if (path.length > 0) path += separator;
			path += filename;
			
			if (main.appInfo.buildType == BuildType.WEB)
			{
				path = config.getString(Config.IO_BASE_PATH) + path;
			}
			else
			{
				path = File.applicationDirectory.resolvePath(path).nativePath;
			}
			return path;
		}
		
		
		/**
		 * Parses text from a text-based ini file.
		 */
		protected function parse(file:TextFile):void
		{
			/* Abstract method! */
		}
	}
}
