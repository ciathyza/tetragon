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
package tetragon.view.render2d.core
{
	import com.hexagonstar.constants.HAlign;
	import com.hexagonstar.constants.VAlign;
	import com.hexagonstar.util.debug.HLog;

	import flash.geom.Rectangle;
	import flash.utils.Dictionary;


	/**
	 * The BitmapFont2D class parses bitmap font files and arranges the glyphs in the form
	 * of a text.
	 * 
	 * The class parses the XML format as it is used in the <a
	 * href="http://www.angelcode.com/products/bmfont/">AngelCode Bitmap Font
	 * Generator</a> or the <a href="http://glyphdesigner.71squared.com/">Glyph
	 * Designer</a>. This is what the file format looks like:
	 * 
	 * <pre>
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
	 * </pre>
	 * 
	 * Pass an instance of this class to the method <code>registerBitmapFont</code> of the
	 * TextField class. Then, set the <code>fontName</code> property of the text field to
	 * the <code>name</code> value of the bitmap font. This will make the text field use
	 * the bitmap font.
	 */
	public class BitmapFont2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Use this constant for the <code>fontSize</code> property of the TextField2D class
		 * to render the bitmap font in exactly the size it was created.
		 */
		public static const DEFAULT_SIZE:int = -1;
		/** @private */
		private static const CHAR_SPACE:int = 32;
		/** @private */
		private static const CHAR_TAB:int = 9;
		/** @private */
		private static const CHAR_NEWLINE:int = 10;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _texture:Texture2D;
		/** @private */
		private var _chars:Dictionary;
		/** @private */
		private var _name:String;
		/** @private */
		private var _size:Number;
		/** @private */
		private var _lineHeight:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a bitmap font by parsing an XML file and uses the specified texture.
		 * 
		 * @param texture
		 * @param fontXML
		 */
		public function BitmapFont2D(texture:Texture2D, fontXML:XML = null)
		{
			_name = "unknown";
			_lineHeight = _size = 14;
			_texture = texture;
			_chars = new Dictionary();

			if (fontXML) parseFontXML(fontXML);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the texture of the bitmap font!
		 */
		public function dispose():void
		{
			if (_texture) _texture.dispose();
		}
		
		
		/**
		 * Returns a single bitmap char with a certain character ID.
		 * 
		 * @param charID
		 * @return BitmapChar2D
		 */
		public function getChar(charID:int):BitmapChar2D
		{
			return _chars[charID];
		}
		
		
		/**
		 * Adds a bitmap char with a certain character ID.
		 * 
		 * @param charID
		 * @param bitmapChar
		 */
		public function addChar(charID:int, bitmapChar:BitmapChar2D):void
		{
			_chars[charID] = bitmapChar;
		}
		
		
		/**
		 * Creates a display object that contains the given text by arranging individual chars.
		 * 
		 * @param width
		 * @param height
		 * @param text
		 * @param fontSize
		 * @param color
		 * @param hAlign
		 * @param vAlign
		 * @param autoScale
		 * @param kerning
		 * @return DisplayObject2D
		 */
		public function createDisplayObject(width:Number, height:Number, text:String,
			fontSize:Number = -1, color:uint = 0xffffff, hAlign:String = "center",
			vAlign:String = "center", autoScale:Boolean = true,
			kerning:Boolean = true):DisplayObject2D
		{
			if (fontSize == DEFAULT_SIZE) fontSize = _size;
			
			var lineContainer:Sprite2D;
			var finished:Boolean = false;
			
			while (!finished)
			{
				var scale:Number = fontSize / _size;
				lineContainer = new Sprite2D();
				
				if (_lineHeight * scale <= height)
				{
					var containerWidth:Number = width / scale;
					var containerHeight:Number = height / scale;
					lineContainer.scaleX = lineContainer.scaleY = scale;
					
					var lastWhiteSpace:int = -1;
					var lastCharID:int = -1;
					var currentX:Number = 0;
					var currentLine:Sprite2D = new Sprite2D();
					var numChars:int = text.length;
					
					for (var i:int = 0; i < numChars; ++i)
					{
						var lineFull:Boolean = false;
						var charID:int = text.charCodeAt(i);
						
						if (charID == CHAR_NEWLINE)
						{
							lineFull = true;
						}
						else
						{
							var bitmapChar:BitmapChar2D = getChar(charID);
							if (!bitmapChar)
							{
								HLog.warn("[BitmapFont2D] Missing character: " + charID);
								continue;
							}
							
							if (charID == CHAR_SPACE || charID == CHAR_TAB) lastWhiteSpace = i;
							var charImage:Image2D = bitmapChar.createImage();
							if (kerning) currentX += bitmapChar.getKerning(lastCharID);
							
							charImage.x = currentX + bitmapChar.xOffset;
							charImage.y = bitmapChar.yOffset;
							charImage.color = color;
							currentLine.addChild(charImage);
							
							currentX += bitmapChar.xAdvance;
							lastCharID = charID;
							
							if (currentX > containerWidth)
							{
								/* Remove characters and add them again to next line. */
								var numCharsToRemove:int = lastWhiteSpace == -1 ? 1 : i - lastWhiteSpace;
								var removeIndex:int = currentLine.numChildren - numCharsToRemove;
								
								for (var r:int = 0; r < numCharsToRemove; ++r)
								{
									currentLine.removeChildAt(removeIndex);
								}

								if (currentLine.numChildren == 0) break;
								
								var lastChar:DisplayObject2D = currentLine.getChildAt(currentLine.numChildren - 1);
								currentX = lastChar.x + lastChar.width;
								
								i -= numCharsToRemove;
								lineFull = true;
							}
						}
						
						if (i == numChars - 1)
						{
							lineContainer.addChild(currentLine);
							finished = true;
						}
						else if (lineFull)
						{
							lineContainer.addChild(currentLine);
							var nextLineY:Number = currentLine.y + _lineHeight;
							
							if (nextLineY + _lineHeight <= containerHeight)
							{
								currentLine = new Sprite2D();
								currentLine.y = nextLineY;
								currentX = 0;
								lastWhiteSpace = -1;
								lastCharID = -1;
							}
							else
							{
								break;
							}
						}
					}
				}
				
				if (autoScale && !finished)
				{
					fontSize -= 1;
					lineContainer.dispose();
				}
				else
				{
					finished = true;
				}
			}
			
			if (hAlign != HAlign.LEFT)
			{
				var numLines:int = lineContainer.numChildren;
				for (var l:int = 0; l < numLines; ++l)
				{
					var line:Sprite2D = lineContainer.getChildAt(l) as Sprite2D;
					var finalChar:DisplayObject2D = line.getChildAt(line.numChildren - 1);
					var lineWidth:Number = finalChar.x + finalChar.width;
					var widthDiff:Number = containerWidth - lineWidth;
					line.x = int(hAlign == HAlign.RIGHT ? widthDiff : widthDiff / 2);
				}
			}
			
			var outerContainer:Sprite2D = new Sprite2D();
			outerContainer.addChild(lineContainer);
			
			if (vAlign != VAlign.TOP)
			{
				var contentHeight:Number = lineContainer.numChildren * _lineHeight * scale;
				var heightDiff:Number = height - contentHeight;
				lineContainer.y = int(vAlign == VAlign.BOTTOM ? heightDiff : heightDiff / 2);
			}
			
			outerContainer.flatten();
			return outerContainer;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The name of the font as it was parsed from the font file.
		 */
		public function get name():String
		{
			return _name;
		}
		
		
		/**
		 * The default size of the font.
		 */
		public function get size():Number
		{
			return _size;
		}
		
		
		/**
		 * The height of one line in pixels.
		 */
		public function get lineHeight():Number
		{
			return _lineHeight;
		}
		public function set lineHeight(v:Number):void
		{
			_lineHeight = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * @param xml
		 */
		private function parseFontXML(xml:XML):void
		{
			_name = xml.info.attribute("face");
			_size = parseFloat(xml.info.attribute("size"));
			_lineHeight = parseFloat(xml.common.attribute("lineHeight"));
			
			if (_size <= 0)
			{
				HLog.warn("[BitmapFont2D] Invalid font size in '" + _name + "' font.");
				_size = (_size == 0.0 ? 16.0 : _size * -1.0);
			}
			
			for each (var c:XML in xml.chars.char)
			{
				var id:int = parseInt(c.attribute("id"));
				var xOffset:Number = parseFloat(c.attribute("xoffset"));
				var yOffset:Number = parseFloat(c.attribute("yoffset"));
				var xAdvance:Number = parseFloat(c.attribute("xadvance"));
				
				var region:Rectangle = new Rectangle();
				region.x = parseFloat(c.attribute("x"));
				region.y = parseFloat(c.attribute("y"));
				region.width = parseFloat(c.attribute("width"));
				region.height = parseFloat(c.attribute("height"));
				
				var t:Texture2D = Texture2D.fromTexture(_texture, region);
				var b:BitmapChar2D = new BitmapChar2D(id, t, xOffset, yOffset, xAdvance);
				addChar(id, b);
			}
			
			for each (var k:XML in xml.kernings.kerning)
			{
				var first:int = parseInt(k.attribute("first"));
				var second:int = parseInt(k.attribute("second"));
				var amount:Number = parseFloat(k.attribute("amount"));
				if (second in _chars) getChar(second).addKerning(first, amount);
			}
		}
	}
}
