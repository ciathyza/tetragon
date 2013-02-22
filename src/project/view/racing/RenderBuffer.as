/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package view.racing
{
	import com.hexagonstar.util.color.colorChannelToString;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * A RenderBuffer is a rectangular bitmap area which is used to render any other
	 * display objects to a common buffer.
	 */
	public class RenderBuffer extends BitmapData
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _fillColor:uint;
		/** @private */
		private var _rect:Rectangle;
		/** @private */
		private var _buffer:Array;
		/** @private */
		private var _r:Rectangle;
		/** @private */
		private var _p:Point;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param width
		 * @param height
		 * @param transparent
		 * @param fillColor
		 */
		public function RenderBuffer(width:int, height:int, transparent:Boolean = true,
			fillColor:uint = 0x00000000):void
		{
			super(width, height, transparent, fillColor);
			
			_fillColor = 0xFFFF00FF; //fillColor;
			_rect = rect;
			_buffer = [];
			_r = new Rectangle();
			_p = new Point();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Clears the render buffer.
		 */
		public function clear():void
		{
			fillRect(_rect, _fillColor);
		}
		
		
		public function drawRect(x:int, y:int, w:int, h:int, color:uint, alpha:Number = 1.0):void
		{
			//color = color | ((alpha * 0xFF) << 24);
			//Debug.trace(colorHexToString(color));
			
			_r.setTo(x, y, w, h);
			//fillRect(_r, (alpha << 24) | color);
			color = 0x7D0000FF;
			fillRect(_r, color);
		}
		
	public function colorHexToString(color:uint):String
	{
		return String(
			colorChannelToString(color >> 24 & 0xFF)
			+ colorChannelToString(color >> 16 & 0xFF)
			+ colorChannelToString(color >> 8 & 0xFF)
			+ colorChannelToString(color & 0xFF)).toUpperCase();
	}
		
		/**
		 * Draw a filled, four-sided polygon.
		 * 
		 * @param x1		first point x coord
		 * @param y1		first point y coord 
		 * @param x2		second point x coord
		 * @param y2		second point y coord
		 * @param x3		third point x coord
		 * @param y4		third point y coord
		 * @param c		color (0xaarrvvbb)
		 */
		public function drawPolygon(x1:int, y1:int, x2:int, y2:int, x3:int, y3:int, x4:int, y4:int, color:uint):void
		{
			_buffer.length = 0;
			lineTo(_buffer, x1, y1, x2, y2, color);
			lineTo(_buffer, x2, y2, x3, y3, color);
			lineTo(_buffer, x3, y3, x4, y4, color);
			lineTo(_buffer, x4, y4, x1, y1, color);
		}
		
		
		public function drawImage(sprite:BitmapData, x:int, y:int, w:int, h:int):void
		{
			_r.setTo(0, 0, w, h);
			_p.setTo(x, y);
			copyPixels(sprite, _r, _p, null, null, true);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get fillColor():uint
		{
			return _fillColor;
		}
		public function set fillColor(v:uint):void
		{
			_fillColor = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Special line for filled triangle
		 */
		private function lineTo(a:Array, x0:int, y0:int, x1:int, y1:int, c:uint):void
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
			
			var deltaX:int = x1 - x0;
			var deltaY:int = (y1 - y0) < 0 ? -(y1 - y0) : (y1 - y0);
			var error:int = 0;
			var y:int = y0;
			var ystep:int = y0 < y1 ? 1 : -1;
			var x:int = x0;
			var xend:int = x1 - (deltaX >> 1);
			var fx:int = x1;
			var fy:int = y1;
			var px:int = 0;
			
			_r.setTo(0, 0, 0, 1);
			
			while (x++ <= xend)
			{
				if (steep)
				{
					checkLine(a, y, x, c, _r);
					if (fx != x1 && fx != xend) checkLine(a, fy, fx + 1, c, _r);
				}
				
				error += deltaY;
				if ((error << 1) >= deltaX)
				{
					if (!steep)
					{
						checkLine(a, x - px + 1, y, c, _r);
						if (fx != xend) checkLine(a, fx + 1, fy, c, _r);
					}
					px = 0;
					y += ystep;
					fy -= ystep;
					error -= deltaX;
				}
				px++;
				fx--;
			}
			
			if (!steep) checkLine(a, x - px + 1, y, c, _r);
		}
		
		
		/**
		 * Check a triangle line
		 */
		private function checkLine(a:Array, x:int, y:int, c:uint, r:Rectangle):void
		{
			if (a[y])
			{
				if (a[y] > x)
				{
					r.width = a[y] - x;
					r.x = x;
					r.y = y;
					fillRect(r, (255 << 24) | c);
				}
				else
				{
					r.width = x - a[y];
					r.x = a[y];
					r.y = y;
					fillRect(r, (255 << 24) | c);
				}
			}
			else
			{
				a[y] = x;
			}
		}
	}
}
