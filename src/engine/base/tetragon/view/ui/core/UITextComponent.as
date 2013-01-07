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
package tetragon.view.ui.core
{
	import tetragon.debug.Log;
	import tetragon.view.ui.signal.UIComponentSignal;
	import tetragon.view.ui.theme.UIStyleNames;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.system.IME;
	import flash.system.IMEConversionMode;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;
	
	
	/**
	 * Provides common methods and properties for TextField-based components like
	 * the TextInput and TextArea. The Label component is not affected by this.
	 */
	public class UITextComponent extends UIComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _tf:TextField;
		/** @private */
		protected var _bg:DisplayObject;
		
		/** @private */
		protected var _savedHTML:String;
		/** @private */
		protected var _imeMode:String;
		/** @private */
		protected var _oldIMEMode:String;
		
		/** @private */
		protected var _editable:Boolean = true;
		/** @private */
		protected var _selectable:Boolean = true;
		/** @private */
		protected var _isHTML:Boolean;
		/** @private */
		protected var _useStylesheet:Boolean;
		/** @private */
		protected var _errorCaught:Boolean;
		/** @private */
		protected var _internalFocus:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new UITextComponent instance.
		 * 
		 * @param id Optional ID.
		 * @param x X-Position of the component.
		 * @param y Y-Position of the component.
		 * @param width Width of the component.
		 * @param height Height of the component.
		 */
		public function UITextComponent(id:String = null, x:Number = 0, y:Number = 0,
			width:Number = 0, height:Number = 0)
		{
			_mouseFocusEnabled = false;
			super();
			
			if (x != 0 || y != 0) move(x, y);
			if (width > 0) _width = width;
			if (height > 0) _height = height;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function drawFocus(focused:Boolean):void
		{
			/* By default the focus rectangle is only drawn on text components
			 * if the focus was done by keyboard (Tab key). This is to conform
			 * with non-textfield components who behave the same. _isInternalFocus
			 * is used to check if the textfield received focus internally by
			 * calling the focus() method. */
			if (_mouseFocusEnabled)
			{
				if (_focusTarget)
				{
					_focusTarget.drawFocus(focused);
					return;
				}
				super.drawFocus(focused);
			}
			else
			{
				if (UIFocusManager.isKeyFocus && !_internalFocus)
				{
					if (_focusTarget)
					{
						_focusTarget.drawFocus(focused);
						return;
					}
					super.drawFocus(focused);
				}
				else
				{
					if (_focusRect && contains(_focusRect))
					{
						removeChild(_focusRect);
						_focusRect = null;
					}
				}
			}
			_internalFocus = false;
		}
		
		
		/**
		 * Sets focus to the TextField of the text component if it allows text input so
		 * that the caret cursor appears and text can be entered immediately.
		 */
		public function focus():void
		{
			if (_tf.type == TextFieldType.INPUT)
			{
				_internalFocus = true;
				var empty:Boolean = _tf.length == 0;
				if (empty) _tf.text = " ";
				if (stage) stage.focus = _tf;
				_tf.setSelection(_tf.length, _tf.length);
				if (empty) _tf.text = "";
			}
		}
		
		
		/**
		 * Sets the range of a selection made in a text area that has focus. The selection
		 * range begins at the index that is specified by the start parameter, and ends at
		 * the index that is specified by the end parameter. If the parameter values that
		 * specify the selection range are the same, this method sets the text insertion
		 * point in the same way that the <code>caretIndex</code> property does.
		 * 
		 * <p>
		 * The selected text is treated as a zero-based string of characters in which the
		 * first selected character is located at index 0, the second character at index
		 * 1, and so on.
		 * </p>
		 * 
		 * <p>
		 * This method has no effect if the text field does not have focus.
		 * </p>
		 * 
		 * @param beginIndex The index location of the first character in the selection.
		 * @param endIndex The index location of the last character in the selection.
		 */
		public function setSelection(beginIndex:int, endIndex:int):void
		{
			_tf.setSelection(beginIndex, endIndex);
		}
		
		
		/**
		 * Retrieves information about a specified line of text.
		 * 
		 * @param lineIndex The line number for which information is to be retrieved.
		 * @return A TextLineMetrics object.
		 */
		public function getLineMetrics(lineIndex:int):TextLineMetrics
		{
			return _tf.getLineMetrics(lineIndex);
		}
		
		
		/**
		 * Appends the specified string after the last character that the text component
		 * contains. This method is more efficient than concatenating two strings by using
		 * an addition assignment on a text property; for example,
		 * <code>myTextArea.text += moreText</code>. This method is particularly useful
		 * when the TextArea component contains a significant amount of content.
		 * 
		 * @param text The string to be appended to the existing text.
		 */
		public function appendText(text:String):void
		{
			_tf.appendText(text);
		}
		
		
		/**
		 * Clears all text from the text component.
		 */
		public function clear():void
		{
			_tf.text = _savedHTML = "";
			invalidate(UIInvalidationType.DATA);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			_tf.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_tf.removeEventListener(Event.CHANGE, onChange);
			_tf.removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Gets or sets a string which contains the text that is currently in 
		 * the TextInput component. This property contains text that is unformatted 
		 * and does not have HTML tags. To retrieve this text formatted as HTML, use 
		 * the <code>htmlText</code> property.
		 * 
		 * @see #htmlText
		 */
		public function get text():String
		{
			return _tf.text;
		}
		public function set text(v:String):void
		{
			_tf.text = v ? v : "";
			_isHTML = false;
			invalidate(UIInvalidationType.DATA);
			invalidate(UIInvalidationType.STYLES);
		}
		
		
		/**
		 * Gets or sets the HTML representation of the string that the text field contains.
		 * 
		 * @see #text
		 */
		public function get htmlText():String
		{
			return _tf.htmlText;
		}
		public function set htmlText(v:String):void
		{
			if (v == "")
			{ 
				text = "";
				return;
			}
			
			_isHTML = true;
			_savedHTML = _tf.htmlText = v ? v : "";
			invalidate(UIInvalidationType.DATA);
			invalidate(UIInvalidationType.STYLES);
		}
		
		
		/**
		 * Gets or sets the mode of the input method editor (IME). The IME makes
		 * it possible for users to use a QWERTY keyboard to enter characters from 
		 * the Chinese, Japanese, and Korean character sets.
		 *
		 * <p>Flash sets the IME to the specified mode when the component gets focus, 
		 * and restores it to the original value after the component loses focus. </p>
		 *
		 * <p>The flash.system.IMEConversionMode class defines constants for 
		 * the valid values for this property. Set this property to <code>null</code> to 
		 * prevent the use of the IME with the component.</p>
		 */
		public function get imeMode():String
		{
			return _imeMode;
		}
		public function set imeMode(v:String):void
		{
			_imeMode = v;
		}
		
		
		/**
		 * Gets or sets a Boolean value that indicates how a selection is
		 * displayed when the text field does not have focus.
		 * <p>When this value is set to <code>true</code> and the text field does 
		 * not have focus, Flash Player highlights the selection in the text field 
		 * in gray. When this value is set to <code>false</code> and the text field 
		 * does not have focus, Flash Player does not highlight the selection in the 
		 * text field.</p>
		 */
		public function get alwaysShowSelection():Boolean
		{
			return _tf.alwaysShowSelection;
		}
		public function set alwaysShowSelection(v:Boolean):void
		{
			_tf.alwaysShowSelection = v;	
		}
		
		
		/**
		 * Gets or sets a Boolean value that indicates whether the text field 
		 * can be edited by the user. A value of <code>true</code> indicates
		 * that the user can edit the text field; a value of <code>false</code>
		 * indicates that the user cannot edit the text field.
		 * 
		 * @default true
		 */		
		public function get editable():Boolean
		{
			return _editable;
		}
		public function set editable(v:Boolean):void
		{
			_editable = v;
		}
		
		
		/**
		 * @default true
		 */
		public function get selectable():Boolean
		{
			return _selectable;
		}
		public function set selectable(v:Boolean):void
		{
			_selectable = v;
		}
		
		
		/**
		 * Gets or sets the change in the position of the scroll bar thumb, in pixels,
		 * after the user scrolls the text field horizontally. If this value is 0, the
		 * text field was not horizontally scrolled.
		 * 
		 * @see #verticalScrollPosition
		 * @see #maxHorizontalScrollPosition
		 */
		public function get horizontalScrollPosition():int
		{
			return _tf.scrollH;
		}
		public function set horizontalScrollPosition(v:int):void
		{
			_tf.scrollH = v;
		}
		
		
		/**
		 * Gets a value that describes the furthest position to which the text 
		 * field can be scrolled to the right.
		 * 
		 * @see #horizontalScrollPosition
		 */
		public function get maxHorizontalScrollPosition():int
		{
			return _tf.maxScrollH;
		}
		
		
		/**
		 * Gets the number of characters in a text component.
		 * 
		 * @see #maxChars
		 */
		public function get length():int
		{
			return _tf.length;
		}
		
		
		/**
		 * Gets or sets the maximum number of characters that a user can enter
		 * in the text field.
		 * 
		 * @see #length
		 */
		public function get maxChars():int
		{
			return _tf.maxChars;
		}
		public function set maxChars(v:int):void
		{
			_tf.maxChars = v;
		}
		
		
		/**
		 * Gets or sets a Boolean value that indicates whether the current TextInput 
		 * component instance was created to contain a password or to contain text. A
		 * value of <code>true</code> indicates that the component instance is a password
		 * text field; a value of <code>false</code> indicates that the component instance
		 * is a normal text field. 
		 * <p>When this property is set to <code>true</code>, for each character that the
		 * user enters into the text field, the TextInput component instance displays an
		 * asterisk. Additionally, the Cut and Copy commands and their keyboard shortcuts
		 * are disabled. These measures prevent the recovery of a password from an
		 * unattended computer.</p>
		 */
		public function get displayAsPassword():Boolean
		{
			return _tf.displayAsPassword;
		}
		public function set displayAsPassword(v:Boolean):void
		{
			_tf.displayAsPassword = v;
		}
		
		
		/**
		 * Gets or sets the string of characters that the text field accepts from a user. 
		 * Note that characters that are not included in this string are accepted in the 
		 * text field if they are entered programmatically.
		 * <p>The characters in the string are read from left to right. You can specify a 
		 * character range by using the hyphen (-) character. </p>
		 * <p>If the value of this property is null, the text field accepts all characters. 
		 * If this property is set to an empty string (""), the text field accepts no
		 * characters.</p>
		 * <p>If the string begins with a caret (^) character, all characters are initially 
		 * accepted and succeeding characters in the string are excluded from the set of 
		 * accepted characters. If the string does not begin with a caret (^) character, 
		 * no characters are initially accepted and succeeding characters in the string 
		 * are included in the set of accepted characters.</p>
		 */
		public function get restrict():String
		{
			return _tf.restrict;
		}
		public function set restrict(v:String):void
		{
			_tf.restrict = v;
		}
		
		
		/**
		 * Gets the index value of the first selected character in a selection 
		 * of one or more characters.
		 * <p>The index position of a selected character is zero-based and calculated 
		 * from the first character that appears in the text area. If there is no 
		 * selection, this value is set to the position of the caret.</p>
		 *
		 * @see #selectionEndIndex
		 * @see #setSelection()
		 */
		public function get selectionBeginIndex():int
		{
			return _tf.selectionBeginIndex;
		}
		
		
		/**
		 * Gets the index position of the last selected character in a selection 
		 * of one or more characters. 
		 * <p>The index position of a selected character is zero-based and calculated 
		 * from the first character that appears in the text area. If there is no 
		 * selection, this value is set to the position of the caret.</p>
		 *
		 * @see #selectionBeginIndex
		 * @see #setSelection()
		 */
		public function get selectionEndIndex():int
		{
			return _tf.selectionEndIndex;
		}
		
		
		/**
		 * Gets or sets a Boolean value that indicates whether extra white space is
		 * removed from a TextInput component that contains HTML text. Examples 
		 * of extra white space in the component include spaces and line breaks.
		 * A value of <code>true</code> indicates that extra 
		 * white space is removed; a value of <code>false</code> indicates that extra 
		 * white space is not removed.
		 * 
		 * <p>This property affects only text that is set by using the <code>htmlText
		 * </code> property; it does not affect text that is set by using the <code>
		 * text</code> property. If you use the <code>text</code> property to set text,
		 * the <code>condenseWhite</code> property is ignored.</p>
		 * 
		 * <p>If the <code>condenseWhite</code> property is set to <code>true</code>,
		 * you must use standard HTML commands, such as &lt;br&gt; and &lt;p&gt;, to
		 * place line breaks in the text field.</p>
		 */
		public function get condenseWhite():Boolean
		{
			return _tf.condenseWhite;
		}
		public function set condenseWhite(v:Boolean):void
		{
			_tf.condenseWhite = v;
		}
		
		
		/**
		 * The width of the text, in pixels.
		 * 
		 * @see #textHeight
		 */
		public function get textWidth():Number
		{
			return _tf.textWidth;
		}
		
		
		/**
		 * The height of the text, in pixels.
		 * 
		 * @see #textWidth
		 */
		public function get textHeight():Number
		{
			return _tf.textHeight;
		}
		
		
		/**
		 * Gets/sets the StyleSheet for use with HTML text.
		 */
		public function set styleSheet(v:StyleSheet):void
		{
			_useStylesheet = v ? true : false;
			_tf.styleSheet = v;
		}
		public function get styleSheet():StyleSheet
		{
			return _tf.styleSheet;
		}
		
		
		/**
		 * Sets the sharpness of the text for embedded fonts.
		 */
		public function get textSharpness():Number
		{
			return _tf.sharpness;
		}
		public function set textSharpness(v:Number):void
		{
			_tf.sharpness = v;
		}
		
		
		/**
		 * Sets the thickness of the text for embedded fonts.
		 */
		public function get textThickness():Number
		{
			return _tf.thickness;
		}
		public function set textThickness(v:Number):void
		{
			_tf.thickness = v;
		}
		
		
		/**
		 * <p>Gets/sets the text component to display a focus rectangle if it has
		 * been focussed with the mouse (true). By default this property is false
		 * so that text components don't display a focus rectangle (like all other
		 * non-text components).</p>
		 * Set this to true if you want the text component to display a focus
		 * rectangle when focussed with the mouse or when the focus() method
		 * is called.
		 */
		override public function get mouseFocusEnabled():Boolean
		{
			return _mouseFocusEnabled;
		}
		override public function set mouseFocusEnabled(v:Boolean):void
		{
			_mouseFocusEnabled = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onKeyDown(e:KeyboardEvent):void
		{
			if (_signal)
			{
				switch (e.keyCode)
				{
					case Keyboard.ENTER:
						_signal.dispatch(UIComponentSignal.ENTER, this);
						break;
					case Keyboard.UP:
						_signal.dispatch(UIComponentSignal.CURSOR_UP, this);
						break;
					case Keyboard.DOWN:
						_signal.dispatch(UIComponentSignal.CURSOR_DOWN, this);
						break;
				}
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onChange(e:Event):void
		{
			e.stopPropagation();
			if (_signal) _signal.dispatch(UIComponentSignal.CHANGE, this);
		}
		
		
		/**
		 * @private
		 */
		protected function onTextInput(e:TextEvent):void
		{
			e.stopPropagation();
			if (_signal) _signal.dispatch(UIComponentSignal.TEXT_INPUT, this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function setup():void
		{
			super.setup();
			
			if (_width <= 0) _width = 120;
			if (_height <= 0) _height = 20;
			
			tabChildren = true;
			
			_tf = new TextField();
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.gridFitType = GridFitType.PIXEL;
			_tf.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_tf.addEventListener(Event.CHANGE, onChange);
			_tf.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			addChild(_tf);
			
			updateTextFieldType();
		}
		
		
		/**
		 * @private
		 */
		protected function updateTextFieldType():void
		{
			_tf.type = (_enabled && _editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			_tf.selectable = _selectable;
		}
		
		
		/**
		 * @private
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean
		{
			return target == _tf || super.isOurFocus(target);
		}
		
		
		/**
		 * @private
		 */
		protected function drawTextFormat():void
		{
			if (!_useStylesheet)
			{
				/* Apply a default textformat */
				var styles:Object = _themeManager.getStyleDefinition(UIComponent);
				var defaultFormat:TextFormat = enabled
					? styles[UIStyleNames.DEFAULT_TEXTFORMAT]
					: styles[UIStyleNames.DEFAULT_TEXTFORMAT_DISABLED];
				
				_tf.setTextFormat(defaultFormat);
				_tf.defaultTextFormat = defaultFormat;
				
				var f:TextFormat = getStyleValue(enabled
					? UIStyleNames.TEXTFORMAT
					: UIStyleNames.TEXTFORMAT_DISABLED);
				
				if (f) _tf.setTextFormat(f);
				else f = defaultFormat;
				
				_tf.defaultTextFormat = f;
			}
			
			setEmbedFont();
			
			if (_isHTML) _tf.htmlText = _savedHTML;
		}
		
		
		/**
		 * @private
		 */
		protected function setEmbedFont():void
		{
			_tf.embedFonts = getStyleValue(UIStyleNames.EMBED_FONTS);
		}
		
		
		/**
		 * @private
		 */
		protected function drawBackground():void
		{
			if (_useSkin)
			{
				var bg:DisplayObject = _bg;
				var styleName:String = enabled ? "upSkin" : "disabledSkin";
				_bg = getSkinInstance(getStyleValue(styleName), this);
				if (!_bg) return;
				addChildAt(_bg, 0);
				if (bg && bg != _bg && contains(bg)) removeChild(bg);
			}
			else
			{
				if (_bg)
				{
					if (contains(_bg)) removeChild(_bg);
					_bg = null;
				}
			}
		}
		
		
		/**
		 * @private
		 */
		protected function drawLayout():void
		{
			if (_bg)
			{
				_bg.width = width;
				_bg.height = height;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function setIMEMode(enabled:Boolean):void
		{
			if (_imeMode)
			{
				if (enabled)
				{
					IME.enabled = true;
					_oldIMEMode = IME.conversionMode;
					try
					{
						if (!_errorCaught && IME.conversionMode != IMEConversionMode.UNKNOWN)
						{
							IME.conversionMode = _imeMode;
						}
						_errorCaught = false;
					}
					catch (err:Error)
					{
						_errorCaught = true;
						Log.error(".setIMEMode(): IME Mode not supported: " + _imeMode, this);
					}
				}
				else
				{
					if (IME.conversionMode != IMEConversionMode.UNKNOWN
						&& _oldIMEMode != IMEConversionMode.UNKNOWN)
					{
						IME.conversionMode = _oldIMEMode;
					}
					IME.enabled = false;
				}
			}
		}
	}
}
