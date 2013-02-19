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
package tetragon.view.render2d.textures
{
	import tetragon.view.render2d.core.Render2D;
	import tetragon.view.render2d.core.VertexData2D;
	import tetragon.view.render2d.events.Event2D;

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


	/**
	 * <p>
	 * A texture stores the information that represents an image. It cannot be added to
	 * the display list directly; instead it has to be mapped onto a display object. In
	 * Render2D, that display object is the class "Image".
	 * </p>
	 * 
	 * <strong>Texture Formats</strong>
	 * 
	 * <p>
	 * Since textures can be created from a "BitmapData" object, Render2D supports any
	 * bitmap format that is supported by Flash. And since you can render any Flash
	 * display object into a BitmapData object, you can use this to display non-Render2D
	 * content in Render2D - e.g. Shape objects.
	 * </p>
	 * 
	 * <p>
	 * Render2D also supports ATF textures (Adobe Texture Format), which is a container
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
	 * = new Image(texture);</listing>
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
	 * @see Render2D.display.Image2D
	 * @see TextureAtlas2D
	 */
	public class Texture2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _frame:Rectangle;
		private var _repeat:Boolean;
		
		/** helper object */
		private static var _origin:Point = new Point();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function Texture2D()
		{
			_repeat = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the underlying texture data. Note that not all textures need to be disposed: 
		 * SubTextures (created with 'Texture.fromTexture') just reference other textures and
		 * and do not take up resources themselves; this is also true for textures from an 
		 * atlas.
		 */
		public function dispose():void
		{ 
			// override in subclasses
		}
		
		
		/**
		 * Creates a texture object from a bitmap.
		 * Beware: you must not dispose 'data' if Render2D should handle a lost device context.
		 * 
		 * @param data
		 * @param generateMipMaps
		 * @param optimizeForRenderToTexture
		 * @param scale
		 **/
		public static function fromBitmap(data:Bitmap, generateMipMaps:Boolean = true,
			optimizeForRenderToTexture:Boolean = false, scale:Number = 1.0):Texture2D
		{
			return fromBitmapData(data.bitmapData, generateMipMaps, optimizeForRenderToTexture,
				scale);
		}
		
		
		/**
		 * Creates a texture from bitmap data. 
		 * Beware: you must not dispose 'data' if Render2D should handle a lost device context.
		 * 
		 * @param data
		 * @param generateMipMaps
		 * @param optimizeForRenderToTexture
		 * @param scale
		 */
		public static function fromBitmapData(data:BitmapData, generateMipMaps:Boolean = true,
			optimizeForRenderToTexture:Boolean = false, scale:Number = 1.0):Texture2D
		{
			var origWidth:int = data.width;
			var origHeight:int = data.height;
			var legalWidth:int = nextPowerOfTwo(origWidth);
			var legalHeight:int = nextPowerOfTwo(origHeight);
			var context:Context3D = Render2D.context;
			var potData:BitmapData;
			
			if (!context) throw new MissingContext3DException();
			
			var nativeTexture:Texture = context.createTexture(legalWidth, legalHeight,
				Context3DTextureFormat.BGRA, optimizeForRenderToTexture);
			
			if (legalWidth > origWidth || legalHeight > origHeight)
			{
				potData = new BitmapData(legalWidth, legalHeight, true, 0);
				potData.copyPixels(data, data.rect, _origin);
				data = potData;
			}
			
			uploadBitmapData(nativeTexture, data, generateMipMaps);
			
			var concreteTexture:ConcreteTexture2D = new ConcreteTexture2D(nativeTexture,
				Context3DTextureFormat.BGRA, legalWidth, legalHeight, generateMipMaps, true,
				optimizeForRenderToTexture, scale);
			
			if (Render2D.handleLostContext) concreteTexture.restoreOnLostContext(data);
			else if (potData) potData.dispose();
			
			if (origWidth == legalWidth && origHeight == legalHeight)
			{
				return concreteTexture;
			}
			else
			{
				return new SubTexture2D(concreteTexture, new Rectangle(0, 0,
					origWidth / scale, origHeight / scale), true);
			}
		}
		
		
		/**
		 * Creates a texture from the compressed ATF format. If you don't want to use any embedded
		 * mipmaps, you can disable them by setting "useMipMaps" to <code>false</code>.
		 * Beware: you must not dispose 'data' if Render2D should handle a lost device context.
		 * 
		 * <p>If you pass a function for the 'loadAsync' parameter, the method will return
		 * immediately, while the texture will be created asynchronously. It can be used as soon
		 * as the callback has been executed. This is the expected function definition:
		 * <code>function(texture:Texture):void;</code></p>
		 * 
		 * @param data
		 * @param scale
		 * @param useMipMaps
		 * @param loadAsync
		 */
		public static function fromATFData(data:ByteArray, scale:Number = 1.0,
			useMipMaps:Boolean = true, loadAsync:Function = null):Texture2D
		{
			const eventType:String = "textureReady"; // defined here for backwards compatibility
			var context:Context3D = Render2D.context;
			
			if (!context) throw new MissingContext3DException();
			
			var async:Boolean = loadAsync != null;
			var atfData:ATFData2D = new ATFData2D(data);
			var nativeTexture:flash.display3D.textures.Texture = context.createTexture(atfData.width,
				atfData.height, atfData.format, false);
			
			uploadATFData(nativeTexture, data, 0, async);
			
			var concreteTexture:ConcreteTexture2D = new ConcreteTexture2D(nativeTexture,
				atfData.format, atfData.width, atfData.height,
				useMipMaps && atfData.numTextures > 1, false, false, scale);
			
			if (Render2D.handleLostContext)
			{
				concreteTexture.restoreOnLostContext(atfData);
			}
			
			if (async)
			{
				nativeTexture.addEventListener(eventType, onTextureReady);
			}
			
			return concreteTexture;
			
			function onTextureReady(e:Event2D):void
			{
				nativeTexture.removeEventListener(eventType, onTextureReady);
				if (loadAsync.length == 1) loadAsync(concreteTexture);
				else loadAsync();
			}
		}
		
		
		/**
		 * Creates a texture with a certain size and color.
		 * 
		 * @param width  in points; number of pixels depends on scale parameter
		 * @param height in points; number of pixels depends on scale parameter
		 * @param color  expected in ARGB format (inlude alpha!)
		 * @param optimizeForRenderToTexture indicates if this texture will be used as render target
		 * @param scale  if you omit this parameter, 'Render2D.contentScaleFactor' will be used.
		 */
		public static function fromColor(width:int, height:int, color:uint = 0xFFFFFFFF,
			optimizeForRenderToTexture:Boolean = false, scale:Number = -1.0):Texture2D
		{
			if (scale <= 0.0) scale = Render2D.contentScaleFactor;
			var b:BitmapData = new BitmapData(width * scale, height * scale, true, color);
			var t:Texture2D = fromBitmapData(b, false, optimizeForRenderToTexture, scale);
			if (!Render2D.handleLostContext) b.dispose();
			return t;
		}
		
		
		/**
		 * Creates an empty texture of a certain size. Useful mainly for render textures. 
		 * Beware that the texture can only be used after you either upload some color data or
		 * clear the texture while it is an active render target. 
		 * 
		 * @param width  in points; number of pixels depends on scale parameter
		 * @param height in points; number of pixels depends on scale parameter
		 * @param premultipliedAlpha the PMA format you will use the texture with
		 * @param optimizeForRenderToTexture indicates if this texture will be used as render target
		 * @param scale if you omit this parameter, 'Render2D.contentScaleFactor' will be used.
		 */
		public static function empty(width:int = 64, height:int = 64,
			premultipliedAlpha:Boolean = false, optimizeForRenderToTexture:Boolean = true,
			scale:Number = -1.0):Texture2D
		{
			if (scale <= 0.0) scale = Render2D.contentScaleFactor;
			
			var origWidth:int = width * scale;
			var origHeight:int = height * scale;
			var legalWidth:int = nextPowerOfTwo(origWidth);
			var legalHeight:int = nextPowerOfTwo(origHeight);
			var format:String = Context3DTextureFormat.BGRA;
			var context:Context3D = Render2D.context;
			
			if (!context) throw new MissingContext3DException();
			
			var nativeTexture:Texture = context.createTexture(legalWidth, legalHeight,
				Context3DTextureFormat.BGRA, optimizeForRenderToTexture);
			var concreteTexture:ConcreteTexture2D = new ConcreteTexture2D(nativeTexture, format,
				legalWidth, legalHeight, false, premultipliedAlpha, optimizeForRenderToTexture, scale);
			
			if (origWidth == legalWidth && origHeight == legalHeight)
			{
				return concreteTexture;
			}
			else
			{
				return new SubTexture2D(concreteTexture, new Rectangle(0, 0, width, height), true);
			}
		}
		
		
		/**
		 * Creates a texture that contains a region (in pixels) of another texture. The new
		 * texture will reference the base texture; no data is duplicated.
		 * 
		 * @param texture
		 * @param region
		 * @param frame
		 */
		public static function fromTexture(texture:Texture2D, region:Rectangle = null,
			frame:Rectangle = null):Texture2D
		{
			var subTexture:Texture2D = new SubTexture2D(texture, region);
			subTexture._frame = frame;
			return subTexture;
		}
		
		
		/**
		 * Converts texture coordinates and vertex positions of raw vertex data into the format 
		 * required for rendering.
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
					throw new ArgumentError("Textures with a frame can only be used on quads.");
				}
				
				var deltaRight:Number = _frame.width + _frame.x - width;
				var deltaBottom:Number = _frame.height + _frame.y - height;
				
				vertexData.translateVertex(vertexID, -_frame.x, -_frame.y);
				vertexData.translateVertex(vertexID + 1, -deltaRight, -_frame.y);
				vertexData.translateVertex(vertexID + 2, -_frame.x, -deltaBottom);
				vertexData.translateVertex(vertexID + 3, -deltaRight, -deltaBottom);
			}
		}
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/** The texture frame (see class description). */
		public function get frame():Rectangle
		{
			// the frame property is readonly - set the frame in the 'fromTexture' method.
			// why is it readonly? To be able to efficiently cache the texture coordinates on
			// rendering, textures need to be immutable (except 'repeat', which is not cached,
			// anyway).
			return _frame ? _frame.clone() : new Rectangle(0, 0, width, height);
		}
		
		
		/** Indicates if the texture should repeat like a wallpaper or stretch the outermost pixels.
		 *  Note: this only works in textures with sidelengths that are powers of two and 
		 *  that are not loaded from a texture atlas (i.e. no subtextures). @default false */
		public function get repeat():Boolean
		{
			return _repeat;
		}
		public function set repeat(v:Boolean):void
		{
			_repeat = v;
		}
		
		
		/** The width of the texture in points. */
		public function get width():Number
		{
			return 0;
		}
		
		
		/** The height of the texture in points. */
		public function get height():Number
		{
			return 0;
		}
		
		
		/** The width of the texture in pixels (without scale adjustment). */
		public function get nativeWidth():Number
		{
			return 0;
		}
		
		
		/** The height of the texture in pixels (without scale adjustment). */
		public function get nativeHeight():Number
		{
			return 0;
		}
		
		
		/** The scale factor, which influences width and height properties. */
		public function get scale():Number
		{
			return 1.0;
		}
		
		
		/** The Stage3D texture object the texture is based on. */
		public function get base():TextureBase
		{
			return null;
		}
		
		
		/** The concrete (power-of-two) texture the texture is based on. */
		public function get root():ConcreteTexture2D
		{
			return null;
		}
		
		
		/** The <code>Context3DTextureFormat</code> of the underlying texture data. */
		public function get format():String
		{
			return Context3DTextureFormat.BGRA;
		}
		
		
		/** Indicates if the texture contains mip maps. */
		public function get mipMapping():Boolean
		{
			return false;
		}
		
		
		/** Indicates if the alpha values are premultiplied into the RGB values. */
		public function get premultipliedAlpha():Boolean
		{
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Uploads the bitmap data to the native texture, optionally creating mipmaps.
		 * @private
		 * 
		 * @param nativeTexture
		 * @param data
		 * @param generateMipmaps
		 */
		internal static function uploadBitmapData(nativeTexture:Texture, data:BitmapData,
			generateMipmaps:Boolean):void
		{
			nativeTexture.uploadFromBitmapData(data);

			if (generateMipmaps && data.width > 1 && data.height > 1)
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
		 * @private
		 * 
		 * @param nativeTexture
		 * @param data
		 * @param offset
		 * @param async
		 */
		internal static function uploadATFData(nativeTexture:Texture, data:ByteArray,
			offset:int = 0, async:Boolean = false):void
		{
			nativeTexture.uploadCompressedTextureFromByteArray(data, offset, async);
		}
	}
}
