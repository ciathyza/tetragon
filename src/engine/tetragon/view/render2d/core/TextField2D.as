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
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import tetragon.view.render2d.core.events.Event2D;


	
	
	/**
	 * A TextField2D displays text, either using standard true type fonts or custom bitmap
	 * fonts.
	 * 
	 * <p>
	 * You can set all properties you are used to, like the font name and size, a color,
	 * the horizontal and vertical alignment, etc. The border property is helpful during
	 * development, because it lets you see the bounds of the textfield.
	 * </p>
	 * 
	 * <p>
	 * There are two types of fonts that can be displayed:
	 * </p>
	 * 
	 * <ul>
	 * <li>Standard true type fonts. This renders the text just like a conventional Flash
	 * TextField. It is recommended to embed the font, since you cannot be sure which
	 * fonts are available on the client system, and since this enhances rendering
	 * quality. Simply pass the font name to the corresponding property.</li>
	 * <li>Bitmap fonts. If you need speed or fancy font effects, use a bitmap font
	 * instead. That is a font that has its glyphs rendered to a texture atlas. To use it,
	 * first register the font with the method <code>registerBitmapFont</code>, and then
	 * pass the font name to the corresponding property of the text field.</li>
	 * </ul>
	 * 
	 * For bitmap fonts, we recommend one of the following tools:
	 * 
	 * <ul>
	 * <li>Windows: <a href="http://www.angelcode.com/products/bmfont">Bitmap Font
	 * Generator</a> from Angel Code (free). Export the font data as an XML file and the
	 * texture as a png with white characters on a transparent background (32 bit).</li>
	 * <li>Mac OS: <a href="http://glyphdesigner.71squared.com">Glyph Designer</a> from
	 * 71squared or <a href="http://http://www.bmglyph.com">bmGlyph</a> (both commercial).
	 * They support Starling natively.</li>
	 * </ul>
	 */
	public class TextField2D extends DisplayObjectContainer2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _hitArea:DisplayObject2D;
		/** @private */
		private var _textArea:DisplayObject2D;
		/** @private */
		private var _contents:DisplayObject2D;
		/** @private */
		private var _border:DisplayObjectContainer2D;
		
		/** @private */
		private var _text:String;
		/** @private */
		private var _fontName:String;
		/** @private */
		private var _hAlign:String;
		/** @private */
		private var _vAlign:String;
		/** @private */
		private var _fontSize:Number;
		/** @private */
		private var _color:uint;
		
		/** @private */
		private var _bold:Boolean;
		/** @private */
		private var _italic:Boolean;
		/** @private */
		private var _underline:Boolean;
		/** @private */
		private var _autoScale:Boolean;
		/** @private */
		private var _kerning:Boolean;
		/** @private */
		private var _requiresRedraw:Boolean;
		/** @private */
		private var _isRenderedText:Boolean;
		
		// this object will be used for text rendering
		/** @private */
		private static var _nativeTF:TextField = new TextField();
		
		// this is the container for bitmap fonts
		/** @private */
		private static var _bitmapFonts:Dictionary = new Dictionary();
		
		/** @private */
		private static var _borderColor:uint = 0xFF00FF;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Create a new text field with the given properties.
		 * 
		 * @param text
		 * @param width
		 * @param height
		 * @param fontName
		 * @param fontSize
		 * @param color
		 * @param bold
		 */
		public function TextField2D(width:int, height:int, text:String = null,
			fontName:String = null, fontSize:Number = 12, color:uint = 0xFFFFFF,
			bold:Boolean = false)
		{
			_text = text ? text : "";
			_fontSize = fontSize;
			_color = color;
			_hAlign = HAlign.CENTER;
			_vAlign = VAlign.CENTER;
			_border = null;
			_kerning = true;
			_bold = bold;
			this.fontName = fontName ? fontName : "Verdana";
			
			_hitArea = new Quad2D(width, height);
			_hitArea.alpha = 0.0;
			addChild(_hitArea);
			
			_textArea = new Quad2D(width, height);
			_textArea.visible = false;
			addChild(_textArea);
			
			addEventListener(Event2D.FLATTEN, onFlatten);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the underlying texture data.
		 */
		public override function dispose():void
		{
			removeEventListener(Event2D.FLATTEN, onFlatten);
			if (_contents is Image2D) (_contents as Image2D).texture.dispose();
			super.dispose();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function renderWithSupport(support:Render2DRenderSupport, alpha:Number):void
		{
			if (_requiresRedraw) redrawContents();
			super.renderWithSupport(support, alpha);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function getBounds(targetSpace:DisplayObject2D, resultRect:Rectangle = null):Rectangle
		{
			return _hitArea.getBounds(targetSpace, resultRect);
		}
		
		
		/**
		 * Makes a bitmap font available to any text field. Set the <code>fontName</code>
		 * property of a text field to the <code>name</code> value of the bitmap font to
		 * use the bitmap font for rendering.
		 * 
		 * @param bitmapFont
		 */
		public static function registerBitmapFont(bitmapFont:BitmapFont2D):void
		{
			_bitmapFonts[bitmapFont.name] = bitmapFont;
		}
		
		
		/**
		 * Unregisters the bitmap font and, optionally, disposes it.
		 * 
		 * @param name
		 * @param dispose
		 */
		public static function unregisterBitmapFont(name:String, dispose:Boolean = true):void
		{
			if (dispose && _bitmapFonts[name] != undefined)
			{
				(_bitmapFonts[name] as BitmapFont2D).dispose();
			}
			delete _bitmapFonts[name];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the bounds of the text within the text field.
		 */
		public function get textBounds():Rectangle
		{
			if (_requiresRedraw) redrawContents();
			return _textArea.getBounds(parent);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function set width(v:Number):void
		{
			// different to ordinary display objects, changing the size of the text field should
			// not change the scaling, but make the texture bigger/smaller, while the size
			// of the text/font stays the same (this applies to the height, as well).
			_hitArea.width = v;
			_requiresRedraw = true;
			updateBorder();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function set height(v:Number):void
		{
			_hitArea.height = v;
			_requiresRedraw = true;
			updateBorder();
		}
		
		
		/**
		 * The displayed text.
		 */
		public function get text():String
		{
			return _text;
		}
		public function set text(v:String):void
		{
			if (v == _text) return;
			_text = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * The name of the font (true type or bitmap font).
		 * 
		 * @default Verdana
		 */
		public function get fontName():String
		{
			return _fontName;
		}
		public function set fontName(v:String):void
		{
			if (v == _fontName) return;
			_fontName = v;
			_requiresRedraw = true;
			_isRenderedText = _bitmapFonts[v] == undefined;
		}
		
		
		/**
		 * The size of the font. For bitmap fonts, use <code>BitmapFont.DEFAULT_SIZE</code>
		 * for the original size.
		 */
		public function get fontSize():Number
		{
			return _fontSize;
		}
		public function set fontSize(v:Number):void
		{
			if (v == _fontSize) return;
			_fontSize = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * The color of the text. For bitmap fonts, use <code>ColorUtil.WHITE</code> to use
		 * the original, untinted color.
		 * 
		 * @default 0xFFFFFF
		 */
		public function get color():uint
		{
			return _color;
		}
		public function set color(v:uint):void
		{
			if (v == _color) return;
			_color = v;
			updateBorder();
			if (_contents)
			{
				if (_isRenderedText) (_contents as Image2D).color = v;
				else _requiresRedraw = true;
			}
		}
		
		
		/**
		 * The horizontal alignment of the text.
		 * 
		 * @default center
		 * @see HAlign
		 */
		public function get hAlign():String
		{
			return _hAlign;
		}
		public function set hAlign(v:String):void
		{
			if (!HAlign.isValid(v)) throw new ArgumentError("Invalid horizontal align: " + v);
			if (v == _hAlign) return;
			_hAlign = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * The vertical alignment of the text.
		 * 
		 * @default center
		 * @see VAlign
		 */
		public function get vAlign():String
		{
			return _vAlign;
		}
		public function set vAlign(v:String):void
		{
			if (!VAlign.isValid(v)) throw new ArgumentError("Invalid vertical align: " + v);
			if (v == _vAlign) return;
			_vAlign = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * Draws a border around the edges of the textfield. Useful for visual debugging.
		 * 
		 * @default false
		 */
		public function get debugBorder():Boolean
		{
			return _border != null;
		}
		public function set debugBorder(v:Boolean):void
		{
			if (v && !_border)
			{
				_border = new Sprite2D();
				addChild(_border);
				for (var i:int = 0; i < 4; ++i)
				{
					_border.addChild(new Quad2D(1.0, 1.0));
				}
				updateBorder();
			}
			else if (!v && _border)
			{
				_border.removeFromParent(true);
				_border = null;
			}
		}
		
		
		/**
		 * Indicates whether the text is bold.
		 * 
		 * @default false
		 */
		public function get bold():Boolean
		{
			return _bold;
		}
		public function set bold(v:Boolean):void
		{
			if (v == _bold) return;
			_bold = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * Indicates whether the text is italicized.
		 * 
		 * @default false
		 */
		public function get italic():Boolean
		{
			return _italic;
		}
		public function set italic(v:Boolean):void
		{
			if (v == _italic) return;
			_italic = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * Indicates whether the text is underlined.
		 * 
		 * @default false
		 */
		public function get underline():Boolean
		{
			return _underline;
		}
		public function set underline(v:Boolean):void
		{
			if (v == _underline) return;
			_underline = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * Indicates whether kerning is enabled.
		 * 
		 * @default true
		 */
		public function get kerning():Boolean
		{
			return _kerning;
		}
		public function set kerning(v:Boolean):void
		{
			if (v == _kerning) return;
			_kerning = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * Indicates whether the font size is scaled down so that the complete text fits
		 * into the text field.
		 * 
		 * @default false
		 */
		public function get autoScale():Boolean
		{
			return _autoScale;
		}
		public function set autoScale(v:Boolean):void
		{
			if (v == _autoScale) return;
			_autoScale = v;
			_requiresRedraw = true;
		}
		
		
		/**
		 * Color of the border used for debugging. Needs to be set before any textfields are
		 * created.
		 * 
		 * @default 0xFF00FF
		 */
		static public function get debugBorderColor():uint
		{
			return _borderColor;
		}
		static public function set debugBorderColor(v:uint):void
		{
			_borderColor = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onFlatten(e:Event2D):void
		{
			if (_requiresRedraw) redrawContents();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function redrawContents():void
		{
			if (_contents) _contents.removeFromParent(true);
			_contents = _isRenderedText ? createRenderedContents() : createComposedContents();
			_contents.touchable = false;
			_requiresRedraw = false;
			addChild(_contents);
		}
		
		
		/**
		 * @private
		 */
		private function createRenderedContents():DisplayObject2D
		{
			if (_text.length == 0) return new Sprite2D();
			
			var w:Number = _hitArea.width;
			var h:Number = _hitArea.height;
			
			var textFormat:TextFormat = new TextFormat(_fontName, _fontSize, 0xFFFFFF, _bold,
				_italic, _underline, null, null, _hAlign);
			textFormat.kerning = _kerning;
			
			_nativeTF.defaultTextFormat = textFormat;
			_nativeTF.width = w;
			_nativeTF.height = h;
			_nativeTF.antiAliasType = AntiAliasType.ADVANCED;
			_nativeTF.selectable = false;
			_nativeTF.multiline = true;
			_nativeTF.wordWrap = true;
			_nativeTF.text = _text;
			_nativeTF.embedFonts = true;
			
			// we try embedded fonts first, non-embedded fonts are just a fallback
			if (_nativeTF.textWidth == 0.0 || _nativeTF.textHeight == 0.0)
			{
				_nativeTF.embedFonts = false;
			}
			
			if (_autoScale) autoScaleNativeTextField(_nativeTF);
			
			var textW:Number = _nativeTF.textWidth;
			var textH:Number = _nativeTF.textHeight;
			var xOffset:Number = 0.0;
			var yOffset:Number = 0.0;
			
			if (_hAlign == HAlign.LEFT) xOffset = 2; // flash adds a 2 pixel offset
			else if (_hAlign == HAlign.CENTER) xOffset = (w - textW) / 2.0;
			else if (_hAlign == HAlign.RIGHT) xOffset = w - textW - 2;
			
			if (_vAlign == VAlign.TOP) yOffset = 2; // flash adds a 2 pixel offset
			else if (_vAlign == VAlign.CENTER) yOffset = (h - textH) / 2.0;
			else if (_vAlign == VAlign.BOTTOM) yOffset = h - textH - 2;
			
			var bitmapData:BitmapData = new BitmapData(w, h, true, 0x00000000);
			bitmapData.draw(_nativeTF, new Matrix(1, 0, 0, 1, 0, int(yOffset) - 2));
			
			_textArea.x = xOffset;
			_textArea.y = yOffset;
			_textArea.width = textW;
			_textArea.height = textH;
			
			var contents:Image2D = new Image2D(Texture2D.fromBitmapData(bitmapData));
			contents.color = _color;
			
			return contents;
		}
		
		
		/**
		 * @private
		 */
		private function autoScaleNativeTextField(tf:TextField):void
		{
			var size:Number = Number(tf.defaultTextFormat.size);
			var maxH:int = tf.height - 4;
			var maxW:int = tf.width - 4;
			
			while (tf.textWidth > maxW || tf.textHeight > maxH)
			{
				if (size <= 4) break;
				var f:TextFormat = tf.defaultTextFormat;
				f.size = size--;
				tf.setTextFormat(f);
			}
		}
		
		
		/**
		 * @private
		 */
		private function createComposedContents():DisplayObject2D
		{
			var bmFont:BitmapFont2D = _bitmapFonts[_fontName];
			if (!bmFont) throw new Error("Bitmap font not registered: " + _fontName);
			
			var contents:DisplayObject2D = bmFont.createDisplayObject(_hitArea.width, _hitArea.height, _text, _fontSize, _color, _hAlign, _vAlign, _autoScale, _kerning);
			var textBounds:Rectangle = (contents as DisplayObjectContainer2D).bounds;
			
			_textArea.x = textBounds.x;
			_textArea.y = textBounds.y;
			_textArea.width = textBounds.width;
			_textArea.height = textBounds.height;
			
			return contents;
		}
		
		
		/**
		 * @private
		 */
		private function updateBorder():void
		{
			if (!_border) return;
			
			var w:Number = _hitArea.width;
			var h:Number = _hitArea.height;
			var topLine:Quad2D = _border.getChildAt(0) as Quad2D;
			var rightLine:Quad2D = _border.getChildAt(1) as Quad2D;
			var bottomLine:Quad2D = _border.getChildAt(2) as Quad2D;
			var leftLine:Quad2D = _border.getChildAt(3) as Quad2D;
			
			topLine.width = w;
			topLine.height = 1;
			bottomLine.width = w;
			bottomLine.height = 1;
			leftLine.width = 1;
			leftLine.height = h;
			rightLine.width = 1;
			rightLine.height = h;
			rightLine.x = w - 1;
			bottomLine.y = h - 1;
			topLine.color = rightLine.color = bottomLine.color = leftLine.color = _borderColor;
		}
	}
}
