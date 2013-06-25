/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.display.shape
{
	import tetragon.util.reflection.getClassName;

	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	
	/**
	 * RectangleGradientShape is a rectangle shape filled with a color gradient.
	 */
	public class RectangleGradientShape extends Shape implements IShape
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _width:Number;
		/** @private */
		protected var _height:Number;
		/** @private */
		protected var _rotation:Number;
		/** @private */
		protected var _colors:Array;
		/** @private */
		protected var _alphas:Array;
		/** @private */
		protected var _ratios:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new RectangleGradientShape instance.
		 * 
		 * @param width The width of the rectangle.
		 * @param height The height of the rectangle.
		 * @param rotation The rotation of the gradient.
		 * @param colors The color values for the gradient. The default is [0x000000, 0xFFFFFF].
		 * @param alphas The alpha values for the gradient. The default is [1.0, 1.0].
		 * @param ratios The ratio values for the gradient. The default is [0, 255].
		 */
		public function RectangleGradientShape(width:int = 0, height:int = 0, rotation:Number = -90,
			colors:Array = null, alphas:Array = null, ratios:Array = null)
		{
			setProperties(width, height, rotation, colors, alphas, ratios);
			draw();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Allows to set all properties at once without re-drawing.
		 */
		public function setProperties(width:Number = NaN, height:Number = NaN, rotation:Number = NaN,
			colors:Array = null, alphas:Array = null, ratios:Array = null):void
		{
			if (!isNaN(width)) _width = width < 0 ? 0 : width;
			if (!isNaN(height)) _height = height < 0 ? 0 : height;
			if (!isNaN(rotation)) _rotation = rotation;
			if (colors) _colors = colors;
			if (alphas) _alphas = alphas;
			if (ratios) _ratios = ratios;
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
		
		
		override public function get rotation():Number
		{
			return _rotation;
		}
		override public function set rotation(v:Number):void
		{
			if (v == _rotation) return;
			_rotation = v;
			draw();
		}
		
		
		public function get colors():Array
		{
			return _colors;
		}
		public function set colors(v:Array):void
		{
			_colors = v;
			draw();
		}
		
		
		public function get alphas():Array
		{
			return _alphas;
		}
		public function set alphas(v:Array):void
		{
			_alphas = v;
			draw();
		}
		
		
		public function get ratios():Array
		{
			return _ratios;
		}
		public function set ratios(v:Array):void
		{
			_ratios = v;
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
			if (!_colors) _colors = [0x000000, 0xFFFFFF];
			if (!_alphas) _alphas = [1.0, 1.0];
			if (!_ratios) _ratios = [0, 255];
			
			var m:Matrix = new Matrix();
			m.createGradientBox(_width, _height, (_rotation * Math.PI / 180));
			
			graphics.clear();
			graphics.lineStyle();
			graphics.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _ratios, m,
				SpreadMethod.PAD, InterpolationMethod.RGB);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		
		/**
		 * @private
		 */
		private static function cloneShape(s:RectangleGradientShape):RectangleGradientShape
		{
			var clazz:Class = (s as Object)['constructor'];
			return new clazz(s.width, s.height, s.rotation, s.colors, s.alphas, s.ratios);
		}
	}
}
