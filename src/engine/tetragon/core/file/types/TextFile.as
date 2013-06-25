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
	/**
	 * The TextFile is a file type implementation that can be used to load any kind of
	 * text-based file. You can use the <code>contentAsString</code> property to return
	 * the loaded text typed as a String.
	 * 
	 * @see com.hexagonstar.file.types.IFile
	 */
	public class TextFile extends BinaryFile implements IFile
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
		public function TextFile(path:String = null, id:String = null, priority:Number = NaN,
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
			return FileTypeIndex.TEXT_FILE_ID;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get content():*
		{
			return contentAsString;
		}
		
		
		/**
		 * The TextFile content, as a String.
		 */
		public function get contentAsString():String
		{
			if (!_content) return null;
			var s:String = _content.readUTFBytes(_content.length);
			_content.position = 0;
			return s;
		}
	}
}
