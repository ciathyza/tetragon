package tetragon.view.render2d.extensions.graphics.shaders.fragment
{
	import tetragon.view.render2d.extensions.graphics.shaders.AbstractShader2D;

	import flash.display3D.Context3DProgramType;


	/*
	 * A pixel shader that multiplies a single texture with constants (the color transform).
	 */
	public class TextureFragmentShader2D extends AbstractShader2D
	{
		public function TextureFragmentShader2D()
		{
			compileAGAL(Context3DProgramType.FRAGMENT,
				  "tex ft1, v1, fs0 <2d, repeat, linear> \n"
				+ "mul oc, ft1, fc0                        ");
		}
	}
}
