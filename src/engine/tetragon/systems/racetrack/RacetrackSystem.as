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
package tetragon.systems.racetrack
{
	import tetragon.Main;
	import tetragon.data.atlas.Atlas;
	import tetragon.systems.racetrack.constants.COLORS;
	import tetragon.systems.racetrack.constants.ColorSet;
	import tetragon.systems.racetrack.constants.ROAD;
	import tetragon.systems.racetrack.vo.Car;
	import tetragon.systems.racetrack.vo.PCamera;
	import tetragon.systems.racetrack.vo.PPoint;
	import tetragon.systems.racetrack.vo.PScreen;
	import tetragon.systems.racetrack.vo.PWorld;
	import tetragon.systems.racetrack.vo.SSprite;
	import tetragon.systems.racetrack.vo.Segment;
	import tetragon.view.render.buffers.IRenderBuffer;
	import tetragon.view.render.buffers.Render2DRenderBuffer;
	import tetragon.view.render.buffers.SoftwareRenderBuffer;
	import tetragon.view.render.scroll.ParallaxLayer;
	import tetragon.view.render.scroll.ParallaxScroller;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	/**
	 * @author Hexagon
	 */
	public class RacetrackSystem
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		private var _useRender2D:Boolean;
		
		private var _renderBuffer:IRenderBuffer;
		private var _renderBitmap:Bitmap;
		private var _atlas:Atlas;
		private var _bgScroller:ParallaxScroller;
		private var _bgLayers:Vector.<ParallaxLayer>;
		
		private var _sprites:Sprites;
		private var _segments:Vector.<Segment>;	// array of road segments
		private var _opponents:Vector.<Car>;	// array of cars on the road
		
		private var _bgColor:uint;
		
		private var _width:int;
		private var _height:int;
		private var _widthHalf:int;
		private var _heightHalf:int;
		
		private var _dt:Number;					// how long is each frame (in seconds)
		private var _resolution:Number;			// scaling factor to provide resolution independence (computed)
		private var _drawDistance:int;			// number of segments to draw
		private var _hazeDensity:int;			// exponential haze density
		private var _hazeColor:uint;
		
		private var _cameraHeight:Number;		// z height of camera (500 - 5000)
		private var _cameraDepth:Number;		// z distance camera is from screen (computed)
		private var _fieldOfView:int;			// angle (degrees) for field of view (80 - 140)
		private var _bgSpeedMult:Number;
		
		private var _roadWidth:int;				// actually half the roads width, easier math if the road spans from -roadWidth to +roadWidth
		private var _segmentLength:int;			// length of a single segment
		private var _rumbleLength:int;			// number of segments per red/white rumble strip
		private var _trackLength:int;			// z length of entire track (computed)
		private var _lanes:int;					// number of lanes
		private var _opponentsTotal:int;		// total number of cars on the road
		
		private var _acceleration:Number;		// acceleration rate - tuned until it 'felt' right
		private var _deceleration:Number;		// 'natural' deceleration rate when neither accelerating, nor braking
		private var _braking:Number;			// deceleration rate when braking
		private var _offRoadDecel:Number;		// speed multiplier when off road (e.g. you lose 2% speed each update frame)
		private var _offRoadLimit:Number;		// limit when off road deceleration no longer applies (e.g. you can always go at least this speed even when off road)
		private var _centrifugal:Number;		// centrifugal force multiplier when going around curves
		
		private var _playerX:Number;			// player x offset from center of road (-1 to 1 to stay independent of roadWidth)
		private var _playerY:int;				// player x offset from center of road (-1 to 1 to stay independent of roadWidth)
		private var _playerZ:Number;			// player relative z distance from camera (computed)
		
		private var _position:Number;			// current camera Z position (add playerZ to get player's absolute Z position)
		private var _speed:Number;				// current speed
		private var _maxSpeed:Number;			// top speed (ensure we can't move more than 1 segment in a single frame to make collision detection easier)
		
		private var _currentLapTime:Number;		// current lap time
		private var _lastLapTime:Number;		// last lap time
		private var _fastestLapTime:Number;
		
		private var _isAccelerating:Boolean;
		private var _isBraking:Boolean;
		private var _isSteeringLeft:Boolean;
		private var _isSteeringRight:Boolean;
		
		
		// -----------------------------------------------------------------------------------------
		// Signals
		// -----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param width
		 * @param height
		 * @param atlas
		 * @param backgroundColor
		 */
		public function RacetrackSystem(width:int, height:int, atlas:Atlas,
			useRender2D:Boolean, backgroundColor:uint = 0x000055)
		{
			_width = width;
			_height = height;
			_atlas = atlas;
			_useRender2D = useRender2D;
			_bgColor = backgroundColor;
			
			if (!_useRender2D) init();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function init():void
		{
			setup();
			prepareSprites();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function reset():void
		{
			_dt = 1 / Main.instance.gameLoop.frameRate;
			_maxSpeed = _segmentLength / _dt;
			_acceleration = _maxSpeed / 5;
			_braking = -_maxSpeed;
			_deceleration = -_maxSpeed / 5;
			_offRoadLimit = _maxSpeed / 4;
			_cameraDepth = 1 / Math.tan((_fieldOfView / 2) * Math.PI / 180);
			_playerZ = (_cameraHeight * _cameraDepth);
			_resolution = 1.6; // _bufferHeight / _bufferHeight;
			_position = 0;
			_speed = 0;
			_widthHalf = _width * 0.5;
			_heightHalf = _height * 0.5;
			_opponents = new Vector.<Car>();

			_hazeColor = COLORS.HAZE;
			
			_currentLapTime = 0.0;
			_lastLapTime = 0.0;
			_fastestLapTime = 0.0;

			resetRoad();
			resetSprites();
			resetOpponents();
		}
		
		
		/**
		 * Ticks the racetrack non-render logic.
		 */
		public function tick():void
		{
			var i:int,
				car:Car,
				carW:Number,
				sprite:SSprite,
				spriteW:Number,
				playerSegment:Segment = findSegment(_position + _playerZ),
				playerW:Number = _sprites.PLAYER_STRAIGHT.width * _sprites.SCALE,
				speedPercent:Number = _speed / _maxSpeed,
				dx:Number = _dt * 2 * speedPercent,
				startPosition:Number = _position,
				bgLayer:ParallaxLayer;
			
			updateOpponents(_dt, playerSegment, playerW);
			_position = increase(_position, _dt * _speed, _trackLength);
			
			/* Update left/right steering. */
			if (_isSteeringLeft) _playerX = _playerX - dx;
			else if (_isSteeringRight) _playerX = _playerX + dx;
			
			_playerX = _playerX - (dx * speedPercent * playerSegment.curve * _centrifugal);
			
			/* Update acceleration & decceleration. */
			if (_isAccelerating) _speed = accel(_speed, _acceleration, _dt);
			else if (_isBraking) _speed = accel(_speed, _braking, _dt);
			else _speed = accel(_speed, _deceleration, _dt);
			
			/* Check if player drives onto off-road area. */
			if ((_playerX < -1) || (_playerX > 1))
			{
				if (_speed > _offRoadLimit)
				{
					_speed = accel(_speed, _offRoadDecel, _dt);
				}
				/* Check player collision with opponents. */
				for (i = 0; i < playerSegment.sprites.length; i++)
				{
					sprite = playerSegment.sprites[i];
					spriteW = sprite.source.width * _sprites.SCALE;
					if (overlap(_playerX, playerW, sprite.offset + spriteW / 2 * (sprite.offset > 0 ? 1 : -1), spriteW))
					{
						_speed = _maxSpeed / 5;
						/* Stop in front of sprite (at front of segment). */
						_position = increase(playerSegment.p1.world.z, -_playerZ, _trackLength);
						break;
					}
				}
			}
			
			for (i = 0; i < playerSegment.cars.length; i++)
			{
				car = playerSegment.cars[i];
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
			
			_playerX = limit(_playerX, -3, 3);		// Don't ever let it go too far out of bounds
			_speed = limit(_speed, 0, _maxSpeed);	// or exceed maxSpeed.
			
			/* Calculate scroll offsets for BG layers. */
			if (_bgLayers)
			{
				for (i = 0; i < _bgLayers.length; i++)
				{
					bgLayer = _bgLayers[i];
					bgLayer.offsetFactorX = increase(bgLayer.offsetFactorX, _bgSpeedMult * playerSegment.curve * (_position - startPosition) / _segmentLength, 1.0);
					bgLayer.offsetFactorY = _resolution * _bgSpeedMult * _playerY;
				}
			}
			
			/* Update track time stats. */
			if (_position > _playerZ)
			{
				if (_currentLapTime && (startPosition < _playerZ))
				{
					_lastLapTime = _currentLapTime;
					_currentLapTime = 0;
					if (_lastLapTime <= _fastestLapTime)
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
		 * Renders the racetrack.
		 */
		public function render():void
		{
			var baseSegment:Segment = findSegment(_position),
				basePercent:Number = percentRemaining(_position, _segmentLength),
				playerSegment:Segment = findSegment(_position + _playerZ),
				playerPercent:Number = percentRemaining(_position + _playerZ, _segmentLength),
				s:Segment,
				car:Car,
				sprite:SSprite,
				maxY:int = _height,
				x:Number = 0,
				dx:Number = -(baseSegment.curve * basePercent),
				i:int,
				j:int,
				spriteScale:Number,
				spriteX:Number,
				spriteY:Number;
			
			_playerY = interpolate(playerSegment.p1.world.y, playerSegment.p2.world.y, playerPercent);
			
			_renderBuffer.clear();
			
			/* Update background layers and blit them to render buffer. */
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

				project(s.p1, (_playerX * _roadWidth) - x, _playerY + _cameraHeight, _position - (s.looped ? _trackLength : 0));
				project(s.p2, (_playerX * _roadWidth) - x - dx, _playerY + _cameraHeight, _position - (s.looped ? _trackLength : 0));

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
					spriteX = interpolate(s.p1.screen.x, s.p2.screen.x, car.percent) + (spriteScale * car.offset * _roadWidth * _widthHalf);
					spriteY = interpolate(s.p1.screen.y, s.p2.screen.y, car.percent);
					renderSprite(car.sprite.source, spriteScale, spriteX, spriteY, -0.5, -1, s.clip, s.haze);
				}

				/* Render roadside objects. */
				for (j = 0; j < s.sprites.length; j++)
				{
					sprite = s.sprites[j];
					spriteScale = s.p1.screen.scale;
					spriteX = s.p1.screen.x + (spriteScale * sprite.offset * _roadWidth * _widthHalf);
					spriteY = s.p1.screen.y;
					renderSprite(sprite.source, spriteScale, spriteX, spriteY, (sprite.offset < 0 ? -1 : 0), -1, s.clip, s.haze);
				}

				/* Render the player sprite. */
				if (s == playerSegment)
				{
					/* Calculate player sprite bouncing depending on speed percentage. */
					var bounce:Number = (1.5 * Math.random() * (_speed / _maxSpeed) * _resolution) * randomChoice([-1, 1]);
					var steering:int = _speed * (_isSteeringLeft ? -1 : _isSteeringRight ? 1 : 0);
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

					renderSprite(spr, _cameraDepth / _playerZ, _widthHalf, (_heightHalf - (_cameraDepth / _playerZ * interpolate(playerSegment.p1.camera.y, playerSegment.p2.camera.y, playerPercent) * _heightHalf)) + bounce, -0.5, -1);
				}
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		public function get width():int
		{
			return _width;
		}
		public function set width(v:int):void
		{
			_width = v;
		}
		
		
		public function get height():int
		{
			return _height;
		}
		public function set height(v:int):void
		{
			_height = v;
		}
		
		
		/**
		 * An array of ParallaxLayer objects. Internally the layers are stored in
		 * a vector.
		 */
		public function get backgroundLayers():Array
		{
			if (!_bgLayers) return null;
			var a:Array = [];
			for (var i:uint = 0; i < _bgLayers.length; i++)
			{
				a.push(_bgLayers[i]);
			}
			return a;
		}
		public function set backgroundLayers(v:Array):void
		{
			if (!v)
			{
				_bgLayers = null;
			}
			else
			{
				_bgLayers = new Vector.<ParallaxLayer>(v.length, true);
				for (var i:uint = 0; i < _bgLayers.length; i++)
				{
					var layer:ParallaxLayer = v[i];
					if (!layer || !layer.source) continue;
					_bgLayers[i] = layer;
				}
				if (_bgScroller) _bgScroller.layers = v;
			}
		}
		
		
		/**
		 * Determines the number of road segments to draw.
		 * 
		 * @default 300
		 */
		public function get drawDistance():int
		{
			return _drawDistance;
		}
		public function set drawDistance(v:int):void
		{
			_drawDistance = v;
		}
		
		
		/**
		 * Determines haze color.
		 */
		public function get hazeColor():uint
		{
			return _hazeColor;
		}
		public function set hazeColor(v:uint):void
		{
			_hazeColor = v;
		}
		
		
		/**
		 * The exponential density of haze.
		 * 
		 * @default 10
		 */
		public function get hazeDensity():int
		{
			return _hazeDensity;
		}
		public function set hazeDensity(v:int):void
		{
			_hazeDensity = v;
		}
		
		
		/**
		 * Z height of camera (usable range is 500 - 5000).
		 * 
		 * @default 1000
		 */
		public function get cameraHeight():Number
		{
			return _cameraHeight;
		}
		public function set cameraHeight(v:Number):void
		{
			_cameraHeight = v;
		}
		
		
		/**
		 * Angle (degrees) for field of view (usable range is 80 - 140).
		 * 
		 * @default 100
		 */
		public function get fieldOfView():int
		{
			return _fieldOfView;
		}
		public function set fieldOfView(v:int):void
		{
			_fieldOfView = v;
		}
		
		
		/**
		 * The color with that the render buffer is cleared before each frame render.
		 */
		public function get backgroundColor():uint
		{
			return _bgColor;
		}
		public function set backgroundColor(v:uint):void
		{
			_bgColor = v;
			if (_renderBuffer) _renderBuffer.fillColor = _bgColor;
		}
		
		
		/**
		 * The bitmap onto which the racetrack is rendered.
		 */
		public function get renderBitmap():Bitmap
		{
			return _renderBitmap;
		}
		
		
		public function get isAccelerating():Boolean
		{
			return _isAccelerating;
		}
		public function set isAccelerating(v:Boolean):void
		{
			_isAccelerating = v;
		}
		
		
		public function get isBraking():Boolean
		{
			return _isBraking;
		}
		public function set isBraking(v:Boolean):void
		{
			_isBraking = v;
		}
		
		
		public function get isSteeringLeft():Boolean
		{
			return _isSteeringLeft;
		}
		public function set isSteeringLeft(v:Boolean):void
		{
			_isSteeringLeft = v;
		}
		
		
		public function get isSteeringRight():Boolean
		{
			return _isSteeringRight;
		}
		public function set isSteeringRight(v:Boolean):void
		{
			_isSteeringRight = v;
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
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function setup():void
		{
			/* Set default. */
			_drawDistance = 300;
			_hazeDensity = 10;
			_hazeColor = 0x333333;
			_cameraHeight = 1000;
			_fieldOfView = 100;
			_bgSpeedMult = 0.001;
			
			_roadWidth = 2000;
			_segmentLength = 200;
			_rumbleLength = 3;
			_trackLength = 200;
			_lanes = 3;
			_opponentsTotal = 200;
			
			_offRoadDecel = 0.99;
			_centrifugal = 0.3;
			
			_playerX = _playerY = _playerZ = 0;
			
			if (!_useRender2D)
			{
				_renderBuffer = new SoftwareRenderBuffer(_width, _height, _bgColor);
				_renderBitmap = new Bitmap(_renderBuffer as SoftwareRenderBuffer);
				_bgScroller = new ParallaxScroller(_width, _height * 0.5, backgroundLayers);
			}
			else
			{
				_renderBuffer = new Render2DRenderBuffer(_width, _height, _bgColor);
			}
		}
		
		
		/**
		 * @private
		 */
		private function prepareSprites():void
		{
			_sprites = new Sprites();
			
			if (_atlas)
			{
				_sprites.BILLBOARD01 = _atlas.getImage("billboard01", 2.5);
				_sprites.BILLBOARD02 = _atlas.getImage("billboard02", 2.5);
				_sprites.BILLBOARD03 = _atlas.getImage("billboard03", 2.5);
				_sprites.BILLBOARD04 = _atlas.getImage("billboard04", 2.5);
				_sprites.BILLBOARD05 = _atlas.getImage("billboard05", 2.5);
				_sprites.BILLBOARD06 = _atlas.getImage("billboard06", 2.5);
				_sprites.BILLBOARD07 = _atlas.getImage("billboard07", 2.5);
				_sprites.BILLBOARD08 = _atlas.getImage("billboard08", 2.5);
				_sprites.BILLBOARD09 = _atlas.getImage("billboard09", 2.5);
				_sprites.BOULDER1 = _atlas.getImage("veg_boulder1", 2.5);
				_sprites.BOULDER2 = _atlas.getImage("veg_boulder2", 2.5);
				_sprites.BOULDER3 = _atlas.getImage("veg_boulder3", 2.5);
				_sprites.BUSH1 = _atlas.getImage("veg_bush1", 2.5);
				_sprites.BUSH2 = _atlas.getImage("veg_bush2", 2.5);
				_sprites.CACTUS = _atlas.getImage("veg_cactus", 2.5);
				_sprites.TREE1 = _atlas.getImage("veg_tree1", 2.5);
				_sprites.TREE2 = _atlas.getImage("veg_tree2", 2.5);
				_sprites.PALM_TREE = _atlas.getImage("veg_palmtree", 2.5);
				_sprites.DEAD_TREE1 = _atlas.getImage("veg_deadtree1", 2.5);
				_sprites.DEAD_TREE2 = _atlas.getImage("veg_deadtree2", 2.5);
				_sprites.STUMP = _atlas.getImage("veg_stump", 2.5);
				_sprites.COLUMN = _atlas.getImage("bldg_column", 3.0);
				_sprites.TOWER = _atlas.getImage("bldg_tower", 10.0);
				_sprites.BOATHOUSE = _atlas.getImage("bldg_boathouse", 3.0);
				_sprites.WINDMILL = _atlas.getImage("bldg_windmill", 4.0);
				_sprites.CAR01 = _atlas.getImage("car01", 1.25);
				_sprites.CAR02 = _atlas.getImage("car02", 1.25);
				_sprites.CAR03 = _atlas.getImage("car03", 1.25);
				_sprites.CAR04 = _atlas.getImage("car04", 1.25);
				_sprites.TRUCK = _atlas.getImage("car05", 1.7);
				_sprites.SEMI = _atlas.getImage("car06", 2.0);
				_sprites.PLAYER_STRAIGHT = _atlas.getImage("player");
				_sprites.PLAYER_LEFT = _atlas.getImage("player_left");
				_sprites.PLAYER_RIGHT = _atlas.getImage("player_right");
				_sprites.PLAYER_UPHILL_STRAIGHT = _atlas.getImage("player_uphill");
				_sprites.PLAYER_UPHILL_LEFT = _atlas.getImage("player_uphill_left");
				_sprites.PLAYER_UPHILL_RIGHT = _atlas.getImage("player_uphill_right");
	
				_sprites.REGION_SKY = _atlas.getRegion("bg_sky");
				_sprites.REGION_HILLS = _atlas.getRegion("bg_hills");
				_sprites.REGION_TREES = _atlas.getRegion("bg_trees");
			}

			_sprites.init();
		}


		/**
		 * @private
		 */
		private function updateOpponents(dt:Number, playerSegment:Segment, playerW:Number):void
		{
			var i:int;
			var car:Car;
			var oldSegment:Segment;
			var newSegment:Segment;
			
			for (i = 0; i < _opponents.length; i++)
			{
				car = _opponents[i];
				oldSegment = findSegment(car.z);
				car.offset = car.offset + updateOpponentOffset(car, oldSegment, playerSegment, playerW);
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
		private function updateOpponentOffset(opponent:Car, opponentSegment:Segment,
			playerSegment:Segment, playerW:Number):Number
		{
			var i:int;
			var j:int;
			var dir:Number;
			var segment:Segment;
			var otherCar:Car;
			var otherCarW:Number;
			var lookahead:int = 20;
			var carW:Number = opponent.sprite.source.width * _sprites.SCALE;

			/* Optimization: dont bother steering around other cars when 'out of sight'
			 * of the player. */
			if ((opponentSegment.index - playerSegment.index) > _drawDistance) return 0;

			for (i = 1; i < lookahead; i++)
			{
				segment = _segments[(opponentSegment.index + i) % _segments.length];

				/* Car drive-around player AI */
				if ((segment === playerSegment) && (opponent.speed > _speed) && (overlap(_playerX, playerW, opponent.offset, carW, 1.2)))
				{
					if (_playerX > 0.5) dir = -1;
					else if (_playerX < -0.5) dir = 1;
					else dir = (opponent.offset > _playerX) ? 1 : -1;
					// The closer the cars (smaller i) and the greater the speed ratio,
					// the larger the offset.
					return dir * 1 / i * (opponent.speed - _speed) / _maxSpeed;
				}

				/* Car drive-around other car AI */
				for (j = 0; j < segment.cars.length; j++)
				{
					otherCar = segment.cars[j];
					otherCarW = otherCar.sprite.source.width * _sprites.SCALE;
					if ((opponent.speed > otherCar.speed) && overlap(opponent.offset, carW, otherCar.offset, otherCarW, 1.2))
					{
						if (otherCar.offset > 0.5) dir = -1;
						else if (otherCar.offset < -0.5) dir = 1;
						else dir = (opponent.offset > otherCar.offset) ? 1 : -1;
						return dir * 1 / i * (opponent.speed - otherCar.speed) / _maxSpeed;
					}
				}
			}

			// if no cars ahead, but car has somehow ended up off road, then steer back on.
			if (opponent.offset < -0.9) return 0.1;
			else if (opponent.offset > 0.9) return -0.1;
			else return 0;
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
		private function resetOpponents():void
		{
			var i:int,
			offset:Number,
			z:Number,
			speed:Number,
			opponent:Car,
			segment:Segment,
			sprite:BitmapData;

			for (i = 0; i < _opponentsTotal; i++)
			{
				offset = Math.random() * randomChoice([-0.8, 0.8]);
				z = int(Math.random() * _segments.length) * _segmentLength;
				sprite = randomChoice(_sprites.CARS);
				speed = _maxSpeed / 4 + Math.random() * _maxSpeed / (sprite == _sprites.SEMI ? 4 : 2);
				opponent = new Car(offset, z, new SSprite(sprite), speed);
				segment = findSegment(opponent.z);
				segment.cars.push(opponent);
				_opponents.push(opponent);
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
		private function renderSegment(x1:int, y1:int, w1:int, x2:int, y2:int, w2:int,
			color:ColorSet, hazeAlpha:Number):void
		{
			/* Calculate rumble widths for current segment. */
			var r1:Number = calcRumbleWidth(w1), r2:Number = calcRumbleWidth(w2);

			/* Draw offroad area segment. */
			_renderBuffer.blitRect(0, y2, _width, y1 - y2, color.grass, _hazeColor, hazeAlpha);

			/* Draw the road segment. */
			_renderBuffer.drawQuad(x1 - w1 - r1, y1, x1 - w1, y1, x2 - w2, y2, x2 - w2 - r2, y2, color.rumble, _hazeColor, hazeAlpha);
			_renderBuffer.drawQuad(x1 + w1 + r1, y1, x1 + w1, y1, x2 + w2, y2, x2 + w2 + r2, y2, color.rumble, _hazeColor, hazeAlpha);
			_renderBuffer.drawQuad(x1 - w1, y1, x1 + w1, y1, x2 + w2, y2, x2 - w2, y2, color.road, _hazeColor, hazeAlpha);

			/* Draw lane strips. */
			if (color.lane > 0)
			{
				var l1:Number = calcLaneMarkerWidth(w1),
				l2:Number = calcLaneMarkerWidth(w2),
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
		private function renderSprite(sprite:BitmapData, scale:Number, destX:int, destY:int,
			offsetX:Number = 0.0, offsetY:Number = 0.0, clipY:Number = 0.0,
			hazeAlpha:Number = 1.0):void
		{
			/* Scale for projection AND relative to roadWidth. */
			var destW:int = (sprite.width * scale * _widthHalf) * (_sprites.SCALE * _roadWidth);
			var destH:int = (sprite.height * scale * _widthHalf) * (_sprites.SCALE * _roadWidth);

			destX = destX + (destW * offsetX);
			destY = destY + (destH * offsetY);

			var clipH:int = clipY ? mathMax(0, destY + destH - clipY) : 0;

			if (clipH < destH)
			{
				_renderBuffer.drawImage(sprite, destX, destY, destW, destH - clipH, destW / sprite.width, _hazeColor, hazeAlpha);
			}
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Util Functions
		// -----------------------------------------------------------------------------------------
		
		private function findSegment(z:Number):Segment
		{
			return _segments[int(z / _segmentLength) % _segments.length];
		}
		
		
		private function increase(start:Number, increment:Number, max:Number):Number
		{
			var result:Number = start + increment;
			while (result >= max) result -= max;
			while (result < 0) result += max;
			return result;
		}


		private function accel(v:Number, accel:Number, dt:Number):Number
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
			p.screen.x = mathRound(_widthHalf + (p.screen.scale * p.camera.x * _widthHalf));
			p.screen.y = mathRound(_heightHalf - (p.screen.scale * p.camera.y * _heightHalf));
			p.screen.w = mathRound((p.screen.scale * _roadWidth * _widthHalf));
		}


		private function calcRumbleWidth(projectedRoadWidth:Number):Number
		{
			return projectedRoadWidth / mathMax(6, 2 * _lanes);
		}


		private function calcLaneMarkerWidth(projectedRoadWidth:Number):Number
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
	}
}
