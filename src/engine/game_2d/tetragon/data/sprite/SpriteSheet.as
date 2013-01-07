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

	import flash.display.BitmapData;
	
	
	/**
	 * Defines a sprite sheet, i.e an image that is divided into frames, each containing
	 * a SpriteFrame object. Frames sizes can be either regular (every frame has the same
	 * size) or irregular (frames have different sizes).
	 */
	public class SpriteSheet extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const SPRITE_SHEET:String = "SpriteSheet";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _frameWidth:int;
		private var _frameHeight:int;
		private var _frameOffsetH:int;
		private var _frameOffsetV:int;
		private var _frameGapH:int;
		private var _frameGapV:int;
		private var _startFrame:int;
		private var _guidePixelColor:uint;
		private var _backgroundColor:uint;
		private var _irregular:Boolean;
		private var _transparent:Boolean;
		private var _imageID:String;
		private var _image:BitmapData;
		
		private var _frames:Vector.<SpriteFrame>;
		private var _frameIndices:Object;
		private var _processed:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function SpriteSheet(id:String)
		{
			_id = id;
			_processed = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the sprite frame of the specified index.
		 * 
		 * @param index
		 * @return A SpriteFrame object or null.
		 */
		public function getFrame(index:uint):SpriteFrame
		{
			if (!_frames || index < 0 || index >= _frames.length) return null;
			return _frames[index];
		}
		
		
		/**
		 * Returns the sprite frame of the specified ID. Can be used to get a specific frame
		 * without using sprite sets.
		 * 
		 * @param frameID
		 * @return A SpriteFrame object or null.
		 */
		public function getFrameByID(frameID:String):SpriteFrame
		{
			if (!_frameIndices) return null;
			var index:uint = _frameIndices[frameID];
			return getFrame(index);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString(...args):String
		{
			if (_frames) return super.toString("id=" + _id, "frames=" + _frames.length);
			return super.toString();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get frameWidth():int
		{
			return _frameWidth;
		}
		public function set frameWidth(v:int):void
		{
			_frameWidth = v;
		}
		
		
		public function get frameHeight():int
		{
			return _frameHeight;
		}
		public function set frameHeight(v:int):void
		{
			_frameHeight = v;
		}
		
		
		public function get frameOffsetH():int
		{
			return _frameOffsetH;
		}
		public function set frameOffsetH(v:int):void
		{
			_frameOffsetH = v;
		}
		
		
		public function get frameOffsetV():int
		{
			return _frameOffsetV;
		}
		public function set frameOffsetV(v:int):void
		{
			_frameOffsetV = v;
		}
		
		
		public function get frameGapH():int
		{
			return _frameGapH;
		}
		public function set frameGapH(v:int):void
		{
			_frameGapH = v;
		}
		
		
		public function get frameGapV():int
		{
			return _frameGapV;
		}
		public function set frameGapV(v:int):void
		{
			_frameGapV = v;
		}
		
		
		public function get startFrame():int
		{
			return _startFrame;
		}
		public function set startFrame(v:int):void
		{
			_startFrame = v;
		}
		
		
		public function get guidePixelColor():uint
		{
			return _guidePixelColor;
		}
		public function set guidePixelColor(v:uint):void
		{
			_guidePixelColor = v;
		}
		
		
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		public function set backgroundColor(v:uint):void
		{
			_backgroundColor = v;
		}
		
		
		public function get irregular():Boolean
		{
			return _irregular;
		}
		public function set irregular(v:Boolean):void
		{
			_irregular = v;
		}
		
		
		public function get transparent():Boolean
		{
			return _transparent;
		}
		public function set transparent(v:Boolean):void
		{
			_transparent = v;
		}
		
		
		public function get imageID():String
		{
			return _imageID;
		}
		public function set imageID(v:String):void
		{
			_imageID = v;
		}
		
		
		public function get image():BitmapData
		{
			return _image;
		}
		public function set image(v:BitmapData):void
		{
			_image = v;
		}
		
		
		public function get frames():Vector.<SpriteFrame>
		{
			return _frames;
		}
		public function set frames(v:Vector.<SpriteFrame>):void
		{
			_frames = v;
			_frameIndices = {};
			if (!_frames) return;
			/* Map indices to IDs so frames can be quickly obtained by ID later. */
			for (var i:uint = 0; i < _frames.length; i++)
			{
				_frameIndices[_frames[i].id] = i;
			}
		}
		
		
		public function get frameCount():uint
		{
			if (!_frames) return 0;
			return _frames.length;
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
