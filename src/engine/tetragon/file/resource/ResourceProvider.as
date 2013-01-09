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
	import tetragon.ClassRegistry;
	import tetragon.Main;
	import tetragon.data.Config;
	import tetragon.debug.Log;
	import tetragon.file.parsers.DataObjectParser;
	import tetragon.file.parsers.IFileDataParser;
	import tetragon.file.resource.loaders.ResourceLoader;
	import tetragon.file.resource.loaders.XMLResourceLoader;

	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.reflection.getClassName;
	
	
	/**
	 * Abstract base class for resource providers.
	 * 
	 * <p>A resource provider provides resources from a specific source to the resource
	 * manager. Such a source can simply be file data, packed data or embedded data.</p>
	 */
	public class ResourceProvider implements IResourceProvider
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _classRegistry:ClassRegistry;
		/** @private */
		private var _config:Config;
		/** @private */
		private var _resourceManager:ResourceManager;
		
		/**
		 * ID of the resource provider, if necessary (PackedResourceProvider needs it!)
		 * @private
		 */
		protected var _id:String;
		
		/** @private */
		protected var _basePath:String;
		/** @private */
		protected var _resourceFolder:String;
		
		/**
		 * A map that stores ResourceBulkFile objects temporarily for loading, used to
		 * keep track of them in event handlers. Bulk files are mapped by their ID.
		 * @private
		 */
		protected var _bulkFiles:Object;
		
		/** @private */
		protected var _lastBulkFile:ResourceBulkFile;
		
		/**
		 * Determines if a loader has completed loading all files.
		 * @private
		 */
		protected var _loaderComplete:Boolean;
		
		/**
		 * Determines if a bulk has completed processing.
		 * @private
		 */
		protected var _bulkComplete:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signal
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _openSignal:Signal;
		/** @private */
		protected var _closeSignal:Signal;
		/** @private */
		protected var _errorSignal:Signal;
		/** @private */
		protected var _fileLoadedSignal:Signal;
		/** @private */
		protected var _fileFailedSignal:Signal;
		/** @private */
		protected var _bulkProgressSignal:Signal;
		/** @private */
		protected var _bulkLoadedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceProvider(id:String = null)
		{
			_config = Main.instance.registry.config;
			_resourceManager = Main.instance.resourceManager;
			_classRegistry = Main.instance.classRegistry;
			
			_id = id;
			_basePath = _config.getString(Config.IO_BASE_PATH);
			_resourceFolder = _config.getString(Config.RESOURCE_FOLDER);
			_bulkFiles = {};
			
			_bulkProgressSignal = new Signal();
			_fileLoadedSignal = new Signal();
			_fileFailedSignal = new Signal();
			_bulkLoadedSignal = new Signal();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function init(arg:* = null):Boolean
		{
			/* Abstract method! */
			return false;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function loadResourceBulk(bulk:ResourceBulk):void
		{
			for each (var bf:ResourceBulkFile in bulk.bulkFiles)
			{
				createLoaderFor(bf);
				if (bf.resourceLoader) addBulkFile(bf);
			}
			loadFiles();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_bulkFiles = null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get bulkProgressSignal():Signal
		{
			return _bulkProgressSignal;
		}
		
		
		public function get fileLoadedSignal():Signal
		{
			return _fileLoadedSignal;
		}
		
		
		public function get fileFailedSignal():Signal
		{
			return _fileFailedSignal;
		}
		
		
		public function get bulkLoadedSignal():Signal
		{
			return _bulkLoadedSignal;
		}
		
		
		internal function get openSignal():Signal
		{
			if (!_openSignal) _openSignal = new Signal();
			return _openSignal;
		}
		
		
		internal function get closeSignal():Signal
		{
			if (!_closeSignal) _closeSignal = new Signal();
			return _closeSignal;
		}
		
		
		internal function get errorSignal():Signal
		{
			if (!_errorSignal) _errorSignal = new Signal();
			return _errorSignal;
		}
		
		
		/**
		 * A reference to the resource manager.
		 */
		protected function get resourceManager():ResourceManager
		{
			return _resourceManager;
		}
		
		
		protected function get config():Config
		{
			return _config;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		protected function onBulkFileOpen(file:IFile):void
		{
		}
		
		
		protected function onBulkFileProgress(progress:BulkProgress):void
		{
			var bf:ResourceBulkFile = _bulkFiles[progress.file.id];
			if (!bf && _lastBulkFile) bf = _lastBulkFile;
			_bulkProgressSignal.dispatch(bf, progress);
		}
		
		
		protected function onBulkFileLoaded(file:IFile):void
		{
			var bf:ResourceBulkFile = _bulkFiles[file.id];
			bf.resourceLoader.initSuccessSignal.addOnce(onResourceInitSuccess);
			bf.resourceLoader.initFailedSignal.addOnce(onResourceInitFailed);
			bf.resourceLoader.initialize();
		}
		
		
		protected function onResourceInitSuccess(bf:ResourceBulkFile):void
		{
			if (bf.resourceLoader is XMLResourceLoader) parseXMLResource(bf);
			else parseMediaResource(bf);
		}
		
		
		protected function onResourceInitFailed(bf:ResourceBulkFile, message:String):void
		{
			fail(bf, message);
		}
		
		
		protected function onBulkFileError(file:IFile):void
		{
			var bf:ResourceBulkFile = _bulkFiles[file.id];
			fail(bf, file.errorMessage);
		}
		
		
		protected function onLoaderComplete(file:IFile):void
		{
			_loaderComplete = true;
			if (_bulkComplete) finishBulk(_lastBulkFile);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Resets the resource provider.
		 */
		protected function reset():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Tries to instantiate the resource loader class for the resource in the specified
		 * bulk file.
		 * 
		 * @param bulkFile
		 */
		protected function createLoaderFor(bulkFile:ResourceBulkFile):void
		{
			var loader:ResourceLoader;
			var item:ResourceBulkItem = bulkFile.item;
			var clazz:Class = item.resource.loaderClass;
			try
			{
				loader = new clazz();
			}
			catch (err:Error)
			{
				fail(bulkFile, "The specified resource loader class \"" + item.resource.loaderClass
					+ "\" for resource with ID \"" + item.resource.id + "\" could not be"
					+ " instantiated because it is not of type ResourceLoader (" + err.message + ").");
				return;
			}
			
			bulkFile.resourceLoader = loader;
		}
		
		
		/**
		 * Adds a resource bulk file for loading.
		 * 
		 * @param bulkFile
		 */
		protected function addBulkFile(bulkFile:ResourceBulkFile):void
		{
			/* Don't allow to re-add bulk files that are currently processed! */
			if (_bulkFiles[bulkFile.id] == null)
			{
				_bulkFiles[bulkFile.id] = bulkFile;
			}
		}
		
		
		/**
		 * Starts loading all resource files that were added with addLoadFile().
		 */
		protected function loadFiles():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @param bulkFile
		 */
		protected function parseXMLResource(bulkFile:ResourceBulkFile):void
		{
			var rl:XMLResourceLoader = XMLResourceLoader(bulkFile.resourceLoader);
			if (!rl.valid)
			{
				fail(bulkFile, rl.status);
				return;
			}
			
			var resourceType:String = bulkFile.resourceType;
			var resourceFamily:String = bulkFile.resourceFamily;
			var parser:IFileDataParser;
			
			if (resourceFamily == ResourceFamily.TEXT)
			{
				parser = _classRegistry.createDataTypeParser(resourceFamily);
				if (parser)
				{
					parser.parse(rl, resourceManager.stringIndex);
				}
				else
				{
					fail(bulkFile, "Failed parsing text resource from " + bulkFile.id
						+ "! Text parser not created.");
					return;
				}
			}
			else if (resourceFamily == ResourceFamily.XML)
			{
				parser = _classRegistry.createDataTypeParser(ResourceFamily.XML);
				parser.parse(rl, resourceManager.resourceIndex);
			}
			else
			{
				if (!resourceType || resourceType.length < 1)
				{
					fail(bulkFile, "Data resource has no type defined (ResourceBulkFile ID: "
						+ bulkFile.id + ").");
					return;
				}
				
				/* Resources of family ResourceFamily.DATA use a parser that is mapped
				 * with their data type. Other data resources (entities) are always mapped
				 * with their resource family name. */
				if (bulkFile.resourceFamily == ResourceFamily.DATA)
				{
					parser = _classRegistry.createDataTypeParser(resourceType);
				}
				else
				{
					parser = _classRegistry.createDataTypeParser(bulkFile.resourceFamily);
				}
				
				if (parser)
				{
					parser.parse(rl, resourceManager.resourceIndex);
				}
				else
				{
					fail(bulkFile, "Failed parsing data resource from " + bulkFile.id
						+ "! Data parser not created.");
					return;
				}
			}
			
			/* Check if referenced resources need to be loaded. */
			if (parser is DataObjectParser)
			{
				loadReferencedResources(DataObjectParser(parser).referencedIDs, bulkFile);
			}
			
			/* Mark all resources in the loaded bulk file as loaded. */
			for (var i:uint = 0; i < bulkFile.items.length; i++)
			{
				bulkFile.items[i].resource.setStatus(ResourceStatus.LOADED);
			}
			
			_fileLoadedSignal.dispatch(bulkFile);
			bulkFile.bulk.increaseLoadedCount();
			checkBulkComplete(bulkFile);
		}
		
		
		/**
		 * @param bulkFile
		 */
		protected function parseMediaResource(bulkFile:ResourceBulkFile):void
		{
			var r:Resource = bulkFile.item.resource;
			r.setContent(bulkFile.resourceLoader.content);
			r.setStatus(ResourceStatus.LOADED);
			_fileLoadedSignal.dispatch(bulkFile);
			bulkFile.bulk.increaseLoadedCount();
			checkBulkComplete(bulkFile);
		}
		
		
		/**
		 * @param referencedIDs
		 * @param bf
		 */
		protected function loadReferencedResources(referencedIDs:Object, bf:ResourceBulkFile):void
		{
			if (!referencedIDs) return;
			var a:Array = [];
			for (var refID:String in referencedIDs)
			{
				var resID:String = referencedIDs[refID];
				a.push(refID);
				Log.debug(bf.id + " requested referenced resource with ID \"" + refID + "\".", this);
			}
			resourceManager.enqueueReferencedResources(a);
		}
		
		
		/**
		 * Checks whether all resources in the current bulk have been processed.
		 * 
		 * It's not guaranteed which occurs first: all resources have been processed
		 * or the loader has completed. So to make sure that the current loaded bulk
		 * is finished and ready for use we wait until both the resources and the
		 * loader is complete.
		 * 
		 * @param bulkFile
		 */
		protected function checkBulkComplete(bulkFile:ResourceBulkFile):void
		{
			if (bulkFile.resourceLoader) bulkFile.resourceLoader.dispose();
			
			/* Finished files can be removed from temporary map now. */
			delete _bulkFiles[bulkFile.id];
			
			if (bulkFile.bulk.isComplete)
			{
				/* We have to store the last bulkfile here because it would be removed
				 * from the bulkFiles map when needed in onLoaderComplete handler! */
				_lastBulkFile = bulkFile;
				_bulkComplete = true;
				if (_loaderComplete) finishBulk(bulkFile);
			}
		}
		
		
		/**
		 * @param bulkFile
		 */
		protected function finishBulk(bulkFile:ResourceBulkFile):void
		{
			_lastBulkFile = null;
			_bulkComplete = false;
			_loaderComplete = false;
			reset();
			_bulkLoadedSignal.dispatch(bulkFile);
		}
		
		
		/**
		 * @param bulkFile
		 * @param message
		 */
		protected function fail(bulkFile:ResourceBulkFile, message:String = null):void
		{
			/* Mark all resources in the failed bulk file as failed. */
			for (var i:uint = 0; i < bulkFile.items.length; i++)
			{
				bulkFile.items[i].resource.setStatus(ResourceStatus.FAILED);
			}
			bulkFile.bulk.decreaseTotalCount();
			_fileFailedSignal.dispatch(bulkFile, message);
			checkBulkComplete(bulkFile);
		}
	}
}
