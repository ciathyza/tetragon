package tetragon.view.render2d.extensions.graphics
{
	import tetragon.view.render2d.display.DisplayObjectContainer2D;


	public class Shape2D extends DisplayObjectContainer2D
	{
		private var _graphics:Graphics2D;


		public function Shape2D()
		{
			_graphics = new Graphics2D(this);
		}


		public function get graphics():Graphics2D
		{
			return _graphics;
		}
	}
}
