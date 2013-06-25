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
package tetragon.util.image
{
	import flash.display.BitmapData;


	/**
	 * scale3x Pixel Art scaling.
	 * 
	 * @param source Source bitmap to which scale3x should be applied to.
	 * @return BitmapData with scale3x applied.
	 */
	public function scale3x(source:BitmapData):BitmapData
	{
		if (!source) return null;
		
		var dest:BitmapData = new BitmapData(source.width * 3, source.height * 3, true);
		var width:int = source.width;
		var height:int = source.height;
		
		source.lock();
		dest.lock();
		
		var e0:uint;
		var e1:uint;
		var e2:uint;
		var e3:uint;
		var e4:uint;
		var e5:uint;
		var e6:uint;
		var e7:uint;
		var e8:uint;
		var a:uint;
		var b:uint;
		var c:uint;
		var d:uint;
		var f:uint;
		var g:uint;
		var h:uint;
		var i:uint;
		var x3:int;
		var y3:int;
		
		for (var x:int = 0; x < width; x++)
		{
			for (var y:int = 0; y < height; y++)
			{
				var e:uint = source.getPixel32(x, y);
				if (x == 0 || y == 0 || x == width - 1 || y == height - 1)
				{
					e0 = e1 = e2 = e3 = e4 = e5 = e6 = e7 = e8 = e;
				}
				else
				{
					a = source.getPixel32(x - 1, y - 1);
					b = source.getPixel32(x, y - 1);
					c = source.getPixel32(x, y + 1);
					d = source.getPixel32(x - 1, y);
					f = source.getPixel32(x + 1, y);
					g = source.getPixel32(x - 1, y + 1);
					h = source.getPixel32(x, y + 1);
					i = source.getPixel32(x + 1, y + 1);
					
					if (b != h && d != f)
					{
						e0 = (d == b) ? d : e;
						e1 = (( d == b && e != c) || (b == f && e != a)) ? b : e;
						e2 = (b == f) ? f : e;
						e3 = ((d == b && e != g) || (d == h && e != a)) ? d : e;
						e4 = e;
						e5 = ((b == f && e != i) || (h == f && e != c)) ? f : e;
						e6 = (d == h) ? d : e;
						e7 = ((d == h && e != i) || (h == f && e != g)) ? h : e;
						e8 = (h == f) ? f : e;
					}
					else
					{
						e0 = e1 = e2 = e3 = e4 = e5 = e6 = e7 = e8 = e;
					}
				}
				
				x3 = x * 3;
				y3 = y * 3;
				
				dest.setPixel32(x3, y3, e0);
				dest.setPixel32(x3 + 1, y3, e1);
				dest.setPixel32(x3 + 2, y3, e2);
				
				dest.setPixel32(x3, y3 + 1, e3);
				dest.setPixel32(x3 + 1, y3 + 1, e4);
				dest.setPixel32(x3 + 2, y3 + 1, e5);
				
				dest.setPixel32(x3, y3 + 2, e6);
				dest.setPixel32(x3 + 1, y3 + 2, e7);
				dest.setPixel32(x3 + 2, y3 + 2, e8);
			}
		}
		
		source.unlock();
		dest.unlock();
		
		return dest;
	}
}
