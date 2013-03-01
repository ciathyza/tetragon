/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package view.render2d
{
	import tetragon.data.texture.TextureAtlas;
	import tetragon.view.render2d.display.View2D;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.extensions.scrollimage.ScrollImage2D;
	import tetragon.view.render2d.extensions.scrollimage.ScrollTile2D;
	import tetragon.view.render2d.textures.TextureSmoothing2D;
	
	
	/**
	 * @author hexagon
	 */
	public class ScrollImage2DTestView extends View2D
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		private var _scrollImage:ScrollImage2D;
		private var _tile1:ScrollTile2D;
		private var _tile2:ScrollTile2D;
		private var _tile3:ScrollTile2D;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ScrollImage2DTestView()
		{
			super();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		public function updateRender():void
		{
			_scrollImage.tilesOffsetX -=1;
			//_scrollImage.tilesOffsetY -=1;
			//_scrollImage.tilesRotation += 0.01;
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		
		// -----------------------------------------------------------------------------------------
		// Callback Handlers
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function onAddedToStage(e:Event2D):void
		{
			super.onAddedToStage(e);
			
			var atlas:TextureAtlas = getResource("textureAtlas");
			if (!atlas) return;
			
			_tile1 = new ScrollTile2D(atlas.getTexture("bg_sky"));
			_tile2 = new ScrollTile2D(atlas.getTexture('bg_hills'));
			_tile3 = new ScrollTile2D(atlas.getTexture('bg_trees'));
			
			_tile2.parallax = 2;
			_tile3.parallax = 4;
			
			_scrollImage = new ScrollImage2D(_frameWidth, 480);
			_scrollImage.smoothing = TextureSmoothing2D.NONE;
			_scrollImage.scale(2.0);
			_scrollImage.addLayer(_tile1);
			_scrollImage.addLayer(_tile2);
			_scrollImage.addLayer(_tile3);
			
			_scrollImage.tilesPivotX = _frameWidth * 0.5;
			_scrollImage.tilesPivotY = _frameHeight * 0.5;
			
			addChild(_scrollImage);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function setup():void
		{
		}
	}
}
