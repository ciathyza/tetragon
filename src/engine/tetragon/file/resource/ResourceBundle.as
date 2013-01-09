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
	import tetragon.debug.Log;

	import com.hexagonstar.exception.FatalException;

	import flash.utils.describeType;
	
	
	/**
	 * The resource bundle handles automatic loading and registering of embedded
	 * resources. To use, create a descendant class and embed resources as public
	 * variables, then instantiate your new class. ResourceBundle will handle loading
	 * all of those resources into the ResourceManager.
	 */
	public class ResourceBundle
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _resourceCount:int = 0;
		/** @private */
		protected var _embeddedResourceDataNames:Object;
		/** @private */
		protected var _embeddedTextResourceDataNames:Object;
		/** @private */
		protected var _resourceIndexDataName:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * init
		 */
		public function init(resourceIndex:ResourceIndex):void
		{
			var classRegistry:ClassRegistry = Main.instance.classRegistry;
			var xml:XML = describeType(this);
			var res:Class;
			var resName:String;
			var resID:String;
			var resType:String;
			var resFamily:String;
			var resPID:String;
			var resPath:String;
			var resLang:String;
			var pkgType:String;
			var isEmbedded:Boolean;
			var isResourceIndex:Boolean;
			
			/* Loop through each public variable in this class */
			for each (var v:XML in xml.variable)
			{
				resName = v.@name;
				res = this[resName];
				
				resID = null;
				resType = null;
				resFamily = null;
				resPID = null;
				resPath = null;
				resLang = null;
				pkgType = null;
				
				/* Assume that there is no properly embedded,
				 * so that we can show an error if needed. */
				isEmbedded = false;
				isResourceIndex = false;
				
				/* Loop through each metadata tag in the child variable */
				for each (var meta:XML in v.children())
				{
					var a:XML;
					/* If we've got an embedded resource tag */
					if (meta.@name == "Resource")
					{
						for each (a in meta.children())
						{
							switch (String(a.@key))
							{
								case "id":
									resID = a.@value;
									break;
								case "family":
									resFamily = a.@value;
									break;
								case "rtype":
									resType = a.@value;
									break;
								case "lang":
									resLang = a.@value;
									break;
								case "parserID":
									/* Not all resources need a parserID. */
									if (String(a.@value).length > 0) resPID = a.@value;
							}
						}
					}
					/* If we've got an embedded metadata tag */
					else if (meta.@name == "Embed")
					{
						isEmbedded = true;
						/* Extract the source path from the embed tag. */
						for each (a in meta.children())
						{
							if (a.@key == "source") resPath = a.@value;
						}
					}
					/* If we've got an embedded resource index tag */
					else if (meta.@name == "ResourceIndex")
					{
						Log.verbose("Found embedded resource index!", this);
						isResourceIndex = true;
						_resourceIndexDataName = resName;
					}
				}
				
				if (isResourceIndex) continue;
				
				// This seems to have changed with Flex 4.x compiler!? isEmbedded is
				// false and resPath is null even though the resource has been embedded
				// correctly. The [Embed] tag is removed by the compiler?
				//if (!isEmbedded || res == null || resID == null || resPath == null)
				
				/* Sanity check */
				if (res == null || resID == null)
				{
					Log.error("A resource in the resource bundle with the name \"" + resName
						+ "\" has failed to embed properly. Please ensure that you have"
						+ " the compiler option '--keep-as3-metadata+=TypeHint,EditorData,Resource,"
						+ " Embed' set properly. Additionally, please check that the [Resource]"
						+ " and [Embed] metadata syntax is correct.", this);
					continue;
				}
				
				/* Try to determine the resource's type class, first by it's embedded type
				 * parameter and if that fails try the file extension. */
				var clazz:Class;
				if (resType && resType.length > 0)
				{
					clazz = classRegistry.getResourceLoaderClassByID(resType);
					if (!clazz)
					{
						Log.warn("No resource file type loader class found for embedded resource with ID \""
							+ resID + "\" (resID: " + resType + "). Falling back to file extension detection.", this);
					}
				}
				
				if (clazz == null)
				{
					/* Get the extension of the source filename */
					var ext:String = resPath.substring(resPath.lastIndexOf(".") + 1);
					
					/* Check if the extension type is recognized or not. */
					clazz = classRegistry.getResourceLoaderClassByExtension(ext);
					if (clazz == null)
					{
						Log.error("Could not determine the resource file type class definition for"
							+ " embedded file extension \"" + ext + "\". Please ensure that the"
							+ " class definition is correctly mapped.", this);
						continue;
					}
				}
				
				/* Map resource data names by the resource ID to be able to obtain the
				 * names later by their resource ID. */
				if (!_embeddedResourceDataNames) _embeddedResourceDataNames = {};
				_embeddedResourceDataNames[resID] = resName;
				
				/* Map resource data names of text resources by their resource ID plus the
				 * language string, e.g. "textUI-en". */
				if (resFamily == ResourceFamily.TEXT)
				{
					if (!_embeddedTextResourceDataNames) _embeddedTextResourceDataNames = {};
					_embeddedTextResourceDataNames[resID + "-" + resLang] = resName;
				}
				
				/* Everything so far is hunky-dory -- go ahead and register the embedded
				 * resource in the resource index! Embedded resources use the resource
				 * variable name as the path. */
				resourceIndex.addResource(resID, resName, null, null, clazz, resFamily, resPID, true);
				_resourceCount++;
			}
			
			Log.verbose("Nr. of embedded resources: " + _resourceCount, this);
		}
		
		
		/**
		 * Checks whether the bundle contains embedded data for a spoecific resource ID.
		 * 
		 * @param resourceID
		 * @return true or false;
		 */
		public function containsResourceData(resourceID:String):Boolean
		{
			return _embeddedResourceDataNames && _embeddedResourceDataNames[resourceID] != null;
		}
		
		
		/**
		 * Returns the resource data name for a specified resource ID.
		 * 
		 * @param resourceID
		 * @return String
		 */
		public function getResourceDataName(resourceID:String):String
		{
			if (!_embeddedResourceDataNames) return null;
			return _embeddedResourceDataNames[resourceID];
		}
		
		
		/**
		 * Returns the resource data name for a specified text resource ID.
		 * 
		 * @param resourceID
		 * @param lang
		 * @return String
		 */
		public function getTextResourceDataName(resourceID:String, lang:String):String
		{
			if (!_embeddedTextResourceDataNames) return null;
			return _embeddedTextResourceDataNames[resourceID + "-" + lang];
		}
		
		
		/**
		 * getResourceData
		 * 
		 * @param resourceDataName
		 * @return Resource Data (ByteArray).
		 */
		public function getResourceData(resourceDataName:String):*
		{
			var res:*;
			
			try
			{
				var clazz:Class = this[resourceDataName];
				res = new clazz();
			}
			catch (err:Error)
			{
				throw new FatalException(toString() + " Could not instantiate a resource of '"
					+ resourceDataName + "' (Error was: " + err.message + ")");
				return null;
			}
			
			return res;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "ResourceBundle";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The amount of embedded resources.
		 */
		public function get resourceCount():int
		{
			return _resourceCount;
		}
		
		
		/**
		 * Returns the data name in case the resource index is embedded.
		 */
		public function get resourceIndexDataName():String
		{
			return _resourceIndexDataName;
		}
	}
}
