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
package tetragon.env.desktop
{
	import tetragon.Main;
	import tetragon.data.Config;
	import tetragon.debug.Log;
	import tetragon.util.file.getUserDataPath;

	import com.hexagonstar.file.FileWriter;
	import com.hexagonstar.file.types.BinaryFile;
	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.util.image.IImageEncoder;
	import com.hexagonstar.util.image.JPGEncoder;
	import com.hexagonstar.util.image.PNGEncoder;

	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Stage;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	
	
	/**
	 * Manages capturing and storing of screenshots.
	 */
	public final class ScreenshotGrabber
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _stage:Stage;
		/** @private */
		//private var _view3D:View3D;
		/** @private */
		private var _fileWriter:FileWriter;
		/** @private */
		private var _encoder:IImageEncoder;
		/** @private */
		private var _filenamePrefix:String;
		/** @private */
		private var _filenameSuffix:String;
		/** @private */
		private var _path:String;
		/** @private */
		private var _counter:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ScreenshotGrabber(stage:Stage)
		{
			var main:Main = Main.instance;
			var config:Config = main.registry.config;
			
			_stage = stage;
			_counter = -1;
			_fileWriter = new FileWriter();
			_fileWriter.fileIOErrorSignal.add(onFileIOError);
			_fileWriter.fileCompleteSignal.add(onFileComplete);
			_filenamePrefix = main.appInfo.filename;
			_path = getUserDataPath() + File.separator + config.getString(Config.USER_SCREENSHOTS_FOLDER);
			
			if (config.getBoolean(Config.SCREENSHOTS_AS_JPG))
			{
				_encoder = new JPGEncoder(config.getNumber(Config.SCREENSHOTS_JPG_QUALITY));
				_filenameSuffix = "jpg";
			}
			else
			{
				_encoder = new PNGEncoder();
				_filenameSuffix = "png";
			}
			
			recallLastCounter();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Takes a screenshot of the specified display and returns it as a BitmapData. If
		 * <code>display</code> is <code>null</code>, the whole stage will be captured.
		 * 
		 * @param display The display to capture. If <code>null</code>, the stage is used.
		 * @param resizeWidth Optional target width of the captured screenshot. If 0, the
		 *        current width of the display is used.
		 * @param resizeHeight Optional target height of the captured screenshot. If 0, the
		 *        current height of the display is used.
		 * @return A BitmapData object of the captured display.
		 */
		public function takeScreenshot(display:IBitmapDrawable = null, resizeWidth:int = 0,
			resizeHeight:int = 0):BitmapData
		{
			
			if (!display) display = _stage;
			
			var m:Matrix;
			var w:Number = display['width'];
			var h:Number = display['height'];
			
			if (resizeWidth < 1 || resizeHeight < 1)
			{
				resizeWidth = w;
				resizeHeight = h;
			}
			else
			{
				m = new Matrix();
				m.scale(resizeWidth / w, resizeHeight / h);
			}
			
			var image:BitmapData = new BitmapData(resizeWidth, resizeHeight, false, 0x000000);
			// TODO Add Stage3D capturing here!
			image.draw(display, m);
			return image;
		}
		
		
		/**
		 * Takes a screenshot of the specified display and saves it to disk. If
		 * <code>display</code> is <code>null</code>, the whole stage will be captured.
		 * 
		 * @param display The display to capture. If <code>null</code>, the stage is used.
		 * @param resizeWidth Optional target width of the captured screenshot. If 0, the
		 *        current width of the display is used.
		 * @param resizeHeight Optional target height of the captured screenshot. If 0, the
		 *        current height of the display is used.
		 * @return A BitmapData object of the captured display.
		 */
		public function saveScreenshot(display:IBitmapDrawable = null, resizeWidth:int = 0,
			resizeHeight:int = 0):BitmapData
		{
			if (!display) display = _stage;
			
			var m:Matrix;
			var w:Number = display['width'];
			var h:Number = display['height'];
			
			if (resizeWidth < 1 || resizeHeight < 1)
			{
				resizeWidth = w;
				resizeHeight = h;
			}
			else
			{
				m = new Matrix();
				m.scale(resizeWidth / w, resizeHeight / h);
			}
			
			var image:BitmapData = new BitmapData(resizeWidth, resizeHeight, false, 0x000000);
			// TODO Add Stage3D capturing here!
			image.draw(display, m);
			
			var file:BinaryFile = new BinaryFile(getFilePath(), "screenshotFile" + _counter);
			file.contentAsBytes = _encoder.encode(image);
			_fileWriter.write(file);
			
			return image;
			
			//if (_stage3Ds && _stage3Ds.length > 0)
			//{
			//	for (var i:uint = 0; i < _stage3Ds.length; i++)
			//	{
			//		var c:Context3D = _stage3Ds[i].context3D;
			//		if (!c) continue;
			//		c.clear();
			//		c.drawToBitmapData(image);
			//	}
			//}
			//if (_view3D)
			//{
			//	_view3D.renderer.swapBackBuffer = false;
			//	_view3D.render();
			//	_view3D.stage3DProxy.context3D.drawToBitmapData(image);
			//	_view3D.renderer.swapBackBuffer = true;				
			//}
		}
		
		
		/*
		 * NOTE: Currently bound to Away3D for testing purposes! Later this needs to be made
		 * more engine-agnostic or changed if Tetragon receives it's own 3D render system.
		 */
		//public function registerView3D(view3D:View3D):void
		//{
		//	_view3D = view3D;
		//}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "ScreenshotGrabber";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onDirectoryListing(e:FileListEvent):void
		{
			var file:File = e.target as File;
			file.removeEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListing);
			file.removeEventListener(IOErrorEvent.IO_ERROR, onDirectoryListingError);
			if (e.files && e.files.length > 0)
			{
				var s:String = (e.files[e.files.length - 1] as File).name;
				s = s.substr(0, s.length - 4).substr(-4);
				_counter = int(s);
			}
		}
		
		
		/**
		 * @private
		 */
		private function onDirectoryListingError(e:IOErrorEvent):void
		{
			var file:File = e.target as File;
			file.removeEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListing);
			file.removeEventListener(IOErrorEvent.IO_ERROR, onDirectoryListingError);
			Log.warn("Could not get screenshot directory listing.", this);
		}
		
		
		/**
		 * @private
		 */
		private function onFileIOError(f:IFile):void
		{
			Log.error(f.errorMessage, this);
		}
		
		
		/**
		 * @private
		 */
		private function onFileComplete(f:IFile):void
		{
			Log.debug("Saved screenshot to " + f.path + ".", this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function recallLastCounter():void
		{
			var file:File = new File(_path);
			file.addEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListing);
			file.addEventListener(IOErrorEvent.IO_ERROR, onDirectoryListingError);
			file.getDirectoryListingAsync();
		}
		
		
		/**
		 * @private
		 */
		private function getFilePath():String
		{
			++_counter;
			var zeros:String;
			if (_counter < 10) zeros = "000";
			else if (_counter < 100) zeros = "00";
			else if (_counter < 1000) zeros = "0";
			else zeros = "";
			return _path + File.separator + _filenamePrefix + zeros + _counter + "." + _filenameSuffix;
		}
	}
}
