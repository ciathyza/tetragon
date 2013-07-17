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
package tetragon.view
{
	import tetragon.Main;
	import tetragon.core.types.IDisposable;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.display.Image2D;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	
	/**
	 * ScreenBackground class
	 *
	 * @author Hexagon
	 */
	public class ScreenBackground implements IDisposable
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _nativeBackground:DisplayObject;
		protected var _screenCover:DisplayObject;
		protected var _render2DBackground:DisplayObject2D;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ScreenBackground()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			if (_render2DBackground) _render2DBackground.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get nativeBackground():DisplayObject
		{
			return _nativeBackground;
		}
		
		
		public function get screenCover():DisplayObject
		{
			if (!_screenCover) _screenCover = _nativeBackground;
			return _screenCover;
		}
		
		
		public function get render2DBackground():DisplayObject2D
		{
			if (!_render2DBackground)
			{
				if (_nativeBackground is Bitmap)
				{
					_render2DBackground = Image2D.fromBitmap(_nativeBackground as Bitmap, false, 1.0);
				}
				else if (_nativeBackground is MovieClip)
				{
					// TODO Add support for MovieClips with multi-frames!
					_render2DBackground = Image2D.fromDisplayObject(_nativeBackground, false, 1.0);
				}
				else if (_nativeBackground is DisplayObject)
				{
					_render2DBackground = Image2D.fromDisplayObject(_nativeBackground, false, 1.0);
				}
			}
			return _render2DBackground;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected static function getResource(resourceID:String):*
		{
			return Main.instance.resourceManager.resourceIndex.getResourceContent(resourceID);
		}
	}
}
