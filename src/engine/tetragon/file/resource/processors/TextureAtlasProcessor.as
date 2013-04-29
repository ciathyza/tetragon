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
package tetragon.file.resource.processors
{
	import tetragon.Main;
	import tetragon.data.atlas.SubTextureBounds;
	import tetragon.data.atlas.TextureAtlas;
	import tetragon.view.render2d.textures.Texture2D;

	import com.hexagonstar.types.PointInt;
	import com.hexagonstar.util.potrace.Polygonizer;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	
	
	/**
	 * Processes texture atlas data so that it is ready for use. This processor parses
	 * through TextureAtlas resources and generates the single frames of a texture atlas.
	 */
	public class TextureAtlasProcessor extends ResourceProcessor
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _polygonizer:Polygonizer;
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function processResources():Boolean
		{
			for (var i:uint = 0; i < resources.length; i++)
			{
				var textureAtlas:TextureAtlas = resources[i].content;
				
				if (!textureAtlas)
				{
					return false;
				}
				if (textureAtlas.processed)
				{
					return true;
				}
				if (textureAtlas.subTextureCount < 1)
				{
					error("Cannot process texture atlas \"" + textureAtlas.id
						+ "\" because it has no subtextures defined.");
					continue;
				}
				
				var image:* = resourceIndex.getResourceContent(textureAtlas.imageID);
				var alpha:* = resourceIndex.getResourceContent(textureAtlas.alphaImageID);
				
				if (image is BitmapData)
				{
					textureAtlas.source = Texture2D.fromBitmapData(image);
				}
				else if (image is ByteArray)
				{
					var bytes:ByteArray = image;
					var sig:String = String.fromCharCode(bytes[0], bytes[1], bytes[2]);
					if (sig == "ATF")
					{
						if (Main.instance.appInfo.swfVersion < 17)
						{
							error("ATF textures require at least SWF version 17!");
							continue;
						}
						else
						{
							try
							{
								textureAtlas.source = Texture2D.fromATFData(bytes);
							}
							catch (err:Error)
							{
								error("ATF texture atlas could not be created. (" + err.message + ")");
								continue;
							}
						}
					}
					else
					{
						error("Cannot process texture atlas \"" + textureAtlas.id
							+ "\". Invalid ATF format!");
						continue;
					}
				}
				else if (image == null)
				{
					error("Cannot process texture atlas \"" + textureAtlas.id
						+ "\". Required texture atlas image \"" + textureAtlas.imageID
						+ "\" is null.");
					continue;
				}
				else
				{
					error("Cannot process texture atlas \"" + textureAtlas.id
						+ "\". Required texture atlas image \"" + textureAtlas.imageID
						+ "\" is an unsupported format.");
					continue;
				}
				
				processTextureAtlas(textureAtlas, alpha);
			}
			return true;
		}
		
		
		/**
		 * Processes a texture atlas.
		 */
		private function processTextureAtlas(textureAtlas:TextureAtlas, alpha:* = null):void
		{
			var len:uint = textureAtlas.subTextureCount;
			var alphaBitmap:BitmapData = (alpha && alpha is BitmapData) ? alpha : null;
			var p:Point;
			var mask:BitmapData;
			var polygonData:Vector.<PointInt>;
			
			for (var i:uint = 0; i < len; i++)
			{
				var s:SubTextureBounds = textureAtlas.subTextureBounds[i];
				var region:Rectangle = new Rectangle(s.x, s.y, s.width, s.height);
				var frame:Rectangle = s.frameWidth > 0 && s.frameHeight > 0
					? new Rectangle(s.frameX, s.frameY, s.frameWidth, s.frameHeight)
					: null;
				
				if (alphaBitmap)
				{
					if (!p) p = new Point(0, 0);
					if (!_polygonizer) _polygonizer = new Polygonizer(2, 6);
					
					mask = new BitmapData(region.width, region.height, false, 0x000000);
					// TODO Add support for regions with frames!
					mask.copyPixels(alphaBitmap, region, p);
					polygonData = _polygonizer.polygonize(mask);
				}
				
				textureAtlas.addRegion(s.id, region, frame, mask, polygonData);
			}
			
			textureAtlas.processed = true;
		}
	}
}
