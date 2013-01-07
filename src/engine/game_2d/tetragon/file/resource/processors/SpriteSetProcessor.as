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
	import tetragon.data.sprite.SpriteFrame;
	import tetragon.data.sprite.SpriteObject;
	import tetragon.data.sprite.SpriteSequence;
	import tetragon.data.sprite.SpriteSet;
	import tetragon.data.sprite.SpriteSheet;
	import tetragon.file.resource.Resource;
	
	
	/**
	 * Processes spriteset data so that it is ready for use. This processor parses
	 * through SpriteSet resources and ...
	 */
	public class SpriteSetProcessor extends ResourceProcessor
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _spriteSheetProcessor:SpriteSheetProcessor;
		private var _defaultSpriteSheet:SpriteSheet;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		protected function get spriteSheetProcessor():SpriteSheetProcessor
		{
			if (!_spriteSheetProcessor) _spriteSheetProcessor = new SpriteSheetProcessor();
			return _spriteSheetProcessor;
		}
		
		
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
				var spriteSet:SpriteSet = resources[i].content;
				if (!spriteSet) continue;
				processSpriteSet(spriteSet);
			}
			
			return true;
		}
		
		
		private function processSpriteSet(spriteSet:SpriteSet):void
		{
			/* Get the referenced spriteSheet and process it if it hasn't yet been processed. */
			var r:Resource = resourceIndex.getResource(spriteSet.spriteSheetID);
			if (!r || !r.content)
			{
				error("Cannot process spriteset \"" + spriteSet.id
					+ "\" because the referenced spritesheet \"" + spriteSet.spriteSheetID
					+ "\" is null.");
				return;
			}
			if (!(r.content is SpriteSheet))
			{
				error("Cannot process spriteset \"" + spriteSet.id
					+ "\" because the referenced spritesheet \"" + spriteSet.spriteSheetID
					+ "\" is not of type SpriteSheet.");
				return;
			}
			var spriteSheet:SpriteSheet = r.content;
			if (!spriteSheet.processed)
			{
				spriteSheetProcessor.process(r);
			}
			
			_defaultSpriteSheet = spriteSheet;
			spriteSet.spriteSheet = _defaultSpriteSheet;
			
			/* Populate the tilesheet's sprite's spritesequence's frames (phew!) with images. */
			var sprites:Object = spriteSet.sprites;
			var sequences:Object = null;
			var frameIDs:Vector.<String> = null;
			var frameID:String = null;
			var frame:SpriteFrame = null;
			var len:uint = 0;
			var referedSpriteSheet:SpriteSheet;
			
			for each (var spr:SpriteObject in sprites)
			{
				referedSpriteSheet = getSpriteSheetFor(spr);
				if (!referedSpriteSheet) continue;
				
				sequences = spr.sequences;
				for each (var seq:SpriteSequence in sequences)
				{
					frameIDs = seq.frameIDs;
					len = frameIDs.length;
					seq.frames = new Vector.<SpriteFrame>(len, true);
					for (var i:uint = 0; i < len; i++)
					{
						frameID = frameIDs[i];
						frame = referedSpriteSheet.getFrameByID(frameID);
						
						/* TODO Check if it's OK here that frames are shared among multiple sprite
						 * sequences or if they need to be cloned so that every sequence
						 * that refers to a frame has it's own instance! */
						seq.frames[i] = frame;
					}
				}
			}
		}


		private function getSpriteSheetFor(sprite:SpriteObject):SpriteSheet
		{
			/* If the sprite has no spriteSheet reference, use the spriteset one's. */
			if (sprite.spriteSheetID == null) return _defaultSpriteSheet;
			
			var r:Resource = resourceIndex.getResource(sprite.spriteSheetID);
			if (!r || !r.content)
			{
				warn("The sprite \"" + sprite.id + "\" references the spritesheet \""
					+ sprite.spriteSheetID + "\" which was not found in the resource index.");
				return null;
			}
			if (!(r.content is SpriteSheet))
			{
				warn("The sprite \"" + sprite.id + "\" references the spritesheet \""
					+ sprite.spriteSheetID + "\" which is not of type SpriteSheet.");
				return null;
			}
			var spriteSheet:SpriteSheet = r.content;
			if (!spriteSheet.processed)
			{
				spriteSheetProcessor.process(r);
			}
			return spriteSheet;
		}
		
		
//		override protected function processResources():Boolean
//		{
//			_spriteSets = new Vector.<SpriteSet>();
//			_spriteSheetProcessor = new SpriteSheetProcessor();
//			
//			for (var i:uint = 0; i < resources.length; i++)
//			{
//				var spriteSet:SpriteSet = resources[i].content;
//				
//				if (!spriteSet)
//				{
//					return false;
//				}
//				if (spriteSet.sequenceCount < 1)
//				{
//					fail("Cannot process spriteset \"" + spriteSet.id + "\" because it has no sequences.");
//					continue;
//				}
//				
//				var r:Resource = resourceIndex.getResource(spriteSet.spriteSheetID);
//				if (!r || !r.content)
//				{
//					fail("Cannot process spriteset \"" + spriteSet.id
//						+ "\" because the required spritesheet \"" + spriteSet.spriteSheetID
//						+ "\" is null.");
//					continue;
//				}
//				
//				_spriteSheetProcessor.process(r);
//				spriteSet.spriteSheet = r.content;
//			}
//			
//			return true;
//		}
		
		
//		private function extractFrame(image:BitmapData, r:Rectangle, guidePixelColor:uint, c:int):void
//		{
//			Debug.trace(c + ". " + r.toString());
//			var step:int = 0;
//			var w:int = 0;
//			for (var y:int = r.y; y < r.height; y++)
//			{
//				for (var x:int = r.x; x <= r.width; x++)
//				{
//					if (x >= image.width)
//					{
//						x = 0;
//						w = 0;
//					}
//					
//					var p:uint = image.getPixel(x, y);
//					if (p == guidePixelColor)
//					{
//						/* We found top left. */
//						if (step == 0)
//						{
//							r.x = x + 1;
//							r.y = y + 1;
//							step = 1;
//							Debug.trace("Found TL: " + r.toString());
//						}
//						/* We found top right. */
//						else if (step == 1)
//						{
//							r.width = w;
//							step = 2;
//							Debug.trace(w);
//							Debug.trace("Found TR: " + r.toString());
//						}
//						/* We found bottom right. */
//						else if (step == 2)
//						{
//							r.width = w - 1;
//							r.height = y - 1;
//							step = 3;
//							Debug.trace("Found BR: " + r.toString());
//							var bd:BitmapData = new BitmapData(r.width, r.height, false, 0x0000FF);
//							bd.copyPixels(image, r, new Point(0, 0));
//							var b:Bitmap = new Bitmap(bd);
//							b.x = c * 180;
//							Main.instance.contextView.addChild(b);
//							
//							r.x = r.x + r.width;
//							r.y = 0; //r.y + r.height;
//							r.width = image.width - r.x;
//							r.height = image.height - r.y;
//							Debug.trace("Reset : " + r.toString());
//							
//							break;
//						}
//					}
//					
//					if (step == 1) w++;
//				}
//			}
//		}
	}
}
