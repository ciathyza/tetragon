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
	
		/**	 * RectangleShape represents a rectangular shape that is drawn with	 * the ActionScript Drawing API.	 */	public class RectangleShape extends BaseShape	{		//-----------------------------------------------------------------------------------------		// Constructor		//-----------------------------------------------------------------------------------------				/**		 * Creates a new RectangleShape instance.		 * 		 * @param width The width of the rectangle.		 * @param height The height of the rectangle.		 * @param fillColor The fill color for the rectangle.		 * @param fillAlpha The fill alpha for the rectangle.		 * @param lineThickness Determines the thickness of the border line.		 * @param lineColor The line color for the rectangle.		 * @param lineAlpha The line alpha for the rectangle.		 */		public function RectangleShape(width:Number = 0, height:Number = 0, fillColor:uint = 0xFF00FF,			fillAlpha:Number = 1.0, lineThickness:Number = NaN, lineColor:uint = 0x000000,			lineAlpha:Number = 1.0)		{			super(width, height, fillColor, fillAlpha, lineThickness, lineColor, lineAlpha);		}						//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function drawShape():void
		{
			graphics.clear();
			graphics.lineStyle(_lineThickness, _lineColor, _lineAlpha, true, LineScaleMode.NORMAL,
				null, JointStyle.MITER);
			graphics.beginFill(_fillColor, _fillAlpha);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
	}}