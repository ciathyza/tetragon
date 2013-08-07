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
	import tetragon.file.resource.Resource;
	import tetragon.file.resource.ResourceBundle;
	import tetragon.file.resource.ResourceIndex;

	import flash.utils.ByteArray;
	
	
	/**
	 * The ResourceIndexLoader loads the resource index file and parses it into the
	 * ResourceIndex.
	 */
	public final class EmbeddedResourceIndexLoader extends ResourceIndexLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _resourceBundle:ResourceBundle;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param resourceIndex
		 * @param resourceBundle
		 */
		public function EmbeddedResourceIndexLoader(resourceIndex:ResourceIndex, resourceBundle:ResourceBundle)
		{
			super(resourceIndex);
			_resourceBundle = resourceBundle;
		}
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function load():void
		{
			var bytes:ByteArray = _resourceBundle.getResourceData(_resourceBundle.resourceIndexDataName);
			var xml:XML = new XML(bytes.readUTFBytes(bytes.length));
			parse(xml);
			
			/* Mark all resource entries that are embedded. */
			for each (var r:Resource in _resourceIndex.resources)
			{
				if (_resourceBundle.containsResourceData(r.id)) r.embedded = true;
			}
			
			if (_completeSignal) _completeSignal.dispatch();
		}
	}
}
