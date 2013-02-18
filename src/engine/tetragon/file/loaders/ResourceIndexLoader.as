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
	import tetragon.data.Config;
	import tetragon.debug.Log;
	import tetragon.file.resource.ResourceCollection;
	import tetragon.file.resource.ResourceFamily;
	import tetragon.file.resource.ResourceIndex;

	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.file.types.XMLFile;
	import com.hexagonstar.file.types.ZipFile;
	import com.hexagonstar.util.env.getSeparator;

	import flash.system.System;
	
	
	/**
	 * The ResourceIndexLoader loads the resource index file and parses it into the
	 * ResourceIndex.
	 */
	public class ResourceIndexLoader extends FileLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _resourceIndex:ResourceIndex;
		/** @private */
		protected var _locale:String;
		/** @private */
		protected var _state:int;
		/** @private */
		protected var _resCount:int;
		/** @private */
		protected var _subCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param resourceIndex
		 */
		public function ResourceIndexLoader(resourceIndex:ResourceIndex)
		{
			super();
			
			if (!resourceIndex) return;
			
			/* Use web loading API for this loader or it can't load packed files. */
			_loader.useAIRFileAPI = false;
			
			_resourceIndex = resourceIndex;
			_locale = main.registry.config.getString(Config.LOCALE_CURRENT);
			_state = 0;
			_resCount = 0;
			_subCount = 0;
			
			/* Create resource index file path */
			var path:String = main.registry.config.getString(Config.RESOURCE_FOLDER);
			if (path == null) path = "";
			if (path.length > 0) path += getSeparator();
			path += main.registry.config.getString(Config.FILENAME_RESOURCEINDEX);
			path = main.registry.config.getString(Config.IO_BASE_PATH) + path;
			
			addFile(path, "resourceIndexFile");
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			_resourceIndex = null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Called everytime after a file load has been completed.
		 * 
		 * @param e
		 */
		override public function onFileComplete(file:IFile):void
		{
			super.onFileComplete(file);
		}
		
		
		/**
		 * Called after all file loads have been completed.
		 * 
		 * @param e
		 */
		override public function onAllFilesComplete(file:IFile):void
		{
			_loader.reset();
			switch (_state)
			{
				case 0:
				case 2:
					/* Non-packed or packed file was loaded successfully! */
					parseFile(file);
					return;
				case 1:
					/* Non-packed index file could not be found so
					 * try loading the packed version. */
					_state = 2;
					loadPacked();
					return;
				case 3:
					/* Neither packed or nonpacked could be loaded! */
			}
			
			super.onAllFilesComplete(file);
		}
		
		
		/**
		 * @param e
		 */
		override public function onFileIOError(file:IFile):void
		{
			if (_state == 0)
			{
				_state = 1;
				return;
			}
			else if (_state == 2)
			{
				_state = 3;
				notifyLoadError(file);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Loads the packed version of the resource index file in case the non-packed
		 * version was not found.
		 */
		protected function loadPacked():void
		{
			_loader.reset();
			
			/* Change file path to use the packed version. */
			var f:IFile = _files.dequeue();
			var path:String = f.path.substring(0, f.path.lastIndexOf(".")) + ".rif";
			
			Log.debug("\"" + f.path + "\" not found, trying to load \"" + path + "\" instead ...",
				this);
			
			_files.enqueue(new ZipFile(path, "resourceIndexFile"));
			_loader.addFileQueue(_files);
			_loader.load();
		}
		
		
		/**
		 * Initiates parsing of different resource index entries.
		 */
		protected function parseFile(file:IFile):void
		{
			if (!file.valid)
			{
				Log.error("Error parsing file: data structure of resource index file is invalid. ("
					+ file.status + ")", this);
				return;
			}
			
			var xmlFile:XMLFile;
			if (file is ZipFile)
			{
				var path:String = main.registry.config.getString(Config.FILENAME_RESOURCEINDEX);
				xmlFile = XMLFile(ZipFile(file).getFile(path));
			}
			else
			{
				xmlFile = XMLFile(file);
			}
			
			parse(xmlFile.contentAsXML);
			
			if (_completeSignal) _completeSignal.dispatch();
		}
		
		
		/**
		 * Parses the resource index XML data.
		 * @private
		 */
		protected function parse(xml:XML):void
		{
			//Log.verbose("Resource Index XML:\n" + xml.toXMLString(), this);
			
			parseReferences(xml);
			parseMedia(xml);
			parseLists(xml);
			parseData(xml);
			parseEntities(xml);
			parseXML(xml);
			parseText(xml);
			parsePreloadResources(xml);
			
			System.disposeXML(xml);
			Log.verbose("Total resource entries parsed: " + _resCount, this);
		}
		
		
		/**
		 * Parses the package file and data file reference entries.
		 */
		protected function parseReferences(xml:XML):void
		{
			_subCount = 0;
			var x:XML;
			
			/* Parse package file entries if packed resources are being used. */
			if (main.appInfo.usePackedResources)
			{
				for each (x in xml.packageFiles.file)
				{
					_resourceIndex.addPackageFileEntry(x.@id, x.@path);
					++_subCount;
				}
				Log.verbose("Parsed " + _subCount + " package files.", this);
			}
			
			/* Parse data file entries. */
			_subCount = 0;
			for each (x in xml.dataFiles.file)
			{
				_resourceIndex.addDataFileEntry(x.@id, x.@path, x.@packageID);
				++_subCount;
			}
			
			Log.verbose("Parsed " + _subCount + " data file entries.", this);
		}
		
		
		/**
		 * Parses media resource entries.
		 */
		protected function parseMedia(xml:XML):void
		{
			_subCount = 0;
			
			for each (var x:XML in xml.media.*)
			{
				var topNodeName:String = x.name();
				var resourceClassID:String = topNodeName;
				
				var collectionID:String = "" + x.@id;
				var collection:ResourceCollection = null;
				
				if (collectionID.length > 0)
				{
					collection = new ResourceCollection(collectionID, null);
				}
				
				for each (var s:XML in x.children())
				{
					/* Check if resource is nested in another child tag. NOTE:
					 * nested tags are obsolete and don't support media resource colections! */
					if (s.name() != "resource")
					{
						resourceClassID = topNodeName + "-" + s.name();
						for each (var c:XML in s.children())
						{
							addResourceEntry(c, resourceClassID, ResourceFamily.MEDIA, null);
							++_subCount;
						}
					}
					else
					{
						addResourceEntry(s, resourceClassID, ResourceFamily.MEDIA, null);
						++_subCount;
						if (collection) collection.addResource(s.@id);
					}
				}
				addResourceCollection(collection);
			}
			
			Log.verbose("Parsed " + _subCount + " media resource entries.", this);
		}
		
		
		/**
		 * Parses list resource entries.
		 */
		protected function parseLists(xml:XML):void
		{
			_subCount = 0;
			
			for each (var x:XML in xml.lists.group)
			{
				var type:String = x.@type;
				var allFileID:String = "" + x.@fileID;
				var collectionID:String = "" + x.@id;
				var collection:ResourceCollection = null;
				
				if (collectionID.length > 0)
				{
					collection = new ResourceCollection(collectionID, type);
				}
				
				for each (var s:XML in x.children())
				{
					if (s.name() != "resource") continue;
					
					const fileID:String = allFileID.length > 0 ? allFileID : s.@fileID;
					const dfp:String = _resourceIndex.getDataFilePath(fileID);
					
					if (!dfp || dfp.length < 1)
					{
						Log.error("No data file with ID \"" + s.@fileID
							+ "\" defined in resource index but the resource with ID \""
							+ s.@id + "\" requires it.", this);
						continue;
					}
					
					s.@path = dfp;
					s.@packageID = _resourceIndex.getDataFilePackageID(fileID);
					addResourceEntry(s, ResourceFamily.DATA, ResourceFamily.LIST, type);
					++_subCount;
					if (collection) collection.addResource(s.@id);
				}
				addResourceCollection(collection);
			}
			
			Log.verbose("Parsed " + _subCount + " list resource entries.", this);
		}
		
		
		/**
		 * Parses data resource entries.
		 */
		protected function parseData(xml:XML):void
		{
			_subCount = 0;
			
			for each (var x:XML in xml.data.group)
			{
				var type:String = x.@type;
				var allFileID:String = "" + x.@fileID;
				var collectionID:String = "" + x.@id;
				var collection:ResourceCollection = null;
				
				if (collectionID.length > 0)
				{
					collection = new ResourceCollection(collectionID, type);
				}
				
				for each (var s:XML in x.children())
				{
					if (s.name() != "resource") continue;
					
					/* If all resources of the group are in the same data file, the
					 * data file ID can be specified globally for all resources instead
					 * of having any resource repeat the same data file ID so if we got
					 * a global data file ID use that one instead. */
					const fileID:String = allFileID.length > 0 ? allFileID : s.@fileID;
					const dfp:String = _resourceIndex.getDataFilePath(fileID);
					
					if (!dfp || dfp.length < 1)
					{
						Log.error("No data file with ID \"" + s.@fileID
							+ "\" defined in resource index but the resource with ID \""
							+ s.@id + "\" requires it.", this);
						continue;
					}
					
					s.@path = dfp;
					s.@packageID = _resourceIndex.getDataFilePackageID(fileID);
					addResourceEntry(s, ResourceFamily.DATA, ResourceFamily.DATA, type);
					++_subCount;
					if (collection) collection.addResource(s.@id);
				}
				addResourceCollection(collection);
			}
			
			Log.verbose("Parsed " + _subCount + " data resource entries.", this);
		}
		
		
		/**
		 * Parses entity resource entries.
		 */
		protected function parseEntities(xml:XML):void
		{
			_subCount = 0;
			
			for each (var x:XML in xml.entities.group)
			{
				var type:String = x.@type;
				var allFileID:String = "" + x.@fileID;
				var collectionID:String = "" + x.@id;
				var collection:ResourceCollection = null;
				
				if (collectionID.length > 0)
				{
					collection = new ResourceCollection(collectionID, type);
				}
				
				for each (var s:XML in x.children())
				{
					if (s.name() != "resource") continue;
					
					const fileID:String = allFileID.length > 0 ? allFileID : s.@fileID;
					const dfp:String = _resourceIndex.getDataFilePath(fileID);
					
					if (!dfp || dfp.length < 1)
					{
						Log.error("No data file with ID \"" + s.@fileID
							+ "\" defined in resource index but the resource with ID \""
							+ s.@id + "\" requires it.", this);
						continue;
					}
					
					s.@path = dfp;
					s.@packageID = _resourceIndex.getDataFilePackageID(fileID);
					addResourceEntry(s, ResourceFamily.DATA, ResourceFamily.ENTITY, type);
					++_subCount;
					if (collection) collection.addResource(s.@id);
				}
				addResourceCollection(collection);
			}
			
			Log.verbose("Parsed " + _subCount + " entity resource entries.", this);
		}
		
		
		/**
		 * Parses raw XML resource entries.
		 */
		protected function parseXML(xml:XML):void
		{
			_subCount = 0;
			
			for each (var x:XML in xml.xml.resource)
			{
				/* Set fileID as the same like ID for raw XML resources! */
				x.@fileID = x.@id;
				addResourceEntry(x, ResourceFamily.XML, ResourceFamily.XML, null);
				++_subCount;
			}
			
			Log.verbose("Parsed " + _subCount + " XML resource entries.", this);
		}
		
		
		/**
		 * Parses text resource entries.
		 */
		protected function parseText(xml:XML):void
		{
			_subCount = 0;
			
			var localePaths:Object = {};
			for each (var x:XML in xml.elements("text").resource)
			{
				for each (var s:XML in x.locale)
				{
					var lang:String = s.@lang;
					var path:String = s.@path;
					
					lang = lang.toLowerCase();
					if (localePaths[lang] == null)
					{
						var p:String = path.substr(0, path.lastIndexOf("/") + 1);
						localePaths[lang] = p;
					}
					
					if (lang != _locale) continue;
					
					/* If text entry for current locale is not available, use default locale! */
					if (!path || path.length < 1)
					{
						var defLocale:String = main.registry.config.getString(Config.LOCALE_DEFAULT);
						s = x.locale.(@lang == defLocale)[0];
					}
					
					s.@id = x.@id;
					addResourceEntry(s, ResourceFamily.TEXT, ResourceFamily.TEXT, null);
					++_subCount;
				}
			}
			_resourceIndex.setLocalePaths(localePaths);
			Log.verbose("Parsed " + _subCount + " text resource entries.", this);
			
			if (_subCount == 0)
			{
				Log.notice("No text resource entries have been parsed. This could be because the"
					+ " resource index hasn't defined a text resource entry for the default locale \""
					+ _locale + "\".", this);
			}
		}
		
		
		/**
		 * Parses resource entry IDs that should be preloaded.
		 */
		protected function parsePreloadResources(xml:XML):void
		{
			for each (var x:XML in xml.preload.resource)
			{
				_resourceIndex.addPreloadResource(x.@id);
			}
		}
		
		
		/**
		 * @param resourceXML
		 * @param loaderClassID
		 * @param resourceFamily
		 * @param resourceType Only used for data and entity resource families.
		 */
		protected function addResourceEntry(resourceXML:XML, loaderClassID:String,
			resourceFamily:String, resourceType:String):void
		{
			var id:String = resourceXML.@id;
			var path:String = resourceXML.@path;
			var packageID:String = resourceXML.@packageID;
			var dataFileID:String = resourceXML.@fileID;
			var rc:Class = main.classRegistry.getResourceLoaderClassByID(loaderClassID);
			if (!rc)
			{
				Log.warn("No resource file type loader class found for resource with ID \"" + id
					+ "\" (loaderClassID: " + loaderClassID + ").", this);
			}
			
			_resourceIndex.addResource(id, path, packageID, dataFileID, rc, resourceFamily,
				resourceType);
			_resCount++;
		}
		
		
		/**
		 * @param collection
		 */
		protected function addResourceCollection(collection:ResourceCollection):void
		{
			_resourceIndex.addResourceCollection(collection);
		}
	}
}
