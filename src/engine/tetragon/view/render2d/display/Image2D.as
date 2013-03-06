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
package tetragon.view.render2d.display
{
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.core.VertexData2D;
	import tetragon.view.render2d.textures.Texture2D;
	import tetragon.view.render2d.textures.TextureSmoothing2D;

	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	/**
	 * An Image is a quad with a texture mapped onto it.
	 * <p>
	 * The Image class is the Render2D equivalent of Flash's Bitmap class. Instead of
	 * BitmapData, Render2D uses textures to represent the pixels of an image. To display
	 * a texture, you have to map it onto a quad - and that's what the Image class is for.
	 * </p>
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
	 * @see Render2D.textures.Texture2D
	 * @see Quad2D
	 */
	public class Image2D extends Quad2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _texture:Texture2D;
		private var _smoothing:String;
		private var _vertexDataCache:VertexData2D;
		private var _vertexDataCacheInvalid:Boolean;
		private var _clipRect:Rectangle;
		
		
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
				var frame:Rectangle = texture.frame;
				var width:Number = frame ? frame.width : texture.width;
				var height:Number = frame ? frame.height : texture.height;
				var pma:Boolean = texture.premultipliedAlpha;
				
				super(width, height, 0xFFFFFF, pma);
				
				_vertexData.setTexCoords(0, 0.0, 0.0);
				_vertexData.setTexCoords(1, 1.0, 0.0);
				_vertexData.setTexCoords(2, 0.0, 1.0);
				_vertexData.setTexCoords(3, 1.0, 1.0);
				
				_texture = texture;
				_smoothing = TextureSmoothing2D.BILINEAR;
				_vertexDataCache = new VertexData2D(4, pma);
				_vertexDataCacheInvalid = true;
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
		 * @param generateMipMaps
		 * @param scale
		 */
		public static function fromBitmap(bitmap:Bitmap, generateMipMaps:Boolean = true,
			scale:Number = 1.0):Image2D
		{
			return new Image2D(Texture2D.fromBitmap(bitmap, generateMipMaps, false, scale));
		}
		
		
		/**
		 * Readjusts the dimensions of the image according to its current texture. Call
		 * this method to synchronize image and texture size after assigning a texture
		 * with a different size.
		 */
		public function readjustSize():void
		{
			var frame:Rectangle = texture.frame;
			var width:Number = frame ? frame.width : texture.width;
			var height:Number = frame ? frame.height : texture.height;
			
			_vertexData.setPosition(0, 0.0, 0.0);
			_vertexData.setPosition(1, width, 0.0);
			_vertexData.setPosition(2, 0.0, height);
			_vertexData.setPosition(3, width, height);
			
			onVertexDataChanged();
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
			onVertexDataChanged();
		}
		
		
		/**
		 * Gets the texture coordinates of a vertex. Coordinates are in the range [0, 1].
		 * If you pass a 'resultPoint', the result will be stored in this point instead of
		 * creating a new object.
		 * 
		 * @param vertexID
		 * @param resultPoint
		 */
		public function getTexCoords(vertexID:int, resultPoint:Point = null):Point
		{
			if (!resultPoint) resultPoint = new Point();
			_vertexData.getTexCoords(vertexID, resultPoint);
			return resultPoint;
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
			if (_vertexDataCacheInvalid)
			{
				_vertexDataCacheInvalid = false;
				_vertexData.copyTo(_vertexDataCache);
				_texture.adjustVertexData(_vertexDataCache, 0, 4);
			}
			_vertexDataCache.copyTo(targetData, targetVertexID);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function render(support:RenderSupport2D, parentAlpha:Number):void
		{
			if (!_clipRect)
			{
				support.batchQuad(this, parentAlpha, _texture, _smoothing);
			}
			else
			{
				support.finishQuadBatch();
				support.scissorRectangle = _clipRect;
				
				support.batchQuad(this, parentAlpha, _texture, _smoothing);
				
				support.finishQuadBatch();
				support.scissorRectangle = null;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject2D
		{
			// without a clip rect, the sprite should behave just like before
			if (!_clipRect) return super.hitTest(localPoint, forTouch);
			
			// on a touch test, invisible or untouchable objects cause the test to fail
			if (forTouch && (!visible || !touchable)) return null;
			
			if (_clipRect.containsPoint(localToGlobal(localPoint)))
			{
				return super.hitTest(localPoint, forTouch);
			}
			else
			{
				return null;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get clipRect():Rectangle
		{
			return _clipRect;
		}
		public function set clipRect(v:Rectangle):void
		{
			if (v)
			{
				if (!_clipRect) _clipRect = v.clone();
				else _clipRect.setTo(v.x, v.y, v.width, v.height);
			}
			else
			{
				_clipRect = null;
			}
		}
		
		
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
				onVertexDataChanged();
			}
		}
		
		
		/**
		 * The smoothing filter that is used for the texture.
		 * 
		 * @default bilinear
		 * @see Render2D.textures.TextureSmoothing2D
		 */
		public function get smoothing():String
		{
			return _smoothing;
		}
		public function set smoothing(value:String):void
		{
			if (TextureSmoothing2D.isValid(value))
			{
				_smoothing = value;
			}
			else
			{
				throw new ArgumentError("Invalid smoothing mode: " + value);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		protected override function onVertexDataChanged():void
		{
			_vertexDataCacheInvalid = true;
		}
	}
}
