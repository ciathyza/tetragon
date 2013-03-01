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
	 * TextureAtlas class
	 *
	 * @author Hexagon
	 */
	public class TextureAtlas extends Atlas
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const TEXTURE_ATLAS:String = "TextureAtlas";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		
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
		 * Disposes the atlas.
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
		
		
		/**
		 * @inheritDoc
		 */
		override public function getImages(prefix:String = "", scale:Number = 1.0):*
		{
			var textures:Vector.<Texture2D> = new <Texture2D>[];
			var names:Vector.<String> = new <String>[];
			var name:String;
			
			for (name in _regions)
			{
				if (name.indexOf(prefix) == 0) names.push(name);
			}
			names.sort(Array.CASEINSENSITIVE);
			for each (name in names)
			{
				textures.push(getImage(name, scale));
			}
			
			return textures;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
	}
}
