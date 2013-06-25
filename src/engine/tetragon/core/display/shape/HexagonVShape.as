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
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;

	
	/**
	 * Creates a regular vertical hexagonal shape. You specify the height of the hexagon
	 * and the width of it is calculated automatically from the six same-length sides.
	 * 
	 * <p>Additionally you can use the calculateWidth method to receive the width of the
	 * hexagon by specifying it's height before the hexagon is actually created.</p>
	 */
	public class HexagonVShape extends BaseShape
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _drawCommands:Vector.<int>;
		/** @private */
		protected var _drawData:Vector.<Number>;
		/** @private */
		private static var _angle:Number = 30 * Math.PI / 180;
		/** @private */
		protected var _oldHeight:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new HexagonVShape instance.
		 * 
		 * @param height The height of the hexagon.
		 * @param fillColor The fill color for the hexagon.
		 * @param fillAlpha The fill alpha for the hexagon.
		 * @param lineThickness Determines the thickness of the border line.
		 * @param lineColor The line color for the hexagon.
		 * @param lineAlpha The line alpha for the hexagon.
		 */
		public function HexagonVShape(height:int = 0, fillColor:uint = 0xFF00FF,
			fillAlpha:Number = 1.0, lineThickness:Number = NaN, lineColor:uint = 0x000000,
			lineAlpha:Number = 1.0)
		{
			/* We only need to create the draw commands vector once. */
			if (!_drawCommands)
			{
				_drawCommands = new Vector.<int>(7, true);
				_drawCommands[0] = 1;
				_drawCommands[1] = 2;
				_drawCommands[2] = 2;
				_drawCommands[3] = 2;
				_drawCommands[4] = 2;
				_drawCommands[5] = 2;
				_drawCommands[6] = 2;
			}
			
			super(0, height, fillColor, fillAlpha, lineThickness, lineColor, lineAlpha);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void
		{
			if (_height > 0) drawShape();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function clone():*
		{
			return cloneShape(this);
		}
		
		
		/**
		 * Calculates the width of a HexagonVShape that has the specified height.
		 * 
		 * @param height The height of the HexagonVShape.
		 * @return The width that a HexagonVShape with the specified height would have.
		 */
		public static function calculateWidth(height:Number):Number
		{
			/* Calculate the sides of the triangle that is one edge of the 'hexagon-square'.
			 * o = opposite leg, a = adjacent leg, s = hypotenuse (= hexagon side length). */
			var o:Number = height / 2;
			var a:Number = Math.round(o * Math.tan(_angle));
			var s:Number = Math.round(Math.sqrt(Math.pow(o, 2) + Math.pow(a, 2)));
			var w:Number = (a * 2) + s;
			return w;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Read Only! Setting width on the HexagonVShape has no effect as the width is
		 * automatically calculated.
		 */
		override public function set width(v:Number):void
		{
		}
		
		
		override public function set height(v:Number):void
		{
			if (v == _height) return;
			_height = v < 0 ? 0 : v;
			draw();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function drawShape():void
		{
			/* Only renew draw commands if the height has changed! */
			if (_height != _oldHeight)
			{
				_oldHeight = _height;
				_width = calculateWidth(_height);
				_drawData = generateDrawData(_height);
			}
			
			graphics.clear();
			graphics.lineStyle(_lineThickness, _lineColor, _lineAlpha, true, LineScaleMode.NORMAL,
				null, JointStyle.MITER);
			graphics.beginFill(_fillColor, _fillAlpha);
			graphics.drawPath(_drawCommands, _drawData);
			graphics.endFill();
		}
		
		
		/**
		 * @private
		 */
		protected static function generateDrawData(height:Number):Vector.<Number>
		{
			/* Calculate the sides of the triangle that is one edge of the 'hexagon-square'.
			 * o = opposite leg, a = adjacent leg, s = hypotenuse (= hexagon side length). */
			var o:Number = height / 2;
			var a:int = Math.round(o * Math.tan(_angle));
			var s:int = Math.round(Math.sqrt(Math.pow(o, 2) + Math.pow(a, 2)));
			var w:int = (a * 2) + s;
			
			/* Create the vector with data for the drawPath operation */
			var d:Vector.<Number> = new Vector.<Number>(14, true);
			d[0] = a;			// Start X
			d[1] = 0;			// Start Y
			d[2] = a + s;		// 1. vertex X
			d[3] = 0;			// 1. vertex Y
			d[4] = w;			// 2. vertex X
			d[5] = o;			// 2. vertex Y
			d[6] = a + s;		// 3. vertex X
			d[7] = height;		// 3. vertex Y
			d[8] = a;			// 4. vertex X
			d[9] = height;		// 4. vertex Y
			d[10] = 0;			// 5. vertex X
			d[11] = o;			// 5. vertex Y
			d[12] = a;			// End X
			d[13] = 0;			// End Y
			
			return d;
		}
		
		
		/**
		 * @private
		 */
		private static function cloneShape(s:BaseShape):BaseShape
		{
			var clazz:Class = (s as Object)['constructor'];
			return new clazz(s.height, s.fillColor, s.fillAlpha, s.lineThickness, s.lineColor,
				s.lineAlpha);
		}
	}
}
