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
package tetragon.data.sprite
{
	import flash.geom.Rectangle;
	import tetragon.data.DataObject;
	import tetragon.view.render2d.core.Texture2D;

	
	
	/**
	 * SpriteAtlas class
	 *
	 * @author Hexagon
	 */
	public class SpriteAtlas extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const SPRITE_ATLAS:String = "SpriteAtlas";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _imageID:String;
		/** @private */
		private var _subTextureBounds:Vector.<SubTextureBounds>;
		/** @private */
		private var _texture:Texture2D;
		/** @private */
		private var _textureRegions:Object;
		/** @private */
		private var _textureFrames:Object;
		/** @private */
		private var _processed:Boolean;
		
		
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
		public function SpriteAtlas(id:String, imageID:String,
			subTextureBounds:Vector.<SubTextureBounds>)
		{
			_id = id;
			_imageID = imageID;
			_subTextureBounds = subTextureBounds;
			_textureRegions = {};
			_textureFrames = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the atlas.
		 */
		override public function dispose():void
		{
			if (!_texture) return;
			_texture.dispose();
		}
		
		
		/**
		 * Retrieves a subtexture by name. Returns <code>null</code> if it is not found.
		 * 
		 * @param id
		 * @return Texture2D or null.
		 */
		public function getTexture(id:String):Texture2D
		{
			var region:Rectangle = _textureRegions[id];
			if (!region) return null;
			else return Texture2D.fromTexture(_texture, region, _textureFrames[id]);
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
		 * @param id
		 * @param region
		 * @param frame
		 */
		public function addRegion(id:String, region:Rectangle, frame:Rectangle = null):void
		{
			_textureRegions[id] = region;
			if (frame) _textureFrames[id] = frame;
		}
		
		
		/**
		 * Removes a region with a certain name.
		 * 
		 * @param id
		 */
		public function removeRegion(id:String):void
		{
			delete _textureRegions[id];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get subTextureBounds():Vector.<SubTextureBounds>
		{
			return _subTextureBounds;
		}
		
		
		public function get subTextureCount():uint
		{
			if (!_subTextureBounds) return 0;
			return _subTextureBounds.length;
		}
		
		
		public function get imageID():String
		{
			return _imageID;
		}
		
		
		public function get texture():Texture2D
		{
			return _texture;
		}
		public function set texture(v:Texture2D):void
		{
			_texture = v;
		}
		
		
		public function get textureRegions():Object
		{
			return _textureRegions;
		}
		
		
		public function get textureFrames():Object
		{
			return _textureFrames;
		}
		
		
		public function get processed():Boolean
		{
			return _processed;
		}
		public function set processed(v:Boolean):void
		{
			_processed = v;
		}
	}
}
