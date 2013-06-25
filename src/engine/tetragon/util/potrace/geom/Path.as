package tetragon.util.potrace.geom
{
	import tetragon.core.types.PointInt;
	
	
	public class Path
	{
		public var area:int;
		public var monotonIntervals:Vector.<MonotonInterval>;
		public var pt:Vector.<PointInt>;
		public var lon:Vector.<int>;
		public var sums:Vector.<SumStruct>;
		public var po:Vector.<int>;
		public var curves:PrivCurve;
		public var optimizedCurves:PrivCurve;
		public var fCurves:PrivCurve;
	}
}
