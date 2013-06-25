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
package tetragon.file.resource.loaders
{
	import tetragon.core.constants.Status;
	import tetragon.core.exception.InvalidDataException;
	import tetragon.core.file.types.IFile;
	import tetragon.core.signals.Signal;
	import tetragon.debug.Log;
	import tetragon.file.resource.ResourceBulkFile;
	import tetragon.util.reflection.getClassName;

	import flash.events.Event;
	import flash.utils.ByteArray;
	
	
	/**
	 * The base class for resource loaders. A resource loader is used by the resource
	 * manager and resource providers to load resources through the specific AS3 API that supports
	 * loading them correctly. Depending on the loaded resource file the method how it is
	 * loaded differs.
	 * 
	 * <p>For example the implementation for loading a sound file is different than that for
	 * an image file. The resource loaders take care that those files are loaded the way
	 * they need to be loaded. In other words: A resource loader essentially represents
	 * the basic resource file type.</p>
	 * 
	 * <p>Resource loaders can load files from the filesystem as well as embedded files.</p>
	 */
	public class ResourceLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _bulkFile:ResourceBulkFile;
		/** @private */
		protected var _status:String = Status.OK;
		/** @private */
		protected var _file:IFile;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _initSuccessSignal:Signal;
		/** @private */
		protected var _initFailedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceLoader()
		{
			_initSuccessSignal = new Signal();
			_initFailedSignal = new Signal();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets up the resource wrapper.
		 */
		public function setup(bulkFile:ResourceBulkFile):void
		{
			_bulkFile = bulkFile;
		}
		
		
		/**
		 * Initializes the resource file with data either from a loaded or an embedded asset.
		 * The data argument is only required to provide embedded data.
		 * 
		 * @param embeddedData The resource data from an embedded asset.
		 */
		public function initialize(embeddedData:* = null):void
		{
			if (embeddedData == null) initializeFromLoaded();
			else initializeFromEmbedded(embeddedData);
		}
		
		
		/**
		 * This method will be used by a Resource Provider to indicate that this
		 * resource file has failed loading.
		 */
		public function fail(message:String):void
		{
			onFailed(message);        	
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			if (_initSuccessSignal) _initSuccessSignal.removeAll();
			if (_initFailedSignal) _initFailedSignal.removeAll();
			_initSuccessSignal = null;
			_initFailedSignal = null;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the ID of the resource loader (which is the same as it's loaded resource).
		 */
		public function get id():String
		{
			return _bulkFile.id;
		}
		
		
		/**
		 * Returns the resource object that this resource loader acts as a loader for.
		 */
		public function get bulkFile():ResourceBulkFile
		{
			return _bulkFile;
		}
		
		
		/**
		 * Returns the resource's loaded content data.
		 */
		public function get content():*
		{
			return null;
		}
		
		
		/**
		 * The status of the resource loader. If the data was validated successfully,
		 * this is FileErrorStatus.OK, if the XML data was not validated successfully, for
		 * example because it contains malformed XML syntax, the errorStatus will contain
		 * the error message returned by the parser.
		 */
		public function get status():String
		{
			return _status;
		}
		
		
		/**
		 * Returns the file that is loaded  by the ResourceLoader. Used only by the resource
		 * provider to load the resource. Once the resource is loaded this object will be null.
		 * 
		 * @private
		 */
		public function get file():IFile
		{
			return _file;
		}
		
		
		public function get initSuccessSignal():Signal
		{
			return _initSuccessSignal;
		}
		
		
		public function get initFailedSignal():Signal
		{
			return _initFailedSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * This is called when the resource data has been fully loaded and conditioned.
		 * Returning true from this method means the load was successful. False indicates
		 * failure. Subclasses must implement this method.
		 * 
		 * @param content The fully conditioned data for this resource.
		 * @return true if content contains valid data, false otherwise.
		 */
		protected function onContentReady(content:*):Boolean
		{
			return false;
		}
		
		
		/**
		 * Called when loading and conditioning of the resource data is complete. This
		 * must be called by, and only by, subclasses that override the initialize
		 * method.
		 * 
		 * @param e This can be ignored by subclasses.
		 */
		protected function onLoadComplete(e:Event = null):void
		{
			try
			{
				if (onContentReady(e ? e.target["content"] : null))
				{
					_file = null;
					_initSuccessSignal.dispatch(_bulkFile);
					return;
				}
				else
				{
					onFailed(_status);
					return;
				}
			}
			catch(err:Error)
			{
				Log.error("Failed to load  \"" + _bulkFile.path + "\" - " + err.message, this);
			}
			
			_status = "The resource type does not match the loaded content.";
			onFailed(_status);
		}
		
		
		/**
		 * @param message
		 */
		protected function onFailed(message:String):void
		{
			_file = null;
			if (_initFailedSignal) _initFailedSignal.dispatch(_bulkFile, message);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the resource file with data from a loaded file.
		 */
		protected function initializeFromLoaded():void
		{
			if (_initSuccessSignal) _initSuccessSignal.dispatch(_bulkFile);
		}
		
		
		/**
		 * Initializes the resource file with data from an embedded file.
		 * embeddedData must be either a ByteArray or an Array of ByteArrays.
		 */
		protected function initializeFromEmbedded(embeddedData:*):void
		{
			if (!(embeddedData is ByteArray))
			{
				throwInvalidDataException("ByteArray");
			}
		}
		
		
		/**
		 * @private
		 */
		protected function throwInvalidDataException(supportedType:String):void
		{
			throw new InvalidDataException(toString() + ": Tried to initialize loader with invalid"
				+ " data! The loader only supports data of type " + supportedType
				+ " (file status: " + _file.status + ").");
		}
	}
}
