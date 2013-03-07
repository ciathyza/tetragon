package tetragon.view.render2d.extensions.graphics.shaders.fragment
{
	import tetragon.view.render2d.extensions.graphics.shaders.AbstractShader2D;

	import flash.display3D.Context3DProgramType;


	/*
	 * A pixel shader that multiplies a single texture with constants (the color transform)
	 * and vertex color.
	 */
	public class TextureVertexColorFragmentShader2D extends AbstractShader2D
	{
		public function TextureVertexColorFragmentShader2D()
		{
			compileAGAL(Context3DProgramType.FRAGMENT,
				  "tex ft1, v1, fs0 <2d, repeat, linear> \n"
				+ "mul ft2, v0, fc0                      \n"
				+ "mul oc, ft1, ft2                        ");
		}
	}
}
