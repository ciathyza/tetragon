/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package tetragon.data.atlas
{
	import tetragon.view.render2d.textures.Texture2D;

	import flash.geom.Rectangle;
	
	
	/**
	 * A texture atlas is a collection of many smaller textures in one big image. This class
	 *  is used to access textures from such an atlas.
	 *  
	 *  <p>Using a texture atlas for your textures solves two problems:</p>
	 *  
	 *  <ul>
	 *    <li>There is always one texture active at a given moment. Whenever you change the active
	 *        texture, a "texture-switch" has to be executed, and that switch takes time.</li>
	 *    <li>Any Stage3D texture has to have side lengths that are powers of two. Render2D hides 
	 *        this limitation from you, but at the cost of additional graphics memory.</li>
	 *  </ul>
	 *  
	 *  <p>By using a texture atlas, you avoid both texture switches and the power-of-two 
	 *  limitation. All textures are within one big "super-texture", and Render2D takes care that 
	 *  the correct part of this texture is displayed.</p>
	 *  
	 *  <p>There are several ways to create a texture atlas. A great multi-platform 
	 *  alternative is the commercial tool <a href="http://www.texturepacker.com">
	 *  Texture Packer</a>.</p>
	 *  
	 *  <p>Whatever tool you use, Render2D expects the following file format:</p>
	 * 
	 *  <listing>
	 * 	&lt;TextureAtlas imagePath='atlas.png'&gt;
	 * 	  &lt;SubTexture name='texture_1' x='0'  y='0' width='50' height='50'/&gt;
	 * 	  &lt;SubTexture name='texture_2' x='50' y='0' width='20' height='30'/&gt; 
	 * 	&lt;/TextureAtlas&gt;
	 *  </listing>
	 *  
	 *  <p>If your images have transparent areas at their edges, you can make use of the 
	 *  <code>frame</code> property of the Texture class. Trim the texture by removing the 
	 *  transparent edges and specify the original texture size like this:</p>
	 * 
	 *  <listing>
	 * 	&lt;SubTexture name='trimmed' x='0' y='0' height='10' width='10'
	 * 	    frameX='-10' frameY='-10' frameWidth='30' frameHeight='30'/&gt;
	 *  </listing>
	 */
	public class TextureAtlas extends Atlas
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const TEXTURE_ATLAS:String = "TextureAtlas";
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param id
		 * @param imageID
		 * @param subTextureBounds
		 */
		public function TextureAtlas(id:String, imageID:String,
			subTextureBounds:Vector.<SubTextureBounds>)
		{
			super(id, imageID, subTextureBounds);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			if (!_source) return;
			(_source as Texture2D).dispose();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function getImage(id:String, scale:Number = 1.0):*
		{
			// TODO Add scaling!
			var region:Rectangle = _regions[id];
			if (!region) return null;
			return Texture2D.fromTexture(_source, region, _frames[id]);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
	}
}
