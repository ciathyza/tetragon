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
		private var _rect:Rectangle;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ParallaxScroller(width:int, height:int, layers:Array = null)
		{
			super(width, height, false, 0x000000);
			_rect = rect;
			this.layers = layers;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function update(x:int):void
		{
			//fillRect(_rect, 0x000000);
			for (var i:uint = 0; i < _layerCount; i++)
			{
				var layer:ParallaxLayer = _layers[i];
				if (!layer) continue;
				//layer.point.x = x;
				copyPixels(layer.bitmapData, layer.rect, layer.point);
				//scroll(-x, 0);
			}
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
			if (!v)
			{
				_layers = null;
			}
			else
			{
				_layers = new Vector.<ParallaxLayer>(v.length, true);
				for (var i:uint = 0; i < _layers.length; i++)
				{
					var layer:ParallaxLayer = v[i];
					if (!layer) continue;
					layer.rect = new Rectangle(0, 0, layer.bitmapData.width, layer.bitmapData.height);
					layer.point = new Point(0, 0);
					_layers[i] = layer;
				}
			}
			_layerCount = !_layers ? 0 : _layers.length;
		}
	}
}
