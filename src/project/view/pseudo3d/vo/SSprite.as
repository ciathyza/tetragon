package view.pseudo3d.vo
{
	import tetragon.view.render2d.display.Image2D;
	
	
	/**
	 * SSprite
	 * @author Hexagon
	 */
	public class SSprite
	{
		public var source:Image2D;
		public var offset:Number;
		
		
		public function SSprite(source:Image2D, offset:Number = 0.0)
		{
			this.source = source;
			this.offset = offset;
		}
	}
}
