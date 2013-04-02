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
package tetragon.view.render2d.extensions.gauge
{
	import tetragon.view.render2d.display.Image2D;
	import tetragon.view.render2d.display.Sprite2D;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.geom.Point;
	
	
	/**
	 * A simple Gauge/Progress Bar.
	 */
	public class Gauge2D extends Sprite2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _image:Image2D;
		private var _ratio:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new gauge.
		 * 
		 * @param texture
		 * @param initialRatio
		 */
		public function Gauge2D(texture:Texture2D, initialRatio:Number = 1.0)
		{
			_ratio = 1.0;
			_image = new Image2D(texture);
			ratio = initialRatio;
			addChild(_image);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A value between 0.0 and 1.0.
		 */
		public function get ratio():Number
		{
			return _ratio;
		}
		public function set ratio(v:Number):void
		{
			if (v == _ratio) return;
			_ratio = Math.max(0.0, Math.min(1.0, v));
			_image.scaleX = _ratio;
			_image.setTexCoords(1, new Point(_ratio, 0.0));
			_image.setTexCoords(3, new Point(_ratio, 1.0));
		}
	}
}
