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
		 * Draw a triangle
		 * 
		 * @param x0		first point x coord
		 * @param y0		first point y coord 
		 * @param x1		second point x coord
		 * @param y1		second point y coord
		 * @param x2		third point x coord
		 * @param y2		third point y coord
		 * @param c		color (0xaarrvvbb)
		 */
		public function triangle(x0:int, y0:int, x1:int, y1:int, x2:int, y2:int, color:uint):void
		{
			line(x0, y0, x1, y1, color);
			line(x1, y1, x2, y2, color);
			line(x2, y2, x0, y0, color);
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
		 * Draw a circle
		 * 
		 * @param px		first point x coord
		 * @param py		first point y coord 
		 * @param r		radius
		 * @param c		color (0xaarrvvbb)
		 */
		public function circle(px:int, py:int, r:int, color:uint):void
		{
			var x:int;
			var y:int;
			var d:int;
			x = 0;
			y = r;
			d = 1 - r;
			setPixel32(px + x, py + y, color);
			setPixel32(px + x, py - y, color);
			setPixel32(px - y, py + x, color);
			setPixel32(px + y, py + x, color);

			while ( y > x )
			{
				if ( d < 0 )
				{
					d += (x + 3) << 1;
				}
				else
				{
					d += ((x - y) << 1) + 5;
					y--;
				}
				x++;
				setPixel32(px + x, py + y, color);
				setPixel32(px - x, py + y, color);
				setPixel32(px + x, py - y, color);
				setPixel32(px - x, py - y, color);
				setPixel32(px - y, py + x, color);
				setPixel32(px - y, py - x, color);
				setPixel32(px + y, py - x, color);
				setPixel32(px + y, py + x, color);
			}
		}


		/**
		 * Draw an anti-aliased circle
		 * 
		 * @param px		first point x coord
		 * @param py		first point y coord 
		 * @param r		radius
		 * @param c		color (0xaarrvvbb)
		 */
		public function aaCircle(px:int, py:int, r:int, color:uint):void
		{
			var vx:int;
			var vy:int;
			var d:int;
			vx = r;
			vy = 0;

			var t:Number = 0;
			var dry:Number;
			var buff:int;

			setPixel(px + vx, py + vy, color);
			setPixel(px - vx, py + vy, color);
			setPixel(px + vy, py + vx, color);
			setPixel(px + vy, py - vx, color);

			while ( vx > vy + 1 )
			{
				vy++;
				buff = Math.sqrt(r * r - vy * vy) + 1;
				dry = buff - Math.sqrt(r * r - vy * vy);
				if (dry < t) vx--;

				drawAlphaPixel(px + vx, py + vy, 1 - dry, color)
				drawAlphaPixel(px + vx - 1, py + vy, dry, color)
				drawAlphaPixel(px - vx, py + vy, 1 - dry, color)
				drawAlphaPixel(px - vx + 1, py + vy, dry, color)
				drawAlphaPixel(px + vx, py - vy, 1 - dry, color)
				drawAlphaPixel(px + vx - 1, py - vy, dry, color)
				drawAlphaPixel(px - vx, py - vy, 1 - dry, color)
				drawAlphaPixel(px - vx + 1, py - vy, dry, color)

				drawAlphaPixel(px + vy, py + vx, 1 - dry, color)
				drawAlphaPixel(px + vy, py + vx - 1, dry, color)
				drawAlphaPixel(px - vy, py + vx, 1 - dry, color)
				drawAlphaPixel(px - vy, py + vx - 1, dry, color)

				drawAlphaPixel(px + vy, py - vx, 1 - dry, color)
				drawAlphaPixel(px + vy, py - vx + 1, dry, color)
				drawAlphaPixel(px - vy, py - vx, 1 - dry, color)
				drawAlphaPixel(px - vy, py - vx + 1, dry, color)

				t = dry;
			}
		}


		/**
		 * Draw an anti-aliased line
		 * 
		 * @param x0		first point x coord
		 * @param y0		first point y coord 
		 * @param x1		second point x coord
		 * @param y1		second point y coord
		 * @param c		color (0xaarrvvbb)
		 */
		public function aaLine(x1:int, y1:int, x2:int, y2:int, color:uint):void
		{
			var steep:Boolean = (y2 - y1) < 0 ? -(y2 - y1) : (y2 - y1) > (x2 - x1) < 0 ? -(x2 - x1) : (x2 - x1);
			var swap:int;

			if (steep)
			{
				swap = x1;
				x1 = y1;
				y1 = swap;
				swap = x2;
				x2 = y2;
				y2 = swap;
			}

			if (x1 > x2)
			{
				swap = x1;
				x1 = x2;
				x2 = swap;
				swap = y1;
				y1 = y2;
				y2 = swap;
			}

			var dx:int = x2 - x1;
			var dy:int = y2 - y1

			var gradient:Number = dy / dx;

			var xend:int = x1;
			var yend:Number = y1 + gradient * (xend - x1);
			var xgap:Number = 1 - ((x1 + 0.5) % 1);
			var xpx1:int = xend;
			var ypx1:int = yend;
			var alpha:Number;

			alpha = ((yend) % 1) * xgap;

			var intery:Number = yend + gradient;

			xend = x2;
			yend = y2 + gradient * (xend - x2)
			xgap = (x2 + 0.5) % 1;

			var xpx2:int = xend;
			var ypx2:int = yend;

			alpha = (1 - ((yend) % 1)) * xgap;

			if (steep)
				drawAlphaPixel(ypx2, xpx2, alpha, color);
			else drawAlphaPixel(xpx2, ypx2, alpha, color);

			alpha = ((yend) % 1) * xgap;

			if (steep)
				drawAlphaPixel(ypx2 + 1, xpx2, alpha, color);
			else drawAlphaPixel(xpx2, ypx2 + 1, alpha, color);

			var x:int = xpx1;

			while (x++ < xpx2)
			{
				alpha = 1 - ((intery) % 1);

				if (steep)
					drawAlphaPixel(intery, x, alpha, color);
				else drawAlphaPixel(x, intery, alpha, color);

				alpha = intery % 1;

				if (steep)
					drawAlphaPixel(intery + 1, x, alpha, color);
				else drawAlphaPixel(x, intery + 1, alpha, color);

				intery = intery + gradient
			}
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
		 * Draws a rounded Rectangle
		 * 
		 * @param rect 			Rectangle dimensions
		 * @param ellipseWidth  Rectangle corners width
		 * @param color			color
		 * */
		public function drawRoundRect(rect:Rectangle, ellipseWidth:int, color:uint):void
		{
			var arc:Number = 4 / 3 * (Math.sqrt(2) - 1);
			var xc:Number = rect.x + rect.width - ellipseWidth;
			var yc:Number = rect.y + ellipseWidth;
			line(rect.x + ellipseWidth, rect.y, xc, rect.y, color);
			cubicBezier(xc, rect.y, xc + ellipseWidth * arc, yc - ellipseWidth, xc + ellipseWidth, yc - ellipseWidth * arc, xc + ellipseWidth, yc, color);
			xc = rect.x + rect.width - ellipseWidth;
			yc = rect.y + rect.height - ellipseWidth;
			line(xc + ellipseWidth, rect.y + ellipseWidth, rect.x + rect.width, yc, color);
			cubicBezier(rect.x + rect.width, yc, xc + ellipseWidth, yc + ellipseWidth * arc, xc + ellipseWidth * arc, yc + ellipseWidth, xc, yc + ellipseWidth, color);
			xc = rect.x + ellipseWidth;
			yc = rect.y + rect.height - ellipseWidth;
			line(rect.x + rect.width - ellipseWidth, rect.y + rect.height, xc, yc + ellipseWidth, color);
			cubicBezier(xc, yc + ellipseWidth, xc - ellipseWidth * arc, yc + ellipseWidth, xc - ellipseWidth, yc + ellipseWidth * arc, xc - ellipseWidth, yc, color);
			xc = rect.x + ellipseWidth;
			yc = rect.y + ellipseWidth;
			line(xc - ellipseWidth, rect.y + rect.height - ellipseWidth, rect.x, yc, color);
			cubicBezier(rect.x, yc, xc - ellipseWidth, yc - ellipseWidth * arc, xc - ellipseWidth * arc, yc - ellipseWidth, xc, yc - ellipseWidth, color);
		}


		/**
		 * Draws a Quadratic Bezier Curve (equivalent to a DisplayObject's graphics#curveTo)
		 * 
		 * @param x0 			x position of first anchor
		 * @param y0 			y position of first anchor
		 * @param x1 			x position of control point
		 * @param y1 			y position of control point
		 * @param x2 			x position of second anchor
		 * @param y2 			y position of second anchor
		 * @param c 			color
		 * @param resolution 	[optional] determines the accuracy of the curve's length (higher number = greater accuracy = longer process)
		 * */
		public function quadBezier(anchorX0:int, anchorY0:int, controlX:int, controlY:int, anchorX1:int, anchorY1:int, c:Number, resolution:int = 3):void
		{
			var ox:Number = anchorX0;
			var oy:Number = anchorY0;
			var px:int;
			var py:int;
			var dist:Number = 0;

			var inverse:Number = 1 / resolution;
			var interval:Number;
			var intervalSq:Number;
			var diff:Number;
			var diffSq:Number;

			var i:int = 0;

			while ( ++i <= resolution )
			{
				interval = inverse * i;
				intervalSq = interval * interval;
				diff = 1 - interval;
				diffSq = diff * diff;

				px = diffSq * anchorX0 + 2 * interval * diff * controlX + intervalSq * anchorX1;
				py = diffSq * anchorY0 + 2 * interval * diff * controlY + intervalSq * anchorY1;

				dist += Math.sqrt(( px - ox ) * ( px - ox ) + ( py - oy ) * ( py - oy ));

				ox = px;
				oy = py;
			}

			// approximates the length of the curve
			var curveLength:int = dist;
			inverse = 1 / curveLength;

			var lastx:int = anchorX0;
			var lasty:int = anchorY0;

			i = -1;
			while ( ++i <= curveLength )
			{
				interval = inverse * i;
				intervalSq = interval * interval;
				diff = 1 - interval;
				diffSq = diff * diff;

				px = diffSq * anchorX0 + 2 * interval * diff * controlX + intervalSq * anchorX1;
				py = diffSq * anchorY0 + 2 * interval * diff * controlY + intervalSq * anchorY1;

				line(lastx, lasty, px, py, c);
				lastx = px;
				lasty = py;
			}
		}


		/**
		 * Draws a Cubic Bezier Curve
		 * 
		 * TODO: Determine whether x/y params would be better named as anchor/control
		 * 
		 * @param x0 			x position of first anchor
		 * @param y0 			y position of first anchor
		 * @param x1 			x position of control point
		 * @param y1 			y position of control point
		 * @param x2 			x position of second control point
		 * @param y2 			y position of second control point
		 * @param x3 			x position of second anchor
		 * @param y3 			y position of second anchor
		 * @param c 			color
		 * @param resolution 	[optional] determines the accuracy of the curve's length (higher number = greater accuracy = longer process)
		 * */
		public function cubicBezier(x0:int, y0:int, x1:int, y1:int, x2:int, y2:int, x3:int, y3:int, c:Number, resolution:int = 5):void
		{
			var ox:Number = x0;
			var oy:Number = y0;
			var px:int;
			var py:int;
			var dist:Number = 0;

			var inverse:Number = 1 / resolution;
			var interval:Number;
			var intervalSq:Number;
			var intervalCu:Number;
			var diff:Number;
			var diffSq:Number;
			var diffCu:Number;
			var i:int = 0;

			while ( ++i <= resolution )
			{
				interval = inverse * i;
				intervalSq = interval * interval;
				intervalCu = intervalSq * interval;
				diff = 1 - interval;
				diffSq = diff * diff;
				diffCu = diffSq * diff;

				px = diffCu * x0 + 3 * interval * diffSq * x1 + 3 * x2 * intervalSq * diff + x3 * intervalCu;
				py = diffCu * y0 + 3 * interval * diffSq * y1 + 3 * y2 * intervalSq * diff + y3 * intervalCu;

				dist += Math.sqrt(( px - ox ) * ( px - ox ) + ( py - oy ) * ( py - oy ));

				ox = px;
				oy = py;
			}

			// approximates the length of the curve
			var curveLength:int = dist;
			inverse = 1 / curveLength;

			var lastx:int = x0;
			var lasty:int = y0;

			i = -1;

			while ( ++i <= curveLength )
			{
				interval = inverse * i;
				intervalSq = interval * interval;
				intervalCu = intervalSq * interval;
				diff = 1 - interval;
				diffSq = diff * diff;
				diffCu = diffSq * diff;

				px = diffCu * x0 + 3 * interval * diffSq * x1 + 3 * x2 * intervalSq * diff + x3 * intervalCu;
				py = diffCu * y0 + 3 * interval * diffSq * y1 + 3 * y2 * intervalSq * diff + y3 * intervalCu;

				line(lastx, lasty, px, py, c);
				lastx = px;
				lasty = py;
			}
		}


		// ------------------------------------------------
		//
		// ---o private static methods
		//
		// ------------------------------------------------
		/**
		 * Draw an alpha32 pixel
		 */
		private function drawAlphaPixel(x:int, y:int, a:Number, c:Number):void
		{
			var g:uint = getPixel32(x, y);

			var r0:uint = ((g & 0x00FF0000) >> 16);
			var g0:uint = ((g & 0x0000FF00) >> 8);
			var b0:uint = ((g & 0x000000FF));

			var r1:uint = ((c & 0x00FF0000) >> 16);
			var g1:uint = ((c & 0x0000FF00) >> 8);
			var b1:uint = ((c & 0x000000FF));

			var ac:Number = 0xFF;
			var rc:Number = r1 * a + r0 * (1 - a);
			var gc:Number = g1 * a + g0 * (1 - a);
			var bc:Number = b1 * a + b0 * (1 - a);

			var n:uint = (ac << 24) + (rc << 16) + (gc << 8) + bc;
			setPixel32(x, y, n);
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
