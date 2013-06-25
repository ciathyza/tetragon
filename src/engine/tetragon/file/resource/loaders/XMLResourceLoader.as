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
	import tetragon.core.file.types.BinaryFile;
	import tetragon.file.resource.ResourceBulkFile;
	import tetragon.file.resource.ResourceBulkItem;

	import flash.utils.ByteArray;
	
	
	/**
	 * A resource loader for XML data.
	 */
	public class XMLResourceLoader extends ResourceLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _xml:XML;
		/** @private */
		protected var _valid:Boolean;
		/** @private */
		protected var _items:Vector.<ResourceBulkItem>;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function setup(bulkFile:ResourceBulkFile):void
		{
			super.setup(bulkFile);
			_items = bulkFile.items;
			_file = new BinaryFile(bulkFile.path, bulkFile.id);
		}
		
		
		/**
		 * Checks if the bulk file that is wrapped by this loader contains the
		 * resource with the specified ID. This can be used to filter out unwanted
		 * resources that are in the same resource file while parsing.
		 */
		public function hasResourceID(id:String):Boolean
		{
			for each (var i:ResourceBulkItem in _items)
			{
				if (i.resourceID == id) return true;
			}
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The loaded data. This will be null until loading of the resource has completed.
		 */
		public function get xml():XML
		{
			return _xml;
		}
		
		
		/**
		 * Indicates whether the loaded XML data is valid or not.
		 */
		public function get valid():Boolean
		{
			return _valid;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function onContentReady(content:*):Boolean
		{
			return _valid;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromLoaded():void
		{
			initializeFromEmbedded(_file.contentAsBytes);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromEmbedded(embeddedData:*):void
		{
			if (embeddedData == null)
			{
				_valid = false;
				_status = "XMLResourceLoader: XML is null (path=" + _file.path + ").";
				onLoadComplete();
				return;
			}
			
			/* Convert ByteArray data to a string. */
			if (embeddedData is ByteArray)
			{
				embeddedData = (embeddedData as ByteArray).readUTFBytes((embeddedData as ByteArray).length);
			}
			
			try
			{
				_xml = new XML(embeddedData);
				_valid = true;
			}
			catch (err:Error)
			{
				_valid = false;
				_status = "XMLResourceLoader: XML check failed: " + err.message
					+ " (path=" + _file.path + ").";
			}
			onLoadComplete();
		}
	}
}
