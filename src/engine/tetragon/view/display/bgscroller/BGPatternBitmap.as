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
	import flash.display.BitmapData;
	
	
	public class BGPatternBitmap extends BitmapData
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _pattern:Array =
		[
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
			[0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],		
		];
		
		protected var _colors:Array = [0x000000, 0xFFFFFF];
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param pattern
		 * @param colors
		 * @param transparent
		 * @param fillColor
		 */
		public function BGPatternBitmap(pattern:Array = null, colors:Array = null,
			transparent:Boolean = false, fillColor:uint = 0x000000)
		{
			if (pattern && pattern[0] is Array) _pattern = pattern;
			if (colors) _colors = colors;
			
			var h:uint = _pattern.length;
			var w:uint = (_pattern[0] as Array).length;
			
			super(w, h, transparent, fillColor);
			
			for (var y:uint = 0; y < h; y++)
			{
				for (var x:uint = 0; x < w; x++)
				{
					setPixel(x, y, uint(_colors[_pattern[y][x]]));
				}
			}
		}
	}
}
