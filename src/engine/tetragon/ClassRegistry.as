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
package tetragon
{
	import tetragon.debug.Log;
	import tetragon.entity.IEntityComponent;
	import tetragon.file.parsers.*;
	import tetragon.file.resource.ResourceFamily;
	import tetragon.file.resource.loaders.*;

	import com.hexagonstar.types.Point2D;
	import com.hexagonstar.types.Point3D;
	import com.hexagonstar.types.Vector2D;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	/**
	 * An odd multi-role class that manages the mapping and creation of several objects
	 * used by the resource management and the entity system. It acts as an index for
	 * parser-, entity component- and complex type classes by mapping data parser classes
	 * to datatype IDs and entity component classes to component class IDs.
	 */
	public final class ClassRegistry
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Maps resource file type name IDs by loader class definitions.
		 * @private
		 */
		private var _resourceFileTypeNameMap:Dictionary;
		
		/**
		 * Maps resource file type loader class definitions by string key.
		 * @private
		 */
		private var _resourceFileTypeMap:Object;
		
		/**
		 * Maps resource processor class definitions by string key.
		 * @private
		 */
		private var _resourceProcessorTypeMap:Object;
		
		/**
		 * Maps resource file type wrapper class definitions by string file extensions.
		 * @private
		 */
		private var _fileTypeExtensionMap:Object;
		
		/**
		 * Maps class definitions of complex types that are used in entity component
		 * definitions by a string key.
		 * @private
		 */
		private var _complexTypeMap:Object;
		
		/**
		 * Maps class definitions of type IResourceParser by datatype string keys.
		 * @private
		 */
		private var _dataTypeMap:Object;
		
		/**
		 * Maps class definitions of type IEntityComponent by class ID string keys.
		 * @private
		 */
		private var _componentMap:Object;
		
		/**
		 * Counter used to create unique entity component IDs.
		 * @private
		 */
		private var _componentIDCount:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ClassRegistry()
		{
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the registry.
		 */
		public function init():void
		{
			_resourceFileTypeNameMap = new Dictionary();
			_resourceFileTypeMap = {};
			_resourceProcessorTypeMap = {};
			_fileTypeExtensionMap = {};
			_complexTypeMap = {};
			_dataTypeMap = {};
			_componentMap = {};
			_componentIDCount = 0;
			
			/* Map default resource file types. */
			mapResourceFileType(ImageResourceLoader,	"image",	["image", "image-opaque"],							["jpg", "jpeg", "gif"]);
			mapResourceFileType(Image32ResourceLoader,	"image32",	["image32", "image-transparent", "image-vector"],	["png", "svg", "svgz"]);
			mapResourceFileType(SWFResourceLoader,		"swf",		["swf"],											["swf"]);
			mapResourceFileType(BinaryResourceLoader,	"binary",	["binary", "shader"],								["obj", "pbj", "bin"]);
			mapResourceFileType(BinaryResourceLoader,	"atf",		["atf"],											["atf"]);
			mapResourceFileType(MP3ResourceLoader,		"mp3",		["mp3"],											["mp3"]);
			mapResourceFileType(BinaryResourceLoader,	"mod",		["soundModule", "sound-module"],					["mod"]); // TODO
			mapResourceFileType(XMLResourceLoader,		"xml",		["data", "xml", "text"],							["xml", "txt", "ini", "css", "htm", "html"]);
			
			/* Map default complex types. */
			mapComplexType("array", Array);
			mapComplexType("rectangle", Rectangle);
			mapComplexType("point", Point);
			mapComplexType("point2d", Point2D);
			mapComplexType("point3d", Point3D);
			mapComplexType("vector2d", Vector2D);
			
			/* Map default resource families. */
			mapDataType(ResourceFamily.NONE, NullDataParser);
			mapDataType(ResourceFamily.TEXT, TextDataParser);
			mapDataType(ResourceFamily.XML, XMLDataParser);
			mapDataType(ResourceFamily.ENTITY, EntityDataParser);
			mapDataType(ResourceFamily.LIST, DataListParser);
			mapDataType(ResourceFamily.SETTINGS, SettingsDataParser);
		}
		
		
		/**
		 * Maps a resource file type wrapper class by one or more fileType ID strings.
		 * Optionally they are also mapped by file extensions, if specified. File
		 * extensions are only of importance for embedded resource files.
		 * 
		 * @param resourceLoaderClass The resource loader class to map.
		 * @param fileTypeName
		 * @param fileTypeIDs An array of keys to map the class under.
		 * @param fileTypeExtensions An array of file extensions to map the class under.
		 */
		public function mapResourceFileType(resourceLoaderClass:Class, fileTypeName:String,
			fileTypeIDs:Array,
			fileTypeExtensions:Array = null):void
		{
			_resourceFileTypeNameMap[resourceLoaderClass] = fileTypeName;
			var key:String;
			for each (key in fileTypeIDs)
			{
				_resourceFileTypeMap[key.toLowerCase()] = resourceLoaderClass;
			}
			for each (key in fileTypeExtensions)
			{
				_fileTypeExtensionMap[key.toLowerCase()] = resourceLoaderClass;
			}
		}
		
		
		/**
		 * Maps the specified resource processor class under the given resourceTypeID.
		 * The processor class must exte nd ResourceProcessor.
		 * 
		 * @param resourceTypeID The ID of the resource type.
		 * @param processorClass The processor class to map.
		 */
		public function mapResourceProcessor(resourceTypeID:String, processorClass:Class):void
		{
			if (resourceTypeID == null || processorClass == null) return;
			_resourceProcessorTypeMap[resourceTypeID.toLowerCase()] = processorClass;
		}
		
		
		/**
		 * Maps complex data types by ID which are used in entity component definitions.
		 * 
		 * @param complexTypeID The ID of the compex data type.
		 * @param clazz The class to map.
		 */
		public function mapComplexType(complexTypeID:String, clazz:Class):void
		{
			if (complexTypeID == null || clazz == null) return;
			_complexTypeMap[complexTypeID.toLowerCase()] = clazz;
		}
		
		
		/**
		 * Maps the specified parser class and optionally the specified builder class under
		 * the given dataTypeID. The parser class must implement IResourceParser and the
		 * builder class must implement IEntityBuilder.
		 * 
		 * @param dataTypeID The ID of the data type.
		 * @param parserClass The parser class to map.
		 */
		public function mapDataType(dataTypeID:String, parserClass:Class):void
		{
			if (dataTypeID == null || parserClass == null) return;
			_dataTypeMap[dataTypeID.toLowerCase()] = parserClass;
		}
		
		
		/**
		 * Maps the specified component class ID to the specified component class.
		 * The component class must implement IEntityComponent.
		 * 
		 * @param classID The ID of the component class.
		 * @param componentClass The component class to map.
		 */
		public function mapComponentClass(classID:String, componentClass:Class):void
		{
			if (classID == null || componentClass == null) return;
			_componentMap[classID.toLowerCase()] = componentClass;
		}
		
		
		/**
		 * Returns a resource file type name that is mapped by the given resource loader class.
		 * 
		 * @param loaderClass
		 * @return A resource file type name.
		 */
		public function getResourceFileTypeName(loaderClass:Class):String
		{
			return _resourceFileTypeNameMap[loaderClass];
		}
		
		
		/**
		 * Returns a resource file type loader class that is mapped by the given ID.
		 * 
		 * @param fileTypeID
		 * @return A resource loader class.
		 */
		public function getResourceLoaderClassByID(fileTypeID:String):Class
		{
			if (fileTypeID == null) return null;
			return _resourceFileTypeMap[fileTypeID.toLowerCase()];
		}
		
		
		/**
		 * Returns a resource file type loader class that is mapped by the given file
		 * type extension.
		 * 
		 * @param fileExtension
		 * @return A resource loader class.
		 */
		public function getResourceLoaderClassByExtension(fileExtension:String):Class
		{
			if (fileExtension == null) return null;
			return _fileTypeExtensionMap[fileExtension.toLowerCase()];
		}
		
		
		/**
		 * Returns a complex type class definition that is mapped under the specified
		 * complexTypeID.
		 * 
		 * @param complexTypeID The ID with that the complex type class is mapped.
		 * @return A class or null if the ID is not mapped.
		 */
		public function getComplexTypeClass(complexTypeID:String):Class
		{
			if (complexTypeID == null) return null;
			return _complexTypeMap[complexTypeID.toLowerCase()];
		}
		
		
		/**
		 * Returns a resource processor class definition that is mapped under the specified
		 * resourceTypeID.
		 * 
		 * @param resourceTypeID The ID with that the processor class is mapped.
		 * @return A processor class of type ResourceProcessor or null if the ID is not mapped.
		 */
		public function getResourceProcessorClass(resourceTypeID:String):Class
		{
			if (resourceTypeID == null) return null;
			return _resourceProcessorTypeMap[resourceTypeID.toLowerCase()];
		}
		
		
		/**
		 * Returns a parser class definition that is mapped under the specified dataTypeID.
		 * 
		 * @param dataTypeID The ID with that the parser class is mapped.
		 * @return A parser class of type IResourceParser or null if the ID is not mapped.
		 */
		public function getDataTypeParserClass(dataTypeID:String):Class
		{
			if (dataTypeID == null) return null;
			return _dataTypeMap[dataTypeID.toLowerCase()];
		}
		
		
		/**
		 * Returns a component class definition that is mapped under the specified classID.
		 * 
		 * @param classID The ID with that the class is mapped.
		 * @return A component class of type IEntityComponent or null if the ID is not mapped.
		 */
		public function getEntityComponentClass(classID:String):Class
		{
			if (classID == null) return null;
			return _componentMap[classID.toLowerCase()];
		}
		
		
		/**
		 * Creates a new data parser that is associated with the specified dataTypeID.
		 * 
		 * @param dataTypeID The ID of the data type for which to create a parser.
		 * @return A parser of type IDataParser.
		 */
		public function createDataTypeParser(dataTypeID:String):IFileDataParser
		{
			if (dataTypeID == null) return null;
			var clazz:* = _dataTypeMap[dataTypeID.toLowerCase()];
			var parser:IFileDataParser;
			if (!clazz)
			{
				fail("Failed to create parser class! No parser class has been mapped for"
					+ " dataTypeID \"" + dataTypeID + "\".");
				return null;
			}
			try
			{
				parser = new clazz();
			}
			catch (err:Error)
			{
				fail("Failed to create parser class! The parser class mapped for dataTypeID \""
					+ dataTypeID + "\" is not of type IResourceParser.");
				return null;
			}
			return parser;
		}
		
		
		/**
		 * Creates a new entity component that is associated with the specified classID.
		 * 
		 * @param classID The ID of the component class from which to create an instance.
		 * @return A component of type IEntityComponent.
		 */
		public function createEntityComponent(classID:String):IEntityComponent
		{
			if (classID == null) return null;
			var clazz:* = _componentMap[classID.toLowerCase()];
			var component:IEntityComponent;
			
			if (!clazz)
			{
				fail("Failed to create component class! No component class has been mapped for"
				+ " classID \"" + classID + "\".");
				return null;
			}
			try
			{
				component = new clazz();
			}
			catch (err:Error)
			{
				fail("Failed to create component class! The component class mapped for classID \""
					+ classID + "\" is not of type IEntityComponent.");
				return null;
			}
			component.id = "component" + _componentIDCount;
			_componentIDCount++;
			return component;
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		public function toString():String
		{
			return "ClassRegistry";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * @param message
		 */
		private function fail(message:String):void
		{
			Log.error(message, this);
		}
	}
}
