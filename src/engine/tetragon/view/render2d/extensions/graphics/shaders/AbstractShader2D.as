package tetragon.view.render2d.extensions.graphics.shaders
{
	import tetragon.view.render2d.core.RenderSupport2D;

	import flash.display3D.Context3D;
	import flash.utils.ByteArray;


	public class AbstractShader2D implements IShader2D
	{
		protected var _opCode:ByteArray;


		public function AbstractShader2D()
		{
		}


		protected function compileAGAL(shaderType:String, agal:String):void
		{
			_opCode = RenderSupport2D.agal.assemble(shaderType, agal);
		}


		public function get opCode():ByteArray
		{
			return _opCode;
		}


		public function setConstants(context:Context3D, firstRegister:int):void
		{
		}
	}
}
