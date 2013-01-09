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
	import tetragon.data.sprite.SpriteFrame;
	import tetragon.data.sprite.SpriteSheet;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.file.resource.loaders.XMLResourceLoader;

	
	/**
	 * Data parser for parsing spritesheet data files.
	 */
	public class SpriteSheetDataParser extends DataObjectParser implements IFileDataParser
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
			
			for each (var x:XML in _xml.spriteSheet)
			{
				/* Get the current item's ID. */
				var id:String = extractString(x, "@id");
				
				/* Only parse the item(s) that we want! */
				if (!loader.hasResourceID(id)) continue;
				
				// TODO It could happen that the user specifies a non-existent resource ID
				// in the resource index file in which case the parser would not parse anything
				// but also doesn't give any warning. Optimally all data parsers should check
				// if any resource has been parsed at all and if parsed resource count is 0
				// they should produce a warning that a resource ID might be misnamed.
				
				/* Create new SpriteSheet definition. */
				var s:SpriteSheet = new SpriteSheet(id);
				
				s.frameWidth = extractNumber(x, "@frameWidth");
				s.frameHeight = extractNumber(x, "@frameHeight");
				s.frameOffsetH = extractNumber(x, "@frameOffsetH");
				s.frameOffsetV = extractNumber(x, "@frameOffsetV");
				s.frameGapH = extractNumber(x, "@frameGapH");
				s.frameGapV = extractNumber(x, "@frameGapV");
				s.startFrame = extractNumber(x, "@startFrame");
				s.guidePixelColor = extractColorValue(x, "@guidePixelColor");
				s.backgroundColor = extractColorValue(x, "@backgroundColor");
				s.irregular = extractBoolean(x, "@irregular");
				s.transparent = extractBoolean(x, "@transparent");
				s.imageID = extractString(x, "@imageID");
				checkReferencedID("imageID", s.imageID);
				
				/* Parse frames if they are already defined in the XML. */
				var len:int = (x.frames.frame as XMLList).length();
				if (len > 0)
				{
					var c:int = 0;
					var frames:Vector.<SpriteFrame> = new Vector.<SpriteFrame>(len, true);
					for each (var f:XML in x.frames.frame)
					{
						var frame:SpriteFrame = new SpriteFrame();
						frame.id = extractString(f, "@id");
						frame.registrationPoint = extractString(f, "@registrationPoint");
						frames[c++] = frame;
					}
					s.frames = frames;
				}
				
				index.addDataResource(s);
			}
			
			dispose();
		}
	}
}
