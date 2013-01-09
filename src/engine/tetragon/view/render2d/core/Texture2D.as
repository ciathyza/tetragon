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
package tetragon.view.render2d.core
{
	import com.hexagonstar.exception.AbstractClassException;
	import com.hexagonstar.exception.MissingContext3DException;
	import com.hexagonstar.util.math.nextPowerOfTwo;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * <p>
	 * A texture stores the information that represents an image. It cannot be added to
	 * the display list directly; instead it has to be mapped onto a display object. In
	 * Starling, that display object is the class "Image".
	 * </p>
	 * 
	 * <strong>Texture Formats</strong>
	 * 
	 * <p>
	 * Since textures can be created from a "BitmapData" object, Starling supports any
	 * bitmap format that is supported by Flash. And since you can render any Flash
	 * display object into a BitmapData object, you can use this to display non-Starling
	 * content in Starling - e.g. Shape objects.
	 * </p>
	 * 
	 * <p>
	 * Starling also supports ATF textures (Adobe Texture Format), which is a container
	 * for compressed texture formats that can be rendered very efficiently by the GPU.
	 * Refer to the Flash documentation for more information about this format.
	 * </p>
	 * 
	 * <strong>Mip Mapping</strong>
	 * 
	 * <p>
	 * MipMaps are scaled down versions of a texture. When an image is displayed smaller
	 * than its natural size, the GPU may display the mip maps instead of the original
	 * texture. This reduces aliasing and accelerates rendering. It does, however, also
	 * need additional memory; for that reason, you can choose if you want to create them
	 * or not.
	 * </p>
	 * 
	 * <strong>Texture Frame</strong>
	 * 
	 * <p>
	 * The frame property of a texture allows you let a texture appear inside the bounds
	 * of an image, leaving a transparent space around the texture. The frame rectangle is
	 * specified in the coordinate system of the texture (not the image):
	 * </p>
	 * 
	 * <listing> var frame:Rectangle = new Rectangle(-10, -10, 30, 30); var
	 * texture:Texture = Texture.fromTexture(anotherTexture, null, frame); var image:Image
	 * = new Image(texture); </listing>
	 * 
	 * <p>
	 * This code would create an image with a size of 30x30, with the texture placed at
	 * <code>x=10, y=10</code> within that image (assuming that 'anotherTexture' has a
	 * width and height of 10 pixels, it would appear in the middle of the image).
	 * </p>
	 * 
	 * <p>
	 * The texture atlas makes use of this feature, as it allows to crop transparent edges
	 * of a texture and making up for the changed size by specifying the original texture
	 * frame. Tools like <a href="http://www.texturepacker.com/">TexturePacker</a> use
	 * this to optimize the atlas.
	 * </p>
	 * 
	 * <strong>Texture Coordinates</strong>
	 * 
	 * <p>
	 * If, on the other hand, you want to show only a part of the texture in an image
	 * (i.e. to crop the the texture), you can either create a subtexture (with the method
	 * 'Texture.fromTexture()' and specifying a rectangle for the region), or you can
	 * manipulate the texture coordinates of the image object. The method
	 * 'image.setTexCoords' allows you to do that.
	 * </p>
	 * 
	 * @see starling.display.Image
	 * @see TextureAtlas
	 */
	public class Texture2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _frame:Rectangle;
		/** @private */
		private var _repeat:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function Texture2D()
		{
			if (getQualifiedClassName(this) == "starling.textures::Texture")
			{
				throw new AbstractClassException(this);
			}
			_repeat = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the underlying texture data.
		 */
		public function dispose():void
		{ 
			/* Abstract method! */
		}
		
		
		/**
		 * Converts texture coordinates and vertex positions of raw vertex data into the
		 * format required for rendering.
		 * 
		 * @param vertexData
		 * @param vertexID
		 * @param count
		 */
		public function adjustVertexData(vertexData:VertexData2D, vertexID:int, count:int):void
		{
			if (_frame)
			{
				if (count != 4)
				{
					throw new ArgumentError("Textures with a frame can only be used on quads");
				}
				
				var deltaRight:Number = _frame.width + _frame.x - width;
				var deltaBottom:Number = _frame.height + _frame.y - height;
				
				vertexData.translateVertex(vertexID, -_frame.x, -_frame.y);
				vertexData.translateVertex(vertexID + 1, -deltaRight, -_frame.y);
				vertexData.translateVertex(vertexID + 2, -_frame.x, -deltaBottom);
				vertexData.translateVertex(vertexID + 3, -deltaRight, -deltaBottom);
			}
		}
		
		
		/**
		 * Creates a texture object from a bitmap. Beware: you must not dispose 'bitmap' if
		 * Starling should handle a lost device context.
		 * 
		 * @param bitmap
		 * @param generateMipMaps
		 * @param optimizeForRenderTexture
		 * @return Texture2D
		 */
		public static function fromBitmap(bitmap:Bitmap,
			generateMipMaps:Boolean = true,
			optimizeForRenderTexture:Boolean = false):Texture2D
		{
			return fromBitmapData(bitmap.bitmapData, generateMipMaps, optimizeForRenderTexture);
		}
		
		
		/**
		 * Creates a texture from bitmap data. Beware: you must not dispose 'data' if
		 * Starling should handle a lost device context.
		 * 
		 * @param bitmapData
		 * @param generateMipMaps
		 * @param optimizeForRenderTexture
		 * @return Texture2D
		 */
		public static function fromBitmapData(bitmapData:BitmapData,
			generateMipMaps:Boolean = true,
			optimizeForRenderTexture:Boolean = false):Texture2D
		{
			var ow:int = bitmapData.width;
			var oh:int = bitmapData.height;
			var lw:int = nextPowerOfTwo(bitmapData.width);
			var lh:int = nextPowerOfTwo(bitmapData.height);
			var c:Context3D = Render2D.context;
			var pd:BitmapData;
			
			if (!c) throwMissingContext3DException("Texture2D.fromBitmapData");
			
			var t:Texture = c.createTexture(lw, lh, Context3DTextureFormat.BGRA, optimizeForRenderTexture);
			if (lw > ow || lh > oh)
			{
				pd = new BitmapData(lw, lh, true, 0);
				pd.copyPixels(bitmapData, bitmapData.rect, new Point(0, 0));
				bitmapData = pd;
			}
			
			uploadBitmapData(t, bitmapData, generateMipMaps);
			
			var ct:ConcreteTexture2D = new ConcreteTexture2D(t, lw, lh, generateMipMaps, true, optimizeForRenderTexture);
			if (Render2D.handleLostContext)
			{
				ct.restoreOnLostContext(bitmapData);
			}
			else if (pd)
			{
				pd.dispose();
			}
			if (ow == lw && oh == lh)
			{
				return ct;
			}
			else
			{
				return new SubTexture2D(ct, new Rectangle(0, 0, ow, oh), true);
			}
		}
		
		
		/**
		 * Creates a texture from the compressed ATF format. Beware: you must not dispose
		 * 'data' if Starling should handle a lost device context.
		 * 
		 * @param data
		 * @return Texture2D
		 */
		public static function fromATFData(data:ByteArray):Texture2D
		{
			var context:Context3D = Render2D.context;
			if (!context) throwMissingContext3DException("Texture2D.fromATFData");
			
			var sig:String = String.fromCharCode(data[0], data[1], data[2]);
			if (sig != "ATF") throw new ArgumentError("Invalid ATF data");
			
			var format:String = data[6] == 2
				? Context3DTextureFormat.COMPRESSED
				: Context3DTextureFormat.BGRA;
			
			var w:int = Math.pow(2, data[7]);
			var h:int = Math.pow(2, data[8]);
			var textureCount:int = data[9];
			var nativeTexture:Texture = context.createTexture(w, h, format, false);

			uploadAtfData(nativeTexture, data);

			var ct:ConcreteTexture2D = new ConcreteTexture2D(nativeTexture, w, h, textureCount > 1, false);
			if (Render2D.handleLostContext) ct.restoreOnLostContext(data);
			return ct;
		}
		
		
		/**
		 * Creates a texture that contains a region (in pixels) of another texture. The
		 * new texture will reference the base texture; no data is duplicated.
		 * 
		 * @param texture
		 * @param region
		 * @param frame
		 * @return Texture2D
		 */
		public static function fromTexture(texture:Texture2D, region:Rectangle = null,
			frame:Rectangle = null):Texture2D
		{
			var subTexture:Texture2D = new SubTexture2D(texture, region);
			subTexture._frame = frame;
			return subTexture;
		}
		
		
		/**
		 * Creates an empty texture of a certain size and color. The color parameter
		 * expects data in ARGB format.
		 * 
		 * @param width
		 * @param height
		 * @param color
		 * @param optimizeForRenderTexture
		 * @return Texture2D
		 */
		public static function createEmpty(width:int = 64, height:int = 64, color:uint = 0xFFFFFFFF,
			optimizeForRenderTexture:Boolean = false):Texture2D
		{
			var b:BitmapData = new BitmapData(width, height, true, color);
			var t:Texture2D = fromBitmapData(b, false, optimizeForRenderTexture);
			if (!Render2D.handleLostContext) b.dispose();
			return t;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The texture frame (see class description).
		 */
		public function get frame():Rectangle
		{
			return _frame ? _frame.clone() : new Rectangle(0, 0, width, height);
			// the frame property is readonly - set the frame in the 'fromTexture' method.
			// why is it readonly? To be able to efficiently cache the texture coordinates on
			// rendering, textures need to be immutable (except 'repeat', which is not cached,
			// anyway).
		}


		/**
		 * Indicates if the texture should repeat like a wallpaper or stretch the
		 * outermost pixels. Note: this makes sense only in textures with sidelengths that
		 * are powers of two and that are not loaded from a texture atlas (i.e. no
		 * subtextures).
		 * 
		 * @default false
		 */
		public function get repeat():Boolean
		{
			return _repeat;
		}
		public function set repeat(value:Boolean):void
		{
			_repeat = value;
		}
		
		
		/**
		 * The width of the texture in pixels.
		 */
		public function get width():Number
		{
			/* Abstract method! */
			return 0;
		}
		
		
		/**
		 * The height of the texture in pixels.
		 */
		public function get height():Number
		{
			/* Abstract method! */
			return 0;
		}
		
		
		/**
		 * The Stage3D texture object the texture is based on.
		 */
		public function get base():TextureBase
		{
			/* Abstract method! */
			return null;
		}
		
		
		/**
		 * Indicates if the texture contains mip maps.
		 */
		public function get mipMapping():Boolean
		{
			/* Abstract method! */
			return false;
		}
		
		
		/**
		 * Indicates if the alpha values are premultiplied into the RGB values.
		 */
		public function get premultipliedAlpha():Boolean
		{
			/* Abstract method! */
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Uploads the bitmap data to the native texture, optionally creating mipmaps.
		 * 
		 * @param nativeTexture
		 * @param data
		 * @param generateMipmaps
		 */
		internal static function uploadBitmapData(nativeTexture:Texture, data:BitmapData,
			generateMipmaps:Boolean):void
		{
			nativeTexture.uploadFromBitmapData(data);
			
			if (generateMipmaps)
			{
				var currentWidth:int = data.width >> 1;
				var currentHeight:int = data.height >> 1;
				var level:int = 1;
				var canvas:BitmapData = new BitmapData(currentWidth, currentHeight, true, 0);
				var transform:Matrix = new Matrix(.5, 0, 0, .5);
				var bounds:Rectangle = new Rectangle();
				
				while (currentWidth >= 1 || currentHeight >= 1)
				{
					bounds.width = currentWidth;
					bounds.height = currentHeight;
					canvas.fillRect(bounds, 0);
					canvas.draw(data, transform, null, null, null, true);
					nativeTexture.uploadFromBitmapData(canvas, level++);
					transform.scale(0.5, 0.5);
					currentWidth = currentWidth >> 1;
					currentHeight = currentHeight >> 1;
				}
				
				canvas.dispose();
			}
		}
		
		
		/**
		 * Uploads ATF data from a ByteArray to a native texture.
		 * 
		 * @param nativeTexture
		 * @param data
		 * @param offset
		 */
		internal static function uploadAtfData(nativeTexture:Texture, data:ByteArray,
			offset:int = 0):void
		{
			nativeTexture.uploadCompressedTextureFromByteArray(data, offset);
		}
		
		
		/**
		 * @private
		 */
		protected static function throwMissingContext3DException(method:String):void
		{
			throw new MissingContext3DException(method + ": context3D is null!");
		}
	}
}