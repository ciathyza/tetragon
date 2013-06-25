package tetragon.util.potrace.backend
{
	import tetragon.util.debug.HLog;

	import flash.geom.Point;


	public class LoggingBackend implements IBackend
	{
		public function init(width:int, height:int):void
		{
			HLog.trace("Canvas width:" + width + ", height:" + height);
		}


		public function initShape():void
		{
			HLog.trace("  Shape");
		}


		public function initSubShape(positive:Boolean):void
		{
			HLog.trace("    SubShape positive:" + positive);
		}


		public function moveTo(a:Point):void
		{
			HLog.trace("      MoveTo a:" + a);
		}


		public function addBezier(a:Point, cpa:Point, cpb:Point, b:Point):void
		{
			HLog.trace("      Bezier a:" + a + ", cpa:" + cpa + ", cpb:" + cpb + ", b:" + b);
		}


		public function addLine(a:Point, b:Point):void
		{
			HLog.trace("      Line a:" + a + ", b:" + b);
		}


		public function exitSubShape():void
		{
		}


		public function exitShape():void
		{
		}


		public function exit():void
		{
		}
	}
}
