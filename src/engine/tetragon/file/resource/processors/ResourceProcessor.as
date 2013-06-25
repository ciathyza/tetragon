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
package tetragon.file.resource.processors
{
	import tetragon.Main;
	import tetragon.debug.Log;
	import tetragon.file.resource.Resource;
	import tetragon.file.resource.ResourceCollection;
	import tetragon.file.resource.ResourceFamily;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.util.reflection.getClassName;
	
	
	/**
	 * ResourceProcessor class
	 */
	public class ResourceProcessor
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _resourceIndex:ResourceIndex;
		/** @private */
		private var _resources:Vector.<Resource>;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceProcessor()
		{
			_resourceIndex = Main.instance.resourceManager.resourceIndex;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Processes the specified resource.
		 */
		public function process(resource:Resource):Boolean
		{
			_resources = new Vector.<Resource>();
			if (resource.family == ResourceFamily.COLLECTION)
			{
				var collection:ResourceCollection = resource.content;
				for each (var id:String in collection.resourceIDs)
				{
					var r:Resource = resourceIndex.getResource(id);
					if (r)
					{
						_resources.push(r);
					}
					else
					{
						error("The resource with ID " + id + " is part of a resource collection"
							+ " that is being processed but is not available.");
					}
				}
			}
			else
			{
				_resources.push(resource);
			}
			
			Log.debug("Processing " + _resources.length + " resources ...", this);
			return processResources();
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
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		protected function get resourceIndex():ResourceIndex
		{
			return _resourceIndex;
		}
		
		
		protected function get resources():Vector.<Resource>
		{
			return _resources;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Abstract method for overriding in concrete processor classes.
		 */
		protected function processResources():Boolean
		{
			/* Abstract method! */
			return false;
		}
		
		
		protected function warn(message:String):void
		{
			Log.warn(message, this);
		}
		
		
		protected function error(message:String):void
		{
			Log.error(message, this);
		}
	}
}
