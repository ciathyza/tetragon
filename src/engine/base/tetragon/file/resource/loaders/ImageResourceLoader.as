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
	import tetragon.file.resource.ResourceBulkFile;

	import com.hexagonstar.file.types.ImageFile;
	import com.hexagonstar.util.display.StageReference;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * This is a resource loader subclass for image data. It allows to load an image file
	 * format supported by Flash (JPG, PNG, or GIF) and access it as a BitmapData or
	 * Bitmap.
	 */
	public class ImageResourceLoader extends ResourceLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _bitmapData:BitmapData;
		/** @private */
		protected var _transparent:Boolean;
		/** @private */
		protected var _pixelSnapping:String;
		/** @private */
		protected var _smoothing:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ImageResourceLoader()
		{
			_transparent = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function setup(bulkFile:ResourceBulkFile):void
		{
			super.setup(bulkFile);
			_file = new ImageFile(bulkFile.path, bulkFile.id, NaN, 1, null, null, _transparent, 0);
		}
		
		
		/**
		 * Allows to set smoothing and pixelSnapping parameters for the image
		 * resource. If a new bitmap of the image resource is created by using
		 * the <code>bitmap</code> property it will use these parameters.
		 */
		public function setBitmapParams(smoothing:Boolean = false, pixelSnapping:String = "auto"):void
		{
			_smoothing = smoothing;
			_pixelSnapping = pixelSnapping;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns a BitmapData object.
		 */
		override public function get content():*
		{
			return _bitmapData;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function onContentReady(content:*):Boolean 
		{
			if (content is BitmapData)
			{
				_bitmapData = content;
			}
			else if (content is Bitmap)
			{
				/* a .png is initialized as a ByteArray and will be provided
				 * through the super(). ResourceFile class as a Bitmap */
				_bitmapData = (content as Bitmap).bitmapData;
				content = null;
			}
			return _bitmapData != null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromLoaded():void
		{
			onContentReady((_file as ImageFile).contentAsBitmapData);
			onLoadComplete();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromEmbedded(embeddedData:*):void
		{
			if (embeddedData is Bitmap)
			{
				/* Directly load embedded resources if they gave us a Bitmap. */
				onContentReady((embeddedData as Bitmap).bitmapData);
				onLoadComplete();
				return;
			}
            else if (embeddedData is BitmapData)
			{
				/* If they gave us a BitmapData object create a new Bitmap from that. */
				onContentReady((embeddedData as BitmapData));
				onLoadComplete();  
				return;
			}
            else if (embeddedData is DisplayObject)
			{
				var d:DisplayObject = embeddedData;
				/* get sprite's targetSpace */
				var targetSpace:DisplayObject;
				if (d.parent) targetSpace = d.parent;
				else targetSpace = StageReference.stage;
				/* get sprite's rectangle */
				var r:Rectangle = d.getBounds(targetSpace);
				/* create transform matrix for drawing this sprite */
				var m:Matrix = new Matrix();
				m.translate(r.x * -1, r.y * -1);
				/* If they gave us a Sprite draw this onto
				 * a transparent filled BitmapData object */
				var bmd:BitmapData = new BitmapData(r.width, r.height, true, 0);
				bmd.draw(d, m);
				/* Use the BitmapData to create a new Bitmap for this ImageResource */
				onContentReady(bmd);
				onLoadComplete();
				return;
			}
			/* Otherwise it must be a ByteArray, pass it over to the normal path. */
			super.initializeFromEmbedded(embeddedData);
		}
	}
}
