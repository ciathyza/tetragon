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
	import com.hexagonstar.util.color.mixColors;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
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
		/** @private */
		private var _m:Matrix;
		/** @private */
		private var _s:Shape;
		/** @private */
		private var _ct:ColorTransform;
		
		
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
		public function RenderBuffer(width:int, height:int, transparent:Boolean = false,
			fillColor:uint = 0x000000):void
		{
			super(width, height, transparent, fillColor);
			
			_fillColor = fillColor;
			_rect = rect;
			_buffer = [];
			_r = new Rectangle();
			_p = new Point();
			_s = new Shape();
			_m = new Matrix();
			_ct = new ColorTransform();
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
		public function drawPolygon(x1:Number, y1:Number, x2:Number, y2:Number,
			x3:Number, y3:Number, x4:Number, y4:Number, color:uint,
			mixColor:uint, mixAlpha:Number = 1.0):void
		{
			if (mixAlpha < 1.0) color = mixColors(color, mixColor, mixAlpha);
			_buffer.length = 0;
			lineTo(x1, y1, x2, y2, color);
			lineTo(x2, y2, x3, y3, color);
			lineTo(x3, y3, x4, y4, color);
			lineTo(x4, y4, x1, y1, color);
		}
		
		
		/**
		 * Blits a rectangle onto the render buffer.
		 */
		public function blitRect(x:int, y:int, w:int, h:int, color:uint, mixColor:uint,
			mixAlpha:Number = 1.0):void
		{
			_r.setTo(x, y, w, h);
			fillRect(_r, mixAlpha < 1.0 ? mixColors(color, mixColor, mixAlpha) : color);
		}
		
		
		//public function drawRect(x:int, y:int, w:int, h:int, color:uint, alpha:Number = 1.0):void
		//{
		//	_s.graphics.clear();
		//	_s.graphics.beginFill(color, alpha);
		//	_s.graphics.drawRect(0, 0, w, h);
		//	_s.graphics.endFill();
		//	_m.identity();
		//	_m.translate(x, y);
		//	draw(_s, _m);
		//}
		
		
		public function blitImage(sprite:BitmapData, x:int, y:int, w:int, h:int):void
		{
			_r.setTo(0, 0, w, h);
			_p.setTo(x, y);
			copyPixels(sprite, _r, _p);
		}
		
		
		public function drawImage(sprite:BitmapData, x:int, y:int, w:int, h:int,
			scale:Number = 1.0, mixColor:uint = 0, mixAlpha:Number = 1.0):void
		{
			//return;
			
			_m.setTo(scale, 0, 0, scale, x, y);
			_r.setTo(x, y, w, h);
			
			if (mixAlpha < 1.0)
			{
				mixAlpha = 1 - mixAlpha;
				_ct.redMultiplier = _ct.greenMultiplier = _ct.blueMultiplier = 1 - mixAlpha;
				_ct.redOffset = ((mixColor >> 16) & 0xFF) * mixAlpha;
				_ct.greenOffset = ((mixColor >> 8) & 0xFF) * mixAlpha;
				_ct.blueOffset = (mixColor & 0xFF) * mixAlpha;
				draw(sprite, _m, _ct, null, _r, false);
				return;
			}
			
			draw(sprite, _m, null, null, _r, false);
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
		private function lineTo(x0:int, y0:int, x1:int, y1:int, c:uint):void
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
			var ysStep:int = y0 < y1 ? 1 : -1;
			var xEnd:int = x1 - (deltaX >> 1);
			var error:int = 0;
			var y:int = y0;
			var x:int = x0;
			var fx:int = x1;
			var fy:int = y1;
			var px:int = 0;
			
			_r.setTo(0, 0, 0, 1);
			
			while (x++ <= xEnd)
			{
				if (steep)
				{
					checkLine(y, x, c, _r);
					if (fx != x1 && fx != xEnd) checkLine(fy, fx + 1, c, _r);
				}
				
				error += deltaY;
				if ((error << 1) >= deltaX)
				{
					if (!steep)
					{
						checkLine(x - px + 1, y, c, _r);
						if (fx != xEnd) checkLine(fx + 1, fy, c, _r);
					}
					px = 0;
					y += ysStep;
					fy -= ysStep;
					error -= deltaX;
				}
				px++;
				fx--;
			}
			
			if (!steep) checkLine(x - px + 1, y, c, _r);
		}
		
		
		/**
		 * Check a triangle line
		 */
		private function checkLine(x:int, y:int, c:uint, r:Rectangle):void
		{
			if (_buffer[y])
			{
				if (_buffer[y] > x)
				{
					r.width = _buffer[y] - x;
					r.x = x;
					r.y = y;
					fillRect(r, c);
				}
				else
				{
					r.width = x - _buffer[y];
					r.x = _buffer[y];
					r.y = y;
					fillRect(r, c);
				}
			}
			else
			{
				_buffer[y] = x;
			}
		}
	}
}
