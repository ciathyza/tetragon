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
	import tetragon.view.render2d.textures.RenderTexture2D;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * 
	 */
	public class Render2DRenderCanvas extends RenderTexture2D implements IRenderCanvas
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _r:Rectangle;
		/** @private */
//		private var _p:Point;
//		/** @private */
		private var _m:Matrix;
		/** @private */
//		private var _s:Shape;
//		/** @private */
//		private var _ct:ColorTransform;
		
		
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
		public function Render2DRenderCanvas(width:int, height:int, fillColor:uint = 0x000000):void
		{
			super(width, height, false);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
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
		public function drawImage(image:Object, x:int, y:int, w:int, h:int,
			scale:Number = 1.0, mixColor:uint = 0x000000, mixAlpha:Number = 1.0):void
		{
			_m.setTo(scale, 0, 0, scale, x, y);
			_r.setTo(x, y, w, h);
			
			//draw(image, _m);
		}
		
		
		public function lock():void
		{
		}
		
		
		public function unlock(changeRect:Rectangle = null):void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get fillColor():uint
		{
			return 0;
		}
		public function set fillColor(v:uint):void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Mixes two colors and returns the hexadecimal color value of the result.
		 * @private
		 * 
		 * @param color1 bottom color.
		 * @param color2 top color.
		 * @param alpha Alpha value (0.0 - 1.0) of color2.
		 * @return uint
		 */
		//private function mixColors(color1:uint, color2:uint, alpha:Number):uint
		//{
		//	return (((color2 >> 16 & 0xFF) * (1 - alpha) + (color1 >> 16 & 0xFF) * alpha) << 16)
		//		+ (((color2 >> 8 & 0xFF) * (1 - alpha) + (color1 >> 8 & 0xFF) * alpha) << 8)
		//		+ ((color2 & 0xFF) * (1 - alpha) + (color1 & 0xFF) * alpha);
		//}
	}
}
