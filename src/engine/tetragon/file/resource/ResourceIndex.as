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
	import lib.display.PlaceholderBitmap;

	import tetragon.ClassRegistry;
	import tetragon.Main;
	import tetragon.data.DataObject;
	import tetragon.debug.Log;

	import com.hexagonstar.util.string.TabularText;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.system.System;
	
	
	/**
	 * The ResourceIndex is the storage index for all resources that are available
	 * to the engine. During engine startup the resource index file is being loaded
	 * and all it's resource entries are being parsed and added to the resource index
	 * from which they later can be obtained.
	 * 
	 * <p>The <code>getResource()</code> method can be used to obtain a specific
	 * resource object. Note that a resource object is not the same as the resource
	 * data that it represents. The resource data, once loaded, is stored inside a
	 * resource object and can be reached through the resource's <code>content</code>
	 * accessor or by using the resource index's <code>getResourceContent()</code>
	 * method.</p>.
	 */
	public final class ResourceIndex
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A map that stores all package file entries by their ID.
		 * @private
		 */
		internal var _packageFiles:Object;
		
		/**
		 * A map that stores all settings file entries.
		 * @private
		 */
		private var _settingsFiles:Object;
		
		/**
		 * A map that stores all data file entries. Contains ResourceDataFileEntry objects.
		 * @private
		 */
		private var _dataFiles:Object;
		
		/**
		 * A map that stores all resources. Contains Resource objects.
		 * @private
		 */
		private var _resources:Object;
		
		/**
		 * Keeps a list of all resource collection IDs.
		 * @private
		 */
		private var _resourceCollectionIDs:Object;
		
		/**
		 * A list that stores resource IDs for resources that are preloaded.
		 * @private
		 */
		private var _preloadResourceIDs:Array;
		
		/**
		 * A map that contains all available locale paths, mapped by their locale ID.
		 * @private
		 */
		private var _localePaths:Object;
		
		/**
		 * The size of the index, i.e. how many resources are mapped.
		 * @private
		 */
		private var _size:int;
		
		/**
		 * Placeholder single frame.
		 * @private
		 */
		private var _placeholderBitmap:PlaceholderBitmap;
		
		/**
		 * A placeholder object that is used for bitmap resources in case the original
		 * resource data could not be found.
		 * @private
		 */
		private var _placeholderImage:BitmapData;
		
		/**
		 * Placeholder shape used to draw placeholder image fills.
		 * @private
		 */
		private var _placeholderShape:Shape;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceIndex()
		{
			clear();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Clears all resource entries from the resource index. All defined resources will
		 * be wiped from the resource index after calling this method.
		 */
		public function clear():void
		{
			_packageFiles = {};
			_settingsFiles = {};
			_dataFiles = {};
			_resources = {};
			_resourceCollectionIDs = {};
			_size = 0;
		}
		
		
		/**
		 * Returns the package path (filename) that is stored under the specified package ID.
		 * 
		 * @param id The ID of the package file entry.
		 * @return The path (file name) of the package file entry or null.
		 */
		public function getPackagePath(id:String):String
		{
			return _packageFiles[id];
		}
		
		
		/**
		 * Returns the path of the data file entry that is mapped with the specified ID.
		 * 
		 * @param id The ID of the data file entry for which to return the path.
		 * @return The path of the data file entry or null.
		 */
		public function getDataFilePath(id:String):String
		{
			if (_dataFiles[id]) return (_dataFiles[id] as ResourceDataFileEntry).path;
			error("getDataFilePath: No data file path mapped for data file ID \"" + id + "\".");
			return null;
		}
		
		
		/**
		 * Returns the package ID of the data file entry that is mapped with the specified ID.
		 * 
		 * @param id The ID of the data file entry for which to return the package ID.
		 * @return The package ID of the data file entry or null.
		 */
		public function getDataFilePackageID(id:String):String
		{
			if (_dataFiles[id]) return (_dataFiles[id] as ResourceDataFileEntry).packageID;
			error("getDataFilePackageID: No package ID mapped for data file ID \"" + id + "\".");
			return null;
		}
		
		
		/**
		 * Returns the specified resource collection, if available.
		 * 
		 * @param id Resource collection ID.
		 * @return A ResourceCollection object or null.
		 */
		public function getResourceCollection(id:String):ResourceCollection
		{
			if (!_resourceCollectionIDs[id]) return null;
			return (_resources[id] as Resource).content;
		}
		
		
		/**
		 * Checks whether the resource index contains the specified resource.
		 * 
		 * @param id The ID of the resource.
		 * @return true or false.
		 */
		public function containsResource(id:String):Boolean
		{
			return _resources[id] != null;
		}
		
		
		/**
		 * Returns the resource that is mapped under the specified ID.
		 * 
		 * @param id The ID of the resource.
		 * @return An object of type Resource or null.
		 */
		public function getResource(id:String):Resource
		{
			return _resources[id];
		}
		
		
		/**
		 * Returns the data type of the resource that is mapped with the specified ID.
		 * Only data resources (data objects, data lists, entities) have a data type.
		 * For media-, text- and raw XML resources this method returns null.
		 * 
		 * @see tetragon.setup.Setup#registerDataTypes()
		 * 
		 * @param id The ID of the resource.
		 * @return A string describing the data type of the resource or null.
		 */
		public function getResourceDataType(id:String):String
		{
			var r:Resource = _resources[id];
			if (r) return r.type;
			return null;
		}
		
		
		/**
		 * Returns the content of a resource. Other than the getResource() method which
		 * returns an Object of type Resource, this method directly returns the resource's
		 * content object.
		 * 
		 * @param id The ID of the resource.
		 * 
		 * @return The resource content. The type of the content depends on what type of
		 *         resource data it contains. This could be a bitmapdata, a sound object,
		 *         a MovieClip, an XML object, etc.
		 */
		public function getResourceContent(id:String):*
		{
			var r:Resource = _resources[id];
			if (!r) return null;
			return r.content;
		}
		
		
		/**
		 * Returns the content of a bitmap image resource.
		 * 
		 * <p>In case the requested resource wasn't loaded or has an incorrect file path
		 * defined in the resource index file this method will try to provide a placeholder
		 * resource for it, while sending a warning to the log. The placeholder functionality
		 * can optionally be disabled by setting allowPlaceholder to false.</p>
		 * 
		 * @param id The ID of the image resource.
		 * @param allowPlaceholder If true, the method tries to return a placeholder
		 *        asset in case the resource's content isn't available. If set to false
		 *        the method will return null instead if the resource has no content.
		 * @param placeholderWidth Optional width for placeholder image.
		 * @param placeholderHeight Optional height for placeholder image.
		 * 
		 * @return A BitmapData object or null.
		 */
		public function getImage(id:String, allowPlaceholder:Boolean = true,
			placeholderWidth:uint = 64, placeholderHeight:uint = 64):BitmapData
		{
			var r:Resource = _resources[id];
			if (r && r.content)
			{
				if (r.content is BitmapData) return r.content;
				else error("getImage: The requested image resource is not of type BitmapData!");
			}
			if (!allowPlaceholder) return null;
			/* Image resource not found! Try to provide a placeholder image! */
			warn("getImage: Image resource \"" + id + "\" not found! Using a placeholder.");
			/* Placeholder with the same size already created, return it! */
			if (_placeholderImage && _placeholderImage.width == placeholderWidth
				&& _placeholderImage.height == placeholderHeight)
			{
				return _placeholderImage.clone();
			}
			/* Else create a new placeholder bitmap with requested size. */
			if (!_placeholderShape) _placeholderShape = new Shape();
			else _placeholderShape.graphics.clear();
			if (!_placeholderBitmap) _placeholderBitmap = new PlaceholderBitmap();
			_placeholderShape.graphics.beginBitmapFill(_placeholderBitmap);
			_placeholderShape.graphics.drawRect(0, 0, placeholderWidth, placeholderHeight);
			_placeholderShape.graphics.endFill();
			_placeholderImage = new BitmapData(placeholderWidth, placeholderHeight, false, 0xCC0000);
			_placeholderImage.draw(_placeholderShape);
			return _placeholderImage.clone();
		}
		
		
		/**
		 * Allows to obtain an instance of a class that is defined as a linked library
		 * asset in a loaded SWF resource.
		 * 
		 * <p>To define resources as classes in an SWF resource file, create an SWF file
		 * with the Flash IDE and export any assets for ActionScript in the asset's
		 * property dialog. The class name can also contain a package, e.g.</p>
		 * 
		 * @example
		 * <pre>
		 * getInstanceFromSWFResource("soundResource", "lib.sounds.MySoundAsset");
		 * </pre>
		 * 
		 * @param swfResourceID The ID of the SWF resource in which to find the class.
		 * @param className The name of the class from which to receive an instance.
		 * @param instanceName An optional name for the created instance.
		 * 
		 * @return An instance of the class of the specified className or null.
		 */
		public function getInstanceFromSWFResource(swfResourceID:String, className:String,
			instanceName:String = null):*
		{
			var r:* = getResourceContent(swfResourceID);
			if (!r)
			{
				error("getInstanceFromSWFResource: Resource of specified ID \"" + swfResourceID
					+ "\" is null.");
				return null;
			}
			if (!(r is MovieClip))
			{
				error("getInstanceFromSWFResource: Resource of specified ID \"" + swfResourceID
					+ "\" is not a SWF resource.");
				return null;
			}
			var swf:MovieClip = r as MovieClip;
			var clazz:Class = swf.loaderInfo.applicationDomain.getDefinition(className) as Class;
			if (!clazz)
			{
				error("getInstanceFromSWFResource: No class named \"" + className
					+ "\" defined in the SWF resource with ID \"" + swfResourceID + "\".");
				return null;
			}
			var instance:* = new clazz();
			if (instanceName) instance['name'] = instanceName;
			return instance;
		}
		
		
		/**
		 * Removes the resource from the resource index that is mapped with the
		 * specified ID.
		 * 
		 * @param id The ID of the resource to remove.
		 */
		public function removeResource(id:String):void
		{
			if (_resources[id])
			{
				delete _resources[id];
				_size--;
			}
		}
		
		
		/**
		 * Resets the resource that is mapped with the specified ID. The resource's
		 * loaded data will be removed, it's refCount is set to 0 and it's status is
		 * set to ResourceStatus.INIT. Note that resource collections cannot be reset.
		 * 
		 * @see tetragon.file.resource.ResourceStatus
		 * 
		 * @param id The ID of the resource to reset.
		 */
		public function resetResource(id:String):void
		{
			var r:Resource = _resources[id];
			if (r)
			{
				/* Resource collections may not be reset! */
				if (r.family == ResourceFamily.COLLECTION)
				{
					return;
				}
				
				if (r.content)
				{
					/* Dispose any BitmapData before removing it. */
					if (r.content is Bitmap)
					{
						var b:Bitmap = r.content;
						if (b.bitmapData) b.bitmapData.dispose();
					}
					else if (r.content is BitmapData)
					{
						(r.content as BitmapData).dispose();
					}
					else if (r.content is XML)
					{
						System.disposeXML(r.content as XML);
					}
				}
				
				r.reset();
			}
		}
		
		
		/**
		 * Resets all resources.
		 */
		public function resetAll():void
		{
			for each (var r:Resource in _resources)
			{
				resetResource(r.id);
			}
		}
		
		
		/**
		 * Checks whether the resource of the specified ID is loaded or not.
		 * 
		 * @param id The ID of the resource to check.
		 * @return true or false.
		 */
		public function isResourceLoaded(id:String):Boolean
		{
			return (_resources[id] && (_resources[id] as Resource).referenceCount > 0);
		}
		
		
		/**
		 * Returns a string dump of the resource list.
		 * 
		 * @return A string dump of the resource list.
		 */
		public function dump(filter:String = "all"):String
		{
			var cr:ClassRegistry = Main.instance.classRegistry;
			var t:TabularText = new TabularText(8, true, "  ", null, "  ", 0,
				["ID", "FAMILY", "FTYPE", "DTYPE", "PACKAGE", "PATH", "EMBEDDED", "REFCOUNT"]);
			
			for each (var e:Resource in _resources)
			{
				/* Apply filters. */
				if (filter == "loaded" && e.referenceCount < 1) continue;
				else if (filter == "unloaded" && e.referenceCount > 0) continue;
				
				var ftype:String;
				var type:String;
				
				/* For media resources the type is the filetype! */
				if (e.family == ResourceFamily.MEDIA)
				{
					ftype = e.type;
					type = "";
				}
				/* For collections we don't want to display a type. */
				else if (e.family == ResourceFamily.COLLECTION)
				{
					ftype = "";
					type = "";
				}
				else
				{
					ftype = cr.getResourceFileTypeName(e.loaderClass) || "";
					type = e.type || "";
				}
				
				var pack:String = getPackagePath(e.packageID) || "";
				var path:String = e.path || "";
				
				t.add([e.id, e.family, ftype, type, pack, path, e.embedded, e.referenceCount]);
			}
			return toString() + " (size: " + _size + ", unloaded: " + unloadedResourceCount
				+ ", loaded: " + loadedResourceCount + ", totalRefs: " + totalRefs + ")\n" + t;
		}
		
		
		/**
		 * Returns a string dump of all mapped resource package files.
		 * 
		 * @return A string dump of all mapped resource package files.
		 */
		public function dumpPackageList():String
		{
			var t:TabularText = new TabularText(2, true, "  ", null, "  ", 0, ["ID", "PATH"]);
			for (var id:String in _packageFiles)
			{
				t.add([id, _packageFiles[id]]);
			}
			return toString() + ": Resource Package Files\n" + t;
		}
		
		
		/**
		 * Returns a string dump of all mapped data files.
		 * 
		 * @return A string dump of all mapped data files.
		 */
		public function dumpDataFileList():String
		{
			var t:TabularText = new TabularText(3, true, "  ", null, "  ", 0,
				["ID", "PATH", "PAKID"]);
			for (var id:String in _dataFiles)
			{
				var dfe:ResourceDataFileEntry = _dataFiles[id];
				t.add([id, dfe.path, dfe.packageID]);
			}
			return toString() + ": Resource Data Files\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "ResourceIndex";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Internal Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a package file entry. Normally you don't add package file entries to the
		 * resource index manually. Instead the resource index loader uses this method.
		 * 
		 * @see tetragon.file.loaders.ResourceIndexLoader
		 * 
		 * @param id The ID of the package file entry.
		 * @param path The path of the package file entry.
		 */
		public function addPackageFileEntry(id:String, path:String):void
		{
			_packageFiles[id] = path;
			Log.verbose("Added package file entry \"" + id + "\", (" + path + ").", this);
		}
		
		
		/**
		 * Adds a data file entry. Normally you don't add data file entries to the
		 * resource index manually. Instead the resource index loader uses this method.
		 * 
		 * @see tetragon.file.loaders.ResourceIndexLoader
		 * 
		 * @param id The ID of the data file entry.
		 * @param path The path of the data file entry.
		 * @param packageID The package ID of the data file entry.
		 */
		public function addDataFileEntry(id:String, path:String, packageID:String):void
		{
			_dataFiles[id] = new ResourceDataFileEntry(path, packageID);
			Log.verbose("Added data file entry \"" + id + "\", (" + path + ").", this);
		}
		
		
		/**
		 * Returns an array that contains the IDs of all settings file resources.
		 * Used to load settings during application init. You normally don't use this
		 * method manually. Instead the StartupApplicationCommand class calls it.
		 */
		public function getSettingsFileIDs():Array
		{
			var a:Array = [];
			var type:String = ResourceFamily.SETTINGS.toLowerCase();
			for each (var e:Resource in _resources)
			{
				if (e.type == null) continue;
				if (e.type.toLowerCase() == type)
				{
					a.push(e.id);
				}
			}
			return a;
		}
		
		
		/**
		 * Adds a resource to the resource index. Note that a resource is not a concrete
		 * file resource but a data object that contains information about where to
		 * find the resource file, it's data type, whether it's embedded or not, etc. and
		 * the actual file data, once it has been loaded.
		 * 
		 * <p>You normally don't call this method manually. Instead the resource index
		 * loader uses this method.</p>
		 * 
		 * @see tetragon.file.loaders.ResourceIndexLoader
		 * 
		 * @param id The unique ID of the resource.
		 * @param path The path of the resource file, either on the filesystem or inside
		 *        a resource package file.
		 * @param packageID The package ID if the resource is packed into a package.
		 * @param dataFileID The ID of the datafile in which this resource can be found.
		 *        Media and textdata resources have no dataFileID.
		 * @param resourceFileClass The resource class of the resource.
		 * @param family The resource family of the resource.
		 * @param type The data type of the resource (if it's a data or entity resource).
		 * @param embedded Whether the resource is embedded or not.
		 */
		public function addResource(id:String, path:String, packageID:String, dataFileID:String,
			resourceFileClass:Class, family:String, type:String, embedded:Boolean = false):void
		{
			if (_resources[id] == null) _size++;
			else delete _resources[id];
			_resources[id] = new Resource(id, path, packageID, dataFileID, resourceFileClass,
				family, type, embedded);
			Log.verbose("Added resource \"" + id + "\", (" + path + ").", this);
		}
		
		
		/**
		 * Adds a resource collection to the resource index.
		 * 
		 * <p>You normally don't call this method manually. Instead the resource index
		 * loader uses this method.</p>
		 * 
		 * @see tetragon.file.loaders.ResourceIndexLoader
		 * 
		 * @param collection The resource collection.
		 */
		public function addResourceCollection(collection:ResourceCollection):void
		{
			if (!collection) return;
			if (_resources[collection.id] == null) _size++;
			else delete _resources[collection.id];
			var r:Resource = new Resource(collection.id, null, null, null, null,
				ResourceFamily.COLLECTION, collection.type, false);
			_resources[collection.id] = r;
			_resourceCollectionIDs[collection.id] = true;
			addDataResource(collection);
			Log.verbose("Added resource collection \"" + collection.id + ".", this);
		}
		
		
		/**
		 * Adds a resource to the resource index that is defined as a resource for
		 * preloading. Resources that are entered in the resource index file's preload
		 * section are automatically preloaded by the engine during startup.
		 * 
		 * <p>You normally don't call this method manually. Instead the resource index
		 * loader uses this method.</p>
		 * 
		 * @see tetragon.file.loaders.ResourceIndexLoader
		 * 
		 * @param id The ID of the preloaded resource.
		 */
		public function addPreloadResource(id:String):void
		{
			if (!_preloadResourceIDs) _preloadResourceIDs = [];
			_preloadResourceIDs.push(id);
		}
		
		
		/**
		 * Adds loaded, parsed data to a resource in the index. called by data parsers.
		 * 
		 * <p>You normally don't call this method manually. Instead data parsers use
		 * this method.</p>
		 * 
		 * @see tetragon.file.parsers.DataListParser
		 * @see tetragon.file.parsers.EntityDataParser
		 * 
		 * @param content The data resource content. Must be of type DataObject!
		 */
		public function addDataResource(content:*):void
		{
			var r:Resource;
			if (content is DataObject)
			{
				var o:DataObject = content;
				if (o.id == null)
				{
					error("addDataResource: Tried to add a resource whose ID is null.");
					return;
				}
				r = _resources[o.id];
				r.setContent(o);
			}
		}
		
		
		/**
		 * Adds a loaded raw XML resource to the index. called by XML data parsers.
		 * 
		 * <p>You normally don't call this method manually. Instead the XML data parser uses
		 * this method.</p>
		 * 
		 * @see tetragon.file.parsers.XMLDataParser
		 * 
		 * @param resourceID The resource's ID.
		 * @param xml The XML data for the resource.
		 */
		public function addXMLResource(resourceID:String, xml:XML):void
		{
			var r:Resource = _resources[resourceID];
			if (r == null || r.family != ResourceFamily.XML)
			{
				error("addXMLResource: Tried to add raw XML resource data with an unmapped"
				+ " resource ID \"" + resourceID + "\" or to a resource that is not part of"
				+ " the XML resource family.");
				return;
			}
			r.setContent(xml);
		}
		
		
		/**
		 * Sets the object map of available locale paths.
		 * 
		 * <p>You normally don't call this method manually. Instead the resource index
		 * loader uses this method.</p>
		 * 
		 * @see tetragon.file.loaders.ResourceIndexLoader
		 * 
		 * @param localePaths An object with mapped locale paths.
		 */
		public function setLocalePaths(localePaths:Object):void
		{
			_localePaths = localePaths;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A map that stores all resources. Contains Resource objects.
		 */
		public function get resources():Object
		{
			return _resources;
		}
		
		
		/**
		 * Returns the total amount of resources that are currently not loaded.
		 */
		public function get unloadedResourceCount():uint
		{
			var c:uint = 0;
			for each (var r:Resource in _resources)
			{
				if (r.status != ResourceStatus.LOADED)
				{
					c++;
				}
			}
			return c;
		}
		
		
		/**
		 * Returns the total amount of resources that are currently loaded.
		 */
		public function get loadedResourceCount():uint
		{
			var c:uint = 0;
			for each (var r:Resource in _resources)
			{
				if (r.status == ResourceStatus.LOADED)
				{
					c++;
				}
			}
			return c;
		}
		
		
		/**
		 * Returns the total amount of resource reference counts.
		 */
		public function get totalRefs():uint
		{
			var c:uint = 0;
			for each (var r:Resource in _resources)
			{
				c += r.referenceCount;
			}
			return c;
		}
		
		
		/**
		 * A List of all resource IDs that are being preloaded by the engine.
		 */
		public function get preloadResourceIDs():Array
		{
			return _preloadResourceIDs;
		}
		
		
		/**
		 * A map that contains all available locale paths, mapped by their locale ID.
		 */
		public function get localePaths():Object
		{
			return _localePaths;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function error(message:String):void
		{
			Log.error(message, this);
		}
		
		
		private function warn(message:String):void
		{
			Log.warn(message, this);
		}
	}
}
