package tetragon.systems.racetrack.vo
{
	/**
	 * PPoint
	 * @author Hexagon
	 */
	public class PPoint
	{
		public var world:PWorld;
		public var camera:PCamera;
		public var screen:PScreen;
		
		
		public function PPoint(world:PWorld, camera:PCamera, screen:PScreen)
		{
			this.world = world;
			this.camera = camera;
			this.screen = screen;
		}
	}
}
