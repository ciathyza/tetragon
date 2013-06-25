package tetragon.util.potrace.backend
{
	import tetragon.core.types.PointInt;

	import flash.geom.Point;


	public class PolygonDataBackend implements IBackend
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _points:Vector.<PointInt>;
		private var _tolerance:int;
		private var _startPoint:PointInt;
		private var _prevPoint:Point;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function PolygonDataBackend(points:Vector.<PointInt> = null, tolerance:int = 10)
		{
			_points = points;
			_tolerance = tolerance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function moveTo(p:Point):void
		{
			if (!_points) return;
			_startPoint = new PointInt(p.x, p.y);
			_points.push(_startPoint);
		}
		
		
		public function addLine(a:Point, b:Point):void
		{
			if (!_points) return;
			var newPoint:Point = new Point(int(b.x), int(b.y));
			if (!_prevPoint || Point.distance(newPoint, _prevPoint) >= _tolerance)
			{
				_points.push(new PointInt(newPoint.x, newPoint.y));
			}
			_prevPoint = newPoint;
		}
		
		
		public function exitShape():void
		{
			if (!_points) return;
			_points.push(_startPoint);
		}
		
		
		public function init(width:int, height:int):void
		{
		}
		public function initShape():void
		{
		}
		public function initSubShape(positive:Boolean):void
		{
		}
		public function addBezier(a:Point, cpa:Point, cpb:Point, b:Point):void
		{
		}
		public function exitSubShape():void
		{
		}
		public function exit():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get points():Vector.<PointInt>
		{
			return _points;
		}
		public function set points(v:Vector.<PointInt>):void
		{
			_points = v;
		}
		
		
		public function get tolerance():int
		{
			return _tolerance;
		}
		public function set tolerance(v:int):void
		{
			_tolerance = v;
		}
	}
}
