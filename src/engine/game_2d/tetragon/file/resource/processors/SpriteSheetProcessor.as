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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import tetragon.data.sprite.SpriteFrame;
	import tetragon.data.sprite.SpriteSheet;

	
	
	/**
	 * Processes sprite sheet data so that it is ready for use. This processor parses
	 * through SpriteSheet resources and generates the single frames of a sprite sheet.
	 * After this processor successfully processed a sprite sheet, the sheets frames
	 * can be found in it's frames property.
	 * 
	 * TODO Add support for irregular sprite sheets.
	 */
	public class SpriteSheetProcessor extends ResourceProcessor
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		//private var _point:Point = new Point(0, 0);
		
		
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
				var spriteSheet:SpriteSheet = resources[i].content;
				
				if (!spriteSheet)
				{
					return false;
				}
				if (spriteSheet.processed)
				{
					return true;
				}
				if (spriteSheet.frameCount < 1)
				{
					error("Cannot process spriteSheet \"" + spriteSheet.id + "\" because it has no frames defined.");
					continue;
				}
				
				spriteSheet.image = resourceIndex.getResourceContent(spriteSheet.imageID);
				if (!spriteSheet.image)
				{
					error("Cannot process spriteSheet \"" + spriteSheet.id
						+ "\" because the required spritesheet image \"" + spriteSheet.imageID
						+ "\" is null.");
					continue;
				}
				
				if (!spriteSheet.irregular)
				{
					processSpriteSheet(spriteSheet);
				}
				else
				{
					processIrregularSpriteSheet(spriteSheet);
				}
			}
			return true;
		}
		
		
		/**
		 * Processes a spritesheet that has regular frame sizes, i.e. where all frames
		 * have the same width and height.
		 */
		private function processSpriteSheet(spriteSheet:SpriteSheet):void
		{
			var fb:FrameBounds = new FrameBounds();
			fb.x = fb.y = 0;
			fb.width = spriteSheet.frameWidth;
			fb.height = spriteSheet.frameHeight;
			
			var p:Point = new Point(0, 0);
			var image:BitmapData = spriteSheet.image;
			var imageWidth:int = image.width;
			var frames:Vector.<SpriteFrame> = spriteSheet.frames;
			var frameCount:uint = spriteSheet.frameCount;
			var transparent:Boolean = spriteSheet.transparent;
			var fillColor:uint = spriteSheet.backgroundColor;
			
			for (var i:uint = 0; i < frameCount; i++)
			{
				if (fb.x >= imageWidth)
				{
					fb.x = 0;
					fb.y += fb.height;
				}
				
				var f:SpriteFrame = frames[i];
				f.image = new BitmapData(fb.width, fb.height, transparent, fillColor);
				f.image.copyPixels(image, fb.rectangle, p);
				
				fb.x += fb.width;
			}
			
			spriteSheet.processed = true;
		}
		
		
		/**
		 * NOTE: Not working correctly yet! Needs more work!
		 */
		private function processIrregularSpriteSheet(spriteSheet:SpriteSheet):void
		{
			var image:BitmapData = spriteSheet.image;
			var guidePixelColor:uint = spriteSheet.guidePixelColor;
			var frameCount:uint = spriteSheet.frameCount;
			var r:FrameBounds = new FrameBounds();
			r.x = r.y = 0;
			r.width = image.width;
			r.height = image.height;
			
			var b:Bitmap = new Bitmap(image);
			//Main.instance.contextView.addChild(b);
			
			for (var c:uint = 0; c < frameCount; c++)
			{
				if (c == 2) break;
				//Debug.delimiter();
				//Debug.trace("Processing frame " + c + ". " + r.toString());
				extractIrregularFrame(image, r, guidePixelColor);
			}
			
			spriteSheet.processed = true;
		}
		
		
		private function extractIrregularFrame(image:BitmapData, r:FrameBounds, guidePixelColor:uint):void
		{
			var step:int = 0;
			
			for (var y:uint = r.y; y < r.height; y++)
			{
				for (var x:uint = r.x; x < r.width; x++)
				{
					if (image.getPixel(x, y) == guidePixelColor)
					{
						//Debug.trace("Found guide at x" + x + " y" + y);
						
						/* Found top left boundary. */
						if (step == 0)
						{
							r.x = x;// + 1;
							r.y = y;// + 1;
							step = 1;
							//Debug.trace("Found TL: " + r.toString());
						}
						/* Found top right boundary. */
						else if (step == 1)
						{
							r.width = x - r.x;// + 1;
							//r.x += 1;
							step = 2;
							//Debug.trace("Found TR: " + r.toString());
						}
						/* Found bottom right boundary. */
						else if (step == 2)
						{
							//r.width -= 1;
							r.height = y - 1;// - 2;
							step = 3;
							//Debug.trace("Found BR: " + r.toString());
							
							var extractX:uint = r.x + 1;
							var extractY:uint = r.y + 1;
							var extractW:uint = r.width - 1;
							var extractH:uint = r.height - 1;
							var bd:BitmapData = new BitmapData(extractW, extractH, true, 0x8800FF00);
							image.copyPixels(bd, bd.rect, new Point(extractX, extractY), bd, null, true);
							//bd.copyPixels(image, r.rectangle, _point);
							//var b:Bitmap = new Bitmap(bd);
							//b.x = 40;
							//b.y = 40;
							//Main.instance.contextView.addChild(b);
							
							/* Reset for next frame. */
							r.x = r.x + r.width;
							r.y = 0;
							r.width = image.width - r.x;
							r.height = image.height - r.y;
							//Debug.trace("Reset: " + r.toString());
							
							return;
						}
					}
					//image.setPixel32(x, y, 0x550000FF);
				}
			}
		}
	}
}


import flash.geom.Rectangle;


final class FrameBounds
{
	public var x:uint;
	public var y:uint;
	public var width:uint;
	public var height:uint;
	
	public function get x2():uint
	{
		return x + width;
	}
	public function get y2():uint
	{
		return y + height;
	}
	public function get rectangle():Rectangle
	{
		return new Rectangle(x, y, width, height);
	}
	
	
	public function toString():String
	{
		return "[x=" + x + ", y=" + y + ", width=" + width + ", height=" + height + "]";
		//return "[x=" + x + ", y=" + y + ", x2=" + x2 + ", y2=" + y2 + ", width=" + width + ", height=" + height + "]";
	}
}
