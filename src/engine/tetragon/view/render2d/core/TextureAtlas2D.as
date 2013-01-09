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
package tetragon.view.render2d.core
{
	import flash.geom.Rectangle;


	/**
	 * A texture atlas is a collection of many smaller textures in one big image. This
	 * class is used to access textures from such an atlas.
	 * 
	 * <p>
	 * Using a texture atlas for your textures solves two problems:
	 * </p>
	 * 
	 * <ul>
	 * <li>There is always one texture active at a given moment. Whenever you change the
	 * active texture, a "texture-switch" has to be executed, and that switch takes time.</li>
	 * <li>Any Stage3D texture has to have side lengths that are powers of two. Starling
	 * hides this limitation from you, but at the cost of additional graphics memory.</li>
	 * </ul>
	 * 
	 * <p>
	 * By using a texture atlas, you avoid both texture switches and the power-of-two
	 * limitation. All textures are within one big "super-texture", and Starling takes
	 * care that the correct part of this texture is displayed.
	 * </p>
	 * 
	 * <p>
	 * There are several ways to create a texture atlas. One is to use the atlas generator
	 * script that is bundled with Starling's sibling, the <a
	 * href="http://www.sparrow-framework.org"> Sparrow framework</a>. It was only tested
	 * in Mac OS X, though. A great multi-platform alternative is the commercial tool <a
	 * href="http://www.texturepacker.com"> Texture Packer</a>.
	 * </p>
	 * 
	 * <p>
	 * Whatever tool you use, Starling expects the following file format:
	 * </p>
	 * 
	 * <listing> &lt;TextureAtlas imagePath='atlas.png'&gt; &lt;SubTexture
	 * name='texture_1' x='0' y='0' width='50' height='50'/&gt; &lt;SubTexture
	 * name='texture_2' x='50' y='0' width='20' height='30'/&gt; &lt;/TextureAtlas&gt;
	 * </listing>
	 * 
	 * <p>
	 * If your images have transparent areas at their edges, you can make use of the
	 * <code>frame</code> property of the Texture class. Trim the texture by removing the
	 * transparent edges and specify the original texture size like this:
	 * </p>
	 * 
	 * <listing> &lt;SubTexture name='trimmed' x='0' y='0' height='10' width='10'
	 * frameX='-10' frameY='-10' frameWidth='30' frameHeight='30'/&gt; </listing>
	 */
	public class TextureAtlas2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _atlasTexture:Texture2D;
		/** @private */
		private var _textureRegions:Object;
		/** @private */
		private var _textureFrames:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Create a texture atlas from a texture by parsing the regions from an XML file.
		 * 
		 * @param texture
		 * @param atlasXML
		 */
		public function TextureAtlas2D(texture:Texture2D, atlasXML:XML = null)
		{
			_atlasTexture = texture;
			_textureRegions = {};
			_textureFrames = {};
			
			if (atlasXML) parseAtlasXML(atlasXML);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the atlas texture.
		 */
		public function dispose():void
		{
			_atlasTexture.dispose();
		}
		
		
		/**
		 * Retrieves a subtexture by name. Returns <code>null</code> if it is not found.
		 * 
		 * @param name
		 * @return Texture2D or null.
		 */
		public function getTexture(name:String):Texture2D
		{
			var region:Rectangle = _textureRegions[name];
			if (!region) return null;
			else return Texture2D.fromTexture(_atlasTexture, region, _textureFrames[name]);
		}
		
		
		/**
		 * Returns all textures that start with a certain string, sorted alphabetically
		 * (especially useful for "MovieClip").
		 * 
		 * @param prefix
		 * @return Vector
		 */
		public function getTextures(prefix:String = ""):Vector.<Texture2D>
		{
			var textures:Vector.<Texture2D> = new <Texture2D>[];
			var names:Vector.<String> = new <String>[];
			var name:String;
			
			for (name in _textureRegions)
			{
				if (name.indexOf(prefix) == 0) names.push(name);
			}
			names.sort(Array.CASEINSENSITIVE);
			for each (name in names)
			{
				textures.push(getTexture(name));
			}
			
			return textures;
		}
		
		
		/**
		 * Creates a region for a subtexture and gives it a name.
		 * 
		 * @param name
		 * @param region
		 * @param frame
		 */
		public function addRegion(name:String, region:Rectangle, frame:Rectangle = null):void
		{
			_textureRegions[name] = region;
			if (frame) _textureFrames[name] = frame;
		}
		
		
		/**
		 * Removes a region with a certain name.
		 * 
		 * @param name
		 */
		public function removeRegion(name:String):void
		{
			delete _textureRegions[name];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function parseAtlasXML(xml:XML):void
		{
			for each (var st:XML in xml.SubTexture)
			{
				var name:String = st.attribute("name");
				var x:Number = parseFloat(st.attribute("x"));
				var y:Number = parseFloat(st.attribute("y"));
				var w:Number = parseFloat(st.attribute("width"));
				var h:Number = parseFloat(st.attribute("height"));
				var frameX:Number = parseFloat(st.attribute("frameX"));
				var frameY:Number = parseFloat(st.attribute("frameY"));
				var frameW:Number = parseFloat(st.attribute("frameWidth"));
				var frameH:Number = parseFloat(st.attribute("frameHeight"));
				var region:Rectangle = new Rectangle(x, y, w, h);
				
				var frame:Rectangle = frameW > 0 && frameH > 0
					? new Rectangle(frameX, frameY, frameW, frameH)
					: null;
				
				addRegion(name, region, frame);
			}
		}
	}
}
