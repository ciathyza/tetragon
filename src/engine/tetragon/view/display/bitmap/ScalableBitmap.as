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
package tetragon.view.display.bitmap
{
	import tetragon.Main;
	import tetragon.util.display.StageReference;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Matrix;
	
	
	/**
	 * A Bitmap that adapts automatically to the stage size.
	 *
	 * @author Hexagon
	 */
	public class ScalableBitmap extends Bitmap
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected static var _stage:Stage;
		protected static var _refWidth:int;
		protected static var _refHeight:int;
		protected static var _matrix:Matrix;
		
		protected var _source:BitmapData;
		protected var _scaledWidth:int;
		protected var _scaledHeight:int;
		protected var _redraw:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param bitmapData
		 * @param smoothing
		 * @param redraw If true the bitmap will be redrawn using matrix scaling and bitmapdata.draw
		 * everytime it is resized. This requires more processing but results in smoother graphic.
		 */
		public function ScalableBitmap(bitmapData:BitmapData = null, smoothing:Boolean = true,
			redraw:Boolean = true)
		{
			super(null, "auto", smoothing);
			
			if (!_stage)
			{
				var main:Main = Main.instance;
				_stage = StageReference.stage;
				_refWidth = main.appInfo.referenceWidth;
				_refHeight = main.appInfo.referenceHeight;
				_matrix = new Matrix();
			}
			
			_source = bitmapData;
			_redraw = redraw;
			updateSize();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Updates the size of the bitmap according to a calculated scaling factor between
		 * the default reference width & height and the current stage width & height.
		 */
		public function updateSize():void
		{
			if (!_source) return;
			
			var scaleFactorX:Number = _stage.stageWidth / _refWidth;
			var scaleFactorY:Number = _stage.stageHeight / _refHeight;
			var targetW:int = _source.width * scaleFactorX;
			var targetH:int = _source.height * scaleFactorY;
			
			if (targetW == _scaledWidth && targetH == _scaledHeight) return;
			
			_scaledWidth = targetW;
			_scaledHeight = targetH;
			
			if (_redraw)
			{
				var b:BitmapData = new BitmapData(targetW, targetH, _source.transparent, 0);
				_matrix.identity();
				_matrix.scale(scaleFactorX, scaleFactorY);
				b.draw(_source, _matrix, null, null, null, smoothing);
				super.bitmapData = b;
			}
			else
			{
				super.bitmapData = _source;
				width = _scaledWidth;
				height = _scaledHeight;
			}
		}
		
		
		/**
		 * Updates size and position of the bitmap.
		 * 
		 * @param x
		 * @param y
		 */
		public function updateSizeAndPosition(x:int = 0, y:int = 0):void
		{
			updateSize();
			setPosition(x, y);
		}
		
		
		/**
		 * Updates the position of the bitmap.
		 * 
		 * @param x
		 * @param y
		 */
		public function setPosition(x:int = 0, y:int = 0):void
		{
			this.x = x;
			this.y = y;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The source bitmap data.
		 */
		override public function get bitmapData():BitmapData
		{
			return _source;
		}
		override public function set bitmapData(v:BitmapData):void
		{
			_source = v;
			updateSize();
		}
		
		
		/**
		 * The scaled bitmap data.
		 */
		public function get scaledBitmapData():BitmapData
		{
			return super.bitmapData;
		}
	}
}
