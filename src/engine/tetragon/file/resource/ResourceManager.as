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
	import tetragon.core.file.BulkProgress;
	import tetragon.core.signals.Signal;
	import tetragon.data.Config;
	import tetragon.debug.Log;
	import tetragon.file.resource.processors.ResourceProcessor;
	import tetragon.util.structures.IIterator;
	import tetragon.util.structures.queues.Queue;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	
	public final class ResourceManager extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _helper:ResourceManagerHelper;
		/** @private */
		private var _resourceProviders:Dictionary;
		/** @private */
		private var _usePackages:Boolean;
		/** @private */
		private var _bulkIDCount:uint;
		/** @private */
		private var _waitingHandlers:Object;
		/** @private */
		private var _referencedIDQueue:Queue;
		/** @private */
		private var _resourceIndex:ResourceIndex;
		/** @private */
		private var _stringIndex:StringIndex;
		/** @private */
		private var _classRegistry:ClassRegistry;
		/** @private */
		private var _locale:String;
		/** @private */
		private var _isDebug:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		// TODO Add full support for signals in addition to already available callback handlers.
		
		/** @private */
		private var _completeSignal:Signal;
		/** @private */
		private var _loadedSignal:Signal;
		/** @private */
		private var _failedSignal:Signal;
		/** @private */
		private var _progressSignal:Signal;
		/** @private */
		private var _alreadyLoadedSignal:Signal;
		
		/** @private */
		private var _localeSwitchCompleteSignal:Signal;
		/** @private */
		private var _localeSwitchFailedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the Resource Manager. Called automatically in the InitApplicationCommand
		 * command.
		 * 
		 * @param resourceBundle Optional class object that acts as a bundle of embedded resources.
		 */
		public function init(resourceBundleClass:Class = null):void
		{
			dispose();
			
			_bulkIDCount = 0;
			_waitingHandlers = {};
			_stringIndex = new StringIndex();
			_classRegistry = Main.instance.classRegistry;
			_helper = new ResourceManagerHelper();
			_helper.init(resourceBundleClass);
			_isDebug = Main.instance.appInfo.isDebug;
		}
		
		
		/**
		 * Loads one or more resources either from the file system, from a packed resource
		 * file or from embedded files.
		 * 
		 * @param resourceIDs Can be one of the following: a string containing one resource
		 *        ID, an array with one or more resource IDs or a queue with one or more
		 *        resource IDs.
		 * @param completeHandler An optional callback handler that is called after all
		 *        resources have completed the load procedure, regardless if some or all
		 *        of them failed or succeeded to load.
		 * @param loadedHandler An optional callback handler that is called everytime a
		 *        resource has been loaded.
		 * @param failedHandler An optional callback handler that is called everytime a
		 *        resource failed to load.
		 * @param alreadyLoadedHandler An optional handler that is called in case all
		 *        the resources have already been loaded or failed to load before.
		 * @param forceReload If true the resource manager will reload the resource
		 *        again from it's file, even if it already has been loaded or failed.
		 */
		public function load(resourceIDs:*, completeHandler:Function = null,
			loadedHandler:Function = null, failedHandler:Function = null,
			progressHandler:Function = null, alreadyLoadedHandler:Function = null,
			forceReload:Boolean = false):void
		{
			if (resourceIDs == null) return;
			
			var items:Array = [];
			var n:int;
			
			if (resourceIDs is Queue)
			{
				var i:IIterator = Queue(resourceIDs).iterator;
				while (i.hasNext)
				{
					items.push(new ResourceBulkItem(i.next));
				}
			}
			else if (resourceIDs is Array)
			{
				var a:Array = resourceIDs;
				for (n = 0; n < a.length; n++)
				{
					items.push(new ResourceBulkItem(a[n]));
				}
			}
			else if (resourceIDs is String)
			{
				items.push(new ResourceBulkItem(resourceIDs));
			}
			else
			{
				return;
			}
			
			var tmpItems:Array = items.concat();
			var done:int = 0;
			var item:ResourceBulkItem;
			var r:Resource;
			
			/* Check if any of the included resourceIDs are for a resource collection. */
			for (n = 0; n < tmpItems.length; n++)
			{
				item = tmpItems[n];
				r = _resourceIndex.getResource(item.resourceID);
				if (!r || r.family != ResourceFamily.COLLECTION) continue;
				
				items[n] = null;
				var collection:ResourceCollection = r.content;
				debug("Loading resource collection \"" + collection.id + "\" ...");
				for each (var id:String in collection.resourceIDs)
				{
					items.push(new ResourceBulkItem(id));
				}
			}
			
			/* Create temporary bulks used to load one or more resources in one go. */
			var bulk1:ResourceBulk;
			var bulk2:ResourceBulk;
			var bulk3:ResourceBulk;
			
			var total:int = items.length;
			for (n = 0; n < total; n++)
			{
				item = items[n];
				if (!item)
				{
					done++;
					continue;
				}
				
				r = _resourceIndex.getResource(item.resourceID);
				item.setResource(r);
				
				/* Check if a resource for the specified ID actually exists. */
				if (!r)
				{
					notifyFailed(item, failedHandler, "A resource with the ID \""
						+ item.resourceID + "\" does not exist in the resource index.");
					done++;
					continue;
				}
				
				/* If resource was loaded but we want to force a reload, reset the resource. */
				if (forceReload)
				{
					_resourceIndex.resetResource(r.id);
				}
				
				/* Resource has already been loaded. */
				if (r.status == ResourceStatus.LOADED || r.status == ResourceStatus.PROCESSED)
				{
					debug("Resource \"" + r.id + "\" has already been loaded.");
					r.increaseReferenceCount();
					notifyLoaded(item, loadedHandler);
					done++;
					continue;
				}
				
				/* Resource has failed to load before. Don't try again! */
				if (r.status == ResourceStatus.FAILED)
				{
					notifyFailed(item, failedHandler, "The resource with ID \"" + item.resourceID
						+ "\" has previously failed to load and is not being loaded again.");
					done++;
					continue;
				}
				
				/* Resource is currently loading, hook up to any listeners if we got them. */
				if (r.status == ResourceStatus.LOADING)
				{
					debug("Resource \"" + r.id + "\" is already loading.");
					r.increaseReferenceCount();
					var vo:HandlerVO = new HandlerVO(completeHandler, loadedHandler, failedHandler,
						progressHandler);
					if (_waitingHandlers[r.id] == null) _waitingHandlers[r.id] = [];
					(_waitingHandlers[r.id] as Array).push(vo);
					continue;
				}
				
				/* Resource needs to be loaded so check from which provider we can get it. */
				if (r.status == ResourceStatus.INIT)
				{
					r.setStatus(ResourceStatus.LOADING);
					if (r.embedded)
					{
						debug("Loading resource \"" + r.id + "\" (embedded).");
						if (!bulk1)
						{
							bulk1 = new ResourceBulk(createBulkID(), getResourceProvider(
								EmbeddedResourceProvider.ID), loadedHandler, failedHandler,
								completeHandler, progressHandler, alreadyLoadedHandler);
						}
						bulk1.addItem(item);
					}
					else
					{
						/* Load resource from a resource package. */
						if (_usePackages && r.packageID && r.packageID.length > 0)
						{
							debug("Loading resource \"" + r.id + "\" (packed).");
							if (!bulk2)
							{
								bulk2 = new ResourceBulk(createBulkID(), getResourceProvider(
									r.packageID), loadedHandler, failedHandler, completeHandler,
										progressHandler, alreadyLoadedHandler);
							}
							bulk2.addItem(item);
						}
						/* Otherwise load loose resource from harddisk. */
						else
						{
							debug("Loading resource \"" + r.id + "\".", r);
							if (!bulk3)
							{
								bulk3 = new ResourceBulk(createBulkID(), getResourceProvider(
									LoadedResourceProvider.ID), loadedHandler, failedHandler,
									completeHandler, progressHandler, alreadyLoadedHandler);
							}
							bulk3.addItem(item);
						}
					}
				}
			}
			
			if (bulk1) bulk1.load();
			if (bulk2) bulk2.load();
			if (bulk3) bulk3.load();
			
			Log.debug("total: " + total + ", done: " + done, this);
			
			/* If all failed/already loaded it means none of them went through any resource
			 * provider but we still want the complete handler to be notified after that. */
			if (done == total)
			{
				if (alreadyLoadedHandler != null) alreadyLoadedHandler();
				else notifyComplete(completeHandler);
			}
		}
		
		
		/**
		 * Unloads previously loaded resources. This does not necessarily mean the resource
		 * will be available for garbage collection. Resources are reference counted so if
		 * the specified resource has been loaded multiple times, its reference count will
		 * only decrease as a result of this.
		 * 
		 * @param resourceIDs IDs of the resources to unload.
		 * @return The resource's reference count.
		 */
		public function unload(resourceIDs:*):void
		{
			if (resourceIDs == null) return;
			
			var ids:Array = [];
			var n:int;
			
			if (resourceIDs is Queue)
			{
				var i:IIterator = Queue(resourceIDs).iterator;
				while (i.hasNext)
				{
					ids.push(i.next);
				}
			}
			else if (resourceIDs is Array)
			{
				ids = resourceIDs;
			}
			else if (resourceIDs is String)
			{
				ids.push(resourceIDs);
			}
			else
			{
				return;
			}
			
			var tmpIDs:Array = ids.concat();
			var r:Resource;
			var id:String;
			
			/* Check if any of the included resourceIDs are for a resource collection. */
			for (n = 0; n < tmpIDs.length; n++)
			{
				id = tmpIDs[n];
				r = _resourceIndex.getResource(id);
				if (!r) continue;
				if (r.family != ResourceFamily.COLLECTION) continue;
				
				ids[n] = null;
				var collection:ResourceCollection = r.content;
				debug("Unloading resource collection \"" + collection.id + "\" ...");
				for each (var s:String in collection.resourceIDs)
				{
					ids.push(s);
				}
			}
			
			for (n = 0; n < ids.length; n++)
			{
				id = ids[n];
				if (id == null) continue;
				
				r = _resourceIndex.getResource(id);
				if (!r) continue;
				debug("Unloading resource \"" + r.id + "\".");
				r.decreaseReferenceCount();
				if (r.referenceCount < 1)
				{
					/* If the to be removed resource is a text resource,
					 * also remove all of it's strings. */
					if (r.type == ResourceFamily.TEXT)
					{
						_stringIndex.removeStrings(r.content);
					}
					_resourceIndex.resetResource(id);
				}
			}
		}
		
		
		/**
		 * Forces an unload of all loaded resources.
		 */
		public function unloadAll():void
		{
			if (_stringIndex) _stringIndex.removeAll();
			if (_resourceIndex) _resourceIndex.resetAll();
		}
		
		
		/**
		 * Checks if a resource is loaded and ready to go.
		 * 
		 * @param resourceID
		 * @return true or false.
		 */
		public function isResourceLoaded(resourceID:String):Boolean
		{
			var r:Resource = _resourceIndex.getResource(resourceID);
			if (!r) return false;
			return r.status == ResourceStatus.LOADED;
		}
		
		
		/**
		 * Checks if a resource is currently in the process of being loaded.
		 * 
		 * @param resourceID
		 * @return true or false.
		 */
		public function isResourceLoading(resourceID:String):Boolean
		{
			var r:Resource = _resourceIndex.getResource(resourceID);
			if (!r) return false;
			return r.status == ResourceStatus.LOADING;
		}
		
		
		/**
		 * Checks whether all resources related to the IDs in the specified resourceIDs
		 * array have already been loaded or already failed loading before or not.
		 * 
		 * @param resourceIDs Resource IDs to check.
		 * @return true if all specified resources have already been loaded or failed
		 *         loading before or false if any of the resources haven't been loaded
		 *         yet or are still loading.
		 */
		public function checkAllResourcesLoaded(resourceIDs:Array):Boolean
		{
			if (!resourceIDs) return false;
			for (var i:uint = 0; i < resourceIDs.length; i++)
			{
				var r:Resource = _resourceIndex.getResource(resourceIDs[i]);
				if (!r) return false;
				if (r.status != ResourceStatus.LOADED && r.status != ResourceStatus.FAILED)
				{
					return false;
				}
			}
			return true;
		}
		
		
		/**
		 * Returns the reference count of the resource with the specified ID.
		 * 
		 * @param resourceID
		 * @return reference count.
		 */
		public function getRefCountFor(resourceID:String):int
		{
			var r:Resource = _resourceIndex.getResource(resourceID);
			if (!r) return 0;
			return r.referenceCount;
		}
		
		
		/**
		 * Returns the resource provider that is used to provide the resource with the
		 * specified id. Embedded and loaded resources both use their own provider and
		 * are identified with either EmbeddedResourceProvider.ID or LoadedResourceProvider.ID
		 * but packed resources are identified by their package file ID since every package
		 * file needs to use it's own dedicated resource provider.
		 * 
		 * @param id
		 */
		public function getResourceProvider(id:String):IResourceProvider
		{
			return _resourceProviders[id];
		}
		
		
		/**
		 * Processes the specified resource using a suitable resource processor.
		 * 
		 * @param resourceID The resource ID to process.
		 * @param force If true forces processing the resource even it has already been processed.
		 * @return The resource content or null.
		 */
		public function process(resourceID:String, force:Boolean = false):*
		{
			if (resourceID == null) return null;
			var resource:Resource = resourceIndex.getResource(resourceID);
			if (!resource)
			{
				error("Failed to process resource \"" + resourceID
					+ "\". Either the specified resource ID is wrong or the resource"
					+ " has not yet been loaded.");
				return null;
			}
			
			if (!force && resource.status == ResourceStatus.PROCESSED)
			{
				return resource.content;
			}
			
			var clazz:Class = _classRegistry.getResourceProcessorClass(resource.type);
			if (!clazz)
			{
				error("Failed to process resource \"" + resource.id
					+ "\". No processor class is registered for it's dataType \""
					+ resource.type + "\".");
				return null;
			}
			
			var processor:ResourceProcessor;
			try
			{
				processor = new clazz();
			}
			catch (err:Error)
			{
				error("Failed to process resource \"" + resource.id
					+ "\". The registered processor class for dataType \""
					+ resource.type + "\" is not of type ResourceProcessor.");
				return null;
			}
			
			//Log.debug("Processing resource \"" + resourceID + "\" with " + processor.toString() + " ...", this);
			processor.process(resource);
			resource.setStatus(ResourceStatus.PROCESSED);
			return resource.content;
		}
		
		
		/**
		 * Switches text resources to a different locale and optionally re-loads all
		 * text resources that have already been loaded so that the text resources for
		 * the switched-to locale are available in the application.
		 * 
		 * <p>To be able to detect when the locale switching has been completed or failed
		 * (regardless of whether text resources are being reloaded or not) listen to
		 * the two signals localeSwitchCompleteSignal and localeSwitchFailedSignal.
		 * Both signals dispatch the switched-to locale ID as a parameter. Additionally
		 * localeSwitchFailedSignal disptaches the failed resource as a parameter.</p>
		 * 
		 * <p>If reloadTextResources is set to false only the 'current locale' config
		 * property will be changed and any text resources have to be re-loaded
		 * manually.</p>
		 * 
		 * @param locale The locale to switch to.
		 * @param reloadTextResources If true all currently loaded text resources will
		 *        be unloaded and then reloaded.
		 */
		public function switchToLocale(locale:String, reloadTextResources:Boolean = true):void
		{
			if (locale == null || !_resourceIndex.localePaths) return;
			_locale = locale.toLowerCase();
			var localePath:String = _resourceIndex.localePaths[_locale];
			if (localePath == null || localePath == "")
			{
				error("Failed switching to locale \"" + _locale
					+ "\". No path has been defined in the resource index for this locale.");
				if (_localeSwitchFailedSignal) _localeSwitchFailedSignal.dispatch(_locale, null);
				return;
			}
			
			Main.instance.registry.config.setProperty(Config.LOCALE_CURRENT, _locale);
			
			var resources:Object = _resourceIndex.resources;
			var reloadIDs:Array = [];
			
			/* Update path of all text resources. */
			for each (var r:Resource in resources)
			{
				if (r.family == ResourceFamily.TEXT)
				{
					r.updatePath(localePath + r.path.substr(r.path.lastIndexOf("/") + 1));
					if (reloadTextResources)
					{
						reloadIDs.push(r.id);
					}
				}
			}
			
			if (!reloadTextResources)
			{
				if (_localeSwitchCompleteSignal) _localeSwitchCompleteSignal.dispatch();
				return;
			}
			
			/* Unload and reload all currently loaded text resources. */
			unload(reloadIDs);
			load(reloadIDs, onLocaleSwitchComplete, null, onLocaleSwitchFailed);
		}
		
		
		/**
		 * dispose
		 */
		public function dispose():void 
		{
			unloadAll();
			_resourceIndex = null;
			_stringIndex = null;
		}
		
		
		/**
		 * Returns a String Representation of ResourceManager.
		 * 
		 * @return A String Representation of ResourceManager.
		 */
		override public function toString():String
		{
			return "ResourceManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The index of resources.
		 */
		public function get resourceIndex():ResourceIndex
		{
			return _resourceIndex;
		}
		
		
		/**
		 * The string index.
		 */
		public function get stringIndex():StringIndex
		{
			return _stringIndex;
		}
		
		
		public function get completeSignal():Signal
		{
			if (!_completeSignal) _completeSignal = new Signal();
			return _completeSignal;
		}
		
		
		public function get loadedSignal():Signal
		{
			if (!_loadedSignal) _loadedSignal = new Signal();
			return _loadedSignal;
		}
		
		
		public function get failedSignal():Signal
		{
			if (!_failedSignal) _failedSignal = new Signal();
			return _failedSignal;
		}
		
		
		public function get progressSignal():Signal
		{
			if (!_progressSignal) _progressSignal = new Signal();
			return _progressSignal;
		}
		
		
		public function get alreadyLoadedSignal():Signal
		{
			if (!_alreadyLoadedSignal) _alreadyLoadedSignal = new Signal();
			return _alreadyLoadedSignal;
		}
		
		
		public function get localeSwitchCompleteSignal():Signal
		{
			if (!_localeSwitchCompleteSignal) _localeSwitchCompleteSignal = new Signal();
			return _localeSwitchCompleteSignal;
		}
		
		
		public function get localeSwitchFailedSignal():Signal
		{
			if (!_localeSwitchFailedSignal) _localeSwitchFailedSignal = new Signal();
			return _localeSwitchFailedSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onResourceFileLoaded(bf:ResourceBulkFile):void
		{
			for (var i:uint = 0; i < bf.items.length; i++)
			{
				var item:ResourceBulkItem = bf.items[i];
				var r:Resource = item.resource;
				r.increaseReferenceCount();
				notifyLoaded(item, bf.bulk.loadedHandler);
				
				/* Call any waiting handlers that might have been
				 * added while the resource was loading. */
				if (_waitingHandlers[r.id])
				{
					var a:Array = _waitingHandlers[r.id];
					for (var j:uint = 0; j < a.length; j++)
					{
						notifyLoaded(item, HandlerVO(a[j]).loadedHandler);
					}
				}
			}
		}
		
		
		private function onResourceFileFailed(bf:ResourceBulkFile, message:String):void
		{
			for (var i:uint = 0; i < bf.items.length; i++)
			{
				var item:ResourceBulkItem = bf.items[i];
				var r:Resource = item.resource;
				
				notifyFailed(item, bf.bulk.failedHandler, message);
				
				/* Call any waiting handlers that might have been
				 * added while the resource was loading. */
				if (_waitingHandlers[r.id])
				{
					var a:Array = _waitingHandlers[r.id];
					for (var j:uint = 0; j < a.length; j++)
					{
						notifyFailed(item, (a[j] as HandlerVO).failedHandler, message);
					}
				}
			}
		}
		
		
		private function onResourceBulkProgress(bf:ResourceBulkFile, progress:BulkProgress):void
		{
			for (var i:uint = 0; i < bf.items.length; i++)
			{
				var item:ResourceBulkItem = bf.items[i];
				var r:Resource = item.resource;
				notifyProgress(bf.bulk.progressHandler, progress);
				
				/* Call any waiting handlers that might have been
				 * added while the resource was loading. */
				if (_waitingHandlers[r.id])
				{
					var a:Array = _waitingHandlers[r.id];
					for (var j:uint = 0; j < a.length; j++)
					{
						notifyProgress(HandlerVO(a[j]).progressHandler, progress);
					}
				}
			}
		}
		
		
		private function onResourceBulkLoaded(bf:ResourceBulkFile):void
		{
			var b:ResourceBulk = bf.bulk;
			var a:Array;
			var r:Resource;
			
			/* We can decrease the bulk ID count anytime a bulk completed loading. */
			if (_bulkIDCount > 1) _bulkIDCount--;
			
			/* If we got queued referenced resources, load these before we finish. */
			if (_referencedIDQueue && _referencedIDQueue.size > 0)
			{
				a = [];
				while (_referencedIDQueue.size > 0)
				{
					var id:String = _referencedIDQueue.dequeue();
					/* Check whether the ID is a substitution ID and a resource with the
					 * substituted ID(s) is already loaded. */
					if (_resourceIndex.isSubstitutionID(id))
					{
						r = _resourceIndex.getResourceFromSubstitutedID(id);
						if (r)
						{
							debug("Substituting resource ID \"" + id + "\" with \"" + r.id + "\".");
							id = r.id;
						}
					}
					a.push(id);
				}
				debug("Loading " + a.length + " referenced resources ...");
				load(a, b.completeHandler, b.loadedHandler, b.failedHandler, b.progressHandler,
					b.alreadyLoadedHandler);
				return;
			}
			
			_referencedIDQueue = null;
			notifyComplete(b.completeHandler);
			
			/* We still need to check if any of the bulk file's resource items has any
			 * waiting handlers assigned, call them and then remove the handlers. */
			for (var i:uint = 0; i < bf.items.length; i++)
			{
				var item:ResourceBulkItem = bf.items[i];
				r = item.resource;
				
				/* Call any waiting handlers that might have been
				 * added while the resource was loading. */
				if (_waitingHandlers[r.id])
				{
					a = _waitingHandlers[r.id];
					_waitingHandlers[r.id] = null;
					delete _waitingHandlers[r.id];
					for (var j:uint = 0; j < a.length; j++)
					{
						notifyComplete(HandlerVO(a[j]).completeHandler);
					}
				}
			}
		}
		
		
		private function onLocaleSwitchComplete():void
		{
			if (_localeSwitchCompleteSignal) _localeSwitchCompleteSignal.dispatch(_locale);
		}
		
		
		private function onLocaleSwitchFailed(r:Resource):void
		{
			if (_localeSwitchFailedSignal) _localeSwitchFailedSignal.dispatch(_locale, r);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param ids
		 */
		internal function enqueueReferencedResources(ids:Array):void
		{
			if (!_referencedIDQueue) _referencedIDQueue = new Queue();
			for (var i:uint = 0; i < ids.length; i++)
			{
				_referencedIDQueue.enqueue(ids[i]);
			}
		}
		
		
		/**
		 * Sends an event that the Resource Manager initialization has been completed.
		 */
		internal function completeInitialization():void
		{
			Log.verbose("Ready!", this);
			completeInit();
		}
		
		
		/**
		 * Sends an event that the Resource Manager initialization has failed.
		 */
		internal function failInitialization():void
		{
			error("Initialization failed!");
			completeInit();
		}
		
		
		private function completeInit():void
		{
			_usePackages = _helper._usePackages;
			_resourceProviders = _helper._resourceProviders;
			_resourceIndex = _helper._resourceIndex;
			_helper = null;
			for each (var p:IResourceProvider in _resourceProviders)
			{
				p.bulkProgressSignal.add(onResourceBulkProgress);
				p.fileFailedSignal.add(onResourceFileFailed);
				p.fileLoadedSignal.add(onResourceFileLoaded);
				p.bulkLoadedSignal.add(onResourceBulkLoaded);
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private function createBulkID():String
		{
			return "bulk" + (_bulkIDCount++);
		}
		
		
		/**
		 * @param progressHandler
		 * @param p
		 */
		private function notifyProgress(progressHandler:Function, p:BulkProgress):void
		{
			if (progressHandler != null) progressHandler(p);
		}
		
		
		/**
		 * @param item
		 * @param loadedHandler
		 */
		private function notifyLoaded(item:ResourceBulkItem, loadedHandler:Function):void
		{
			if (loadedHandler != null) loadedHandler(item.resource);
		}
		
		
		/**
		 * @param item
		 * @param failedHandler
		 */
		private function notifyFailed(item:ResourceBulkItem, failedHandler:Function,
			message:String):void
		{
			error(message);
			if (failedHandler != null) failedHandler(item.resource);
		}
		
		
		/**
		 * @param completeHandler
		 */
		private function notifyComplete(completeHandler:Function):void
		{
			if (completeHandler != null) completeHandler();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Helper Methods
		//-----------------------------------------------------------------------------------------
		
		private function debug(message:String, r:Resource = null):void
		{
			if (r && _isDebug) Log.debug(message + " (" + r.path + ")", this);
			else Log.debug(message, this);
		}
		
		
		private function error(message:String):void
		{
			Log.error(message, this);
		}
	}
}


/**
 * VO used for waiting handlers.
 */
final class HandlerVO
{
	public var completeHandler:Function;
	public var loadedHandler:Function;
	public var failedHandler:Function;
	public var progressHandler:Function;
	
	public function HandlerVO(ch:Function, lh:Function, fh:Function, ph:Function)
	{
		completeHandler = ch;
		loadedHandler = lh;
		failedHandler = fh;
		progressHandler = ph;
	}
}
