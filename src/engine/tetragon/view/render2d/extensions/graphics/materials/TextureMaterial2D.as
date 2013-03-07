package tetragon.view.render2d.extensions.graphics.materials
{
	import tetragon.view.render2d.extensions.graphics.shaders.fragment.TextureVertexColorFragmentShader2D;
	import tetragon.view.render2d.extensions.graphics.shaders.vertex.StandardVertexShader2D;
	import tetragon.view.render2d.textures.Texture2D;


	public class TextureMaterial2D extends StandardMaterial2D
	{
		public function TextureMaterial2D(texture:Texture2D, color:uint = 0xFFFFFF)
		{
			super(new StandardVertexShader2D(), new TextureVertexColorFragmentShader2D());
			textures[0] = texture;
			this.color = color;
		}
	}
}
