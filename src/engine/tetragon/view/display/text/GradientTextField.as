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
package tetragon.view.display.text
{
	import tetragon.core.types.Gradient;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	
	/**
	 * A GradientTextField is a text field that uses a color gradient as the text's color.
	 */
	public class GradientTextField extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _tf:TextField;
		/** @private */
		protected var _shape:Shape;
		/** @private */
		protected var _gradient:Gradient;
		/** @private */
		protected var _gradientAffordance:int = -1;
		/** @private */
		protected var _oldWidth:Number;
		/** @private */
		protected var _oldHeight:Number;
		/** @private */
		protected var _debug:Boolean;
		/** @private */
		protected static var _defaultGradient:Gradient;
		/** @private */
		protected static var _matrix:Matrix;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param textFormat
		 * @param text
		 * @param gradient
		 * @param gradientAffordance
		 */
		public function GradientTextField(textFormat:TextFormat = null, text:String = null,
			gradient:Gradient = null, gradientAffordance:int = -1)
		{
			setup();
			
			this.gradient = gradient;
			this.gradientAffordance = gradientAffordance;
			this.defaultTextFormat = textFormat;
			this.text = text;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Appends the string specified by the newText parameter to the end of the text of
		 * the text field. This method is more efficient than an addition assignment (+=)
		 * on a text property (such as someTextField.text += moreText), particularly for a
		 * text field that contains a significant amount of content.
		 * 
		 * @param newText
		 */
		public function appendText(newText:String):void
		{
			if (!_tf) return;
			_tf.appendText(newText);
		}
		
		
		/**
		 * Returns a TextFormat object that contains formatting information for the range
		 * of text that the beginIndex and endIndex parameters specify. Only properties
		 * that are common to the entire text specified are set in the resulting
		 * TextFormat object. Any property that is mixed, meaning that it has different
		 * values at different points in the text, has a value of null.
		 * 
		 * <p>
		 * If you do not specify values for these parameters, this method is applied to
		 * all the text in the text field.
		 * </p>
		 * 
		 * @param beginIndex
		 * @param endIndex
		 * @return TextFormat
		 */
		public function getTextFormat(beginIndex:int = -1, endIndex:int = -1):TextFormat
		{
			if (!_tf) return null;
			return _tf.getTextFormat(beginIndex, endIndex);
		}
		
		
		/**
		 * Applies the text formatting that the format parameter specifies to the
		 * specified text in a text field. The value of format must be a TextFormat object
		 * that specifies the desired text formatting changes. Only the non-null
		 * properties of format are applied to the text field. Any property of format that
		 * is set to null is not applied. By default, all of the properties of a newly
		 * created TextFormat object are set to null.
		 * 
		 * <p>
		 * Note: This method does not work if a style sheet is applied to the text field.
		 * </p>
		 * 
		 * <p>
		 * The setTextFormat() method changes the text formatting applied to a range of
		 * characters or to the entire body of text in a text field. To apply the
		 * properties of format to all text in the text field, do not specify values for
		 * beginIndex and endIndex. To apply the properties of the format to a range of
		 * text, specify values for the beginIndex and the endIndex parameters. You can
		 * use the length property to determine the index values.
		 * </p>
		 * 
		 * <p>
		 * The two types of formatting information in a TextFormat object are character
		 * level formatting and paragraph level formatting. Each character in a text field
		 * can have its own character formatting settings, such as font name, font size,
		 * bold, and italic.
		 * </p>
		 * 
		 * <p>
		 * For paragraphs, the first character of the paragraph is examined for the
		 * paragraph formatting settings for the entire paragraph. Examples of paragraph
		 * formatting settings are left margin, right margin, and indentation.
		 * </p>
		 * 
		 * @param format
		 * @param beginIndex
		 * @param endIndex
		 */
		public function setTextFormat(format:TextFormat, beginIndex:int = -1, endIndex:int = -1):void
		{
			if (!_tf) return;
			_tf.setTextFormat(format, beginIndex, endIndex);
		}
		
		
		/**
		 * Sets as selected the text designated by the index values of the first and last
		 * characters, which are specified with the beginIndex and endIndex parameters. If
		 * the two parameter values are the same, this method sets the insertion point, as
		 * if you set the caretIndex property.
		 * 
		 * @param beginIndex
		 * @param endIndex
		 */
		public function setSelection(beginIndex:int, endIndex:int):void
		{
			if (!_tf) return;
			_tf.setSelection(beginIndex, endIndex);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A string that is the current text in the text field. Lines are separated by the
		 * carriage return character ('\r', ASCII 13). This property contains unformatted
		 * text in the text field, without HTML tags.
		 * 
		 * <p>
		 * To get the text in HTML form, use the htmlText property.
		 * </p>
		 */
		public function get text():String
		{
			if (!_tf) return null;
			return _tf.text;
		}
		public function set text(v:String):void
		{
			if (!_tf || v == _tf.text) return;
			_tf.text = v || "";
			draw();
		}
		
		
		public function get htmlText():String
		{
			if (!_tf) return null;
			return _tf.htmlText;
		}
		
		public function set htmlText(v:String):void
		{
			_tf.htmlText = v || "";
			draw();
		}
		
		
		/**
		 * @default true
		 */
		public function get condenseWhite():Boolean
		{
			if (!_tf) return false;
			return _tf.condenseWhite;
		}
		public function set condenseWhite(v:Boolean):void
		{
			if (!_tf || v == _tf.condenseWhite) return;
			_tf.condenseWhite = v;
			draw();
		}
		
		
		/**
		 * @default false
		 */
		public function get selectable():Boolean 
		{
			if (!_tf) return false;
			return _tf.selectable;
		}		
		public function set selectable(v:Boolean):void
		{
			if (!_tf) return;
			_tf.selectable = v;
		}
		
		
		/**
		 * @default false
		 */
		override public function get mouseEnabled():Boolean
		{
			if (!_tf) return false;
			return _tf.mouseEnabled;
		}
		override public function set mouseEnabled(v:Boolean):void
		{
			if (!_tf) return;
			_tf.mouseEnabled = v;
		}
		
		
		/**
		 * @default TextFieldAutoSize.LEFT
		 */
		public function get autoSize():String
		{
			if (!_tf) return null;
			return _tf.autoSize;
		}
		public function set autoSize(v:String):void
		{
			if (!_tf || v == _tf.autoSize) return;
			_tf.autoSize = v;
			draw();
		}
		
		
		public function get defaultTextFormat():TextFormat
		{
			if (!_tf) return null;
			return _tf.defaultTextFormat;
		}
		public function set defaultTextFormat(v:TextFormat):void
		{
			if (!_tf || !v || v == _tf.defaultTextFormat) return;
			_tf.defaultTextFormat = v;
			draw();
		}
		
		
		/**
		 * @default AntiAliasType.ADVANCED
		 */
		public function get antiAliasType():String
		{
			if (!_tf) return null;
			return _tf.antiAliasType;
		}
		public function set antiAliasType(v:String):void
		{
			if (!_tf) return;
			_tf.antiAliasType = v;
		}
		
		
		/**
		 * @default GridFitType.PIXEL
		 */
		public function get gridFitType():String
		{
			if (!_tf) return null;
			return _tf.gridFitType;
		}
		public function set gridFitType(v:String):void
		{
			if (!_tf) return;
			_tf.gridFitType = v;
		}
		
		
		/**
		 * @default TextFieldType.DYNAMIC
		 */
		public function get type():String
		{
			if (!_tf) return null;
			return _tf.type;
		}
		public function set type(v:String):void
		{
			if (!_tf) return;
			_tf.type = v;
		}
		
		
		/**
		 * @default false
		 */
		public function get border():Boolean
		{
			if (!_tf) return false;
			return _tf.border;
		}
		public function set border(v:Boolean):void
		{
			if (!_tf) return;
			_tf.border = v;
		}
		
		
		/**
		 * @default 0xFF00FF
		 */
		public function get borderColor():uint
		{
			if (!_tf) return 0;
			return _tf.borderColor;
		}
		public function set borderColor(v:uint):void
		{
			if (!_tf) return;
			_tf.borderColor = v;
		}
		
		
		public function get length():int
		{
			if (!_tf) return 0;
			return _tf.length;
		}
		
		
		public function get displayAsPassword():Boolean
		{
			if (!_tf) return false;
			return _tf.displayAsPassword;
		}
		public function set displayAsPassword(v:Boolean):void
		{
			if (!_tf) return;
			_tf.displayAsPassword = v;
		}
		
		
		public function get maxChars():int
		{
			if (!_tf) return 0;
			return _tf.maxChars;
		}
		public function set maxChars(v:int):void
		{
			if (!_tf) return;
			_tf.maxChars = v;
		}
		
		
		public function get restrict():String
		{
			if (!_tf) return null;
			return _tf.restrict;
		}
		public function set restrict(v:String):void
		{
			if (!_tf) return;
			_tf.restrict = v;
		}
		
		
		public function get styleSheet():StyleSheet
		{
			if (!_tf) return null;
			return _tf.styleSheet;
		}
		public function set styleSheet(v:StyleSheet):void
		{
			if (!_tf || v == _tf.styleSheet) return;
			_tf.styleSheet = v;
			draw();
		}
		
		
		public function get sharpness():Number
		{
			if (!_tf) return NaN;
			return _tf.sharpness;
		}
		public function set sharpness(v:Number):void
		{
			if (!_tf) return;
			_tf.sharpness = v;
		}
		
		
		public function get thickness():Number
		{
			if (!_tf) return NaN;
			return _tf.thickness;
		}
		public function set thickness(v:Number):void
		{
			if (!_tf) return;
			_tf.thickness = v;
		}
		
		
		public function get textWidth():Number
		{
			if (!_tf) return NaN;
			return _tf.textWidth;
		}
		
		
		public function get textHeight():Number
		{
			if (!_tf) return NaN;
			return _tf.textHeight;
		}
		
		
		override public function set width(v:Number):void
		{
			if (!_tf || v == _tf.width) return;
			_tf.width = v;
			draw();
		}
		
		
		override public function set height(v:Number):void
		{
			if (!_tf || v == _tf.height) return;
			_tf.height = v;
			draw();
		}
		
		
		public function get gradient():Gradient
		{
			return _gradient;
		}
		public function set gradient(v:Gradient):void
		{
			if (!v)
			{
				if (!_defaultGradient)
				{
					_defaultGradient = new Gradient([0x0066FD,0xFFFFFF, 0x996600, 0xFFCC00, 0xFFFFFF]);
				}
				v = _defaultGradient;
			}
			if (v == _gradient) return;
			_gradient = v;
			draw(true);
		}
		
		
		/**
		 * @default -1
		 */
		public function get gradientAffordance():int
		{
			return _gradientAffordance;
		}
		public function set gradientAffordance(v:int):void
		{
			if (v == _gradientAffordance) return;
			_gradientAffordance = v;
			draw(true);
		}
		
		
		public function get debug():Boolean
		{
			return _debug;
		}
		public function set debug(v:Boolean):void
		{
			if (v == _debug) return;
			_debug = v;
			_shape.mask = v ? null : _tf;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function setup():void
		{
			_tf = new TextField();
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.embedFonts = true;
			_tf.mouseEnabled = false;
			_tf.multiline = false;
			_tf.selectable = false;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.gridFitType = GridFitType.PIXEL;
			_tf.type = TextFieldType.DYNAMIC;
			_tf.borderColor = 0xFF00FF;
			_tf.textColor = 0xFF00FF;
			_tf.border = false;
			
			_shape = new Shape();
			_shape.mask = _tf;
			
			addChild(_shape);
			addChild(_tf);
		}
		
		
		/**
		 * @private
		 */
		protected function draw(force:Boolean = false):void
		{
			if (!force && _tf.width == _oldWidth && _tf.height == _oldHeight) return;
			
			var gh:int = _gradientAffordance < 0
				? _tf.height - (_tf.height - _tf.textHeight) : _tf.height - _gradientAffordance;
			if (gh < 0) return;
			
			drawGradient(_shape, _tf.width, gh, _gradient);
			_shape.y = int((_tf.height - gh) * 0.5);
			
			_oldWidth = _tf.width;
			_oldHeight = _tf.height;
		}
		
		
		/**
		 * @private
		 */
		protected static function drawGradient(s:Shape, w:int, h:int, g:Gradient):void
		{
			if (!_matrix) _matrix = new Matrix();
			_matrix.createGradientBox(w, h, (g.rotation * Math.PI / 180));
			
			s.graphics.clear();
			s.graphics.lineStyle();
			s.graphics.beginGradientFill(g.type, g.colors, g.alphas, g.ratios, _matrix,
				g.spreadMethod, g.interpolationMethod, g.focalPointRatio);
			s.graphics.drawRect(0, 0, w, h);
			s.graphics.endFill();
		}
	}
}
