package view.pseudo3d.vo
{
	import tetragon.view.render2d.display.Image2D;


	/**
	 * SPRITES
	 * @author Hexagon
	 */
	public class Sprites
	{
		public var PALM_TREE:Image2D;
		public var BILLBOARD08:Image2D;
		public var TREE1:Image2D;
		public var DEAD_TREE1:Image2D;
		public var BILLBOARD09:Image2D;
		public var BOULDER3:Image2D;
		public var COLUMN:Image2D;
		public var BILLBOARD01:Image2D;
		public var BILLBOARD06:Image2D;
		public var BILLBOARD05:Image2D;
		public var BILLBOARD07:Image2D;
		public var BOULDER2:Image2D;
		public var TREE2:Image2D;
		public var BILLBOARD04:Image2D;
		public var DEAD_TREE2:Image2D;
		public var BOULDER1:Image2D;
		public var BUSH1:Image2D;
		public var CACTUS:Image2D;
		public var BUSH2:Image2D;
		public var BILLBOARD03:Image2D;
		public var BILLBOARD02:Image2D;
		public var STUMP:Image2D;
		public var SEMI:Image2D;
		public var TRUCK:Image2D;
		public var CAR03:Image2D;
		public var CAR02:Image2D;
		public var CAR04:Image2D;
		public var CAR01:Image2D;
		public var PLAYER_UPHILL_LEFT:Image2D;
		public var PLAYER_UPHILL_STRAIGHT:Image2D;
		public var PLAYER_UPHILL_RIGHT:Image2D;
		public var PLAYER_LEFT:Image2D;
		public var PLAYER_STRAIGHT:Image2D;
		public var PLAYER_RIGHT:Image2D;
		
		public var BILLBOARDS:Vector.<Image2D>;
		public var PLANTS:Vector.<Image2D>;
		public var CARS:Vector.<Image2D>;

		// the reference sprite width should be 1/3rd the (half-)roadWidth
		public var SCALE:Number = 0.3 * (1 / PLAYER_STRAIGHT.width);
		
		
		public function init():void
		{
			BILLBOARDS = new Vector.<Image2D>();
			BILLBOARDS.push(BILLBOARD01, BILLBOARD02, BILLBOARD03, BILLBOARD04, BILLBOARD05, BILLBOARD06, BILLBOARD07, BILLBOARD08, BILLBOARD09);
			
			PLANTS = new Vector.<Image2D>();
			PLANTS.push(TREE1, TREE2, DEAD_TREE1, DEAD_TREE2, PALM_TREE, BUSH1, BUSH2, CACTUS, STUMP, BOULDER1, BOULDER2, BOULDER3);
			
			CARS = new Vector.<Image2D>();
			CARS.push(CAR01, CAR02, CAR03, CAR04, SEMI, TRUCK);
		}
	}
}
