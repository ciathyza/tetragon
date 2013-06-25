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
package tetragon.core.display.shape
{
	import tetragon.util.reflection.getClassName;

	import flash.display.Shape;
	
	
	/**
	 * Abstract base class for shapes.
	 */
	public class BaseShape extends Shape implements IShape
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _width:Number;
		/** @private */
		protected var _height:Number;
		/** @private */
		protected var _fillColor:uint;
		/** @private */
		protected var _fillAlpha:Number;
		/** @private */
		protected var _lineThickness:Number;
		/** @private */
		protected var _lineColor:uint;
		/** @private */
		protected var _lineAlpha:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function BaseShape(width:Number, height:Number, fillColor:uint, fillAlpha:Number,
			lineThickness:Number, lineColor:uint, lineAlpha:Number)
		{
			setProperties(width, height, fillColor, fillAlpha, lineThickness, lineColor, lineAlpha);
			draw();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Allows to set all properties at once without re-drawing.
		 * 
		 * @param width
		 * @param height
		 * @param fillColor
		 * @param fillAlpha
		 * @param lineThickness
		 * @param lineColor
		 * @param lineAlpha
		 */
		public function setProperties(width:Number = NaN, height:Number = NaN,
			fillColor:Number = NaN, fillAlpha:Number = NaN, lineThickness:Number = NaN,
			lineColor:Number = NaN, lineAlpha:Number = NaN):void
		{
			if (!isNaN(width)) _width = width < 0 ? 0 : width;
			if (!isNaN(height)) _height = height < 0 ? 0 : height;
			if (!isNaN(fillColor)) _fillColor = fillColor;
			if (!isNaN(fillAlpha)) _fillAlpha = fillAlpha < 0 ? 0 : fillAlpha;
			if (!isNaN(lineThickness)) _lineThickness = lineThickness < 0 ? 0 : lineThickness;
			if (!isNaN(lineColor)) _lineColor = lineColor;
			if (!isNaN(lineAlpha)) _lineAlpha = lineAlpha < 0 ? 0 : lineAlpha;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function draw():void
		{
			if (_width > 0 && _height > 0) drawShape();
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
		
		
		public function get fillColor():uint
		{
			return _fillColor;
		}
		public function set fillColor(v:uint):void
		{
			if (v == _fillColor) return;
			_fillColor = v;
			draw();
		}
		
		
		public function get fillAlpha():Number
		{
			return _fillAlpha;
		}
		public function set fillAlpha(v:Number):void
		{
			if (v == _fillAlpha) return;
			_fillAlpha = v < 0 ? 0 : v;
			draw();
		}
		
		
		public function get lineThickness():Number
		{
			return _lineThickness;
		}
		public function set lineThickness(v:Number):void
		{
			if (v == _lineThickness) return;
			_lineThickness = v < 0 ? 0 : v;
			draw();
		}
		
		
		public function get lineColor():uint
		{
			return _lineColor;
		}
		public function set lineColor(v:uint):void
		{
			if (v == _lineColor) return;
			_lineColor = v;
			draw();
		}
		
		
		public function get lineAlpha():Number
		{
			return _lineAlpha;
		}
		public function set lineAlpha(v:Number):void
		{
			if (v == _lineAlpha) return;
			_lineAlpha = v < 0 ? 0 : v;
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
			/* Abstract method! */
		}
		
		
		/**
		 * @private
		 */
		private static function cloneShape(s:BaseShape):BaseShape
		{
			var clazz:Class = (s as Object)['constructor'];
			return new clazz(s.width, s.height, s.fillColor, s.fillAlpha,
				s.lineThickness, s.lineColor, s.lineAlpha);
		}
	}
}
