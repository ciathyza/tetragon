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
package tetragon.entity.systems
{
	import tetragon.Main;
	import tetragon.view.render.RenderBuffer;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	public class EndlessScrollLayer extends BitmapData
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _scroller:EndlessScroller;
		private var _buffer:RenderBuffer;
		private var _tiles:Vector.<BitmapData>;
		private var _position:Point;
		private var _bounds:Rectangle;
		private var _tilePosition:Point;
		private var _tileBounds:Rectangle;
		private var _tileWidth:int;
		private var _tileHeight:int;
		private var _scrollSpeedMult:Number;
		private var _scrollPosition:int;
		private var _colMax:int;
		private var _colCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EndlessScrollLayer(scroller:EndlessScroller, x:int, y:int, width:int,
			height:int, tileWidth:int, tileHeight:int, transparent:Boolean = true)
		{
			super(width + tileWidth, height, transparent, transparent ? 0x00000000 : 0x000000);
			
			_scroller = scroller;
			_buffer = _scroller.buffer;
			_tileWidth = tileWidth;
			_tileHeight = tileHeight;
			_scrollPosition = 0;
			_position = new Point(x, y);
			_bounds = rect;
			_tilePosition = new Point(0, 0);
			_tileBounds = new Rectangle(tileWidth, tileHeight);
			
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function tick():void
		{
			if (_scrollPosition <= _tileWidth - scrollSpeed)
			{
				_tilePosition.x = width - _tileWidth - scrollSpeed;
				copyPixels(_tiles[0], _tileBounds, _tilePosition);
				
				_scrollPosition += _tileWidth;
				_colCount++;
				
				if (_colCount == _colMax)
				{
					_colCount = 0;
				}
			}
			
			scroll(-scrollSpeed, 0);
			_scrollPosition -= scrollSpeed;
			
			_buffer.copyPixels(this, _bounds, _position);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get scrollSpeed():int
		{
			return _scroller.scrollSpeed * _scrollSpeedMult;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		protected function setup():void
		{
			_tiles = new Vector.<BitmapData>();
			_colMax = width / _tileWidth;
		}
		
		
		protected static function getResource(resourceID:String):*
		{
			return Main.instance.resourceManager.resourceIndex.getResourceContent(resourceID);
		}
	}
}
