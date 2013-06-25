/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.file.types
{
	import tetragon.core.constants.Status;

	import flash.utils.ByteArray;
	
	
	/**
	 * The XMLFile is a file type implementation that can be used to load XML files. You
	 * can use the <code>contentAsXML</code> property to return the loaded XML data typed
	 * as a XML object.
	 * 
	 * @see com.hexagonstar.file.types.IFile
	 */
	public class XMLFile extends TextFile implements IFile
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the file class.
		 * 
		 * @param path The path of the file that this file object is used for.
		 * @param id An optional ID for the file.
		 * @param priority An optional load priority for the file. Used for loading with the
		 *            BulkLoader class.
		 * @param weight An optional weight for the file. Used for weighted loading with the
		 *            BulkLoader class.
		 * @param callback An optional callback method that can be associated with the file.
		 * @param params An optional array of parameters that can be associated with the file.
		 */
		public function XMLFile(path:String = null, id:String = null, priority:Number = NaN,
			weight:int = 1, callback:Function = null, params:Array = null)
		{
			super(path, id, priority, weight, callback, params);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get fileTypeID():int
		{
			return FileTypeIndex.XML_FILE_ID;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get content():*
		{
			return contentAsXML;
		}
		
		
		/**
		 * The XMLFile content, as a XML object.
		 */
		public function get contentAsXML():XML
		{
			var xml:XML;
			try
			{
				xml = new XML(contentAsString);
				if (!xml.name())
				{
					_valid = false;
					_status = "File doesn't contain valid XML.";
				}
				else
				{
					_valid = true;
					_status = Status.OK;
				}
			}
			catch (err:Error)
			{
				_valid = false;
				_status = err.message;
			}
			
			return xml;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set contentAsBytes(v:ByteArray):void
		{
			try
			{
				_content = new ByteArray();
				_content.writeBytes(v);
				_content.position = 0;
				/* Get as XML right after loading here because we want the valid property
				 * to be correctly set depending on whether the XML is valid or not! */
				var xml:XML = contentAsXML;
			}
			catch (err:Error)
			{
				_valid = false;
				_status = err.message;
			}
			
			complete();
		}
	}
}
