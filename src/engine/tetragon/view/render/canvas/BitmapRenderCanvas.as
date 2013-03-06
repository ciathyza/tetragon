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
package tetragon.view.render.canvas
{
	import tetragon.Main;
	import tetragon.debug.IDrawCallsPollingSource;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * A render buffer that draws objects onto a bitmapdata.
	 */
	public class BitmapRenderCanvas extends BitmapData implements IRenderCanvas,
		IDrawCallsPollingSource
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
		/** @private */
		private var _drawCount:uint;
		
		
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
		public function BitmapRenderCanvas(width:int, height:int, fillColor:uint = 0x000000,
			transparent:Boolean = false):void
		{
			super(width, height, transparent, fillColor);
			
			/* Register renderer for draw calls polling on Tetragon's stats monitor. */
			if (Main.instance.statsMonitor)
			{
				Main.instance.statsMonitor.registerDrawCallsPolling(this);
			}
			
			_fillColor = fillColor;
			_rect = rect;
			_buffer = [];
			_drawCount = 0;
			
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
			_drawCount = 0;
		}
		
		
		/**
		 * Draws a filled, four-sided polygon onto the render buffer.
		 * 
		 * @param x1		first point x coord
		 * @param y1		first point y coord 
		 * @param x2		second point x coord
		 * @param y2		second point y coord
		 * @param x3		third point x coord
		 * @param y4		third point y coord
		 * @param color		color (0xRRGGBB)
		 * @param mixColor
		 * @param mixAlpha
		 */
		public function drawQuad(x1:Number, y1:Number, x2:Number, y2:Number,
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
		 * Fast method to blit a rectangle onto the render buffer.
		 * 
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * @param color
		 * @param mixColor
		 * @param mixAlpha
		 */
		public function blitRect(x:int, y:int, w:int, h:int, color:uint, mixColor:uint = 0x000000,
			mixAlpha:Number = 1.0):void
		{
			_r.setTo(x, y, w, h);
			fillRect(_r, mixAlpha < 1.0 ? mixColors(color, mixColor, mixAlpha) : color);
		}
		
		
		/**
		 * Draws a rectangle shape onmto the render buffer, using the draw API.
		 * 
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * @param color
		 * @param alpha
		 */
		public function drawRect(x:int, y:int, w:int, h:int, color:uint, alpha:Number = 1.0):void
		{
			_s.graphics.clear();
			_s.graphics.beginFill(color, alpha);
			_s.graphics.drawRect(0, 0, w, h);
			_s.graphics.endFill();
			_m.identity();
			_m.translate(x, y);
			draw(_s, _m);
		}
		
		
		/**
		 * Fast method to blit a bitmap onto the render buffer.
		 * 
		 * @param image
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 */
		public function blitImage(image:BitmapData, x:int, y:int, w:int, h:int):void
		{
			_r.setTo(0, 0, w, h);
			_p.setTo(x, y);
			copyPixels(image, _r, _p);
		}
		
		
		/**
		 * Draws a display object onto the render buffer using the draw API.
		 * 
		 * @param image
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * @param scale
		 * @param mixColor
		 * @param mixAlpha
		 */
		public function drawImage(image:*, x:int, y:int, w:int, h:int,
			scale:Number = 1.0, mixColor:uint = 0x000000, mixAlpha:Number = 1.0):void
		{
			++_drawCount;
			
			_m.setTo(scale, 0, 0, scale, x, y);
			_r.setTo(x, y, w, h);
			
			if (mixAlpha < 1.0)
			{
				mixAlpha = 1 - mixAlpha;
				_ct.redMultiplier = _ct.greenMultiplier = _ct.blueMultiplier = 1 - mixAlpha;
				_ct.redOffset = ((mixColor >> 16) & 0xFF) * mixAlpha;
				_ct.greenOffset = ((mixColor >> 8) & 0xFF) * mixAlpha;
				_ct.blueOffset = (mixColor & 0xFF) * mixAlpha;
				draw(image as BitmapData, _m, _ct, null, _r, false);
				return;
			}
			
			draw(image as BitmapData, _m, null, null, _r, false);
		}
		
		
		public function drawBundled():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The fill color of the render buffer.
		 */
		public function get fillColor():uint
		{
			return _fillColor;
		}
		public function set fillColor(v:uint):void
		{
			_fillColor = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get drawCount():uint
		{
			return _drawCount;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Draws special line for filled quad polygon.
		 * @private
		 * 
		 * @param x0
		 * @param y0
		 * @param x1
		 * @param y1
		 * @param c
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
			var yStep:int = y0 < y1 ? 1 : -1;
			var xEnd:int = x1 - (deltaX >> 1);
			var error:int = 0;
			var x:int = x0;
			var y:int = y0;
			var fx:int = x1;
			var fy:int = y1;
			var px:int = 0;
			
			_r.setTo(0, 0, 0, 1);
			
			while (x++ <= xEnd)
			{
				if (steep)
				{
					checkLine(y, x, c);
					if (fx != x1 && fx != xEnd) checkLine(fy, fx + 1, c);
				}
				
				error += deltaY;
				if ((error << 1) >= deltaX)
				{
					if (!steep)
					{
						checkLine(x - px + 1, y, c);
						if (fx != xEnd) checkLine(fx + 1, fy, c);
					}
					px = 0;
					y += yStep;
					fy -= yStep;
					error -= deltaX;
				}
				px++;
				fx--;
			}
			
			if (!steep) checkLine(x - px + 1, y, c);
		}
		
		
		/**
		 * Checks a quad line.
		 * @private
		 * 
		 * @param x
		 * @param y
		 * @param c
		 */
		private function checkLine(x:int, y:int, c:uint):void
		{
			if (_buffer[y])
			{
				if (_buffer[y] > x)
				{
					_r.width = _buffer[y] - x;
					_r.x = x;
					_r.y = y;
					fillRect(_r, c);
				}
				else
				{
					_r.width = x - _buffer[y];
					_r.x = _buffer[y];
					_r.y = y;
					fillRect(_r, c);
				}
			}
			else
			{
				_buffer[y] = x;
			}
		}
		
		
		/**
		 * Mixes two colors and returns the hexadecimal color value of the result.
		 * @private
		 * 
		 * @param color1 bottom color.
		 * @param color2 top color.
		 * @param alpha Alpha value (0.0 - 1.0) of color2.
		 * @return uint
		 */
	    private function mixColors(color1:uint, color2:uint, alpha:Number):uint
		{
			return (((color2 >> 16 & 0xFF) * (1 - alpha) + (color1 >> 16 & 0xFF) * alpha) << 16)
				+ (((color2 >> 8 & 0xFF) * (1 - alpha) + (color1 >> 8 & 0xFF) * alpha) << 8)
				+ ((color2 & 0xFF) * (1 - alpha) + (color1 & 0xFF) * alpha);
		}
	}
}
