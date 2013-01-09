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
	import com.hexagonstar.constants.TextureSmoothing;

	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * An Image2D is a quad with a texture mapped onto it.
	 * 
	 * <p>
	 * The Image class is the Starling equivalent of Flash's Bitmap class. Instead of
	 * BitmapData, Starling uses textures to represent the pixels of an image. To display
	 * a texture, you have to map it onto a quad - and that's what the Image class is for.
	 * </p>
	 * 
	 * <p>
	 * As "Image" inherits from "Quad", you can give it a color. For each pixel, the
	 * resulting color will be the result of the multiplication of the color of the
	 * texture with the color of the quad. That way, you can easily tint textures with a
	 * certain color. Furthermore, images allow the manipulation of texture coordinates.
	 * That way, you can move a texture inside an image without changing any vertex
	 * coordinates of the quad. You can also use this feature as a very efficient way to
	 * create a rectangular mask.
	 * </p>
	 * 
	 * @see direct2d.textures.Texture2D
	 * @see Quad2D
	 */
	public class Image2D extends Quad2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _texture:Texture2D;
		/** @private */
		private var _smoothing:String;
		/** @private */
		private var _vertexDataCache:VertexData2D;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a quad with a texture mapped onto it.
		 * 
		 * @param texture
		 */
		public function Image2D(texture:Texture2D)
		{
			if (texture)
			{
				var f:Rectangle = texture.frame;
				var w:Number = f ? f.width : texture.width;
				var h:Number = f ? f.height : texture.height;
				var pma:Boolean = texture.premultipliedAlpha;
				
				super(w, h, 0xFFFFFF, pma);
				
				_texture = texture;
				_smoothing = TextureSmoothing.BILINEAR;
				_vertexDataCache = new VertexData2D(4, pma);
				
				updateVertexDataCache();
			}
			else
			{
				throw new ArgumentError("Texture cannot be null.");
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates an Image with a texture that is created from a bitmap object.
		 * 
		 * @param bitmap
		 * @return Image2D
		 */
		public static function fromBitmap(bitmap:Bitmap):Image2D
		{
			return new Image2D(Texture2D.fromBitmap(bitmap));
		}
		
		
		/**
		 * Readjusts the dimensions of the image according to its current texture. Call
		 * this method to synchronize image and texture size after assigning a texture
		 * with a different size.
		 */
		public function readjustSize():void
		{
			var f:Rectangle = texture.frame;
			var w:Number = f ? f.width : texture.width;
			var h:Number = f ? f.height : texture.height;
			
			_vertexData.setPosition(0, 0.0, 0.0);
			_vertexData.setPosition(1, w, 0.0);
			_vertexData.setPosition(2, 0.0, h);
			_vertexData.setPosition(3, w, h);
			
			updateVertexDataCache();
		}
		
		
		/**
		 * Sets the texture coordinates of a vertex. Coordinates are in the range [0, 1].
		 * 
		 * @param vertexID
		 * @param coords
		 */
		public function setTexCoords(vertexID:int, coords:Point):void
		{
			_vertexData.setTexCoords(vertexID, coords.x, coords.y);
			updateVertexDataCache();
		}
		
		
		/**
		 * Gets the texture coordinates of a vertex. Coordinates are in the range [0, 1].
		 * 
		 * @param vertexID
		 * @return Point
		 */
		public function getTexCoords(vertexID:int):Point
		{
			var coords:Point = new Point();
			_vertexData.getTexCoords(vertexID, coords);
			return coords;
		}
		
		
		/**
		 * Copies the raw vertex data to a VertexData instance. The texture coordinates
		 * are already in the format required for rendering.
		 * 
		 * @param targetData
		 * @param targetVertexID
		 */
		public override function copyVertexDataTo(targetData:VertexData2D,
			targetVertexID:int = 0):void
		{
			_vertexDataCache.copyTo(targetData, targetVertexID);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function setVertexColor(vertexID:int, color:uint):void
		{
			super.setVertexColor(vertexID, color);
			updateVertexDataCache();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function setVertexAlpha(vertexID:int, alpha:Number):void
		{
			super.setVertexAlpha(vertexID, alpha);
			updateVertexDataCache();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function renderWithSupport(support:Render2DRenderSupport, alpha:Number):void
		{
			support.batchQuad(this, alpha, _texture, _smoothing);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The texture that is displayed on the quad.
		 */
		public function get texture():Texture2D
		{
			return _texture;
		}
		public function set texture(v:Texture2D):void
		{
			if (!v)
			{
				throw new ArgumentError("Texture cannot be null.");
			}
			else if (v != _texture)
			{
				_texture = v;
				_vertexData.setPremultipliedAlpha(_texture.premultipliedAlpha);
				updateVertexDataCache();
			}
		}
		
		
		/**
		 * The smoothing filter that is used for the texture.
		 * 
		 * @default bilinear
		 * @see TextureSmoothing
		 */
		public function get smoothing():String
		{
			return _smoothing;
		}
		public function set smoothing(v:String):void
		{
			if (TextureSmoothing.isValid(v)) _smoothing = v;
			else throw new ArgumentError("Invalid smoothing mode: " + v);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		protected override function updateVertexData(width:Number, height:Number, color:uint,
			premultipliedAlpha:Boolean):void
		{
			super.updateVertexData(width, height, color, premultipliedAlpha);
			
			_vertexData.setTexCoords(0, 0.0, 0.0);
			_vertexData.setTexCoords(1, 1.0, 0.0);
			_vertexData.setTexCoords(2, 0.0, 1.0);
			_vertexData.setTexCoords(3, 1.0, 1.0);
		}
		
		
		/**
		 * @private
		 */
		private function updateVertexDataCache():void
		{
			_vertexData.copyTo(_vertexDataCache);
			_texture.adjustVertexData(_vertexDataCache, 0, 4);
		}
	}
}
