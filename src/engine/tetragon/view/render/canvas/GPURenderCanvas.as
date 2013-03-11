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
	import tetragon.debug.Log;
	import tetragon.view.render2d.display.BlendMode2D;
	import tetragon.view.render2d.display.Image2D;
	import tetragon.view.render2d.display.Quad2D;
	import tetragon.view.render2d.display.Rect2D;
	import tetragon.view.render2d.textures.RenderTexture2D;
	import tetragon.view.render2d.textures.TextureSmoothing2D;

	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * 
	 */
	public class GPURenderCanvas extends Image2D implements IRenderCanvas
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _texture:RenderTexture2D;
		private var _rect:Rect2D;
		private var _quad:Quad2D;
		private var _r:Rectangle;
		private var _m:Matrix;
		
		private var _drawCommandBuffer:Vector.<DrawCommand>;
		private var _drawCommandsMax:uint = 1000;
		private var _drawCommandsExtend:uint = 100;
		private var _drawCommandIndex:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param width
		 * @param height
		 * @smoothing TextureSmoothing2D
		 */
		public function GPURenderCanvas(width:int, height:int,
			smoothing:String = TextureSmoothing2D.NONE):void
		{
			_texture = new RenderTexture2D(width, height, false);
			
			super(_texture);
			
			this.smoothing = smoothing;
			
			_m = new Matrix();
			_r = new Rectangle();
			
			_rect = new Rect2D(10, 10);
			_rect.blendMode = BlendMode2D.NONE;
			_quad = new Quad2D();
			_quad.blendMode = BlendMode2D.NONE;
			
			preallocateCommandBuffer();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function clear():void
		{
			/* Not required for the render texture as we're using a non-persistent one! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function drawRect(x:int, y:int, w:int, h:int, color:uint, mixColor:uint = 0x000000,
			mixAlpha:Number = 1.0):void
		{
			checkCommandBufferFull();
			
			var c:DrawCommand = _drawCommandBuffer[_drawCommandIndex];
			c.type = 1;
			c.x = x;
			c.y = y;
			c.w = w;
			c.h = h;
			c.color = color;
			c.mixAlpha = mixAlpha;
			c.mixColor = mixColor;
			
			++_drawCommandIndex;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function drawQuad(x1:Number, y1:Number, x2:Number, y2:Number,
			x3:Number, y3:Number, x4:Number, y4:Number, color:uint,
			mixColor:uint, mixAlpha:Number = 1.0):void
		{
			checkCommandBufferFull();
			
			var c:DrawCommand = _drawCommandBuffer[_drawCommandIndex];
			c.type = 2;
			c.x = x1;
			c.y = y1;
			c.x2 = x2;
			c.y2 = y2;
			c.x3 = x3;
			c.y3 = y3;
			c.x4 = x4;
			c.y4 = y4;
			c.color = color;
			c.mixAlpha = mixAlpha;
			c.mixColor = mixColor;
			
			++_drawCommandIndex;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function drawImage(image:*, x:int, y:int, w:int, h:int,
			scale:Number = 1.0, mixColor:uint = 0x000000, mixAlpha:Number = 1.0):void
		{
			checkCommandBufferFull();
			
			var c:DrawCommand = _drawCommandBuffer[_drawCommandIndex];
			c.type = 3;
			c.image = image;
			c.x = x;
			c.y = y;
			c.w = w;
			c.h = h;
			c.scale = scale;
			c.mixAlpha = mixAlpha;
			c.mixColor = mixColor;
			
			++_drawCommandIndex;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function blitImage(image:*, x:int, y:int, w:int, h:int):void
		{
			checkCommandBufferFull();
			
			var c:DrawCommand = _drawCommandBuffer[_drawCommandIndex];
			c.type = 4;
			c.image = image;
			c.x = x;
			c.y = y;
			c.w = w;
			c.h = h;
			
			++_drawCommandIndex;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function complete():void
		{
			_texture.drawBundled(function():void
			{
				for (var i:uint = 0; i < _drawCommandsMax; i++)
				{
					var c:DrawCommand = _drawCommandBuffer[i];
					
					/* Ignore commands that are not used in this cycle. */
					if (c.type < 1)
					{
						continue;
					}
					/* Draw Rect */
					else if (c.type == 1)
					{
						if (c.mixAlpha < 1.0) c.color = mixColors(c.color, c.mixColor, c.mixAlpha);
						_rect.setTo(c.x, c.y, c.w, c.h);
						_rect.color = c.color;
						_texture.draw(_rect);
					}
					/* Draw Quad */
					else if (c.type == 2)
					{
						if (c.mixAlpha < 1.0) c.color = mixColors(c.color, c.mixColor, c.mixAlpha);
						_quad.update(c.x, c.y, c.x2, c.y2, c.x3, c.y3, c.x4, c.y4, c.color);
						_texture.draw(_quad);
					}
					/* Draw Image */
					else if (c.type == 3)
					{
						c.image.color = mixColors(0xFFFFFF, c.mixColor, c.mixAlpha);;
						_m.setTo(c.scale, 0, 0, c.scale, c.x, c.y);
						_r.setTo(c.x, c.y, c.w, c.h);
						_texture.drawImage(c.image, _m, _r);
					}
					/* Blit Image */
					else if (c.type == 4)
					{
						_m.setTo(1.0, 0, 0, 1.0, c.x, c.y);
						_r.setTo(c.x, c.y, c.w, c.h);
						_texture.drawImage(c.image, _m, _r);
					}
					
					/* Invalidate command. */
					c.type = 0;
				}
				
				/* Reset draw command index. */
				_drawCommandIndex = 0;
			});
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return "GPURenderCanvas";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get fillColor():uint
		{
			return 0;
		}
		public function set fillColor(v:uint):void
		{
		}
		
		
		/**
		 * Number of draw commands that are pre-allocated.
		 */
		public function get drawCommandsMax():uint
		{
			return _drawCommandsMax;
		}
		public function set drawCommandsMax(v:uint):void
		{
			if (v == _drawCommandsMax) return;
			_drawCommandsMax = v;
			preallocateCommandBuffer();
		}
		
		
		/**
		 * The number of draw commands which that the command buffer is automatically
		 * extended if the buffer gets full.
		 */
		public function get drawCommandsExtend():uint
		{
			return _drawCommandsExtend;
		}
		public function set drawCommandsExtend(v:uint):void
		{
			if (v == _drawCommandsExtend) return;
			_drawCommandsExtend = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function checkCommandBufferFull():void
		{
			if (_drawCommandIndex < _drawCommandsMax) return;
			Log.notice("Draw command buffer full! Extending by "
				+ _drawCommandsExtend + " ...", this);
			extendCommandBuffer();
		}
		
		
		/**
		 * @private
		 */
		private function preallocateCommandBuffer():void
		{
			_drawCommandIndex = 0;
			_drawCommandBuffer = new Vector.<DrawCommand>(_drawCommandsMax, false);
			for (var i:uint = 0; i < _drawCommandBuffer.length; i++)
			{
				_drawCommandBuffer[i] = new DrawCommand();
			}
		}
		
		
		/**
		 * @private
		 */
		private function extendCommandBuffer():void
		{
			var len:uint = _drawCommandsMax + _drawCommandsExtend;
			for (var i:uint = _drawCommandsMax - 1; i < len; i++)
			{
				_drawCommandBuffer[i] = new DrawCommand();
			}
			_drawCommandsMax = len;
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
				+ (((color2 >> 8 & 0xFF) * (1 - alpha) + (color1 >> 8 & 0xFF) * alpha) << 8) + ((color2 & 0xFF) * (1 - alpha) + (color1 & 0xFF) * alpha);
		}
	}
}


import tetragon.view.render2d.display.Image2D;

/**
 * @private
 */
final class DrawCommand
{
	/* type:
	 * 0 = invalidate
	 * 1 = drawRect
	 * 2 = drawQuad
	 * 3 = drawImage
	 * 4 = blitImage
	 */
	public var type:int,
		x:int, y:int,
		x2:int, y2:int,
		x3:int, y3:int,
		x4:int, y4:int,
		w:int, h:int,
		scale:Number,
		color:uint,
		mixColor:uint,
		mixAlpha:Number,
		image:Image2D;
}
