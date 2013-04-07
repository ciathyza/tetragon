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
	/**
	 * Interface for render canvas classes that use a render surface to draw
	 * display objects onto it.
	 * 
	 * @author Hexagon
	 */
	public interface IRenderCanvas
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Clears the render canvas.
		 */
		function clear():void;
		
		
		/**
		 * Draws a rectangle onto the render canvas.
		 * 
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * @param color
		 * @param mixColor
		 * @param mixAlpha
		 */
		function drawRect(x:Number, y:Number, w:Number, h:Number, color:uint,
			mixColor:uint = 0x000000, mixAlpha:Number = 1.0, mixThreshold:Number = 1.0):void;
		
		
		/**
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 */
		function drawDebugRect(x:Number, y:Number, w:Number, h:Number, color:uint = 0xFF00FF):void;
		
		
		/**
		 * Draws a filled, four-sided polygon onto the render canvas.
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
		function drawQuad(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number,
			x4:Number, y4:Number, color:uint, mixColor:uint, mixAlpha:Number = 1.0,
			mixThreshold:Number = 1.0):void;
		
		
		/**
		 * Draws a display object onto the render canvas using the draw API of the
		 * underlying render surface.
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
		function drawImage(image:*, x:Number, y:Number, w:Number, h:Number, scale:Number = 1.0,
			mixColor:uint = 0x000000, mixAlpha:Number = 1.0, mixThreshold:Number = 1.0):void;
		
		
		/**
		 * Draws a display object onto the render canvas using fast blitting but doesn't
		 * support scaling or color mixing.
		 * 
		 * @param image
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 */
		function blit(displayObject:*, x:Number = 0, y:Number = 0, w:Number = 0, h:Number = 0):void;
		
		
		/**
		 * Can be used to finish a frame rendering on the canvas. Useful for sub-classes
		 * that bundle draw calls.
		 */
		function complete():void;
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		function toString():String;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The fill color of the render canvas.
		 */
		function get fillColor():uint;
		function set fillColor(v:uint):void;
	}
}
