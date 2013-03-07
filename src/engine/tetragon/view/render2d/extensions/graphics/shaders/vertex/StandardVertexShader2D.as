package tetragon.view.render2d.extensions.graphics.shaders.vertex
{
	import tetragon.view.render2d.extensions.graphics.shaders.AbstractShader2D;

	import flash.display3D.Context3DProgramType;


	public class StandardVertexShader2D extends AbstractShader2D
	{
		public function StandardVertexShader2D()
		{
			var agal:String =
			"m44 op, va0, vc0 \n" +			// Apply matrix
			"mov v0, va1 \n" +				// Copy color to v0
			"mov v1, va2 \n";				// Copy UV to v1
			
			compileAGAL(Context3DProgramType.VERTEX, agal);
		}
	}
}
