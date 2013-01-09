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
package tetragon.view.render2d.tile
{
	import flash.display.Stage;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import tetragon.Main;
	import tetragon.core.GameLoop;
	import tetragon.view.render2d.core.Sprite2D;

	
	
	/**
	 * TileScroller class
	 *
	 * @author Hexagon
	 */
	public class TileScroller extends Sprite2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		//private static const BOUNDINGBOX_COLORS:Array =
		//[
		//	0xFF0000, 0x00FF00, 0x0000FF, 0xFF8800, 0x00FFFF, 0xFFFF00
		//];
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _stage:Stage;
		private var _gameLoop:GameLoop;
		private var _tilemap:TileMap;
		private var _container:Sprite2D;
		
		private var _width:int;
		private var _height:int;
		
		private var _speed:int;
		private var _speedH:int;
		private var _speedV:int;
		private var _speedScaled:int;
		private var _speedHScaled:int;
		private var _speedVScaled:int;
		private var _speedAvr:Number;
		
		private var _frameRate:int;
		private var _fps:int;
		private var _ms:int;
		private var _mss:int;
		private var _msPrev:int;
		private var _time:int;
		private var _frameCount:int;
		
		private var _xPos:Number;
		private var _yPos:Number;
		private var _xPosOld:Number;
		private var _yPosOld:Number;
		private var _xVelocity:Number;
		private var _yVelocity:Number;
		private var _decel:Number;
		
		private var _scale:Number;
		
		private var _areaX:int;
		private var _areaY:int;
		private var _oldAreaX:int;
		private var _oldAreaY:int;
		private var _visibleObjectCount:int;
		private var _visibleAnimTileCount:int;
		private var _cachedObjectCount:int;
		//private var _bgColor:uint;
		private var _opa:int;
		private var _edgeMode:int;
		
		private var _onFrame:Function;
		
		private var _scrollLeft:Boolean;
		private var _scrollRight:Boolean;
		private var _scrollUp:Boolean;
		private var _scrollDown:Boolean;
		
		//private var _allowHScroll:Boolean;
		//private var _allowVScroll:Boolean;
		private var _autoScrollH:Boolean;
		private var _autoScrollV:Boolean;
		private var _reachedHEdge:Boolean;
		private var _reachedVEdge:Boolean;
		
		private var _started:Boolean;
		private var _paused:Boolean;
		private var _autoPurge:Boolean;
		private var _cacheObjects:Boolean;
		//private var _wrap:Boolean;
		
		private var _showBuffer:Boolean;
		private var _showAreas:Boolean;
		private var _showMapBoundaries:Boolean;
		private var _showBoundingBoxes:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param width
		 * @param height
		 */
		public function TileScroller(width:int = 0, height:int = 0)
		{
			super();
			setup();
			setViewportSize(width, height);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets the width and height of the tilescroller's viewport, i.e. the visible
		 * render area of the tilescroller.
		 * 
		 * @param width
		 * @param height
		 */
		public function setViewportSize(width:int, height:int):void
		{
			_width = width > 0 ? width : _stage.stageWidth;
			_height = height > 0 ? height : _stage.stageHeight;
			
			setupView();
			
			/* If the size was changed after we provided a tilemap,
			 * the tilemap needs to be re-setup again. */
			if (_tilemap) setupTilemap();
			
			forceRedraw();
		}
		
		
		/**
		 * Starts the tilescroller.
		 */
		public function start():void
		{
			if (_started) return;
			_started = true;
			_frameCount = 0;
			_gameLoop.tickSignal.add(onTick);
			_gameLoop.renderSignal.add(onRender);
		}
		
		
		/**
		 * Stops the tilescroller.
		 */
		public function stop():void
		{
			if (!_started) return;
			_started = false;
			_gameLoop.tickSignal.remove(onTick);
			_gameLoop.renderSignal.remove(onRender);
		}
		
		
		/**
		 * Resets the tilescroller.
		 */
		public function reset():void
		{
			_fps = 0;
			_areaX = 0;
			_areaY = 0;
			_oldAreaX = -1;
			_oldAreaY = -1;
			_xPos = 0;
			_yPos = 0;
			_xPosOld = NaN;
			_yPosOld = NaN;
			_xVelocity = 0;
			_yVelocity = 0;
			
			_paused = false;
			_scrollLeft = false;
			_scrollRight = false;
			_scrollUp = false;
			_scrollDown = false;
			_reachedHEdge = false;
			_reachedVEdge = false;
			
			if (_container)
			{
				_container.x = 0;
				_container.y = 0;
			}
		}
		
		
		/**
		 * Scrolls the tilescroller into the specified direction.
		 * 
		 * @param direction
		 */
		public function scroll(direction:String):void
		{
			if (direction == TileScrollDirection.LEFT)
			{
				_scrollRight = false;
				_scrollLeft = true;
			}
			else if (direction == TileScrollDirection.RIGHT)
			{
				_scrollLeft = false;
				_scrollRight = true;
			}
			else if (direction == TileScrollDirection.UP)
			{
				_scrollDown = false;
				_scrollUp = true;
			}
			else if (direction == TileScrollDirection.DOWN)
			{
				_scrollUp = false;
				_scrollDown = true;
			}
		}
		
		
		/**
		 * Stops scrolling in the specified direction.
		 * 
		 * @param direction
		 */
		public function stopScroll(direction:String):void
		{
			if (direction == TileScrollDirection.LEFT) _scrollLeft = false;
			else if (direction == TileScrollDirection.RIGHT) _scrollRight = false;
			else if (direction == TileScrollDirection.UP) _scrollUp = false;
			else if (direction == TileScrollDirection.DOWN) _scrollDown = false;
		}
		
		
		/**
		 * Disposes the scroller.
		 */
		override public function dispose():void
		{
			stop();
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The tilemap that is used by the tilescroller.
		 */
		public function get tilemap():TileMap
		{
			return _tilemap;
		}
		public function set tilemap(v:TileMap):void
		{
			// TODO
		}
		
		
		/**
		 * Determines whether the tilescroller is paused or not.
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			if (v == _paused) return;
			_paused = v;
		}
		
		
		/**
		 * The width of the scroll viewport.
		 */
		public function get viewportWidth():int
		{
			return _width;
		}
		public function set viewportWidth(v:int):void
		{
			if (v == _width) return;
			_width = v;
			setViewportSize(_width, _height);
		}
		
		
		/**
		 * The height of the scroll viewport.
		 */
		public function get viewportHeight():int
		{
			return _height;
		}
		public function set viewportHeight(v:int):void
		{
			if (v == _height) return;
			_height = v;
			setViewportSize(_width, _height);
		}
		
		
		/**
		 * The speed of the tile scroller. This is a value that determines by how many
		 * pixels the tilemap is shifted when scrolling. The default is 10. setting this
		 * to 0 stops the ability of scrolling. Setting this value to a negative value will
		 * invert the scroll direction. This property sets both horizontal and vertical
		 * scroll speed to the same value.
		 */
		public function get speed():int
		{
			return _speed;
		}
		public function set speed(v:int):void
		{
			_speed = _speedH = _speedV = _speedAvr = v;
			_speedScaled = _speedHScaled = _speedVScaled = roundSpeed(_speed / _scale);
		}
		
		
		/**
		 * The horizontal scroll speed.
		 */
		public function get speedH():int
		{
			return _speedH;
		}
		public function set speedH(v:int):void
		{
			_speedH = v;
			_speedHScaled = roundSpeed(_speedH / _scale);
			_speedAvr = (_speedH + _speedV) * .5;
		}
		
		
		/**
		 * The vertical scroll speed.
		 */
		public function get speedV():int
		{
			return _speedV;
		}
		public function set speedV(v:int):void
		{
			_speedV = v;
			_speedVScaled = roundSpeed(_speedV / _scale);
			_speedAvr = (_speedH + _speedV) * .5;
		}
		
		
		/**
		 * The deceleration factor that applies to the scroll velocity after scrolling
		 * is stopped. Valid values are from 0 (instant stop) to 0.99 (max. easing).
		 * The default value is 0.9.
		 */
		public function get deceleration():Number
		{
			return _decel;
		}
		public function set deceleration(v:Number):void
		{
			_decel = (v < 0.0) ? 0.0 : (v > 0.99) ? 0.99 : v;
		}
		
		
		/**
		 * The actual framerate at that the tilescroller runs currently. This value can be
		 * used to monitor the scroll performance.
		 */
		public function get fps():int
		{
			return _fps;
		}
		
		
		/**
		 * The time in milliseconds that it took the tilescroller to render one frame.
		 */
		public function get ms():int
		{
			return _ms;
		}
		
		
		/**
		 * The current x position on the tilemap.
		 */
		public function get xPos():int
		{
			return _xPos;
		}
		
		
		/**
		 * The current y position on the tilemap.
		 */
		public function get yPos():int
		{
			return _yPos;
		}
		
		
		/**
		 * Determines if the tilescroller automatically scrolls horizontally. Speed and
		 * direction can be changed with the speed property.
		 */
		public function get autoScrollH():Boolean
		{
			return _autoScrollH;
		}
		public function set autoScrollH(v:Boolean):void
		{
			if (v == _autoScrollH) return;
			_autoScrollH = v;
		}
		
		
		/**
		 * Determines if the tilescroller automatically scrolls vertically. Speed and
		 * direction can be changed with the speed property.
		 */
		public function get autoScrollV():Boolean
		{
			return _autoScrollV;
		}
		public function set autoScrollV(v:Boolean):void
		{
			if (v == _autoScrollV) return;
			_autoScrollV = v;
		}
		
		
		/**
		 * Determines the behavior of the scrolling when an edge (incl. margin) of the
		 * tilemap is reached. The following choices are available: off, halt, wrap and
		 * bounce. Bounce only has an effect with autoscrolling turned on.
		 */
		public function get edgeMode():int
		{
			return _edgeMode;
		}
		public function set edgeMode(v:int):void
		{
			// TODO
		}
		
		
		/**
		 * The scale factor at which the scroller viewport is scaled.
		 * 
		 * @default 1.0
		 */
		public function get scale():Number
		{
			return _scale;
		}
		public function set scale(v:Number):void
		{
			/* No down-scaling supported yet, only up-scaling! */
			if (v == _scale || v < 1.0 || v > 10) return;
			_scale = v;
			// TODO
		}
		
		
		/**
		 * Allows to disable/enable automatic object purge calculation. By default this
		 * option is active (true) and can be left as that. If disabled you have to set
		 * <code>objectPurgeAmount</code> manually.
		 * 
		 * @default true
		 */
		public function get autoPurge():Boolean
		{
			return _autoPurge;
		}
		public function set autoPurge(v:Boolean):void
		{
			_autoPurge = v;
		}
		
		
		/**
		 * A value that determines how many off-screen objects (tilegroups) are removed
		 * at once per loop. By default the tilescroller calculates this value automatically
		 * by measuring the visible object count and the current scroll speed. If you want
		 * to set this value manually you first have to set <code>autoPurge</code> to false.
		 * <br/>
		 * Setting the optimal value for this depends on the tilegroup amount of the used
		 * tilemap, the scrolling speed and the viewport size. As a general rule of thumb
		 * the more objects are drawn to the screen and the faster the scrolling, the
		 * higher this value needs to be set.
		 * <br/>
		 * If set to 0 the tile engine will remove all off-screen objects on every loop
		 * which can reduce performance.
		 */
		public function get objectPurgeAmount():int
		{
			return _opa;
		}
		public function set objectPurgeAmount(v:int):void
		{
			if (v < 0) v = 0;
			_opa = v;
		}
		
		
		/**
		 * Can be used to disable/enable object (tilegroup) caching. By default any tile
		 * group that is created is cached and re-used later. You don't need to disable
		 * this unless memory consumption is more critical than CPU cycles for you.
		 * 
		 * @default true
		 */
		public function get cacheObjects():Boolean
		{
			return _cacheObjects;
		}
		public function set cacheObjects(v:Boolean):void
		{
			if (v == _cacheObjects) return;
			_cacheObjects = v;
			// TODO
		}
		
		
		/**
		 * The number of objects (tile groups) that are currently being rendered. In other
		 * words, the number of objects that are currently visible on the scroller viewport.
		 */
		public function get visibleObjectCount():int
		{
			return _visibleObjectCount;
		}
		
		
		/**
		 * The number of objects (tile groups) that are currently cached.
		 */
		public function get cachedObjectCount():int
		{
			return _cachedObjectCount;
		}
		
		
		/**
		 * A callback handler that is called after every time a frame is rendered. The callback
		 * function receives one argument which is a reference to this tilescroller.
		 */
		public function get onFrame():Function
		{
			return _onFrame;
		}
		public function set onFrame(v:Function):void
		{
			_onFrame = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Debugging Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the tilegroup buffer is rendered or not. This is only
		 * useful for debugging and should best be left turned off (false). In practice
		 * what the tilescroller does if showBuffer is set to true is that it not only
		 * displays the render buffer but also the underlying tilegroup container which
		 * normally isn't on the display list.
		 */
		public function get showBuffer():Boolean
		{
			return _showBuffer;
		}
		public function set showBuffer(v:Boolean):void
		{
			if (v == _showBuffer) return;
			_showBuffer = v;
			// TODO
		}
		
		
		/**
		 * If set to true the tilescroller renders the boundaries of the currently
		 * used tilemap. This property works only after a tilemap has been supplied
		 * to the tilescroller.
		 */
		public function get showMapBoundaries():Boolean
		{
			return _showMapBoundaries;
		}
		public function set showMapBoundaries(v:Boolean):void
		{
			if (v == _showMapBoundaries) return;
			_showMapBoundaries = v;
			// TODO
		}
		
		
		/**
		 * Determines if tile area boundaries are rendered. Useful for debugging.
		 * Only works after a tilemap has been provided to the scroller.
		 */
		public function get showAreas():Boolean
		{
			return _showAreas;
		}
		public function set showAreas(v:Boolean):void
		{
			if (v == _showAreas) return;
			_showAreas = v;
			// TODO
		}
		
		
		/**
		 * Determines if tilegroup bounding boxes are rendered. Useful for debugging.
		 */
		public function get showBoundingBoxes():Boolean
		{
			return _showBoundingBoxes;
		}
		public function set showBoundingBoxes(v:Boolean):void
		{
			if (v == _showBoundingBoxes) return;
			_showBoundingBoxes = v;
			// TODO
		}
		
		
		/**
		 * A String that can be used to identify the tile area which currently has
		 * it's top-left corner visible on the scroll area. The format of the returned
		 * string is "x0 y0" where X and Y are not pixel coordinates but sequencial
		 * values in x and y order on which tile areas are placed.
		 */
		public function get currentAreaInfo():String
		{
			return "x" + _areaX + " y" + _areaY;
		}
		
		
		/**
		 * A string with IDs of all currently visible areas. Only used for debugging!
		 */
		public function get currentAreasInfo():String
		{
			return "" + _areaX + ":" + _areaY + ""
				+ "  " + (_areaX + 1) + ":" + _areaY + ""
				+ "\n" + _areaX + ":" + (_areaY + 1) + ""
				+ "  " + (_areaX + 1) + ":" + (_areaY + 1) + "";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onTick():void
		{
			updatePosition();
		}
		
		
		/**
		 * @private
		 */
		private function onRender(ticks:uint, ms:uint):void
		{
			if (!_paused)
			{
				draw();
			}
			
			if (_onFrame != null)
			{
				_onFrame(this);
			}
			
			/* Measure current FPS and the time it took to process a frame. */
			/* TODO Might be obsolete since scroller now hooks onto gameloop! */
			_time = getTimer();
			if (_time - 1000 > _msPrev)
			{
				_msPrev = _time;
				_ms = _time - _mss;
				_fps = _frameCount;
				_frameCount = -1;
			}
			_frameCount++;
			_mss = _time;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets up the tilescroller. Called only once after instantiation.
		 * 
		 * @private
		 */
		private function setup():void
		{
			_stage = Main.instance.stage;
			_gameLoop = Main.instance.gameLoop;
			
			_frameRate = _stage.frameRate;
			_scale = 1.0;
			_decel = 0.9;
			_speed = _speedH = _speedV = _speedAvr = 10;
			_speedScaled = _speedHScaled = _speedVScaled = roundSpeed(_speed / _scale);
			_opa = 0;
			_visibleObjectCount = 0;
			_visibleAnimTileCount = 0;
			_cachedObjectCount = 0;
			
			_autoPurge = true;
			_cacheObjects = true;
		}
		
		
		/**
		 * Sets up the view part of the scroller. this is called anytime a new tilemap
		 * is provided to the scroller.
		 * 
		 * @private
		 */
		private function setupView():void
		{
		}
		
		
		/**
		 * Sets up the provided tilemap for use with the tilescroller.
		 * 
		 * @private
		 */
		private function setupTilemap():void
		{
		}
		
		
		/**
		 * Updates the scroll position.
		 * 
		 * @private
		 */
		private function updatePosition():void
		{
		}
		
		
		/**
		 * Draws the current tilescroller frame.
		 * 
		 * @private
		 */
		private function draw():void
		{
		}
		
		
		/**
		 * @private
		 */
		//private function flagVisibleTileGroupsWrap(areaX:int, areaY:int):void
		//{
		//	
		//}
		
		
		/**
		 * Places the specified tilegroup on the render buffer.
		 * 
		 * @private
		 */
		//private function placeTileGroup(g:TileGroup):void
		//{
		//	
		//}
		
		
		/**
		 * Creates a bounding box for the specified tilegroup.
		 * 
		 * @private
		 */
		//private function createBoundingBox(g:TileGroup):void
		//{
		//	g.boundingBox = new Shape();
		//	g.boundingBox.graphics.lineStyle(3, BOUNDINGBOX_COLORS[int(g.id) % 6],
		//		0.5, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
		//	g.boundingBox.graphics.drawRect(0, 0, g.width - 1, g.height - 1);
		//}
		
		
		/**
		 * Forces a redraw of the scroller view on the next frame.
		 * 
		 * @private
		 */
		private function forceRedraw():void
		{
			setTimeout(function():void
			{
				_xPosOld = NaN;
				/* Hopefully we never reach an area of int.MIN_VALUE! However in that
				 * case it would simply not redraw all tilegroups immediately if we'd
				 * resize the viewport. */
				_oldAreaX = int.MIN_VALUE;
			}, _ms);
		}
		
		
		/**
		 * Rounds the speed which can be positive or negative.
		 * 
		 * @private
		 */
		private function roundSpeed(v:Number):int
		{
			if (v > 0) return Math.ceil(v);
			if (v < 0) return Math.floor(v);
			return 0;
		}
	}
}
