package view.racing
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;


	/**
	 * SPRITES
	 * @author Hexagon
	 */
	public class Sprites
	{
		public var BG_SKY:BitmapData;
		public var BG_HILLS:BitmapData;
		public var BG_TREES:BitmapData;
		
		public var REGION_SKY:Rectangle;
		public var REGION_HILLS:Rectangle;
		public var REGION_TREES:Rectangle;
		
		public var BILLBOARD01:BitmapData;
		public var BILLBOARD02:BitmapData;
		public var BILLBOARD03:BitmapData;
		public var BILLBOARD04:BitmapData;
		public var BILLBOARD05:BitmapData;
		public var BILLBOARD06:BitmapData;
		public var BILLBOARD07:BitmapData;
		public var BILLBOARD08:BitmapData;
		public var BILLBOARD09:BitmapData;
		
		public var BOULDER1:BitmapData;
		public var BOULDER2:BitmapData;
		public var BOULDER3:BitmapData;
		public var DEAD_TREE1:BitmapData;
		public var DEAD_TREE2:BitmapData;
		public var PALM_TREE:BitmapData;
		public var TREE1:BitmapData;
		public var TREE2:BitmapData;
		public var BUSH1:BitmapData;
		public var BUSH2:BitmapData;
		public var CACTUS:BitmapData;
		public var STUMP:BitmapData;
		
		public var COLUMN:BitmapData;
		public var TOWER:BitmapData;
		public var BOATHOUSE:BitmapData;
		public var WINDMILL:BitmapData;
		
		public var CAR01:BitmapData;
		public var CAR02:BitmapData;
		public var CAR03:BitmapData;
		public var CAR04:BitmapData;
		public var TRUCK:BitmapData;
		public var SEMI:BitmapData;
		
		public var PLAYER_STRAIGHT:BitmapData;
		public var PLAYER_LEFT:BitmapData;
		public var PLAYER_RIGHT:BitmapData;
		public var PLAYER_UPHILL_LEFT:BitmapData;
		public var PLAYER_UPHILL_STRAIGHT:BitmapData;
		public var PLAYER_UPHILL_RIGHT:BitmapData;
		
		public var BILLBOARDS:Array;
		public var VEGETATION:Array;
		public var BUILDINGS:Array;
		public var CARS:Array;

		public var SCALE:Number;
		
		
		public function init():void
		{
			// the reference sprite width should be 1/3rd the (half-)roadWidth
			SCALE = 0.3 * (1 / PLAYER_STRAIGHT.width);
			
			BILLBOARDS = [BILLBOARD01, BILLBOARD02, BILLBOARD03, BILLBOARD04, BILLBOARD05, BILLBOARD06, BILLBOARD07, BILLBOARD08, BILLBOARD09];
			VEGETATION = [TREE1, TREE2, DEAD_TREE1, DEAD_TREE2, PALM_TREE, BUSH1, BUSH2, CACTUS, STUMP, BOULDER1, BOULDER2, BOULDER3];
			CARS = [CAR01, CAR02, CAR03, CAR04, SEMI, TRUCK];
			BUILDINGS = [COLUMN, TOWER, BOATHOUSE, WINDMILL];
		}
	}
}
