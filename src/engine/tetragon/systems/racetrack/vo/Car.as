package tetragon.systems.racetrack.vo
{
	
	
	/**
	 * Car
	 * @author Hexagon
	 */
	public class Car
	{
		public var offset:Number;
		public var z:Number;
		public var sprite:SSprite;
		public var speed:Number;
		public var percent:Number;
		
		
		public function Car(offset:Number, z:Number, sprite:SSprite, speed:Number)
		{
			this.offset = offset;
			this.z = z;
			this.sprite = sprite;
			this.speed = speed;
		}
	}
}
