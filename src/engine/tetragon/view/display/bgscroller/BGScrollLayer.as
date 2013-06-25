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
package tetragon.view.display.bgscroller
{
	import tetragon.util.geom.degToRad;
	import tetragon.util.geom.radToDeg;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	
	
	public class BGScrollLayer
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public var bitmapData:BitmapData;
		public var matrix:Matrix;
		
		public var repeatFill:Boolean;
		public var x:int;
		public var y:int;
		
		protected var _scrollSpeedH:Number;
		protected var _scrollSpeedV:Number;
		protected var _rotation:Number;
		protected var _intervalRotation:Number;
		protected var _intervalScale:Number;
		protected var _intervalScaleValue:Number;
		protected var _scale:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param image
		 * @param scrollSpeedH
		 * @param scrollSpeedV
		 * @param x
		 * @param y
		 * @param rotation
		 * @param intervalRotation
		 * @param scale
		 * @param intervalScale
		 * @param repeatFill
		 * @param transparent
		 * @param fillColor
		 */
		public function BGScrollLayer(image:IBitmapDrawable, scrollSpeedH:Number = 1.0,
			scrollSpeedV:Number = 1.0, x:int = 0, y:int = 0, scale:Number = 1.0, intervalScale:Number = 0.0,
			rotation:Number = 0.0, intervalRotation:Number = 0.0, repeatFill:Boolean = false,
			transparent:Boolean = true, fillColor:uint = 0x00000000)
		{
			matrix = new Matrix();
			
			this.scrollSpeedH = scrollSpeedH;
			this.scrollSpeedV = scrollSpeedV;
			this.x = x;
			this.y = y;
			this.scale = scale;
			this.intervalScale = intervalScale;
			this.rotation = rotation;
			this.intervalRotation = intervalRotation;
			this.repeatFill = repeatFill;
			
			matrix.translate(x, y);
			
			var w:int;
			var h:int;
			if (image is BitmapData)
			{
				w = BitmapData(image).width;
				h = BitmapData(image).height;
				if (image is BGPatternBitmap) this.repeatFill = true;
			}
			else
			{
				w = DisplayObject(image).width;
				h = DisplayObject(image).height;
			}
			
			bitmapData = new BitmapData(w, h, transparent, fillColor);
			bitmapData.draw(image);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function tick():void
		{
			if (_intervalScale != 0)
			{
				matrix.a = matrix.d = _intervalScaleValue;
				_intervalScaleValue += _intervalScale;
			}
			
			matrix.translate(_scrollSpeedH, _scrollSpeedV);
			if (_intervalRotation != 0) matrix.rotate(_intervalRotation);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get scrollSpeedH():Number
		{
			return _scrollSpeedH;
		}
		public function set scrollSpeedH(v:Number):void
		{
			_scrollSpeedH = v;
		}
		
		
		public function get scrollSpeedV():Number
		{
			return _scrollSpeedV;
		}
		public function set scrollSpeedV(v:Number):void
		{
			_scrollSpeedV = v;
		}
		
		
		public function get rotation():Number
		{
			return radToDeg(_rotation);
		}
		public function set rotation(v:Number):void
		{
			_rotation = degToRad(v);
			matrix.rotate(_rotation);
		}
		
		
		public function get intervalRotation():Number
		{
			return radToDeg(_intervalRotation);
		}
		public function set intervalRotation(v:Number):void
		{
			_intervalRotation = degToRad(v);
		}
		
		
		public function get scale():Number
		{
			return _scale;
		}
		public function set scale(v:Number):void
		{
			_scale = matrix.a = matrix.d = v;
		}
		
		
		public function get intervalScale():Number
		{
			return _intervalScale;
		}
		public function set intervalScale(v:Number):void
		{
			_intervalScale = _intervalScaleValue = v;
		}
	}
}
