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
package view.pseudo3d
{
	import tetragon.data.texture.TextureAtlas;
	import tetragon.view.render2d.textures.RenderTexture2D;
	
	
	/**
	 * RenderBuffer class
	 *
	 * @author Hexagon
	 */
	public class RenderBuffer extends RenderTexture2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public var fillStyle:uint;
		public var globalAlpha:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function RenderBuffer(width:int, height:int, persistent:Boolean = true,
			scale:Number = -1.0)
		{
			super(width, height, persistent, scale);
		}


		public function beginPath():void
		{
		}


		public function moveTo(x1:Number, y1:Number):void
		{
		}


		public function lineTo(x2:Number, y2:Number):void
		{
		}


		public function closePath():void
		{
		}


		public function fill():void
		{
		}


		public function fillRect(i:int, y2:Number, width:Number, width1:Number):void
		{
		}


		public function drawImage(atlas:TextureAtlas, sourceX:Number, sourceY:Number, sourceW:Number, sourceH:Number, destX:Number, destY:Number, destW:Number, destH:Number):void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
