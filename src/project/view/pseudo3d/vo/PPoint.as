package view.pseudo3d.vo
{
	/**
	 * PPoint
	 * @author Hexagon
	 */
	public class PPoint
	{
		public var world:PWorld;
		public var camera:Object;
		public var screen:Object;
		
		
		public function PPoint(world:PWorld, camera:Object, screen:Object)
		{
			this.world = world;
			this.camera = camera;
			this.screen = screen;
		}
	}
}
