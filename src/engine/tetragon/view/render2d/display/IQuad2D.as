package tetragon.view.render2d.display
{
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.core.VertexData2D;

	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * IQuad2D
	 * @author Hexagon
	 */
	public interface IQuad2D
	{
		/**
		 * @inheritDoc
		 */
		function getBounds(targetSpace:DisplayObject2D, resultRect:Rectangle = null):Rectangle;
		
		
		/**
		 * Returns the color of a vertex at a certain index.
		 * 
		 * @param vertexID
		 */
		function getVertexColor(vertexID:int):uint;
		
		
		/**
		 * Sets the color of a vertex at a certain index.
		 * 
		 * @param vertexID
		 * @param color
		 */
		function setVertexColor(vertexID:int, color:uint):void;
		
		
		/**
		 * Returns the alpha value of a vertex at a certain index.
		 * 
		 * @param vertexID
		 */
		function getVertexAlpha(vertexID:int):Number;
		
		
		/**
		 * Sets the alpha value of a vertex at a certain index.
		 * 
		 * @param vertexID
		 * @param alpha
		 */
		function setVertexAlpha(vertexID:int, alpha:Number):void;
		
		
		/**
		 * Copies the raw vertex data to a VertexData instance.
		 * 
		 * @param targetData
		 * @param targetVertexID
		 */
		function copyVertexDataTo(targetData:VertexData2D, targetVertexID:int = 0):void;
		
		
		/**
		 * @inheritDoc
		 */
		function render(support:RenderSupport2D, parentAlpha:Number):void;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the color of the quad, or of vertex 0 if vertices have different colors.
		 */
		function get color():uint;
		
		/**
		 * Sets the colors of all vertices to a certain value.
		 */
		function set color(v:uint):void;
		
		
		function get transformationMatrix():Matrix;
		function get blendMode():String;
		
		/**
		 * @inheritDoc
		 */
		function get alpha():Number;
		function set alpha(v:Number):void;
		
		
		/**
		 * Returns true if the quad (or any of its vertices) is non-white or non-opaque.
		 */
		function get tinted():Boolean;
	}
}
