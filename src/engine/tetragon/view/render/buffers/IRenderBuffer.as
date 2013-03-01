package tetragon.view.render.buffers
{
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	
	
	/**
	 * IRenderBuffer
	 * @author Hexagon
	 */
	public interface IRenderBuffer
	{
		/**
		 * Clears the render buffer.
		 */
		function clear():void;
		
		
		/**
		 * Draws a filled, four-sided polygon onto the render buffer.
		 * 
		 * @param x1		first point x coord
		 * @param y1		first point y coord 
		 * @param x2		second point x coord
		 * @param y2		second point y coord
		 * @param x3		third point x coord
		 * @param y4		third point y coord
		 * @param color		color (0xRRGGBB)
		 * @param mixColor
		 * @param mixAlpha
		 */
		function drawQuad(x1:Number, y1:Number, x2:Number, y2:Number,
			x3:Number, y3:Number, x4:Number, y4:Number, color:uint,
			mixColor:uint, mixAlpha:Number = 1.0):void;
		
		
		/**
		 * Fast method to blit a rectangle onto the render buffer.
		 * 
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * @param color
		 * @param mixColor
		 * @param mixAlpha
		 */
		function blitRect(x:int, y:int, w:int, h:int, color:uint, mixColor:uint = 0x000000,
			mixAlpha:Number = 1.0):void;
		
		
		/**
		 * Draws a rectangle shape onmto the render buffer, using the draw API.
		 * 
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * @param color
		 * @param alpha
		 */
		function drawRect(x:int, y:int, w:int, h:int, color:uint, alpha:Number = 1.0):void;
		
		
		/**
		 * Fast method to blit a bitmap onto the render buffer.
		 * 
		 * @param image
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 */
		function blitImage(image:BitmapData, x:int, y:int, w:int, h:int):void;
		
		
		/**
		 * Draws a display object onto the render buffer using the draw API.
		 * 
		 * @param image
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * @param scale
		 * @param mixColor
		 * @param mixAlpha
		 */
		function drawImage(image:IBitmapDrawable, x:int, y:int, w:int, h:int,
			scale:Number = 1.0, mixColor:uint = 0x000000, mixAlpha:Number = 1.0):void;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The fill color of the render buffer.
		 */
		function get fillColor():uint;
		function set fillColor(v:uint):void;
	}
}
