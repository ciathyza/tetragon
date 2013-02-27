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
package view.racing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import tetragon.data.sprite.SpriteAtlas;
	import tetragon.input.KeyMode;
	import tetragon.util.display.centerChild;
	import tetragon.view.Screen;
	import tetragon.view.render.buffers.SoftwareRenderBuffer;
	import tetragon.view.render.scroll.ParallaxLayer;
	import tetragon.view.render.scroll.ParallaxScroller;
	import view.racing.constants.COLORS;
	import view.racing.constants.ColorSet;
	import view.racing.constants.ROAD;
	import view.racing.vo.Car;
	import view.racing.vo.PCamera;
	import view.racing.vo.PPoint;
	import view.racing.vo.PScreen;
	import view.racing.vo.PWorld;
	import view.racing.vo.SSprite;
	import view.racing.vo.Segment;




	/**
	 * @author Hexagon
	 */
	public class RacingScreen extends Screen
	{
		// -----------------------------------------------------------------------------------------
		// Constants
		// -----------------------------------------------------------------------------------------
		public static const ID:String = "racingScreen";
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		private var _atlas:SpriteAtlas;
		private var _atlasImage:BitmapData;
		private var _renderBuffer:SoftwareRenderBuffer;
		private var _bufferBitmap:Bitmap;
		private var _sprites:Sprites;
		private var _bgScroller:ParallaxScroller;
		private var _bgLayer1:ParallaxLayer;
		private var _bgLayer2:ParallaxLayer;
		private var _bgLayer3:ParallaxLayer;
		private var _segments:Vector.<Segment>;
		// array of road segments
		private var _cars:Vector.<Car>;
		// array of cars on the road
		private var _bufferWidth:int = 1024;
		private var _bufferHeight:int = 640;
		private var _bufferWidthHalf:int;
		private var _bufferHeightHalf:int;
		private var _dt:Number;
		// how long is each frame (in seconds)
		private var _resolution:Number;
		// scaling factor to provide resolution independence (computed)
		private var _drawDistance:int = 300;
		// number of segments to draw
		private var _hazeDensity:int = 10;
		// exponential fog density
		private var _hazeColor:uint;
		private var _cameraHeight:Number = 1000;
		// z height of camera (500 - 5000)
		private var _cameraDepth:Number;
		// z distance camera is from screen (computed)
		private var _fieldOfView:int = 100;
		// angle (degrees) for field of view (80 - 140)
		private var _bgSpeedMult:Number = 0.001;
		// background sky layer scroll speed when going around curve (or up hill)
		private var _skyOffset:Number = 0;
		// current sky scroll offset
		private var _hillOffset:Number = 0;
		// current hill scroll offset
		private var _treeOffset:Number = 0;
		// current tree scroll offset
		private var _playerX:Number = 0;
		// player x offset from center of road (-1 to 1 to stay independent of roadWidth)
		private var _playerZ:Number;
		// player relative z distance from camera (computed)
		private var _roadWidth:int = 2000;
		// actually half the roads width, easier math if the road spans from -roadWidth to +roadWidth
		private var _segmentLength:int = 200;
		// length of a single segment
		private var _rumbleLength:int = 3;
		// number of segments per red/white rumble strip
		private var _trackLength:int = 200;
		// z length of entire track (computed)
		private var _lanes:int = 3;
		// number of lanes
		private var _totalCars:Number = 200;
		// total number of cars on the road
		private var _accel:Number;
		// acceleration rate - tuned until it 'felt' right
		private var _breaking:Number;
		// deceleration rate when braking
		private var _decel:Number;
		// 'natural' deceleration rate when neither accelerating, nor braking
		private var _offRoadDecel:Number = 0.99;
		// speed multiplier when off road (e.g. you lose 2% speed each update frame)
		private var _offRoadLimit:Number;
		// limit when off road deceleration no longer applies (e.g. you can always go at least this speed even when off road)
		private var _centrifugal:Number = 0.3;
		// centrifugal force multiplier when going around curves
		private var _position:Number;
		// current camera Z position (add playerZ to get player's absolute Z position)
		private var _speed:Number;
		// current speed
		private var _maxSpeed:Number;
		// top speed (ensure we can't move more than 1 segment in a single frame to make collision detection easier)
		private var _currentLapTime:Number = 0;
		// current lap time
		private var _lastLapTime:Number = 0;
		// last lap time
		private var _fast_lap_time:Number;
		private var _isAccelerate:Boolean;
		private var _isBrake:Boolean;
		private var _isSteerLeft:Boolean;
		private var _isSteerRight:Boolean;


		// -----------------------------------------------------------------------------------------
		// Signals
		// -----------------------------------------------------------------------------------------
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
			reset();
			main.statsMonitor.toggle();
			main.gameLoop.start();
		}


		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
		}


		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			super.reset();

			_dt = 1 / main.gameLoop.frameRate;
			_maxSpeed = _segmentLength / _dt;
			_accel = _maxSpeed / 5;
			_breaking = -_maxSpeed;
			_decel = -_maxSpeed / 5;
			_offRoadLimit = _maxSpeed / 4;
			_cameraDepth = 1 / Math.tan((_fieldOfView / 2) * Math.PI / 180);
			_playerZ = (_cameraHeight * _cameraDepth);
			_resolution = 1.6;
			// _bufferHeight / _bufferHeight;
			_position = 0;
			_speed = 0;
			_bufferWidthHalf = _bufferWidth * 0.5;
			_bufferHeightHalf = _bufferHeight * 0.5;
			_cars = new Vector.<Car>();

			_hazeColor = COLORS.HAZE;

			resetRoad();
			resetSprites();
			resetCars();
		}


		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			main.gameLoop.stop();
		}


		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
		}


		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		/**
		 * @inheritDoc
		 */
		override protected function get unload():Boolean
		{
			return true;
		}


		/**
		 * @private
		 */
		private function get lastY():Number
		{
			return (_segments.length == 0) ? 0 : _segments[_segments.length - 1].p2.world.y;
		}


		// -----------------------------------------------------------------------------------------
		// Callback Handlers
		// -----------------------------------------------------------------------------------------
		/**
		 * @inheritDoc
		 */
		override protected function onStageResize():void
		{
			super.onStageResize();
		}


		/**
		 * @private
		 */
		private function onKeyDown(key:String):void
		{
			switch (key)
			{
				case "u":
					_isAccelerate = true;
					break;
				case "d":
					_isBrake = true;
					break;
				case "l":
					_isSteerLeft = true;
					break;
				case "r":
					_isSteerRight = true;
					break;
			}
		}


		/**
		 * @private
		 */
		private function onKeyUp(key:String):void
		{
			switch (key)
			{
				case "u":
					_isAccelerate = false;
					break;
				case "d":
					_isBrake = false;
					break;
				case "l":
					_isSteerLeft = false;
					break;
				case "r":
					_isSteerRight = false;
					break;
			}
		}


		/**
		 * @private
		 */
		private function onTick():void
		{
			var n:int, car:Car, carW:Number, sprite:SSprite, spriteW:Number;
			var playerSegment:Segment = findSegment(_position + _playerZ);
			var playerW:Number = _sprites.PLAYER_STRAIGHT.width * _sprites.SCALE;
			var speedPercent:Number = _speed / _maxSpeed;
			var dx:Number = _dt * 2 * speedPercent;

			// at top speed, should be able to cross from left to right (-1
			// to 1) in 1 second
			var startPosition:Number = _position;

			updateCars(_dt, playerSegment, playerW);

			_position = increase(_position, _dt * _speed, _trackLength);

			if (_isSteerLeft)
				_playerX = _playerX - dx;
			else if (_isSteerRight)
				_playerX = _playerX + dx;

			_playerX = _playerX - (dx * speedPercent * playerSegment.curve * _centrifugal);

			if (_isAccelerate)
				_speed = accelerate(_speed, _accel, _dt);
			else if (_isBrake)
				_speed = accelerate(_speed, _breaking, _dt);
			else
				_speed = accelerate(_speed, _decel, _dt);

			if ((_playerX < -1) || (_playerX > 1))
			{
				if (_speed > _offRoadLimit)
					_speed = accelerate(_speed, _offRoadDecel, _dt);

				for (n = 0; n < playerSegment.sprites.length; n++)
				{
					sprite = playerSegment.sprites[n];
					spriteW = sprite.source.width * _sprites.SCALE;
					if (overlap(_playerX, playerW, sprite.offset + spriteW / 2 * (sprite.offset > 0 ? 1 : -1), spriteW))
					{
						_speed = _maxSpeed / 5;
						_position = increase(playerSegment.p1.world.z, -_playerZ, _trackLength);
						// stop
						// in
						// front
						// of
						// sprite
						// (at
						// front
						// of
						// segment)
						break;
					}
				}
			}

			for (n = 0; n < playerSegment.cars.length; n++)
			{
				car = playerSegment.cars[n];
				carW = car.sprite.source.width * _sprites.SCALE;
				if (_speed > car.speed)
				{
					if (overlap(_playerX, playerW, car.offset, carW, 0.8))
					{
						_speed = car.speed * (car.speed / _speed);
						_position = increase(car.z, -_playerZ, _trackLength);
						break;
					}
				}
			}

			_playerX = limit(_playerX, -3, 3);
			// dont ever let it go too far out of bounds
			_speed = limit(_speed, 0, _maxSpeed);
			// or exceed maxSpeed

			_skyOffset = increase(_skyOffset, _bgSpeedMult * playerSegment.curve * (_position - startPosition) / _segmentLength, 1);
			_hillOffset = increase(_hillOffset, _bgSpeedMult * playerSegment.curve * (_position - startPosition) / _segmentLength, 1);
			_treeOffset = increase(_treeOffset, _bgSpeedMult * playerSegment.curve * (_position - startPosition) / _segmentLength, 1);
			
			if (_position > _playerZ)
			{
				if (_currentLapTime && (startPosition < _playerZ))
				{
					_lastLapTime = _currentLapTime;
					_currentLapTime = 0;
					if (_lastLapTime <= _fast_lap_time)
					{
					}
					else
					{
					}
				}
				else
				{
					_currentLapTime += _dt;
				}
			}
		}


		/**
		 * @private
		 */
		private function onRender(ticks:uint, ms:uint, fps:uint):void
		{
			var baseSegment:Segment = findSegment(_position),
			basePercent:Number = percentRemaining(_position, _segmentLength),
			playerSegment:Segment = findSegment(_position + _playerZ),
			playerPercent:Number = percentRemaining(_position + _playerZ, _segmentLength),
			playerY:int = interpolate(playerSegment.p1.world.y, playerSegment.p2.world.y, playerPercent),
			s:Segment,
			car:Car,
			sprite:SSprite,
			maxY:int = _bufferHeight,
			x:Number = 0,
			dx:Number = -(baseSegment.curve * basePercent),
			i:int,
			j:int,
			spriteScale:Number,
			spriteX:Number,
			spriteY:Number;

			_renderBuffer.clear();

			/* Render background layers. */
			_bgLayer1.offsetFactorX = _skyOffset;
			_bgLayer1.offsetFactorY = _resolution * _bgSpeedMult * playerY;
			_bgLayer2.offsetFactorX = _hillOffset;
			_bgLayer3.offsetFactorX = _treeOffset;
			
			_bgScroller.update();
			_renderBuffer.blitImage(_bgScroller, 0, 0, _bgScroller.width, _bgScroller.height);
			
			/* PHASE 1: render segments, front to back and clip far segments that have been
			 * obscured by already rendered near segments if their projected coordinates are
			 * lower than maxY. */
			for (i = 0; i < _drawDistance; i++)
			{
				s = _segments[(baseSegment.index + i) % _segments.length];
				s.looped = s.index < baseSegment.index;
				/* Apply exponential haze alpha value. */
				s.haze = 1 / (Math.pow(2.718281828459045, ((i / _drawDistance) * (i / _drawDistance) * _hazeDensity)));
				s.clip = maxY;

				project(s.p1, (_playerX * _roadWidth) - x, playerY + _cameraHeight, _position - (s.looped ? _trackLength : 0));
				project(s.p2, (_playerX * _roadWidth) - x - dx, playerY + _cameraHeight, _position - (s.looped ? _trackLength : 0));

				x = x + dx;
				dx = dx + s.curve;

				if ((s.p1.camera.z <= _cameraDepth)		// behind us
				|| (s.p2.screen.y >= s.p1.screen.y)		// back face cull
				|| (s.p2.screen.y >= maxY))				// clip by (already rendered) hill
				{
					continue;
				}

				renderSegment(s.p1.screen.x, s.p1.screen.y, s.p1.screen.w, s.p2.screen.x, s.p2.screen.y, s.p2.screen.w, s.color, s.haze);
				maxY = s.p1.screen.y;
			}

			/* PHASE 2: Back to front render the sprites. */
			for (i = (_drawDistance - 1); i > 0; i--)
			{
				s = _segments[(baseSegment.index + i) % _segments.length];

				/* Render opponent cars. */
				for (j = 0; j < s.cars.length; j++)
				{
					car = s.cars[j];
					sprite = car.sprite;
					spriteScale = interpolate(s.p1.screen.scale, s.p2.screen.scale, car.percent);
					spriteX = interpolate(s.p1.screen.x, s.p2.screen.x, car.percent) + (spriteScale * car.offset * _roadWidth * _bufferWidthHalf);
					spriteY = interpolate(s.p1.screen.y, s.p2.screen.y, car.percent);
					renderSprite(car.sprite.source, spriteScale, spriteX, spriteY, -0.5, -1, s.clip, s.haze);
				}

				/* Render roadside objects. */
				for (j = 0; j < s.sprites.length; j++)
				{
					sprite = s.sprites[j];
					spriteScale = s.p1.screen.scale;
					spriteX = s.p1.screen.x + (spriteScale * sprite.offset * _roadWidth * _bufferWidthHalf);
					spriteY = s.p1.screen.y;
					renderSprite(sprite.source, spriteScale, spriteX, spriteY, (sprite.offset < 0 ? -1 : 0), -1, s.clip, s.haze);
				}

				/* Render the player sprite. */
				if (s == playerSegment)
				{
					/* Calculate player sprite bouncing depending on speed percentage. */
					var bounce:Number = (1.5 * Math.random() * (_speed / _maxSpeed) * _resolution) * randomChoice([-1, 1]);
					var steering:int = _speed * (_isSteerLeft ? -1 : _isSteerRight ? 1 : 0);
					var updown:Number = playerSegment.p2.world.y - playerSegment.p1.world.y;
					var spr:BitmapData;

					if (steering < 0)
					{
						spr = (updown > 0) ? _sprites.PLAYER_UPHILL_LEFT : _sprites.PLAYER_LEFT;
					}
					else if (steering > 0)
					{
						spr = (updown > 0) ? _sprites.PLAYER_UPHILL_RIGHT : _sprites.PLAYER_RIGHT;
					}
					else
					{
						spr = (updown > 0) ? _sprites.PLAYER_UPHILL_STRAIGHT : _sprites.PLAYER_STRAIGHT;
					}

					renderSprite(spr, _cameraDepth / _playerZ, _bufferWidthHalf, (_bufferHeightHalf - (_cameraDepth / _playerZ * interpolate(playerSegment.p1.camera.y, playerSegment.p2.camera.y, playerPercent) * _bufferHeightHalf)) + bounce, -0.5, -1);
				}
			}
		}
		
		
