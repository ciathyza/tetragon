package tetragon.view.render2d.extensions.graphics.shaders.fragment
{
	import tetragon.view.render2d.extensions.graphics.shaders.AbstractShader2D;

	import flash.display3D.Context3DProgramType;


	/*
	 * A pixel shader that multiplies the vertex color by the material color transform.
	 */
	public class VertexColorFragmentShader2D extends AbstractShader2D
	{
		public function VertexColorFragmentShader2D()
		{
			compileAGAL(Context3DProgramType.FRAGMENT, "mul oc, v0, fc0");
		}
	}
}
