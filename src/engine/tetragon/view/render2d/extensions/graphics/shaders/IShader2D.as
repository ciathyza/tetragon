package tetragon.view.render2d.extensions.graphics.shaders
{
	import flash.display3D.Context3D;
	import flash.utils.ByteArray;


	public interface IShader2D
	{
		function get opCode():ByteArray
		function setConstants(context:Context3D, firstRegister:int):void
	}
}
