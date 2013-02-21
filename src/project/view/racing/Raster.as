/**
 *
 *	Raster class
 *	
 *	@author		Didier Brun aka Foxy - www.foxaweb.com
 *	@version		1.4
 * 	@date 		2006-01-06
 * 	@link		http://www.foxaweb.com
 * 
 * 	AUTHORS ******************************************************************************
 * 
 *	authorName : 	Didier Brun - www.foxaweb.com
 * 	contribution : 	the original class
 * 	date :			2007-01-07
 * 
 * 	authorName :	Drew Cummins - http://blog.generalrelativity.org
 * 	contribution :	added bezier curves
 * 	date :			2007-02-13
 * 
 * 	authorName :	Thibault Imbert - http://www.bytearray.org
 * 	contribution :	Raster now extends BitmapData, performance optimizations
 * 	date :			2009-10-16
 * 
 * 	PLEASE CONTRIBUTE ? http://www.bytearray.org/?p=67
 * 
 * 	DESCRIPTION **************************************************************************
 * 
 * 	Raster is an AS3 Bitmap drawing library. It provide some functions to draw directly 
 * 	into BitmapData instance.
 *
 *	LICENSE ******************************************************************************
 * 
 * 	This class is under RECIPROCAL PUBLIC LICENSE.
 * 	http://www.opensource.org/licenses/rpl.php
 * 
 * 	Please, keep this header and the list of all authors
 * 
 */
package view.racing
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;


	public class Raster extends BitmapData
	{
		private var buffer:Array = new Array();
		private var r:Rectangle = new Rectangle();


		public function Raster(width:uint, height:uint, transparent:Boolean = true, color:uint = 0xFFFFFFFF)
		{
			super(width, height, transparent, color);
		}


		// ------------------------------------------------
		//
		// ---o public methods
		//
		// ------------------------------------------------
		/**
		 * Draw a line
		 * 
		 * @param x0		first point x coord
		 * @param y0		first point y coord 
		 * @param x1		second point x coord
		 * @param y1		second point y coord
		 * @param c		color (0xaarrvvbb)
		 */
		public function line(x0:int, y0:int, x1:int, y1:int, color:uint):void
		{
			var dx:int;
			var dy:int;
			var i:int;
			var xinc:int;
			var yinc:int;
			var cumul:int;
			var x:int;
			var y:int;
			x = x0;
			y = y0;
			dx = x1 - x0;
			dy = y1 - y0;
			xinc = ( dx > 0 ) ? 1 : -1;
			yinc = ( dy > 0 ) ? 1 : -1;
			dx = dx < 0 ? -dx : dx;
			dy = dy < 0 ? -dy : dy;
			setPixel32(x, y, color);

			if ( dx > dy )
			{
				cumul = dx >> 1;
				for ( i = 1 ; i <= dx ; ++i )
				{
					x += xinc;
					cumul += dy;
					if (cumul >= dx)
					{
						cumul -= dx;
						y += yinc;
					}
					setPixel32(x, y, color);
				}
			}
			else
			{
				cumul = dy >> 1;
				for ( i = 1 ; i <= dy ; ++i )
				{
					y += yinc;
					cumul += dx;
					if ( cumul >= dy )
					{
						cumul -= dy;
						x += xinc ;
					}
					setPixel32(x, y, color);
				}
			}
		}


		/**
		 * Draw a filled triangle
		 * 
		 * @param x0		first point x coord
		 * @param y0		first point y coord 
		 * @param x1		second point x coord
		 * @param y1		second point y coord
		 * @param x2		third point x coord
		 * @param y2		third point y coord
		 * @param c		color (0xaarrvvbb)
		 */
		public function filledTri(x0:int, y0:int, x1:int, y1:int, x2:int, y2:int, color:uint):void
		{
			buffer.length = 0;
			lineTri(buffer, x0, y0, x1, y1, color);
			lineTri(buffer, x1, y1, x2, y2, color);
			lineTri(buffer, x2, y2, x0, y0, color);
		}


		/**
		 * Draws a Rectangle
		 * 
		 * @param rect 			Rectangle dimensions
		 * @param color			color
		 * */
		public function drawRect(rect:Rectangle, color:uint):void
		{
			line(rect.x, rect.y, rect.x + rect.width, rect.y, color);
			line(rect.x + rect.width, rect.y, rect.x + rect.width, rect.y + rect.height, color);
			line(rect.x + rect.width, rect.y + rect.height, rect.x, rect.y + rect.height, color);
			line(rect.x, rect.y + rect.height, rect.x, rect.y, color);
		}



		/**
		 * Check a triangle line
		 */
		private function checkLine(o:Array, x:int, y:int, c:int, r:Rectangle):void
		{
			if (o[y])
			{
				if (o[y] > x)
				{
					r.width = o[y] - x;
					r.x = x;
					r.y = y;
					fillRect(r, c);
				}
				else
				{
					r.width = x - o[y];
					r.x = o[y];
					r.y = y;
					fillRect(r, c);
				}
			}
			else
			{
				o[y] = x;
			}
		}


		/**
		 * Special line for filled triangle
		 */
		private function lineTri(o:Array, x0:int, y0:int, x1:int, y1:int, c:Number):void
		{
			var steep:Boolean = (y1 - y0) * (y1 - y0) > (x1 - x0) * (x1 - x0);
			var swap:int;

			if (steep)
			{
				swap = x0;
				x0 = y0;
				y0 = swap;
				swap = x1;
				x1 = y1;
				y1 = swap;
			}

			if (x0 > x1)
			{
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
			}

			var deltax:int = x1 - x0;
			var deltay:int = (y1 - y0) < 0 ? -(y1 - y0) : (y1 - y0);
			var error:int = 0;
			var y:int = y0;
			var ystep:int = y0 < y1 ? 1 : -1;
			var x:int = x0;
			var xend:int = x1 - (deltax >> 1);
			var fx:int = x1;
			var fy:int = y1;
			var px:int = 0;
			r.x = 0;
			r.y = 0;
			r.width = 0;
			r.height = 1;

			while (x++ <= xend)
			{
				if (steep)
				{
					checkLine(o, y, x, c, r);
					if (fx != x1 && fx != xend)
						checkLine(o, fy, fx + 1, c, r);
				}

				error += deltay;
				if ((error << 1) >= deltax)
				{
					if (!steep)
					{
						checkLine(o, x - px + 1, y, c, r);
						if (fx != xend)
							checkLine(o, fx + 1, fy, c, r);
					}
					px = 0;
					y += ystep;
					fy -= ystep;
					error -= deltax;
				}
				px++;
				fx--;
			}

			if (!steep)
				checkLine(o, x - px + 1, y, c, r);
		}
	}
}
