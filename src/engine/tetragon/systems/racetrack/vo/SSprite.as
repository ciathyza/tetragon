package tetragon.systems.racetrack.vo
{
	import flash.display.BitmapData;
	
	
	/**
	 * SSprite
	 * @author Hexagon
	 */
	public class SSprite
	{
		public var source:BitmapData;
		public var offset:Number;
		
		
		public function SSprite(source:BitmapData, offset:Number = 0.0)
		{
			this.source = source;
			this.offset = offset;
		}
	}
}
