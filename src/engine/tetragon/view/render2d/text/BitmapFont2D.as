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
package tetragon.view.render2d.text
{
	import tetragon.core.constants.HAlign;
	import tetragon.core.constants.TextureSmoothing;
	import tetragon.core.constants.VAlign;
	import tetragon.view.render2d.display.Image2D;
	import tetragon.view.render2d.display.QuadBatch2D;
	import tetragon.view.render2d.display.Sprite2D;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.geom.Rectangle;
	import flash.utils.Dictionary;


	/** The BitmapFont class parses bitmap font files and arranges the glyphs 
	 *  in the form of a text.
	 *
	 *  The class parses the XML format as it is used in the 
	 *  <a href="http://www.angelcode.com/products/bmfont/">AngelCode Bitmap Font Generator</a> or
	 *  the <a href="http://glyphdesigner.71squared.com/">Glyph Designer</a>. 
	 *  This is what the file format looks like:
	 *
	 *  <pre> 
	 *  &lt;font&gt;
	 *    &lt;info face="BranchingMouse" size="40" /&gt;
	 *    &lt;common lineHeight="40" /&gt;
	 *    &lt;pages&gt;  &lt;!-- currently, only one page is supported --&gt;
	 *      &lt;page id="0" file="texture.png" /&gt;
	 *    &lt;/pages&gt;
	 *    &lt;chars&gt;
	 *      &lt;char id="32" x="60" y="29" width="1" height="1" xoffset="0" yoffset="27" xadvance="8" /&gt;
	 *      &lt;char id="33" x="155" y="144" width="9" height="21" xoffset="0" yoffset="6" xadvance="9" /&gt;
	 *    &lt;/chars&gt;
	 *    &lt;kernings&gt; &lt;!-- Kerning is optional --&gt;
	 *      &lt;kerning first="83" second="83" amount="-4"/&gt;
	 *    &lt;/kernings&gt;
	 *  &lt;/font&gt;
	 *  </pre>
	 *  
	 *  Pass an instance of this class to the method <code>registerBitmapFont</code> of the
	 *  TextField class. Then, set the <code>fontName</code> property of the text field to the 
	 *  <code>name</code> value of the bitmap font. This will make the text field use the bitmap
	 *  font.  
	 */
	public class BitmapFont2D
	{
		/** Use this constant for the <code>fontSize</code> property of the TextField class to 
		 *  render the bitmap font in exactly the size it was created. */
		public static const NATIVE_SIZE:int = -1;
		/** The font name of the embedded minimal bitmap font. Use this e.g. for debug output. */
		public static const MINI:String = "mini";
		private static const CHAR_SPACE:int = 32;
		private static const CHAR_TAB:int = 9;
		private static const CHAR_NEWLINE:int = 10;
		private static const CHAR_CARRIAGE_RETURN:int = 13;
		private var mTexture:Texture2D;
		private var mChars:Dictionary;
		private var mName:String;
		private var mSize:Number;
		private var mLineHeight:Number;
		private var mBaseline:Number;
		private var mHelperImage:Image2D;
		private var mCharLocationPool:Vector.<CharLocation>;


		/** Creates a bitmap font by parsing an XML file and uses the specified texture. 
		 *  If you don't pass any data, the "mini" font will be created. */
		public function BitmapFont2D(texture:Texture2D = null, fontXml:XML = null)
		{
			// if no texture is passed in, we create the minimal, embedded font
			if (texture == null && fontXml == null)
			{
				texture = MiniBitmapFont2D.texture;
				fontXml = MiniBitmapFont2D.xml;
			}

			mName = "unknown";
			mLineHeight = mSize = mBaseline = 14;
			mTexture = texture;
			mChars = new Dictionary();
			mHelperImage = new Image2D(texture);
			mCharLocationPool = new <CharLocation>[];

			if (fontXml) parseFontXml(fontXml);
		}


		/** Disposes the texture of the bitmap font! */
		public function dispose():void
		{
			if (mTexture)
				mTexture.dispose();
		}


		private function parseFontXml(fontXml:XML):void
		{
			var scale:Number = mTexture.scale;
			var frame:Rectangle = mTexture.frame;

			mName = fontXml.info.attribute("face");
			mSize = parseFloat(fontXml.info.attribute("size")) / scale;
			mLineHeight = parseFloat(fontXml.common.attribute("lineHeight")) / scale;
			mBaseline = parseFloat(fontXml.common.attribute("base")) / scale;

			if (fontXml.info.attribute("smooth").toString() == "0")
				smoothing = TextureSmoothing.NONE;

			if (mSize <= 0)
			{
				trace("[Starling] Warning: invalid font size in '" + mName + "' font.");
				mSize = (mSize == 0.0 ? 16.0 : mSize * -1.0);
			}

			for each (var charElement:XML in fontXml.chars.char)
			{
				var id:int = parseInt(charElement.attribute("id"));
				var xOffset:Number = parseFloat(charElement.attribute("xoffset")) / scale;
				var yOffset:Number = parseFloat(charElement.attribute("yoffset")) / scale;
				var xAdvance:Number = parseFloat(charElement.attribute("xadvance")) / scale;

				var region:Rectangle = new Rectangle();
				region.x = parseFloat(charElement.attribute("x")) / scale + frame.x;
				region.y = parseFloat(charElement.attribute("y")) / scale + frame.y;
				region.width = parseFloat(charElement.attribute("width")) / scale;
				region.height = parseFloat(charElement.attribute("height")) / scale;

				var texture:Texture2D = Texture2D.fromTexture(mTexture, region);
				var bitmapChar:BitmapChar2D = new BitmapChar2D(id, texture, xOffset, yOffset, xAdvance);
				addChar(id, bitmapChar);
			}

			for each (var kerningElement:XML in fontXml.kernings.kerning)
			{
				var first:int = parseInt(kerningElement.attribute("first"));
				var second:int = parseInt(kerningElement.attribute("second"));
				var amount:Number = parseFloat(kerningElement.attribute("amount")) / scale;
				if (second in mChars) getChar(second).addKerning(first, amount);
			}
		}


		/** Returns a single bitmap char with a certain character ID. */
		public function getChar(charID:int):BitmapChar2D
		{
			return mChars[charID];
		}


		/** Adds a bitmap char with a certain character ID. */
		public function addChar(charID:int, bitmapChar:BitmapChar2D):void
		{
			mChars[charID] = bitmapChar;
		}


		/** Creates a sprite that contains a certain text, made up by one image per char. */
		public function createSprite(width:Number, height:Number, text:String, fontSize:Number = -1, color:uint = 0xffffff, hAlign:String = "center", vAlign:String = "center", autoScale:Boolean = true, kerning:Boolean = true):Sprite2D
		{
			var charLocations:Vector.<CharLocation> = arrangeChars(width, height, text, fontSize, hAlign, vAlign, autoScale, kerning);
			var numChars:int = charLocations.length;
			var sprite:Sprite2D = new Sprite2D();

			for (var i:int = 0; i < numChars; ++i)
			{
				var charLocation:CharLocation = charLocations[i];
				var char:Image2D = charLocation.char.createImage();
				char.x = charLocation.x;
				char.y = charLocation.y;
				char.scaleX = char.scaleY = charLocation.scale;
				char.color = color;
				sprite.addChild(char);
			}

			return sprite;
		}


		/** Draws text into a QuadBatch. */
		public function fillQuadBatch(quadBatch:QuadBatch2D, width:Number, height:Number, text:String, fontSize:Number = -1, color:uint = 0xffffff, hAlign:String = "center", vAlign:String = "center", autoScale:Boolean = true, kerning:Boolean = true):void
		{
			var charLocations:Vector.<CharLocation> = arrangeChars(width, height, text, fontSize, hAlign, vAlign, autoScale, kerning);
			var numChars:int = charLocations.length;
			mHelperImage.color = color;

			if (numChars > 8192)
				throw new ArgumentError("Bitmap Font text is limited to 8192 characters.");

			for (var i:int = 0; i < numChars; ++i)
			{
				var charLocation:CharLocation = charLocations[i];
				mHelperImage.texture = charLocation.char.texture;
				mHelperImage.readjustSize();
				mHelperImage.x = charLocation.x;
				mHelperImage.y = charLocation.y;
				mHelperImage.scaleX = mHelperImage.scaleY = charLocation.scale;
				quadBatch.addImage(mHelperImage);
			}
		}


		/** Arranges the characters of a text inside a rectangle, adhering to the given settings. 
		 *  Returns a Vector of CharLocations. */
		private function arrangeChars(width:Number, height:Number, text:String, fontSize:Number = -1, hAlign:String = "center", vAlign:String = "center", autoScale:Boolean = true, kerning:Boolean = true):Vector.<CharLocation>
		{
			if (text == null || text.length == 0) return new <CharLocation>[];
			if (fontSize < 0) fontSize *= -mSize;

			var lines:Vector.<Vector.<CharLocation>>;
			var finished:Boolean = false;
			var charLocation:CharLocation;
			var numChars:int;
			var containerWidth:Number;
			var containerHeight:Number;
			var scale:Number;

			while (!finished)
			{
				scale = fontSize / mSize;
				containerWidth = width / scale;
				containerHeight = height / scale;

				lines = new Vector.<Vector.<CharLocation>>();

				if (mLineHeight <= containerHeight)
				{
					var lastWhiteSpace:int = -1;
					var lastCharID:int = -1;
					var currentX:Number = 0;
					var currentY:Number = 0;
					var currentLine:Vector.<CharLocation> = new <CharLocation>[];

					numChars = text.length;
					for (var i:int = 0; i < numChars; ++i)
					{
						var lineFull:Boolean = false;
						var charID:int = text.charCodeAt(i);
						var char:BitmapChar2D = getChar(charID);

						if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
						{
							lineFull = true;
						}
						else if (char == null)
						{
							trace("[Starling] Missing character: " + charID);
						}
						else
						{
							if (charID == CHAR_SPACE || charID == CHAR_TAB)
								lastWhiteSpace = i;

							if (kerning)
								currentX += char.getKerning(lastCharID);

							charLocation = mCharLocationPool.length ? mCharLocationPool.pop() : new CharLocation(char);

							charLocation.char = char;
							charLocation.x = currentX + char.xOffset;
							charLocation.y = currentY + char.yOffset;
							currentLine.push(charLocation);

							currentX += char.xAdvance;
							lastCharID = charID;

							if (charLocation.x + char.width > containerWidth)
							{
								// remove characters and add them again to next line
								var numCharsToRemove:int = lastWhiteSpace == -1 ? 1 : i - lastWhiteSpace;
								var removeIndex:int = currentLine.length - numCharsToRemove;

								currentLine.splice(removeIndex, numCharsToRemove);

								if (currentLine.length == 0)
									break;

								i -= numCharsToRemove;
								lineFull = true;
							}
						}

						if (i == numChars - 1)
						{
							lines.push(currentLine);
							finished = true;
						}
						else if (lineFull)
						{
							lines.push(currentLine);

							if (lastWhiteSpace == i)
								currentLine.pop();

							if (currentY + 2 * mLineHeight <= containerHeight)
							{
								currentLine = new <CharLocation>[];
								currentX = 0;
								currentY += mLineHeight;
								lastWhiteSpace = -1;
								lastCharID = -1;
							}
							else
							{
								break;
							}
						}
					}
					// for each char
				}
				// if (mLineHeight <= containerHeight)

				if (autoScale && !finished)
				{
					fontSize -= 1;
					lines.length = 0;
				}
				else
				{
					finished = true;
				}
			}
			// while (!finished)

			var finalLocations:Vector.<CharLocation> = new <CharLocation>[];
			var numLines:int = lines.length;
			var bottom:Number = currentY + mLineHeight;
			var yOffset:int = 0;

			if (vAlign == VAlign.BOTTOM) yOffset = containerHeight - bottom;
			else if (vAlign == VAlign.CENTER) yOffset = (containerHeight - bottom) / 2;

			for (var lineID:int = 0; lineID < numLines; ++lineID)
			{
				var line:Vector.<CharLocation> = lines[lineID];
				numChars = line.length;

				if (numChars == 0) continue;

				var xOffset:int = 0;
				var lastLocation:CharLocation = line[line.length - 1];
				var right:Number = lastLocation.x - lastLocation.char.xOffset + lastLocation.char.xAdvance;

				if (hAlign == HAlign.RIGHT) xOffset = containerWidth - right;
				else if (hAlign == HAlign.CENTER) xOffset = (containerWidth - right) / 2;

				for (var c:int = 0; c < numChars; ++c)
				{
					charLocation = line[c];
					charLocation.x = scale * (charLocation.x + xOffset);
					charLocation.y = scale * (charLocation.y + yOffset);
					charLocation.scale = scale;

					if (charLocation.char.width > 0 && charLocation.char.height > 0)
						finalLocations.push(charLocation);

					// return to pool for next call to "arrangeChars"
					mCharLocationPool.push(charLocation);
				}
			}

			return finalLocations;
		}


		/** The name of the font as it was parsed from the font file. */
		public function get name():String
		{
			return mName;
		}


		/** The native size of the font. */
		public function get size():Number
		{
			return mSize;
		}


		/** The height of one line in pixels. */
		public function get lineHeight():Number
		{
			return mLineHeight;
		}


		public function set lineHeight(value:Number):void
		{
			mLineHeight = value;
		}


		/** The smoothing filter that is used for the texture. */
		public function get smoothing():String
		{
			return mHelperImage.smoothing;
		}


		public function set smoothing(value:String):void
		{
			mHelperImage.smoothing = value;
		}


		/** The baseline of the font. */
		public function get baseline():Number
		{
			return mBaseline;
		}
	}
}


import tetragon.view.render2d.text.BitmapChar2D;

class CharLocation
{
	public var char:BitmapChar2D;
	public var scale:Number;
	public var x:Number;
	public var y:Number;


	public function CharLocation(char:BitmapChar2D)
	{
		this.char = char;
	}
}
