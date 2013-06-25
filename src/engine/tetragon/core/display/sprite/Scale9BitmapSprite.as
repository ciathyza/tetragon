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
package tetragon.core.display.sprite
{
	import tetragon.core.display.shape.Scale9BitmapShape;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	/**
	 * A Sprite that uses a Scale9BitmapShape and which can properly be resized.
	 */
	public class Scale9BitmapSprite extends Sprite
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		private var _shape:Scale9BitmapShape;
		private var _bitmapData:BitmapData;
		private var _height:Number;
		private var _width:Number;
		private var _minWidth:Number;
		private var _minHeight:Number;
		private var _outerWidth:Number;
		private var _outerHeight:Number;
		private var _inner:Rectangle;
		private var _outer:Rectangle;
		private var _smoothing:Boolean;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param bitmapData BitmapData source
		 * @param inner Inner rectangle (relative to 0,0)
		 * @param outer Outer rectangle (relative to 0,0)
		 * @param smoothing If <code>false</code>, upscaled bitmap images are rendered by
		 *            using a nearest-neighbor algorithm and look pixelated. If
		 *            <code>true</code>, upscaled bitmap images are rendered by using a
		 *            bilinear algorithm. Rendering by using the nearest neighbor algorithm is
		 *            usually faster.
		 */
		function Scale9BitmapSprite(bitmapData:BitmapData, inner:Rectangle = null,
			outer:Rectangle = null, smoothing:Boolean = false)
		{
			_shape = new Scale9BitmapShape();
			_bitmapData = bitmapData;
			_inner = inner;
			_outer = outer;
			_smoothing = smoothing;
			
			if (!inner)
			{
				inner = new Rectangle(10, 10, bitmapData.width - 10, bitmapData.height - 10);
			}
			if (!outer)
			{
				_width = inner.width;
				_height = inner.height;
				_outerWidth = 0;
				_outerHeight = 0;
			}
			else
			{
				_width = outer.width;
				_height = outer.height;
				_outerWidth = bitmapData.width - outer.width;
				_outerHeight = bitmapData.height - outer.height;
			}
			
			_minWidth = bitmapData.width - inner.width - _outerWidth + 2;
			_minHeight = bitmapData.height - inner.height - _outerHeight + 2;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		/**
		 * setter deactivated
		 */
		override public function set scaleX(v:Number):void
		{
		}
		
		
		/**
		 * setter deactivated
		 */
		override public function set scaleY(v:Number):void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get width():Number
		{
			return _width;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set width(v:Number):void
		{
			_width = v > _minWidth ? v : _minWidth;
			if (stage) stage.invalidate();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get height():Number
		{
			return _height;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set height(v:Number):void
		{
			_height = v > _minHeight ? v : _minHeight;
			if (stage) stage.invalidate();
		}
		
		
		/**
		 * The BitmapData object being referenced.
		 */
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		
		public function set bitmapData(v:BitmapData):void
		{
			_bitmapData = v;
			if (stage) stage.invalidate();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Callback Handlers
		// -----------------------------------------------------------------------------------------
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(Event.RENDER, onRender);
			onRender();
		}
		
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(Event.RENDER, onRender);
		}
		
		
		private function onRender(e:Event = null):void
		{
			/*
			 * Math.floor optimisation (works only with positive values)
			 * Slower 1733ms
			 * var test:Number = Math.floor(1.5);
			 * Fastest 145ms
			 * var test:int = 1.5 >> 0;
			 */
			_shape.graphics.clear();
			_shape.setProperties(_bitmapData, (_width + _outerWidth) >> 0,
				(_height + _outerHeight) >> 0, _inner, _outer, _smoothing);
			_shape.draw();
		}
	}
}
