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
package tetragon.util.image
{
	import flash.display.BitmapData;
	
	
	/**
	 * scale2x Pixel Art scaling.
	 * 
	 * @param source Source bitmap to which scale2x should be applied to.
	 * @return BitmapData with scale2x applied.
	 */
	public function scale2x(source:BitmapData):BitmapData
	{
		if (!source) return null;
		
		var dest:BitmapData = new BitmapData(source.width * 2, source.height * 2, true);
		var width:int = source.width;
		var height:int = source.height;
		
		source.lock();
		dest.lock();
		
		var e0:uint;
		var e1:uint;
		var e2:uint;
		var e3:uint;
		var b:uint;
		var d:uint;
		var f:uint;
		var h:uint;
		var x2:int;
		var y2:int;
		
		for (var x:int = 0; x < width; x++)
		{
			for (var y:int = 0; y < height; y++)
			{
				var e:uint = source.getPixel32(x, y);
				if (x == 0 || y == 0 || x == width - 1 || y == height - 1)
				{
					e0 = e1 = e2 = e3 = e;
				}
				else
				{
					b = source.getPixel32(x, y - 1);
					d = source.getPixel32(x - 1, y);
					f = source.getPixel32(x + 1, y);
					h = source.getPixel32(x, y + 1);
					
					if (b != h && d != f)
					{
						e0 = (d == b) ? d : e;
						e1 = (b == f) ? f : e;
						e2 = (d == h) ? d : e;
						e3 = (h == f) ? f : e;
					}
					else
					{
						e0 = e1 = e2 = e3 = e;
					}
				}
				
				x2 = x * 2;
				y2 = y * 2;
				
				dest.setPixel32(x2, y2, e0);
				dest.setPixel32(x2 + 1, y2, e1);
				dest.setPixel32(x2, y2 + 1, e2);
				dest.setPixel32(x2 + 1, y2 + 1, e3);
			}
		}
		
		source.lock();
		dest.unlock();
		
		return dest;
	}
}
