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
package tetragon.view.render2d.extensions.scrollimage
{
	import tetragon.view.render2d.textures.ConcreteTexture2D;
	import tetragon.view.render2d.textures.SubTexture2D;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.geom.Rectangle;


	/**
	 * Tile layer used in ScrollImage
	 */
	public class ScrollTile2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public var parallax:Number = 1.0;
		public var offsetX:Number = 0.0;
		public var offsetY:Number = 0.0;
		public var rotation:Number = 0.0;
		public var scaleX:Number = 1.0;
		public var scaleY:Number = 1.0;
		
		private var _subTexture:SubTexture2D;
		private var _baseTexture:Texture2D;
		private var _baseClipping:Rectangle;
		private var _color:uint;
		private var _alpha:Number;
		private var _colorTrans:Vector.<Number>;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a tile from texture.
		 * 
		 * @param texture
		 * @param autoCrop
		 */
		public function ScrollTile2D(texture:Texture2D, autoCrop:Boolean = false)
		{
			if (!texture)
			{
				throw new ArgumentError("Texture cannot be null");
			}
			else if (texture is ConcreteTexture2D)
			{
				_subTexture = new SubTexture2D(texture, null);
			}
			else
			{
				_subTexture = texture as SubTexture2D;
			}
			
			_baseTexture = _subTexture.parent;
			
			while (_baseTexture is SubTexture2D)
			{
				_baseTexture = (_baseTexture as SubTexture2D).parent;
			}
			
			var pcx:Number = _subTexture.parent.width / _baseTexture.width;
			var pcy:Number = _subTexture.parent.height / _baseTexture.height;
			
			_baseClipping = new Rectangle(_subTexture.clipping.x * pcx, _subTexture.clipping.y * pcy,
				_subTexture.clipping.width * pcx, _subTexture.clipping.height * pcy);
			
			if (autoCrop) crop(1, 1);
			_colorTrans = new Vector.<Number>(4, true);
			
			alpha = 1;
			color = 0xFFFFFF;
		}
		
		
		/**
		 * Set crop inside of texture - helps with borders artefact.
		 * 
		 * @param x
		 * @param y
		 */
		public function crop(x:Number = 2, y:Number = 2):void
		{
			var dx:Number = x * 2 < _subTexture.width ? -x / _baseTexture.width : 0;
			var dy:Number = y * 2 < _subTexture.height ? -y / _baseTexture.height : 0;
			_baseClipping.inflate(dx, dy);
		}
		
		
		/**
		 * Dispose
		 */
		public function dispose():void
		{
			_subTexture = null;
			_baseTexture = null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Return texture.
		 */
		public function get baseTexture():Texture2D
		{
			return _baseTexture;
		}
		
		
		/**
		 * Return texure clipping
		 */
		public function get baseClipping():Rectangle
		{
			return _baseClipping;
		}


		/**
		 * Return color of tile.
		 */
		public function get color():uint
		{
			return _color;
		}
		public function set color(v:uint):void
		{
			_color = v;

			_colorTrans[0] = ((v >> 16) & 0xff) / 255.0;
			_colorTrans[1] = ((v >> 8) & 0xff) / 255.0;
			_colorTrans[2] = ( v & 0xff) / 255.0;
		}


		/**
		 * Return alpha color of tile
		 */
		public function get alpha():Number
		{
			return _alpha;
		}
		public function set alpha(v:Number):void
		{
			_alpha = v;
			_colorTrans[3] = v;
		}
		
		
		/**
		 * Alpha and color as Vector
		 */
		internal function get colorTrans():Vector.<Number>
		{
			return _colorTrans;
		}


		/**
		 * Width of tile in pixels.
		 */
		public function get width():Number
		{
			return _subTexture.width;
		}


		/**
		 * Return height of tile in pixels.
		 */
		public function get height():Number
		{
			return _subTexture.height;
		}
	}
}
