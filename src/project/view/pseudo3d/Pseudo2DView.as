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
package view.pseudo3d
{
	import tetragon.data.texture.TextureAtlas;
	import tetragon.view.render2d.display.Image2D;
	import tetragon.view.render2d.display.View2D;
	import tetragon.view.render2d.events.Event2D;

	import view.pseudo3d.constants.COLORS;
	import view.pseudo3d.constants.ROAD;
	import view.pseudo3d.vo.SSprite;
	import view.pseudo3d.vo.Segment;
	import view.pseudo3d.vo.Sprites;
	
	
	/**
	 * @author hexagon
	 */
	public class Pseudo2DView extends View2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
        private var _frameCount:int;
        private var _failCount:int;
        private var _waitFrames:int;
		
		private var fps:int = 60;							// how many 'update' frames per second
		private var step:Number = 1 / fps;					// how long is each frame (in seconds)
		private var centrifugal:Number = 0.3;				// centrifugal force multiplier when going around curves
		private var offRoadDecel:Number = 0.99;				// speed multiplier when off road (e.g. you lose 2% speed each update frame)
		
		private var skySpeed:Number = 0.001;				// background sky layer scroll speed when going around curve (or up hill)
		private var hillSpeed:Number = 0.002;				// background hill layer scroll speed when going around curve (or up hill)
		private var treeSpeed:Number = 0.003;				// background tree layer scroll speed when going around curve (or up hill)
		
		private var skyOffset:int = 0;						// current sky scroll offset
		private var hillOffset:int = 0;						// current hill scroll offset
		private var treeOffset:int = 0;						// current tree scroll offset
		
		private var segments:Vector.<Segment>;				// array of road segments
		private var cars:Array = [];						// array of cars on the road
		
		private var resolution:Number;						// scaling factor to provide resolution independence (computed)
		
		private var roadWidth:int = 2000;					// actually half the roads width, easier math if the road spans from -roadWidth to +roadWidth
		private var segmentLength:int = 200;				// length of a single segment
		private var rumbleLength:int = 3;					// number of segments per red/white rumble strip
		private var trackLength:int;						// z length of entire track (computed)
		private var lanes:int = 3;							// number of lanes
		private var fieldOfView:int = 100;					// angle (degrees) for field of view
		private var cameraHeight:int = 1000;				// z height of camera
		private var cameraDepth:int;						// z distance camera is from screen (computed)
		private var drawDistance:int = 300;					// number of segments to draw
		private var playerX:Number = 0;						// player x offset from center of road (-1 to 1 to stay independent of roadWidth)
		private var playerZ:Number;							// player relative z distance from camera (computed)
		private var fogDensity:int = 5;						// exponential fog density
		private var position:Number = 0;					// current camera Z position (add playerZ to get player's absolute Z position)
		private var speed:Number = 0;						// current speed
		private var maxSpeed:Number = segmentLength / step;	// top speed (ensure we can't move more than 1 segment in a single frame to make collision detection easier)
		private var accel:Number = maxSpeed / 5;			// acceleration rate - tuned until it 'felt' right
		private var breaking:Number = -maxSpeed;			// deceleration rate when braking
		private var decel:Number = -maxSpeed / 5;			// 'natural' deceleration rate when neither accelerating, nor braking
		//private var offRoadDecel:Number = -maxSpeed / 2;	// off road deceleration is somewhere in between
		private var offRoadLimit:Number = maxSpeed / 4;		// limit when off road deceleration no longer applies (e.g. you can always go at least this speed even when off road)
		private var totalCars:Number = 200;					// total number of cars on the road
		private var currentLapTime:Number = 0;				// current lap time
		private var lastLapTime:Number;						// last lap time
		
		private var SPRITES:Sprites;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Pseudo2DView()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function start():void
		{
			prepareSprites();
			
			cameraDepth = 1 / Math.tan((fieldOfView / 2) * Math.PI / 180);
			playerZ = (cameraHeight * cameraDepth);
			resolution = frameHeight / 640;
			
			resetRoad();
		}
		
		
		/**
		 * @private
		 */
		private function prepareSprites():void
		{
			var atlas:TextureAtlas = _main.resourceManager.resourceIndex.getResourceContent("spriteTextureAtlas");
			SPRITES = new Sprites();
			
			SPRITES.BG_SKY = new Image2D(atlas.getTexture("bg_sky"));
			SPRITES.BG_HILLS = new Image2D(atlas.getTexture("bg_hills"));
			SPRITES.BG_TREES = new Image2D(atlas.getTexture("bg_trees"));
			
			SPRITES.BILLBOARD01 = new Image2D(atlas.getTexture("sprite_billboard01"));
			SPRITES.BILLBOARD02 = new Image2D(atlas.getTexture("sprite_billboard02"));
			SPRITES.BILLBOARD03 = new Image2D(atlas.getTexture("sprite_billboard03"));
			SPRITES.BILLBOARD04 = new Image2D(atlas.getTexture("sprite_billboard04"));
			SPRITES.BILLBOARD05 = new Image2D(atlas.getTexture("sprite_billboard05"));
			SPRITES.BILLBOARD06 = new Image2D(atlas.getTexture("sprite_billboard06"));
			SPRITES.BILLBOARD07 = new Image2D(atlas.getTexture("sprite_billboard07"));
			SPRITES.BILLBOARD08 = new Image2D(atlas.getTexture("sprite_billboard08"));
			SPRITES.BILLBOARD09 = new Image2D(atlas.getTexture("sprite_billboard09"));
			
			SPRITES.BOULDER1 = new Image2D(atlas.getTexture("sprite_boulder1"));
			SPRITES.BOULDER2 = new Image2D(atlas.getTexture("sprite_boulder2"));
			SPRITES.BOULDER3 = new Image2D(atlas.getTexture("sprite_boulder3"));
			
			SPRITES.BUSH1 = new Image2D(atlas.getTexture("sprite_bush1"));
			SPRITES.BUSH2 = new Image2D(atlas.getTexture("sprite_bush2"));
			SPRITES.CACTUS = new Image2D(atlas.getTexture("sprite_cactus"));
			SPRITES.TREE1 = new Image2D(atlas.getTexture("sprite_tree1"));
			SPRITES.TREE2 = new Image2D(atlas.getTexture("sprite_tree2"));
			SPRITES.PALM_TREE = new Image2D(atlas.getTexture("sprite_palm_tree"));
			SPRITES.DEAD_TREE1 = new Image2D(atlas.getTexture("sprite_dead_tree1"));
			SPRITES.DEAD_TREE2 = new Image2D(atlas.getTexture("sprite_dead_tree2"));
			SPRITES.STUMP = new Image2D(atlas.getTexture("sprite_stump"));
			SPRITES.COLUMN = new Image2D(atlas.getTexture("sprite_column"));
			
			SPRITES.CAR01 = new Image2D(atlas.getTexture("sprite_car01"));
			SPRITES.CAR02 = new Image2D(atlas.getTexture("sprite_car02"));
			SPRITES.CAR03 = new Image2D(atlas.getTexture("sprite_car03"));
			SPRITES.CAR04 = new Image2D(atlas.getTexture("sprite_car04"));
			SPRITES.SEMI = new Image2D(atlas.getTexture("sprite_semi"));
			SPRITES.TRUCK = new Image2D(atlas.getTexture("sprite_truck"));
			
			SPRITES.PLAYER_STRAIGHT = new Image2D(atlas.getTexture("sprite_player_straight"));
			SPRITES.PLAYER_LEFT = new Image2D(atlas.getTexture("sprite_player_left"));
			SPRITES.PLAYER_RIGHT = new Image2D(atlas.getTexture("sprite_player_right"));
			SPRITES.PLAYER_UPHILL_STRAIGHT = new Image2D(atlas.getTexture("sprite_player_uphill_straight"));
			SPRITES.PLAYER_UPHILL_LEFT = new Image2D(atlas.getTexture("sprite_player_uphill_left"));
			SPRITES.PLAYER_UPHILL_RIGHT = new Image2D(atlas.getTexture("sprite_player_uphill_right"));
			
			SPRITES.init();
		}
		
		
		// =========================================================================
		// BUILD ROAD GEOMETRY
		// =========================================================================
		
		private function lastY():Number
		{
			return (segments.length == 0) ? 0 : segments[segments.length - 1].p2.world.y;
		}
		
		
		private function findSegment(z:Number):*
		{
			return segments[Math.floor(z / segmentLength) % segments.length];
		}
		
		
		private function addSegment(curve:Number, y:Number):void
		{
			var n:uint = segments.length;
			var seg:Segment = new Segment();
			seg.index = n;
			seg.p1 = {world: {y: lastY(), z: n * segmentLength}, camera: {}, screen: {}};
			seg.p2 = {world: {y: y, z: (n + 1) * segmentLength}, camera: {}, screen: {}};
			seg.curve = curve;
			seg.sprites = new Vector.<SSprite>();
			seg.cars = [];
			seg.color = Math.floor(n / rumbleLength) % 2 ? COLORS.DARK : COLORS.LIGHT;
			segments.push(seg);
		}
		
		
		private function addSprite(n:int, sprite, offset:Number):void
		{
			var s:SSprite = new SSprite();
			s.source = sprite;
			s.offset = offset;
			segments[n].sprites.push(s);
		}
		
		
		private function addRoad(enter:int, hold:int, leave:int, curve:Number, y:Number):void
		{
			var startY:Number = lastY();
			var endY:Number = startY + (Util.toInt(y, 0) * segmentLength);
			var n:int, total:int = enter + hold + leave;
			
			for (n = 0 ; n < enter; n++)
			{
				addSegment(Util.easeIn(0, curve, n / enter), Util.easeInOut(startY, endY, n / total));
			}
			for (n = 0 ; n < hold; n++)
			{
				addSegment(curve, Util.easeInOut(startY, endY, (enter + n) / total));
			}
			for (n = 0 ; n < leave; n++)
			{
				addSegment(Util.easeInOut(curve, 0, n / leave), Util.easeInOut(startY, endY, (enter + hold + n) / total));
			}
		}
		
		
		private function resetRoad():void
		{
			segments = new Vector.<Segment>();
			
			addStraight(ROAD.LENGTH.SHORT);
			addLowRollingHills();
			addSCurves();
			addCurve(ROAD.LENGTH.MEDIUM, ROAD.CURVE.MEDIUM, ROAD.HILL.LOW);
			addBumps();
			addLowRollingHills();
			addCurve(ROAD.LENGTH.LONG * 2, ROAD.CURVE.MEDIUM, ROAD.HILL.MEDIUM);
			addStraight();
			addHill(ROAD.LENGTH.MEDIUM, ROAD.HILL.HIGH);
			addSCurves();
			addCurve(ROAD.LENGTH.LONG, -ROAD.CURVE.MEDIUM, ROAD.HILL.NONE);
			addHill(ROAD.LENGTH.LONG, ROAD.HILL.HIGH);
			addCurve(ROAD.LENGTH.LONG, ROAD.CURVE.MEDIUM, -ROAD.HILL.LOW);
			addBumps();
			addHill(ROAD.LENGTH.LONG, -ROAD.HILL.MEDIUM);
			addStraight();
			addSCurves();
			addDownhillToEnd();
			
			resetSprites();
			resetCars();

			segments[findSegment(playerZ).index + 2].color = COLORS.START;
			segments[findSegment(playerZ).index + 3].color = COLORS.START;
			
			for (var n:int = 0; n < rumbleLength; n++)
			{
				segments[segments.length - 1 - n].color = COLORS.FINISH;
			}

			trackLength = segments.length * segmentLength;
		}
		
		
		private function resetSprites():void
		{
			var n:int, i:int;

			addSprite(20, SPRITES.BILLBOARD07, -1);
			addSprite(40, SPRITES.BILLBOARD06, -1);
			addSprite(60, SPRITES.BILLBOARD08, -1);
			addSprite(80, SPRITES.BILLBOARD09, -1);
			addSprite(100, SPRITES.BILLBOARD01, -1);
			addSprite(120, SPRITES.BILLBOARD02, -1);
			addSprite(140, SPRITES.BILLBOARD03, -1);
			addSprite(160, SPRITES.BILLBOARD04, -1);
			addSprite(180, SPRITES.BILLBOARD05, -1);

			addSprite(240, SPRITES.BILLBOARD07, -1.2);
			addSprite(240, SPRITES.BILLBOARD06, 1.2);
			addSprite(segments.length - 25, SPRITES.BILLBOARD07, -1.2);
			addSprite(segments.length - 25, SPRITES.BILLBOARD06, 1.2);

			for (n = 10 ; n < 200 ; n += 4 + Math.floor(n / 100))
			{
				addSprite(n, SPRITES.PALM_TREE, 0.5 + Math.random() * 0.5);
				addSprite(n, SPRITES.PALM_TREE, 1 + Math.random() * 2);
			}

			for (n = 250 ; n < 1000 ; n += 5)
			{
				addSprite(n, SPRITES.COLUMN, 1.1);
				addSprite(n + Util.randomInt(0, 5), SPRITES.TREE1, -1 - (Math.random() * 2));
				addSprite(n + Util.randomInt(0, 5), SPRITES.TREE2, -1 - (Math.random() * 2));
			}

			for (n = 200 ; n < segments.length ; n += 3)
			{
				addSprite(n, Util.randomChoice(SPRITES.PLANTS), Util.randomChoice([1, -1]) * (2 + Math.random() * 5));
			}

			var side, sprite, offset;
			for (n = 1000 ; n < (segments.length - 50) ; n += 100)
			{
				side = Util.randomChoice([1, -1]);
				addSprite(n + Util.randomInt(0, 50), Util.randomChoice(SPRITES.BILLBOARDS), -side);
				for (i = 0 ; i < 20 ; i++)
				{
					sprite = Util.randomChoice(SPRITES.PLANTS);
					offset = side * (1.5 + Math.random());
					addSprite(n + Util.randomInt(0, 50), sprite, offset);
				}
			}
		}
		
		
		function resetCars():void
		{
			cars = [];
			var n:int, car, segment, offset, z, sprite, speed;
			
			for (n = 0 ; n < totalCars ; n++)
			{
				offset = Math.random() * Util.randomChoice([-0.8, 0.8]);
				z = Math.floor(Math.random() * segments.length) * segmentLength;
				sprite = Util.randomChoice(SPRITES.CARS);
				speed = maxSpeed / 4 + Math.random() * maxSpeed / (sprite == SPRITES.SEMI ? 4 : 2);
				car = {offset:offset, z:z, sprite:sprite, speed:speed};
				segment = findSegment(car.z);
				segment.cars.push(car);
				cars.push(car);
			}
		}
	
	
		private function addStraight(num:Number = NaN):void
		{
			num = num || ROAD.LENGTH.MEDIUM;
			addRoad(num, num, num, 0, 0);
		}


		private function addHill(num:Number, height:Number):void
		{
			num = num || ROAD.LENGTH.MEDIUM;
			height = height || ROAD.HILL.MEDIUM;
			addRoad(num, num, num, 0, height);
		}


		private function addCurve(num:Number, curve:Number, height:Number):void
		{
			num = num || ROAD.LENGTH.MEDIUM;
			curve = curve || ROAD.CURVE.MEDIUM;
			height = height || ROAD.HILL.NONE;
			addRoad(num, num, num, curve, height);
		}


		private function addLowRollingHills(num:Number = NaN, height:Number = NaN):void
		{
			num = num || ROAD.LENGTH.SHORT;
			height = height || ROAD.HILL.LOW;
			addRoad(num, num, num, 0, height / 2);
			addRoad(num, num, num, 0, -height);
			addRoad(num, num, num, ROAD.CURVE.EASY, height);
			addRoad(num, num, num, 0, 0);
			addRoad(num, num, num, -ROAD.CURVE.EASY, height / 2);
			addRoad(num, num, num, 0, 0);
		}


		private function addSCurves():void
		{
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.EASY, ROAD.HILL.NONE);
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.CURVE.MEDIUM, ROAD.HILL.MEDIUM);
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.CURVE.EASY, -ROAD.HILL.LOW);
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.EASY, ROAD.HILL.MEDIUM);
			addRoad(ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, ROAD.LENGTH.MEDIUM, -ROAD.CURVE.MEDIUM, -ROAD.HILL.MEDIUM);
		}


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


		private function addDownhillToEnd(num:Number = NaN):void
		{
			num = num || 200;
			addRoad(num, num, num, -ROAD.CURVE.EASY, -lastY() / segmentLength);
		}
	
	
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		override protected function onAddedToStage(e:Event2D):void
		{
			super.onAddedToStage(e);
				
			_failCount = 0;
			_waitFrames = 2;
			_frameCount = 0;
			
			_gameLoop.renderSignal.add(onRender);
		}
		
		
		override protected function onRender(ticks:uint, ms:uint, fps:uint):void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function setup():void
		{
			super.setup();
		}
	}
}