//		private function renderBackground(layer:BitmapData, offsetX:Number = 0.0, offsetY:Number = 0.0):void
//		{
//			var imageW:Number = layer.width / 2;
//			var imageH:Number = layer.height;
//
//			var sourceX:Number = 0 + Math.floor(layer.width * offsetX);
//			var sourceY:Number = 0;
//			var sourceW:Number = Math.min(imageW, 0 + layer.width - sourceX);
//			var sourceH:Number = imageH;
//
//			var destX:Number = 0;
//			var destY:Number = offsetY;
//			var destW:Number = Math.floor(_bufferWidth * (sourceW / imageW));
//			var destH:Number = _bufferHeight;
//			
//			drawImage(layer, sourceX, sourceY, sourceW, sourceH, destX, destY, destW, destH);
//			
//			if (sourceW < imageW)
//			{
//				drawImage(layer, 0, sourceY, imageW - sourceW, sourceH, destW - 1, destY, _bufferWidth - destW, destH);
//			}
//		}
//		
//		
//		private function drawImage(image:BitmapData, sx:Number, sy:Number, sw:Number, sh:Number, dx:Number, dy:Number, dw:Number, dh:Number):void
//		{
//			var b:BitmapData = new BitmapData(dw, dh, false, 0xFF0000);
//			var r:Rectangle = new Rectangle(sx, sy, sw, sh);
//			var p:Point = new Point(dx, dy);
//			b.copyPixels(image, r, p);
//			_renderBuffer.blitImage(b, 0, 0, _bufferWidth, _bufferHeight);
//		}
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		/**
		 * @inheritDoc
		 */
		override protected function setup():void
		{
			super.setup();
		}


		/**
		 * @inheritDoc
		 */
		override protected function registerResources():void
		{
			registerResource("spriteAtlas");
		}


		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			main.keyInputManager.assign("CURSORUP", KeyMode.DOWN, onKeyDown, "u");
			main.keyInputManager.assign("CURSORDOWN", KeyMode.DOWN, onKeyDown, "d");
			main.keyInputManager.assign("CURSORLEFT", KeyMode.DOWN, onKeyDown, "l");
			main.keyInputManager.assign("CURSORRIGHT", KeyMode.DOWN, onKeyDown, "r");
			main.keyInputManager.assign("CURSORUP", KeyMode.UP, onKeyUp, "u");
			main.keyInputManager.assign("CURSORDOWN", KeyMode.UP, onKeyUp, "d");
			main.keyInputManager.assign("CURSORLEFT", KeyMode.UP, onKeyUp, "l");
			main.keyInputManager.assign("CURSORRIGHT", KeyMode.UP, onKeyUp, "r");

			resourceManager.process("spriteAtlas");
			_atlas = getResource("spriteAtlas");
			_atlasImage = _atlas.image;

			prepareSprites();

			_renderBuffer = new SoftwareRenderBuffer(_bufferWidth, _bufferHeight, false, 0x000055);
			_bufferBitmap = new Bitmap(_renderBuffer);

			_bgLayer1 = new ParallaxLayer(_sprites.BG_SKY, 2);
			_bgLayer2 = new ParallaxLayer(_sprites.BG_HILLS, 3);
			_bgLayer3 = new ParallaxLayer(_sprites.BG_TREES, 4);
			
			// TODO add feature to apply fog to bg layer for better realism!
			
			_bgScroller = new ParallaxScroller(_bufferWidth, _sprites.BG_SKY.height);
			_bgScroller.layers = [_bgLayer1, _bgLayer2, _bgLayer3];
		}


		/**
		 * @inheritDoc
		 */
		override protected function registerChildren():void
		{
		}


		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void
		{
			addChild(_bufferBitmap);
		}


		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
			main.gameLoop.tickSignal.add(onTick);
			main.gameLoop.renderSignal.add(onRender);
		}


		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
			main.gameLoop.tickSignal.remove(onTick);
			main.gameLoop.renderSignal.remove(onRender);
		}


		/**
		 * @inheritDoc
		 */
		override protected function executeBeforeStart():void
		{
		}


		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayText():void
		{
		}


		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
			centerChild(_bufferBitmap);
		}


		/**
		 * @private
		 */
		private function prepareSprites():void
		{
			_sprites = new Sprites();
			_sprites.BG_SKY = _atlas.getSprite("bg_sky", 2.0);
			_sprites.BG_HILLS = _atlas.getSprite("bg_hills", 2.0);
			_sprites.BG_TREES = _atlas.getSprite("bg_trees", 2.0);
			_sprites.BILLBOARD01 = _atlas.getSprite("billboard01", 2.5);
			_sprites.BILLBOARD02 = _atlas.getSprite("billboard02", 2.5);
			_sprites.BILLBOARD03 = _atlas.getSprite("billboard03", 2.5);
			_sprites.BILLBOARD04 = _atlas.getSprite("billboard04", 2.5);
			_sprites.BILLBOARD05 = _atlas.getSprite("billboard05", 2.5);
			_sprites.BILLBOARD06 = _atlas.getSprite("billboard06", 2.5);
			_sprites.BILLBOARD07 = _atlas.getSprite("billboard07", 2.5);
			_sprites.BILLBOARD08 = _atlas.getSprite("billboard08", 2.5);
			_sprites.BILLBOARD09 = _atlas.getSprite("billboard09", 2.5);
			_sprites.BOULDER1 = _atlas.getSprite("veg_boulder1", 2.5);
			_sprites.BOULDER2 = _atlas.getSprite("veg_boulder2", 2.5);
			_sprites.BOULDER3 = _atlas.getSprite("veg_boulder3", 2.5);
			_sprites.BUSH1 = _atlas.getSprite("veg_bush1", 2.5);
			_sprites.BUSH2 = _atlas.getSprite("veg_bush2", 2.5);
			_sprites.CACTUS = _atlas.getSprite("veg_cactus", 2.5);
			_sprites.TREE1 = _atlas.getSprite("veg_tree1", 2.5);
			_sprites.TREE2 = _atlas.getSprite("veg_tree2", 2.5);
			_sprites.PALM_TREE = _atlas.getSprite("veg_palmtree", 2.5);
			_sprites.DEAD_TREE1 = _atlas.getSprite("veg_deadtree1", 2.5);
			_sprites.DEAD_TREE2 = _atlas.getSprite("veg_deadtree2", 2.5);
			_sprites.STUMP = _atlas.getSprite("veg_stump", 2.5);
			_sprites.COLUMN = _atlas.getSprite("bldg_column", 3.0);
			_sprites.TOWER = _atlas.getSprite("bldg_tower", 10.0);
			_sprites.BOATHOUSE = _atlas.getSprite("bldg_boathouse", 3.0);
			_sprites.WINDMILL = _atlas.getSprite("bldg_windmill", 4.0);
			_sprites.CAR01 = _atlas.getSprite("car01", 1.25);
			_sprites.CAR02 = _atlas.getSprite("car02", 1.25);
			_sprites.CAR03 = _atlas.getSprite("car03", 1.25);
			_sprites.CAR04 = _atlas.getSprite("car04", 1.25);
			_sprites.TRUCK = _atlas.getSprite("car05", 1.7);
			_sprites.SEMI = _atlas.getSprite("car06", 2.0);
			_sprites.PLAYER_STRAIGHT = _atlas.getSprite("player");
			_sprites.PLAYER_LEFT = _atlas.getSprite("player_left");
			_sprites.PLAYER_RIGHT = _atlas.getSprite("player_right");
			_sprites.PLAYER_UPHILL_STRAIGHT = _atlas.getSprite("player_uphill");
			_sprites.PLAYER_UPHILL_LEFT = _atlas.getSprite("player_uphill_left");
			_sprites.PLAYER_UPHILL_RIGHT = _atlas.getSprite("player_uphill_right");

			_sprites.REGION_SKY = _atlas.getRegion("bg_sky");
			_sprites.REGION_HILLS = _atlas.getRegion("bg_hills");
			_sprites.REGION_TREES = _atlas.getRegion("bg_trees");

			_sprites.init();
		}


		// -----------------------------------------------------------------------------------------
		// ROAD GEOMETRY CONSTRUCTION
		// -----------------------------------------------------------------------------------------
		/**
		 * @private
		 */
		private function resetRoad():void
		{
			_segments = new Vector.<Segment>();

			addStraight(ROAD.LENGTH.SHORT / 2);
			addHill(ROAD.LENGTH.SHORT, ROAD.HILL.LOW);
			addLowRollingHills();
			addSCurves();
			addCurve(ROAD.LENGTH.MEDIUM, ROAD.CURVE.MEDIUM, ROAD.HILL.LOW);
			addBumps();
			addLowRollingHills();
			addCurve(ROAD.LENGTH.LONG, ROAD.CURVE.MEDIUM, ROAD.HILL.MEDIUM);
			addStraight();
			addCurve(ROAD.LENGTH.LONG, -ROAD.CURVE.MEDIUM, ROAD.HILL.MEDIUM);
			addHill(ROAD.LENGTH.LONG, ROAD.HILL.HIGH);
			addCurve(ROAD.LENGTH.LONG, ROAD.CURVE.MEDIUM, -ROAD.HILL.LOW);
			addHill(ROAD.LENGTH.LONG, -ROAD.HILL.MEDIUM);
			addStraight();
			addDownhillToEnd();

			_segments[findSegment(_playerZ).index + 2].color = COLORS.START;
			_segments[findSegment(_playerZ).index + 3].color = COLORS.START;

			for (var n:uint = 0 ; n < _rumbleLength ; n++)
			{
				_segments[_segments.length - 1 - n].color = COLORS.FINISH;
			}

			_trackLength = _segments.length * _segmentLength;
		}


		/**
		 * @private
		 */
		private function resetSprites():void
		{
			var i:int;
			var j:int;
			var side:Number;
			var sprite:BitmapData;
			var offset:Number;
			var density:int = 10;

			/* Add row of billboards right after start line. */
			addSprite(20, _sprites.BILLBOARD07, -1);
			addSprite(40, _sprites.BILLBOARD06, -1);
			addSprite(60, _sprites.BILLBOARD08, -1);
			addSprite(80, _sprites.BILLBOARD09, -1);
			addSprite(100, _sprites.BILLBOARD01, -1);
			addSprite(120, _sprites.BILLBOARD02, -1);
			addSprite(140, _sprites.BILLBOARD03, -1);
			addSprite(160, _sprites.BILLBOARD04, -1);
			addSprite(180, _sprites.BILLBOARD05, -1);
			addSprite(240, _sprites.BILLBOARD07, -1.2);
			addSprite(240, _sprites.BILLBOARD06, 1.2);

			/* Add some billboards at end of track. */
			addSprite(_segments.length - 25, _sprites.BILLBOARD07, -1.2);
			addSprite(_segments.length - 25, _sprites.BILLBOARD06, 1.2);

			/* Add palm trees at start of track. */
			addSprites(_sprites.PALM_TREE, 10, 200, null, 4, 100, 0.5, 0.5);
			addSprites(_sprites.PALM_TREE, 10, 200, null, 4, 100, 1, 2);

			/* Add a long row of columns on right side and trees on left side. */
			addSprites(_sprites.COLUMN, 250, 1000, null, 5, 0, 1.1);
			addSprites(_sprites.TREE1, 250, 1000, [0, 5], 8, 0, -1, 2, "sub");
			addSprites(_sprites.TREE2, 250, 1000, [0, 5], 8, 0, -1, 2, "sub");

			// TODO
			for (i = 200; i < _segments.length; i += 3)
			{
				addSprite(i, randomChoice(_sprites.VEGETATION), randomChoice([1, -1]) * (2 + Math.random() * 5));
			}

			for (i = 1600; i < _segments.length; i += 20)
			{
				addSprite(i, randomChoice(_sprites.BUILDINGS), randomChoice([1, -1]) * (2 + Math.random() * 5));
			}

			for (i = 1000; i < (_segments.length - 50); i += 100)
			{
				side = randomChoice([1, -1]);
				addSprite(i + randomInt(0, 50), randomChoice(_sprites.BILLBOARDS), -side);
				for (j = 0 ; j < 20 ; j++)
				{
					sprite = randomChoice(_sprites.VEGETATION);
					offset = side * (1.5 + Math.random());
					addSprite(i + randomInt(0, 50), sprite, offset);
				}
			}
		}


		/**
		 * @param sprite The sprite to add.
		 * @param start The start segment number.
		 * @param end The end segment number.
		 * 
		 * @private
		 */
		private function addSprites(sprite:BitmapData, start:int, end:int, segmentRandRange:Array, stepSize:int, stepInc:int, offset:Number, postOffset:Number = 0.0, offsetMode:String = "add"):void
		{
			for (var i:int = start; i < end; i += stepSize + int(i / stepInc))
			{
				if (postOffset == 0.0)
				{
					if (segmentRandRange) addSprite(i + randomInt(segmentRandRange[0], segmentRandRange[1]), sprite, offset);
					else addSprite(i, sprite, offset);
				}
				else
				{
					var offs:Number = offset;
					if (offsetMode == "add") offs = offset + Math.random() * postOffset;
					else if (offsetMode == "sub") offs = offset - Math.random() * postOffset;
					if (segmentRandRange) addSprite(i + randomInt(segmentRandRange[0], segmentRandRange[1]), sprite, offs);
					else addSprite(i, sprite, offset + Math.random() * postOffset);
				}
			}
		}


		/**
		 * @private
		 */
		private function addSprite(segNum:int, sprite:BitmapData, offset:Number):void
		{
			var s:SSprite = new SSprite(sprite, offset);
			_segments[segNum].sprites.push(s);
		}


		/**
		 * @private
		 */
		private function resetCars():void
		{
			var i:int,
			offset:Number,
			z:Number,
			speed:Number,
			car:Car,
			segment:Segment,
			sprite:BitmapData;

			for (i = 0; i < _totalCars; i++)
			{
				offset = Math.random() * randomChoice([-0.8, 0.8]);
				z = int(Math.random() * _segments.length) * _segmentLength;
				sprite = randomChoice(_sprites.CARS);
				speed = _maxSpeed / 4 + Math.random() * _maxSpeed / (sprite == _sprites.SEMI ? 4 : 2);
				car = new Car(offset, z, new SSprite(sprite), speed);
				segment = findSegment(car.z);
				segment.cars.push(car);
				_cars.push(car);
			}
		}


		/**
		 * @private
		 */
		private function addStraight(num:int = ROAD.LENGTH.MEDIUM):void
		{
			addRoad(num, num, num, 0, 0);
		}


		/**
		 * @private
		 */
		private function addCurve(num:int = ROAD.LENGTH.MEDIUM, curve:int = ROAD.CURVE.MEDIUM, height:int = ROAD.HILL.NONE):void
		{
			addRoad(num, num, num, curve, height);
		}


		/**
		 * @private
		 */
		private function addSCurves():void
		{
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.EASY);
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.CURVE.MEDIUM);
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.CURVE.EASY);
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.EASY);
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.MEDIUM);
		}


		/**
		 * @private
		 */
		private function addHill(num:int = ROAD.LENGTH.MEDIUM, height:int = ROAD.HILL.MEDIUM):void
		{
			addRoad(num, num, num, 0, height);
		}


		/**
		 * @private
		 */
		private function addLowRollingHills(num:int = ROAD.LENGTH.SHORT, height:int = ROAD.HILL.LOW):void
		{
			addRoad(num, num, num, 0, height / 2);
			addRoad(num, num, num, 0, -height);
			addRoad(num, num, num, ROAD.CURVE.EASY, height);
			addRoad(num, num, num, 0, 0);
			addRoad(num, num, num, -ROAD.CURVE.EASY, height / 2);
			addRoad(num, num, num, 0, 0);
		}


		/**
		 * @private
		 */
		private function addBumps():void
		{
			addRoad(10, 10, 10, 0, 5);
			addRoad(10, 10, 10, 0, -2);
			addRoad(10, 10, 10, 0, -5);
			addRoad(10, 10, 10, 0, 8);
			addRoad(10, 10, 10, 0, 5);
			addRoad(10, 10, 10, 0, -7);
			addRoad(10, 10, 10, 0, 5);
			addRoad(10, 10, 10, 0, -2);
		}


		/**
		 * @private
		 */
		private function addDownhillToEnd(num:int = 200):void
		{
			addRoad(num, num, num, -ROAD.CURVE.EASY, -lastY / _segmentLength);
		}


		/**
		 * @private
		 */
		private function addRoad(enter:int, hold:int, leave:int, curve:Number, y:Number = NaN):void
		{
			var startY:Number = lastY;
			var endY:Number = startY + (int(y) * _segmentLength);
			var total:uint = enter + hold + leave;
			var i:uint;

			for (i = 0; i < enter; i++)
			{
				addSegment(easeIn(0, curve, i / enter), easeInOut(startY, endY, i / total));
			}
			for (i = 0; i < hold; i++)
			{
				addSegment(curve, easeInOut(startY, endY, (enter + i) / total));
			}
			for (i = 0; i < leave; i++)
			{
				addSegment(easeInOut(curve, 0, i / leave), easeInOut(startY, endY, (enter + hold + i) / total));
			}
		}


		/**
		 * @private
		 */
		private function addSegment(curve:Number, y:Number):void
		{
			var i:uint = _segments.length;
			var segment:Segment = new Segment();
			segment.index = i;
			segment.p1 = new PPoint(new PWorld(lastY, i * _segmentLength), new PCamera(), new PScreen());
			segment.p2 = new PPoint(new PWorld(y, (i + 1) * _segmentLength), new PCamera(), new PScreen());
			segment.curve = curve;
			segment.sprites = new Vector.<SSprite>();
			segment.cars = new Vector.<Car>();
			segment.color = int(i / _rumbleLength) % 2 ? COLORS.DARK : COLORS.LIGHT;
			_segments.push(segment);
		}


		/**
		 * @private
		 */
		private function findSegment(z:Number):Segment
		{
			return _segments[int(z / _segmentLength) % _segments.length];
		}


		/**
		 * @private
		 */
		private function updateCars(dt:Number, playerSegment:Segment, playerW:Number):void
		{
			var n:int;
			var car:Car;
			var oldSegment:Segment;
			var newSegment:Segment;

			for (n = 0; n < _cars.length; n++)
			{
				car = _cars[n];
				oldSegment = findSegment(car.z);
				car.offset = car.offset + updateCarOffset(car, oldSegment, playerSegment, playerW);
				car.z = increase(car.z, dt * car.speed, _trackLength);
				car.percent = percentRemaining(car.z, _segmentLength);
				// useful for interpolation during rendering phase
				newSegment = findSegment(car.z);

				if (oldSegment != newSegment)
				{
					var index:int = oldSegment.cars.indexOf(car);
					oldSegment.cars.splice(index, 1);
					newSegment.cars.push(car);
				}
			}
		}


		/**
		 * @private
		 */
		private function updateCarOffset(car:Car, carSegment:Segment, playerSegment:Segment, playerW:Number):Number
		{
			var i:int;
			var j:int;
			var dir:Number;
			var segment:Segment;
			var otherCar:Car;
			var otherCarW:Number;
			var lookahead:int = 20;
			var carW:Number = car.sprite.source.width * _sprites.SCALE;

			/* Optimization: dont bother steering around other cars when 'out of sight'
			 * of the player. */
			if ((carSegment.index - playerSegment.index) > _drawDistance) return 0;

			for (i = 1; i < lookahead; i++)
			{
				segment = _segments[(carSegment.index + i) % _segments.length];

				/* Car drive-around player AI */
				if ((segment === playerSegment) && (car.speed > _speed) && (overlap(_playerX, playerW, car.offset, carW, 1.2)))
				{
					if (_playerX > 0.5) dir = -1;
					else if (_playerX < -0.5) dir = 1;
					else dir = (car.offset > _playerX) ? 1 : -1;
					// The closer the cars (smaller i) and the greater the speed ratio,
					// the larger the offset.
					return dir * 1 / i * (car.speed - _speed) / _maxSpeed;
				}

				/* Car drive-around other car AI */
				for (j = 0; j < segment.cars.length; j++)
				{
					otherCar = segment.cars[j];
					otherCarW = otherCar.sprite.source.width * _sprites.SCALE;
					if ((car.speed > otherCar.speed) && overlap(car.offset, carW, otherCar.offset, otherCarW, 1.2))
					{
						if (otherCar.offset > 0.5) dir = -1;
						else if (otherCar.offset < -0.5) dir = 1;
						else dir = (car.offset > otherCar.offset) ? 1 : -1;
						return dir * 1 / i * (car.speed - otherCar.speed) / _maxSpeed;
					}
				}
			}

			// if no cars ahead, but car has somehow ended up off road, then steer back on.
			if (car.offset < -0.9) return 0.1;
			else if (car.offset > 0.9) return -0.1;
			else return 0;
		}


		// -----------------------------------------------------------------------------------------
		// Util Functions
		// -----------------------------------------------------------------------------------------
		
		private function increase(start:Number, increment:Number, max:Number):Number
		{
			var result:Number = start + increment;
			while (result >= max) result -= max;
			while (result < 0) result += max;
			return result;
		}


		private function accelerate(v:Number, accel:Number, dt:Number):Number
		{
			return v + (accel * dt);
		}


		private function limit(value:Number, min:Number, max:Number):Number
		{
			return mathMax(min, mathMin(value, max));
		}


		private function project(p:PPoint, cameraX:Number, cameraY:Number, cameraZ:Number):void
		{
			p.camera.x = (p.world.x || 0) - cameraX;
			p.camera.y = (p.world.y || 0) - cameraY;
			p.camera.z = (p.world.z || 0) - cameraZ;
			p.screen.scale = _cameraDepth / p.camera.z;
			p.screen.x = mathRound(_bufferWidthHalf + (p.screen.scale * p.camera.x * _bufferWidthHalf));
			p.screen.y = mathRound(_bufferHeightHalf - (p.screen.scale * p.camera.y * _bufferHeightHalf));
			p.screen.w = mathRound((p.screen.scale * _roadWidth * _bufferWidthHalf));
		}


		private function getRumbleWidth(projectedRoadWidth:Number):Number
		{
			return projectedRoadWidth / mathMax(6, 2 * _lanes);
		}


		private function getLaneMarkerWidth(projectedRoadWidth:Number):Number
		{
			return projectedRoadWidth / mathMax(32, 8 * _lanes);
		}


		private function interpolate(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * percent;
		}


		private function randomInt(min:int, max:int):int
		{
			return mathRound(interpolate(min, max, Math.random()));
		}


		private function randomChoice(a:Array):*
		{
			return a[randomInt(0, a.length - 1)];
		}


		private function easeIn(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * Math.pow(percent, 2);
		}


		// private static function easeOut(a:Number, b:Number, percent:Number):Number
		// {
		// return a + (b - a) * (1 - Math.pow(1 - percent, 2));
		// }
		private function easeInOut(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * ((-Math.cos(percent * 3.141592653589793) / 2) + 0.5);
		}


		private function percentRemaining(n:Number, total:Number):Number
		{
			return (n % total) / total;
		}


		private function overlap(x1:Number, w1:Number, x2:Number, w2:Number, percent:Number = 1.0):Boolean
		{
			var half:Number = percent * 0.5;
			/* return !((max1 < min2) || (min1 > max2)) */
			return !(((x1 + (w1 * half)) < (x2 - (w2 * half))) || ((x1 - (w1 * half)) > (x2 + (w2 * half))));
		}


		private function mathMax(a:Number, b:Number):Number
		{
			return (a > b) ? a : b;
		}


		private function mathMin(a:Number, b:Number):Number
		{
			return (a < b) ? a : b;
		}


		private function mathRound(n:Number):int
		{
			return n + (n < 0 ? -0.5 : +0.5) >> 0;
		}


		// -----------------------------------------------------------------------------------------
		// Render Functions
		// -----------------------------------------------------------------------------------------
		/**
		 * Renders a segment.
		 * 
		 * @param x1
		 * @param y1
		 * @param w1
		 * @param x2
		 * @param y2
		 * @param w2
		 * @param color
		 * @param hazeAlpha
		 */
		private function renderSegment(x1:int, y1:int, w1:int, x2:int, y2:int, w2:int, color:ColorSet, hazeAlpha:Number):void
		{
			/* Calculate rumble widths for current segment. */
			var r1:Number = getRumbleWidth(w1), r2:Number = getRumbleWidth(w2);

			/* Draw offroad area segment. */
			_renderBuffer.blitRect(0, y2, _bufferWidth, y1 - y2, color.grass, _hazeColor, hazeAlpha);

			/* Draw the road segment. */
			_renderBuffer.drawQuad(x1 - w1 - r1, y1, x1 - w1, y1, x2 - w2, y2, x2 - w2 - r2, y2, color.rumble, _hazeColor, hazeAlpha);
			_renderBuffer.drawQuad(x1 + w1 + r1, y1, x1 + w1, y1, x2 + w2, y2, x2 + w2 + r2, y2, color.rumble, _hazeColor, hazeAlpha);
			_renderBuffer.drawQuad(x1 - w1, y1, x1 + w1, y1, x2 + w2, y2, x2 - w2, y2, color.road, _hazeColor, hazeAlpha);

			/* Draw lane strips. */
			if (color.lane > 0)
			{
				var l1:Number = getLaneMarkerWidth(w1),
				l2:Number = getLaneMarkerWidth(w2),
				lw1:Number = w1 * 2 / _lanes,
				lw2:Number = w2 * 2 / _lanes,
				lx1:Number = x1 - w1 + lw1,
				lx2:Number = x2 - w2 + lw2;

				for (var lane:int = 1 ;lane < _lanes; lx1 += lw1, lx2 += lw2, lane++)
				{
					_renderBuffer.drawQuad(lx1 - l1 / 2, y1, lx1 + l1 / 2, y1, lx2 + l2 / 2, y2, lx2 - l2 / 2, y2, color.lane, _hazeColor, hazeAlpha);
				}
			}
		}


		/**
		 * Renders a sprite onto the render buffer.
		 * 
		 * @param sprite
		 * @param scale
		 * @param destX
		 * @param destY
		 * @param offsetX
		 * @param offsetY
		 * @param clipY
		 * @param hazeAlpha
		 */
		private function renderSprite(sprite:BitmapData, scale:Number, destX:int, destY:int, offsetX:Number = 0.0, offsetY:Number = 0.0, clipY:Number = 0.0, hazeAlpha:Number = 1.0):void
		{
			/* Scale for projection AND relative to roadWidth. */
			var destW:int = (sprite.width * scale * _bufferWidthHalf) * (_sprites.SCALE * _roadWidth);
			var destH:int = (sprite.height * scale * _bufferWidthHalf) * (_sprites.SCALE * _roadWidth);

			destX = destX + (destW * offsetX);
			destY = destY + (destH * offsetY);

			var clipH:int = clipY ? mathMax(0, destY + destH - clipY) : 0;

			if (clipH < destH)
			{
				_renderBuffer.drawImage(sprite, destX, destY, destW, destH - clipH, destW / sprite.width, _hazeColor, hazeAlpha);
			}
		}
	}
}
