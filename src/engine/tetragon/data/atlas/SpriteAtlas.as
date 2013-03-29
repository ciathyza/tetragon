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
package tetragon.data.atlas
{
	import tetragon.file.resource.ResourceIndex;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * SpriteAtlas class
	 *
	 * @author Hexagon
	 */
	public class SpriteAtlas extends Atlas
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const SPRITE_ATLAS:String = "SpriteAtlas";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _backgroundColor:uint;
		/** @private */
		protected var _transparent:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param id
		 * @param imageID
		 * @param subTextureBounds
		 * @param transparent
		 * @param backgroundColor
		 */
		public function SpriteAtlas(id:String, imageID:String,
			subTextureBounds:Vector.<SubTextureBounds>, transparent:Boolean = false,
			backgroundColor:uint = 0xFF00FF, alphaImageID:String = null)
		{
			super(id, imageID, subTextureBounds, alphaImageID);
			
			_transparent = transparent;
			_backgroundColor = backgroundColor;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			if (!_source) return;
			(_source as BitmapData).dispose();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function getImage(id:String, scale:Number = 1.0):*
		{
			var region:Rectangle = _regions[id];
			if (!_source || !region) return ResourceIndex.getPlaceholderImage();
			if (!_point) _point = new Point();
			
			var sprite:BitmapData;
			var frame:Rectangle = _frames[id];
			
			/* If the sub image has associated frame boundaries, prepare a bitmap data
			 * with the size of the frame and copy the image onto it at the right offset. */
			if (frame)
			{
				sprite = new BitmapData(frame.width, frame.height, _transparent,
					_backgroundColor);
				_point.setTo(-frame.x, -frame.y);
			}
			else
			{
				sprite = new BitmapData(region.width, region.height, _transparent,
				_backgroundColor);
				_point.setTo(0, 0);
			}
			
			sprite.copyPixels(_source, region, _point);
			
			if (scale == 1.0) return sprite;
			
			var scaled:BitmapData = new BitmapData(Math.round(sprite.width * scale),
				Math.round(sprite.height * scale), _transparent, _backgroundColor);
			if (!_matrix) _matrix = new Matrix();
			_matrix.setTo(scale, 0, 0, scale, 0, 0);
			scaled.draw(sprite, _matrix);
			return scaled;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		public function set backgroundColor(v:uint):void
		{
			_backgroundColor = v;
		}
		
		
		public function get transparent():Boolean
		{
			return _transparent;
		}
		public function set transparent(v:Boolean):void
		{
			_transparent = v;
		}
	}
}
