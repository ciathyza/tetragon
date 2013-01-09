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
package tetragon.file.parsers
{
	import tetragon.data.sprite.SpriteAtlas;
	import tetragon.data.sprite.SubTextureBounds;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.file.resource.loaders.XMLResourceLoader;

	
	/**
	 * Data parser for parsing Sparrow texture atlas data files.
	 */
	public class SpriteAtlasDataParser extends DataObjectParser implements IFileDataParser
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function parse(loader:XMLResourceLoader, model:*):void
		{
			_xml = loader.xml;
			const index:ResourceIndex = model;
			
			for each (var xml:XML in _xml.spriteAtlas)
			{
				/* Get the current item's ID. */
				var id:String = extractString(xml, "@id");
				
				/* Only parse the item(s) that we want! */
				if (!loader.hasResourceID(id)) continue;
				
				/* Parse sub textures first. */
				var len:int = (xml.SubTexture as XMLList).length();
				if (len > 0)
				{
					var c:int = 0;
					var subTextures:Vector.<SubTextureBounds> = new Vector.<SubTextureBounds>(len, true);
					for each (var s:XML in xml.SubTexture)
					{
						var st:SubTextureBounds = new SubTextureBounds(extractString(s, "@name"));
						st.x = extractNumber(s, "@x");
						st.y = extractNumber(s, "@y");
						st.width = extractNumber(s, "@width");
						st.height = extractNumber(s, "@height");
						st.frameX = extractNumber(s, "@frameX");
						st.frameY = extractNumber(s, "@frameY");
						st.frameWidth = extractNumber(s, "@frameWidth");
						st.frameHeight = extractNumber(s, "@frameHeight");
						subTextures[c++] = st;
					}
				}
				
				/* Create new SpriteAtlas definition. */
				var sa:SpriteAtlas = new SpriteAtlas(id, extractString(xml, "@imageID"), subTextures);
				checkReferencedID("imageID", sa.imageID);
				index.addDataResource(sa);
			}
			
			dispose();
		}
	}
}
