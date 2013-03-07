package tetragon.view.render2d.extensions.graphics
{
	import tetragon.view.render2d.display.DisplayObjectContainer2D;


	public class Shape2D extends DisplayObjectContainer2D
	{
		public var graphics:Graphics2D;


		public function Shape2D()
		{
			graphics = new Graphics2D(this);
		}
	}
}
