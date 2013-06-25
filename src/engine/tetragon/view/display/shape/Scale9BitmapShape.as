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
package tetragon.view.display.shape
{
	import tetragon.util.reflection.getClassName;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * A scale-9 Shape that uses a bitmap fill.
	 */
	public class Scale9BitmapShape extends Shape implements IShape
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _bitmapData:BitmapData;
		/** @private */
		protected var _width:Number = 0;
		/** @private */
		protected var _height:Number = 0;
		/** @private */
		protected var _inner:Rectangle;
		/** @private */
		protected var _outer:Rectangle;
		/** @private */
		protected var _smoothing:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param bitmapData BitmapData source.
		 * @param width Draw width.
		 * @param height Draw height.
		 * @param inner Inner rectangle (relative to 0,0).
		 * @param outer Outer rectangle (relative to 0,0).
		 * @param smoothing If <code>false</code>, upscaled bitmap images are rendered by
		 *            using a nearest-neighbor algorithm and look pixelated. If
		 *            <code>true</code>, upscaled bitmap images are rendered by using a
		 *            bilinear algorithm. Rendering by using the nearest neighbor algorithm is
		 *            usually faster.
		 */
		public function Scale9BitmapShape(bitmapData:BitmapData = null, width:Number = 0,
			height:Number = 0, inner:Rectangle = null, outer:Rectangle = null,
			smoothing:Boolean = false)
		{
			setProperties(bitmapData, width, height, inner, outer, smoothing);
			draw();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Allows to set all properties at once without updating.
		 * 
		 * @param bitmapData
		 * @param width
		 * @param height
		 * @param inner
		 * @param outer
		 * @param smoothing
		 */
		public function setProperties(bitmapData:BitmapData = null, width:Number = NaN,
			height:Number = NaN, inner:Rectangle = null, outer:Rectangle = null,
			smoothing:Boolean = false):void
		{
			if (bitmapData) _bitmapData = bitmapData;
			if (!isNaN(width)) _width = width < 0 ? 0 : width;
			if (!isNaN(height)) _height = height < 0 ? 0 : height;
			if (inner) _inner = inner;
			if (outer) _outer = outer;
			_smoothing = smoothing;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function draw():void
		{
			if (_bitmapData && _width > 0 && _height > 0) drawShape();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function clone():*
		{
			return cloneShape(this);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(v:Number):void
		{
			if (v == _width) return;
			_width = v < 0 ? 0 : v;
			draw();
		}
		
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(v:Number):void
		{
			if (v == _height) return;
			_height = v < 0 ? 0 : v;
			draw();
		}
		
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		public function set bitmapData(v:BitmapData):void
		{
			if (v == _bitmapData) return;
			_bitmapData = v;
			draw();
		}
		
		
		public function get inner():Rectangle
		{
			return _inner;
		}
		public function set inner(v:Rectangle):void
		{
			if (v == _inner) return;
			_inner = v;
			draw();
		}
		
		
		public function get outer():Rectangle
		{
			return _outer;
		}
		public function set outer(v:Rectangle):void
		{
			if (v == _outer) return;
			_outer = v;
			draw();
		}
		
		
		public function get smoothing():Boolean
		{
			return _smoothing;
		}
		public function set smoothing(v:Boolean):void
		{
			if (v == _smoothing) return;
			_smoothing = v;
			draw();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function drawShape():void
		{
			if (!_inner)
			{
				_inner = new Rectangle(10, 10, _bitmapData.width - 10, _bitmapData.height - 10);
			}
			
			var x:int, y:int;
			var ox:Number = 0, oy:Number;
			var dx:Number = 0, dy:Number;
			var w:Number, h:Number, dw:Number, dh:Number;
			var sw:int = _bitmapData.width;
			var sh:int = _bitmapData.height;
			
			var widths:Array = [_inner.left + 1, _inner.width - 2, sw - _inner.right + 1];
			var heights:Array = [_inner.top + 1, _inner.height - 2, sh - _inner.bottom + 1];
			var rx:Number = _width - widths[0] - widths[2];
			var ry:Number = _height - heights[0] - heights[2];
			var ol:Number = _outer ? -_outer.left : 0;
			var ot:Number = _outer ? -_outer.top : 0;
			
			var m:Matrix = new Matrix();
			
			for (x; x < 3 ; x++)
			{
				w = widths[x];
				dw = x == 1 ? rx : w;
				dy = oy = 0;
				m.a = dw / w;

				for (y = 0; y < 3; y++)
				{
					h = heights[y];
					dh = y == 1 ? ry : h;

					if (dw > 0 && dh > 0)
					{
						m.d = dh / h;
						m.tx = -ox * m.a + dx;
						m.ty = -oy * m.d + dy;
						m.translate(ol, ot);
						graphics.beginBitmapFill(_bitmapData, m, false, _smoothing);
						graphics.drawRect(dx + ol, dy + ot, dw, dh);
					}
					
					oy += h;
					dy += dh;
				}
				
				ox += w;
				dx += dw;
			}
			
			graphics.endFill();
		}
		
		
		/**
		 * @private
		 */
		private static function cloneShape(s:Scale9BitmapShape):Scale9BitmapShape
		{
			var clazz:Class = (s as Object)['constructor'];
			return new clazz(s.bitmapData, s.width, s.height, s.inner, s.outer, s.smoothing);
		}
	}
}
