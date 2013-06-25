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
	import tetragon.core.constants.Status;
	import tetragon.core.exception.IllegalOperationException;
	import tetragon.util.env.isAIRApplication;

	import flash.display.AVM1Movie;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	
	/**
	 * The SWFFile is a file type implementation that can be used to load SWF files. It
	 * uses the AS3 Loader class to load the SWF file and then provides getters to obtain
	 * a MovieClip of the Loader content or the Loader directly.
	 * 
	 * @see com.hexagonstar.file.types.IFile
	 */
	public class SWFFile extends BinaryFile implements IFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _loader:Loader;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the file class.
		 * 
		 * @param path The path of the file that this file object is used for.
		 * @param id An optional ID for the file.
		 * @param priority An optional load priority for the file. Used for loading with the
		 *            BulkLoader class.
		 * @param weight An optional weight for the file. Used for weighted loading with the
		 *            BulkLoader class.
		 * @param callback An optional callback method that can be associated with the file.
		 * @param params An optional array of parameters that can be associated with the file.
		 */
		public function SWFFile(path:String = null, id:String = null, priority:Number = NaN,
			weight:int = 1, callback:Function = null, params:Array = null)
		{
			super(path, id, priority, weight, callback, params);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get fileTypeID():int
		{
			return FileTypeIndex.SWF_FILE_ID;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get content():*
		{
			return contentAsMovieClip;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set contentAsBytes(v:ByteArray):void
		{
			if (!_loader) _loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onComplete);
			
			var lc:LoaderContext = new LoaderContext(false,
				new ApplicationDomain(ApplicationDomain.currentDomain));
			
			/* allowCodeImport is only available for AIR and throws an exception if
			 * we don't check for AIR! TODO Make sure that this check is safe enough! */
			if (isAIRApplication())
			{
				try
				{
					lc["allowLoadBytesCodeExecution"] = true;
				}
				catch (err1:Error)
				{
					/* TODO allowLoadBytesCodeExecution property changed in AIR runtime!
					 * Give an error message?  */
				}
				
				try
				{
					lc["allowCodeImport"] = true;
				}
				catch (err2:Error)
				{
					/* Same as above! allowCodeImport is deprecated! */
				}
			}
			
			try
			{
				_loader.loadBytes(v, lc);
				_valid = true;
				_status = Status.OK;
			}
			catch (err:Error)
			{
				_valid = false;
				_status = err.message;
			}
		}
		
		
		/**
		 * The SWFFile content, as a MovieClip.
		 */
		public function get contentAsMovieClip():MovieClip
		{
			if (!_loader) return null;
			if (_loader.content is AVM1Movie)
			{
				throw new IllegalOperationException("The loaded content is an AVM1Movie. Use the"
					+ " contentAsAVM1 accessor instead.");
				return null;
			}
			return MovieClip(_loader.content);
		}
		
		
		/**
		 * The SWFFile content, as a AVM1Movie.
		 */
		public function get contentAsAVM1():AVM1Movie
		{
			if (!_loader) return null;
			if (_loader.content is MovieClip)
			{
				throw new IllegalOperationException("The loaded content is a MovieClip. Use the"
					+ " contentAsMovieClip accessor instead.");
				return null;
			}
			return AVM1Movie(_loader.content);
		}
		
		
		/**
		 * The Loader object that loaded the SWFFile content internally.
		 */
		public function get loader():Loader
		{
			return _loader;
		}
		
		
		/**
		 * Determines whether loaded SWF content is AVM1 content or not.
		 */
		public function get isAVM1():Boolean
		{
			if (_loader && _loader.content is AVM1Movie) return true;
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onComplete(e:Event):void 
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onComplete);
			complete();
		}
	}
}
