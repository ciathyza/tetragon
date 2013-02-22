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
package view.racing
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	
	
	public class BGScrollLayer extends BitmapData
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _matrix:Matrix;
		
		protected var x:int;
		protected var y:int;
		
		protected var _scrollSpeedH:Number;
		protected var _scrollSpeedV:Number;
		protected var _scale:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function BGScrollLayer(image:IBitmapDrawable, scrollSpeedH:Number = 1.0,
			scrollSpeedV:Number = 1.0, x:int = 0, y:int = 0, scale:Number = 1.0, intervalScale:Number = 0.0,
			rotation:Number = 0.0, intervalRotation:Number = 0.0, repeatFill:Boolean = false,
			transparent:Boolean = true, fillColor:uint = 0x00000000)
		{
			_matrix = new Matrix();
			
			this.scrollSpeedH = scrollSpeedH;
			this.scrollSpeedV = scrollSpeedV;
			this.x = x;
			this.y = y;
			
			_matrix.translate(x, y);
			
			var w:int;
			var h:int;
			if (image is BitmapData)
			{
				w = BitmapData(image).width;
				h = BitmapData(image).height;
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
		
		public function scroll():void
		{
			_matrix.translate(_scrollSpeedH, _scrollSpeedV);
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
	}
}
