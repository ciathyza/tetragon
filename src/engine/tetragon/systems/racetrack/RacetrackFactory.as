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
	import tetragon.systems.racetrack.constants.COLOR;
	import tetragon.systems.racetrack.constants.ROAD;
	import tetragon.systems.racetrack.vo.Opponent;
	import tetragon.systems.racetrack.vo.PCamera;
	import tetragon.systems.racetrack.vo.PPoint;
	import tetragon.systems.racetrack.vo.PScreen;
	import tetragon.systems.racetrack.vo.PWorld;
	import tetragon.systems.racetrack.vo.SSprite;
	import tetragon.systems.racetrack.vo.Segment;

	import com.hexagonstar.util.debug.Debug;

	import flash.display.BitmapData;
	
	
	/**
	 * RacetrackFactory class
	 *
	 * @author Hexagon
	 */
	public class RacetrackFactory
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _atlas:Atlas;
		private var _racetrack:Racetrack;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function RacetrackFactory()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a racetrack for demo and testing purposes.
		 */
		public function createDemoRacetrack(atlas:Atlas):Racetrack
		{
			_atlas = atlas;
			_racetrack = new Racetrack();
			_racetrack.opponents = new Vector.<Opponent>();
			
			initDefaults();
			prepareSprites();
			
			var i:int,
			j:int,
			side:Number,
			density:int = 10,
			offset:Number,
			z:Number,
			speed:Number,
			opponent:Opponent,
			segment:Segment,
			sprite:BitmapData;
			
			/* Create Demo Road ---------------------------------------------------------- */
			_racetrack.segments = new Vector.<Segment>();
			addStraight(ROAD.LENGTH.SHORT / 2);
			addHill(ROAD.LENGTH.SHORT, ROAD.HILL.LOW);
			addLowRollingHills();
			addSCurves();
			addCurve(ROAD.LENGTH.MEDIUM, ROAD.CURVE.MEDIUM, ROAD.HILL.HIGH);
			addBumps();
			addLowRollingHills();
			addCurve(ROAD.LENGTH.LONG, ROAD.CURVE.MEDIUM, ROAD.HILL.MEDIUM);
			addStraight();
			addCurve(ROAD.LENGTH.LONG, -ROAD.CURVE.MEDIUM, ROAD.HILL.MEDIUM);
			addHill(ROAD.LENGTH.MEDIUM, ROAD.HILL.EXTREME);
			addCurve(ROAD.LENGTH.LONG, ROAD.CURVE.MEDIUM, -ROAD.HILL.LOW);
			addHill(ROAD.LENGTH.LONG, -ROAD.HILL.MEDIUM);
			addStraight();
			addDownhillToEnd();
			_racetrack.segments[findSegment(_racetrack.playerZ).index + 2].color = COLOR.START;
			_racetrack.segments[findSegment(_racetrack.playerZ).index + 3].color = COLOR.START;
			for (var n:uint = 0 ; n < _racetrack.rumbleLength ; n++)
			{
				_racetrack.segments[_racetrack.segments.length - 1 - n].color = COLOR.FINISH;
			}
			_racetrack.trackLength = _racetrack.segments.length * _racetrack.segmentLength;
			
			/* Create Demo Sprites ------------------------------------------------------- */
			/* Add row of billboards right after start line. */
			addSprite(20, _racetrack.sprold.BILLBOARD07, -1);
			addSprite(40, _racetrack.sprold.BILLBOARD06, -1);
			addSprite(60, _racetrack.sprold.BILLBOARD08, -1);
			addSprite(80, _racetrack.sprold.BILLBOARD09, -1);
			addSprite(100, _racetrack.sprold.BILLBOARD01, -1);
			addSprite(120, _racetrack.sprold.BILLBOARD02, -1);
			addSprite(140, _racetrack.sprold.BILLBOARD03, -1);
			addSprite(160, _racetrack.sprold.BILLBOARD04, -1);
			addSprite(180, _racetrack.sprold.BILLBOARD05, -1);
			addSprite(240, _racetrack.sprold.BILLBOARD07, -1.2);
			addSprite(240, _racetrack.sprold.BILLBOARD06, 1.2);
			/* Add some billboards at end of track. */
			addSprite(_racetrack.segments.length - 25, _racetrack.sprold.BILLBOARD07, -1.2);
			addSprite(_racetrack.segments.length - 25, _racetrack.sprold.BILLBOARD06, 1.2);
			/* Add palm trees at start of track. */
			addSprites(_racetrack.sprold.PALM_TREE, 10, 200, null, 4, 100, 0.5, 0.5);
			addSprites(_racetrack.sprold.PALM_TREE, 10, 200, null, 4, 100, 1, 2);
			/* Add a long row of columns on right side and trees on left side. */
			addSprites(_racetrack.sprold.COLUMN, 250, 1000, null, 5, 0, 1.1);
			addSprites(_racetrack.sprold.TREE1, 250, 1000, [0, 5], 8, 0, -1, 2, "sub");
			addSprites(_racetrack.sprold.TREE2, 250, 1000, [0, 5], 8, 0, -1, 2, "sub");
			// TODO
			for (i = 200; i < _racetrack.segments.length; i += 3)
			{
				addSprite(i, randomChoice(_racetrack.sprold.VEGETATION), randomChoice([1, -1]) * (2 + Math.random() * 5));
			}
			for (i = 1600; i < _racetrack.segments.length; i += 20)
			{
				addSprite(i, randomChoice(_racetrack.sprold.BUILDINGS), randomChoice([1, -1]) * (2 + Math.random() * 5));
			}
			for (i = 1000; i < (_racetrack.segments.length - 50); i += 100)
			{
				side = randomChoice([1, -1]);
				addSprite(i + randomInt(0, 50), randomChoice(_racetrack.sprold.BILLBOARDS), -side);
				for (j = 0 ; j < 20 ; j++)
				{
					sprite = randomChoice(_racetrack.sprold.VEGETATION);
					offset = side * (1.5 + Math.random());
					addSprite(i + randomInt(0, 50), sprite, offset);
				}
			}
			
			/* Create Demo Opponents ----------------------------------------------------- */
			for (i = 0; i < _racetrack.opponentsNum; i++)
			{
				offset = Math.random() * randomChoice([-0.8, 0.8]);
				z = int(Math.random() * _racetrack.segments.length) * _racetrack.segmentLength;
				sprite = randomChoice(_racetrack.sprold.CARS);
				speed = _racetrack.maxSpeed / 4 + Math.random() * _racetrack.maxSpeed / (sprite == _racetrack.sprold.SEMI ? 4 : 2);
				opponent = new Opponent(offset, z, new SSprite(sprite), speed);
				segment = findSegment(opponent.z);
				segment.cars.push(opponent);
				_racetrack.opponents.push(opponent);
			}
			
			return _racetrack;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function get lastY():Number
		{
			return (_racetrack.segments.length == 0)
				? 0.0
				: _racetrack.segments[_racetrack.segments.length - 1].p2.world.y;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function initDefaults():void
		{
			_racetrack.hazeDensity = 10;
			_racetrack.hazeColor = 0x333333;
			_racetrack.hazeColor = COLOR.HAZE;
			_racetrack.roadWidth = 2000;
			_racetrack.segmentLength = 200;
			_racetrack.rumbleLength = 3;
			_racetrack.trackLength = 200;
			_racetrack.lanes = 3;
			_racetrack.opponentsNum = 200;
			
			_racetrack.dt = 1 / Main.instance.gameLoop.frameRate;
			_racetrack.fieldOfView = 100;
			_racetrack.cameraHeight = 1000;
			_racetrack.cameraDepth = 1 / Math.tan((_racetrack.fieldOfView / 2) * Math.PI / 180);
			_racetrack.playerZ = (_racetrack.cameraHeight * _racetrack.cameraDepth);
			
			_racetrack.offRoadDecel = 0.99;
			_racetrack.centrifugal = 0.3;
			_racetrack.maxSpeed = _racetrack.segmentLength / _racetrack.dt;
			_racetrack.acceleration = _racetrack.maxSpeed / 5;
			_racetrack.braking = -_racetrack.maxSpeed;
			_racetrack.deceleration = -_racetrack.maxSpeed / 5;
			_racetrack.offRoadLimit = _racetrack.maxSpeed / 4;
		}
		
		
		/**
		 * @private
		 */
		private function prepareSprites():void
		{
			_racetrack.sprites = _atlas.getImageMap();
			
			var spriteMap:Object = _atlas.getImageMap();
			for (var i:String in spriteMap)
			{
				Debug.trace(i);
			}
			
			
			_racetrack.sprold = new Sprites();
			var s:Sprites = _racetrack.sprold;
			
			if (_atlas)
			{
				s.BILLBOARD01 = _atlas.getImage("billboard01", 2.5);
				s.BILLBOARD02 = _atlas.getImage("billboard02", 2.5);
				s.BILLBOARD03 = _atlas.getImage("billboard03", 2.5);
				s.BILLBOARD04 = _atlas.getImage("billboard04", 2.5);
				s.BILLBOARD05 = _atlas.getImage("billboard05", 2.5);
				s.BILLBOARD06 = _atlas.getImage("billboard06", 2.5);
				s.BILLBOARD07 = _atlas.getImage("billboard07", 2.5);
				s.BILLBOARD08 = _atlas.getImage("billboard08", 2.5);
				s.BILLBOARD09 = _atlas.getImage("billboard09", 2.5);
				s.BOULDER1 = _atlas.getImage("veg_boulder1", 2.5);
				s.BOULDER2 = _atlas.getImage("veg_boulder2", 2.5);
				s.BOULDER3 = _atlas.getImage("veg_boulder3", 2.5);
				s.BUSH1 = _atlas.getImage("veg_bush1", 2.5);
				s.BUSH2 = _atlas.getImage("veg_bush2", 2.5);
				s.CACTUS = _atlas.getImage("veg_cactus", 2.5);
				s.TREE1 = _atlas.getImage("veg_tree1", 2.5);
				s.TREE2 = _atlas.getImage("veg_tree2", 2.5);
				s.PALM_TREE = _atlas.getImage("veg_palmtree", 2.5);
				s.DEAD_TREE1 = _atlas.getImage("veg_deadtree1", 2.5);
				s.DEAD_TREE2 = _atlas.getImage("veg_deadtree2", 2.5);
				s.STUMP = _atlas.getImage("veg_stump", 2.5);
				s.COLUMN = _atlas.getImage("bldg_column", 3.0);
				s.TOWER = _atlas.getImage("bldg_tower", 10.0);
				s.BOATHOUSE = _atlas.getImage("bldg_boathouse", 3.0);
				s.WINDMILL = _atlas.getImage("bldg_windmill", 4.0);
				s.CAR01 = _atlas.getImage("car01", 1.25);
				s.CAR02 = _atlas.getImage("car02", 1.25);
				s.CAR03 = _atlas.getImage("car03", 1.25);
				s.CAR04 = _atlas.getImage("car04", 1.25);
				s.TRUCK = _atlas.getImage("car05", 1.7);
				s.SEMI = _atlas.getImage("car06", 2.0);
				s.PLAYER_STRAIGHT = _atlas.getImage("player");
				s.PLAYER_LEFT = _atlas.getImage("player_left");
				s.PLAYER_RIGHT = _atlas.getImage("player_right");
				s.PLAYER_UPHILL_STRAIGHT = _atlas.getImage("player_uphill");
				s.PLAYER_UPHILL_LEFT = _atlas.getImage("player_uphill_left");
				s.PLAYER_UPHILL_RIGHT = _atlas.getImage("player_uphill_right");
	
				s.REGION_SKY = _atlas.getRegion("bg_sky");
				s.REGION_HILLS = _atlas.getRegion("bg_hills");
				s.REGION_TREES = _atlas.getRegion("bg_trees");
			}

			// the reference sprite width should be 1/3rd the (half-)roadWidth
			_racetrack.spriteScale = 0.3 * (1 / s.PLAYER_STRAIGHT.width);
			
			s.init();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// ROAD GEOMETRY CONSTRUCTION
		// -----------------------------------------------------------------------------------------
		
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
			_racetrack.segments[segNum].sprites.push(s);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// ROAD GEOMETRY CONSTRUCTION
		// -----------------------------------------------------------------------------------------
		
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
			addRoad(num, num, num, -ROAD.CURVE.EASY, -lastY / _racetrack.segmentLength);
		}
		
		
		/**
		 * @private
		 */
		private function addRoad(enter:int, hold:int, leave:int, curve:Number, y:Number = NaN):void
		{
			var startY:Number = lastY;
			var endY:Number = startY + (int(y) * _racetrack.segmentLength);
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
			var i:uint = _racetrack.segments.length;
			var segment:Segment = new Segment();
			segment.index = i;
			segment.p1 = new PPoint(new PWorld(lastY, i * _racetrack.segmentLength), new PCamera(), new PScreen());
			segment.p2 = new PPoint(new PWorld(y, (i + 1) * _racetrack.segmentLength), new PCamera(), new PScreen());
			segment.curve = curve;
			segment.sprites = new Vector.<SSprite>();
			segment.cars = new Vector.<Opponent>();
			segment.color = int(i / _racetrack.rumbleLength) % 2 ? COLOR.DARK : COLOR.LIGHT;
			_racetrack.segments.push(segment);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Util Functions
		// -----------------------------------------------------------------------------------------
		
		private function findSegment(z:Number):Segment
		{
			return _racetrack.segments[int(z / _racetrack.segmentLength) % _racetrack.segments.length];
		}
		
		
		private function randomInt(min:int, max:int):int
		{
			return mathRound(interpolate(min, max, Math.random()));
		}
		
		
		private function randomChoice(a:Array):*
		{
			return a[randomInt(0, a.length - 1)];
		}
		
		
		private function mathRound(n:Number):int
		{
			return n + (n < 0 ? -0.5 : +0.5) >> 0;
		}
		
		
		private function interpolate(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * percent;
		}
		
		
		private function easeIn(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * Math.pow(percent, 2);
		}


		//private static function easeOut(a:Number, b:Number, percent:Number):Number
		//{
		//	return a + (b - a) * (1 - Math.pow(1 - percent, 2));
		//}
		
		
		private function easeInOut(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * ((-Math.cos(percent * 3.141592653589793) / 2) + 0.5);
		}
	}
}
