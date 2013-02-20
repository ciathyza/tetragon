package view.pseudo3d.vo
{
	import tetragon.view.render2d.display.Image2D;
	
	
	/**
	 * Car
	 * @author Hexagon
	 */
	public class Car
	{
		public var offset:Number;
		public var z:Number;
		public var sprite:Image2D;
		public var speed:Number;
		
		
		public function Car(offset:Number, z:Number, sprite:Image2D, speed:Number)
		{
			this.offset = offset;
			this.z = z;
			this.sprite = sprite;
			this.speed = speed;
		}
	}
}
