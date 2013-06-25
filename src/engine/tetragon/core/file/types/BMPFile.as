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
	import tetragon.util.image.BMPDecoder;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	
	/**
	 * A file that can be used to load BMP image files.
	 * 
	 * @see com.hexagonstar.file.types.IFile
	 */
	public class BMPFile extends BinaryFile implements IFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _bitmapData:BitmapData;
		/** @private */
		protected var _transparent:Boolean;
		/** @private */
		protected var _fillColor:uint;
		/** @private */
		protected var _smoothing:Boolean;
		/** @private */
		protected var _pixelSnapping:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new BMPFile instance.
		 * 
		 * @param path The path of the file that this file object is used for.
		 * @param id An optional ID for the file.
		 * @param priority An optional load priority for the file. Used for loading with
		 *            the BulkLoader class.
		 * @param weight An optional weight for the file. Used for weighted loading with
		 *            the BulkLoader class.
		 * @param callback An optional callback method that can be associated with the file.
		 * @param params An optional array of parameters that can be associated with the file.
		 * @param transparent <code>true</code> if the resulting image should be
		 *            transparent, <code>false</code> if not.
		 * @param fillColor The fill color of the image, an RGB value for opaque images or
		 *            an ARGB value for transparent images.
		 * @param smoothing <code>true</code> if the bitmap uses smoothing,
		 *            <code>false</code> if not.
		 * @param pixelSnapping <code>true</code> if the bitmap uses pixel snapping,
		 *            <code>false</code> if not.
		 */
		public function BMPFile(path:String = null, id:String = null, priority:Number = NaN,
			weight:int = 1, callback:Function = null, params:Array = null,
			transparent:Boolean = false, fillColor:uint = 0x000000, smoothing:Boolean = false,
			pixelSnapping:String = "auto")
		{
			super(path, id, priority, weight, callback, params);
			
			_transparent = transparent;
			_fillColor = fillColor;
			_smoothing = smoothing;
			_pixelSnapping = pixelSnapping;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get fileTypeID():int
		{
			return FileTypeIndex.BMP_FILE_ID;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get content():*
		{
			return contentAsBitmap;
		}
		
		
		/**
		 * The image file content as a <code>Bitmap</code> object. This creates and
		 * returns a new <code>Bitmap</code> object.
		 */
		public function get contentAsBitmap():Bitmap
		{
			var b:BitmapData = contentAsBitmapData;
			if (b) return new Bitmap(b, _pixelSnapping, _smoothing);
			return null;
		}
		
		
		/**
		 * The image file content as a <code>BitmapData</code> object.
		 */
		public function get contentAsBitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get contentAsBytes():ByteArray
		{
			if (_bitmapData) return _bitmapData.getPixels(new Rectangle(0, 0, _bitmapData.width,
				_bitmapData.height));
			return null;
		}
		override public function set contentAsBytes(v:ByteArray):void
		{
			var decoder:BMPDecoder = new BMPDecoder();
			try
			{
				_bitmapData = decoder.decode(v);
				_valid = true;
				_status = Status.OK;
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
