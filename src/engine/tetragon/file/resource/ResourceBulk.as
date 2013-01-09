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
	/**
	 * A resource bulk is a bulk of resources that are being loaded in the same
	 * call by the resource manager. It is created temporarily by the resource
	 * manager to load resources and contains a collection of files which in
	 * turn contain one or more resource items.
	 */
	public final class ResourceBulk
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _id:String;
		/** @private */
		private var _provider:IResourceProvider;
		/** @private */
		private var _bulkFiles:Object;
		
		/** @private */
		private var _filesLoaded:uint = 0;
		/** @private */
		private var _filesTotal:uint = 0;
		
		/** @private */
		private var _loadedHandler:Function;
		/** @private */
		private var _failedHandler:Function;
		/** @private */
		private var _completeHandler:Function;
		/** @private */
		private var _progressHandler:Function;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceBulk(id:String, p:IResourceProvider, lh:Function, fh:Function,
			ch:Function, ph:Function)
		{
			_id = id;
			_provider = p;
			_bulkFiles = {};
			
			_loadedHandler = lh;
			_failedHandler = fh;
			_completeHandler = ch;
			_progressHandler = ph;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a resource bulk item for loading to the bulk.
		 */
		internal function addItem(item:ResourceBulkItem):void
		{
			/* Get file ID for resource file. If it's a data file it has a dedicated ID,
			 * otherwise for media or raw XML files we use the path as it's ID. */
			var fileID:String = item.resource.dataFileID;
			if (fileID == null || fileID.length < 1) fileID = item.resource.path;
			
			/* Check if a file object has already been created for the data file this item
			 * is in and if not create one. */
			var f:ResourceBulkFile = _bulkFiles[fileID];
			if (f == null)
			{
				f = _bulkFiles[fileID] = new ResourceBulkFile(fileID, this);
				increaseTotalCount();
			}
			
			/* Store the item in the file object. */
			f.addItem(item);
		}
		
		
		/**
		 * Loads the resource bulk via it's assigned resource provider.
		 */
		internal function load():void
		{
			_provider.loadResourceBulk(this);
		}
		
		
		/**
		 * Increases the bulk's file complete count.
		 */
		internal function increaseLoadedCount():void
		{
			_filesLoaded++;
		}
		
		
		/**
		 * Decreases the bulk's file count. Used when bulk files failed to load.
		 */
		internal function increaseTotalCount():void
		{
			_filesTotal++;
		}
		
		
		/**
		 * Decreases the bulk's file count. Used when bulk files failed to load.
		 */
		internal function decreaseTotalCount():void
		{
			if (_filesTotal < 1) return;
			_filesTotal--;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		internal function toString():String
		{
			return "[ResourceBulk, id=" + _id + ", filesTotal=" + _filesTotal + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The ID of the resource bulk.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		/**
		 * A map containing all resource bulk files in the bulk.
		 */
		public function get bulkFiles():Object
		{
			return _bulkFiles;
		}
		
		
		public function get filesLoaded():uint
		{
			return _filesLoaded;
		}
		
		
		public function get filesTotal():uint
		{
			return _filesTotal;
		}
		
		
		internal function get isComplete():Boolean
		{
			return _filesLoaded == _filesTotal;
		}
		
		
		internal function get loadedHandler():Function
		{
			return _loadedHandler;
		}
		
		
		internal function get failedHandler():Function
		{
			return _failedHandler;
		}
		
		
		internal function get completeHandler():Function
		{
			return _completeHandler;
		}
		
		
		internal function get progressHandler():Function
		{
			return _progressHandler;
		}
	}
}
