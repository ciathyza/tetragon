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
	import tetragon.data.DataObject;
	import tetragon.data.texture.SubTextureBounds;
	import tetragon.file.resource.ResourceIndex;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
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
		private var _image:BitmapData;
		/** @private */
		private var _spriteRegions:Object;
		/** @private */
		private var _spriteFrames:Object;
		/** @private */
		private var _processed:Boolean;
		
		/** @private */
		private static var _point:Point;
			
		
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
			_spriteRegions = {};
			_spriteFrames = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the atlas.
		 */
		override public function dispose():void
		{
			if (!_image) return;
			_image.dispose();
		}
		
		
		/**
		 * Retrieves a sprite by name. Returns <code>null</code> if it is not found.
		 * 
		 * @param id
		 * @return BitmapData or null.
		 */
		public function getSprite(id:String):BitmapData
		{
			var region:Rectangle = _spriteRegions[id];
			if (!_image || !region) return ResourceIndex.getPlaceholderImage();
			if (!_point) _point = new Point(0, 0);
			var sprite:BitmapData = new BitmapData(region.width, region.height, true, 0x00000000);
			sprite.copyPixels(_image, region, _point);
			return sprite;
		}
		
		
		/**
		 * Returns all sprites that start with a certain string, sorted alphabetically
		 * 
		 * @param prefix
		 * @return A Vector of BitmapDatas.
		 */
		public function getSprites(prefix:String = ""):Vector.<BitmapData>
		{
			var sprites:Vector.<BitmapData> = new <BitmapData>[];
			var names:Vector.<String> = new <String>[];
			var name:String;
			
			for (name in _spriteRegions)
			{
				if (name.indexOf(prefix) == 0) names.push(name);
			}
			names.sort(Array.CASEINSENSITIVE);
			for each (name in names)
			{
				sprites.push(getSprite(name));
			}
			
			return sprites;
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
			_spriteRegions[id] = region;
			if (frame) _spriteFrames[id] = frame;
		}
		
		
		/**
		 * Removes a region with a certain name.
		 * 
		 * @param id
		 */
		public function removeRegion(id:String):void
		{
			delete _spriteRegions[id];
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dump():String
		{
			var s:String = toString();
			for (var i:uint = 0; i < _subTextureBounds.length; i++)
			{
				var stb:SubTextureBounds = _subTextureBounds[i];
				s += "\n\t" + stb.id;
			}
			return s;
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
		
		
		public function get image():BitmapData
		{
			return _image;
		}
		public function set image(v:BitmapData):void
		{
			_image = v;
		}
		
		
		public function get spriteRegions():Object
		{
			return _spriteRegions;
		}
		
		
		public function get spriteFrames():Object
		{
			return _spriteFrames;
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
