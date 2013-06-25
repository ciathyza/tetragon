package tetragon.util.potrace.backend
{
	import tetragon.debug.Log;

	import flash.geom.Point;


	public class LoggingBackend implements IBackend
	{
		public function init(width:int, height:int):void
		{
			Log.trace("Canvas width:" + width + ", height:" + height, this);
		}


		public function initShape():void
		{
			Log.trace("  Shape", this);
		}


		public function initSubShape(positive:Boolean):void
		{
			Log.trace("    SubShape positive:" + positive, this);
		}


		public function moveTo(a:Point):void
		{
			Log.trace("      MoveTo a:" + a, this);
		}


		public function addBezier(a:Point, cpa:Point, cpb:Point, b:Point):void
		{
			Log.trace("      Bezier a:" + a + ", cpa:" + cpa + ", cpb:" + cpb + ", b:" + b, this);
		}


		public function addLine(a:Point, b:Point):void
		{
			Log.trace("      Line a:" + a + ", b:" + b, this);
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
