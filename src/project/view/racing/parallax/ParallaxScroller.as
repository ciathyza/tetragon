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
package view.racing.parallax
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * ParallaxScroller class
	 *
	 * @author Hexagon
	 */
	public class ParallaxScroller extends BitmapData
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _layers:Vector.<ParallaxLayer>;
		private var _layerCount:uint;
		private var _buffer:BitmapData;
		private var _clearRect:Rectangle;
		private var _rect:Rectangle;
		private var _point:Point;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ParallaxScroller(width:int, height:int, layers:Array = null)
		{
			super(width, height, false, 0x000000);
			this.layers = layers;
			
			_rect = new Rectangle();
			_point = new Point();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function update():void
		{
			for (var i:uint = 0; i < _layerCount; i++)
			{
				offsetLayer(_layers[i]);
			}
		}
		
		
		public function offsetLayer(layer:ParallaxLayer):void
		{
			if (!layer) return;
			
			var distX:int = layer.offsetFactorX * layer.width;
//			var distY:int = layer.offsetFactorY * layer.height;
			
			if (distX != layer.prevScrollX)
			{
				var scrollX:int = (distX - layer.prevScrollX) * layer.speed;
				/* Ignore scroll if scrollX is too large (might happen if factor wraps around)! */
				if (Math.abs(scrollX) <= layer.width)
				{
					scrollLayerBy(layer, scrollX, 0);
				}
			}
			
			// TODO add vertical scrolling!
//			if (distY != layer.prevScrollY)
//			{
//				var scrollY:int = (distY - layer.prevScrollY) * layer.speed;
//				/* Ignore scroll if scrollX is too large (might happen if factor wraps around)! */
//				if (Math.abs(scrollY) <= layer.height)
//				{
//					scrollLayerBy(layer, 0, scrollY);
//				}
//			}
			
			layer.prevScrollX = distX;
//			layer.prevScrollY = distY;
		}
		
		
		/**
		 * Scrolls a layer by <x> and <y> pixels.
		 */
		public function scrollLayerBy(layer:ParallaxLayer, pixelX:int, pixelY:int):void
		{
			if (!layer) return;
			
			/* Reset rect & point. */
			_rect.setTo(0, 0, layer.width, layer.height);
			_point.setTo(0, 0);
			
			/* Determine the region that needs to be copied to the buffer. */
			if (pixelX > 0)
			{
				_rect.width = pixelX;
			}
			else if (pixelX < 0)
			{
				_rect.x = layer.width + pixelX;
				_rect.width = -pixelX;
			}
			if (pixelY > 0)
			{
				_rect.height = pixelY;
			}
			else if (pixelY < 0)
			{
				_rect.y = layer.height + pixelY;
				_rect.height = -pixelY;
			}
			
			/* Copy scrolling-out part from source to buffer. */
			_buffer.fillRect(_clearRect, 0x00000000);
			_buffer.copyPixels(layer.source, _rect, _point);
			
			/* Scroll the source by <speed> pixels. */
			layer.source.scroll(-pixelX, -pixelY);
			
			/* Determine the region to copy back from the buffer to the source. */
			if (pixelX > 0)
			{
				_point.x = layer.width - pixelX;
			}
			else if (pixelX < 0)
			{
				_rect.x = _point.x = 0;
			}
			if (pixelY > 0)
			{
				_point.y = layer.height - pixelY;
			}
			else if (pixelY < 0)
			{
				_rect.y = _point.y = 0;
			}
			
			/* Copy scrolled-out part from buffer back to scroll-in area on source. */
			layer.source.copyPixels(_buffer, _rect, _point);
			
			/* Reset rect & point. */
			_rect.setTo(0, 0, layer.width, layer.height);
			_point.setTo(0, 0);
			
			/* Copy source to canvas. */
			copyPixels(layer.source, _rect, _point);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get layers():Array
		{
			if (!_layers) return null;
			var a:Array = [];
			for (var i:uint = 0; i < _layers.length; i++)
			{
				a.push(_layers[i]);
			}
			return a;
		}
		public function set layers(v:Array):void
		{
			var i:uint;
			if (!v)
			{
				_layers = null;
			}
			else
			{
				var w:int = 0;
				var h:int = 0;
				_layers = new Vector.<ParallaxLayer>(v.length, true);
				for (i = 0; i < _layers.length; i++)
				{
					var layer:ParallaxLayer = v[i];
					if (!layer || !layer.source) continue;
					/* find the width & height of the largest layer. */
					if (layer.source.width > w) w = layer.source.width;
					if (layer.source.height > h) h = layer.source.height;
					_layers[i] = layer;
				}
			}
			_layerCount = !_layers ? 0 : _layers.length;
			
			/* Create buffer of largest layer width & height. */
			if (w > 0 && h > 0)
			{
				_buffer = new BitmapData(w, h, true, 0x00000000);
				_clearRect = _buffer.rect;
				for (i = 0; i < _layers.length; i++)
				{
					scrollLayerBy(_layers[i], 0, 0);
				}
			}
		}
	}
}
