package tetragon.view.render2d.extensions.graphics.materials
{
	import tetragon.view.render2d.extensions.graphics.shaders.IShader2D;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;


	public interface IMaterial2D
	{
		function dispose():void
		function drawTriangles(context:Context3D, matrix:Matrix3D, vertexBuffer:VertexBuffer3D,
			indexBuffer:IndexBuffer3D, alpha:Number = 1):void;

		function set alpha(value:Number):void;
		function get alpha():Number;
		function set color(value:uint):void;
		function get color():uint;
		function set vertexShader(value:IShader2D):void;
		function get vertexShader():IShader2D;
		function set fragmentShader(value:IShader2D):void
		function get fragmentShader():IShader2D;
		function get textures():Vector.<Texture2D>;
		function set textures(value:Vector.<Texture2D>):void;
	}
}
