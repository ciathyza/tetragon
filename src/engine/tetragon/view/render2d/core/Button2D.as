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
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import tetragon.view.render2d.core.events.Event2D;
	import tetragon.view.render2d.core.events.Touch2D;
	import tetragon.view.render2d.core.events.TouchEvent2D;
	import tetragon.view.render2d.core.events.TouchPhase2D;


	
	
	/**
	 * A simple button composed of an image and, optionally, text.
	 * 
	 * <p>
	 * You can pass a texture for up- and downstate of the button. If you do not provide a
	 * down state, the button is simply scaled a little when it is touched. In addition,
	 * you can overlay a text on the button. To customize the text, almost the same
	 * options as those of text fields are provided. In addition, you can move the text to
	 * a certain position with the help of the <code>textBounds</code> property.
	 * </p>
	 * 
	 * <p>
	 * To react on touches on a button, there is special <code>triggered</code>-event
	 * type. Use this event instead of normal touch events - that way, users can cancel
	 * button activation by moving the mouse/finger away from the button before releasing.
	 * </p>
	 */
	public class Button2D extends DisplayObjectContainer2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static const MAX_DRAG_DISTANCE:Number = 50;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _upState:Texture2D;
		/** @private */
		private var _downState:Texture2D;
		/** @private */
		private var _contents:Sprite2D;
		/** @private */
		private var _background:Image2D;
		/** @private */
		private var _textField:TextField2D;
		/** @private */
		private var _textBounds:Rectangle;
		/** @private */
		private var _scaleWhenDown:Number;
		/** @private */
		private var _alphaWhenDisabled:Number;
		/** @private */
		private var _enabled:Boolean;
		/** @private */
		private var _isDown:Boolean;
		/** @private */
		private var _useHandCursor:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a button with textures for up- and down-state or text.
		 * 
		 * @param upState
		 * @param text
		 * @param downState
		 */
		public function Button2D(upState:Texture2D, text:String = "", downState:Texture2D = null)
		{
			if (upState == null) throw new ArgumentError("Texture cannot be null");

			_upState = upState;
			_downState = downState ? downState : upState;
			_background = new Image2D(upState);
			_scaleWhenDown = downState ? 1.0 : 0.9;
			_alphaWhenDisabled = 0.5;
			_enabled = true;
			_isDown = false;
			_useHandCursor = true;
			_textBounds = new Rectangle(0, 0, upState.width, upState.height);

			_contents = new Sprite2D();
			_contents.addChild(_background);
			addChild(_contents);
			addEventListener(TouchEvent2D.TOUCH, onTouch);

			if (text.length != 0) this.text = text;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/** The scale factor of the button on touch. Per default, a button with a down state 
		 * texture won't scale. */
		public function get scaleWhenDown():Number
		{
			return _scaleWhenDown;
		}
		public function set scaleWhenDown(v:Number):void
		{
			_scaleWhenDown = v;
		}
		
		
		/** The alpha value of the button when it is disabled. @default 0.5 */
		public function get alphaWhenDisabled():Number
		{
			return _alphaWhenDisabled;
		}
		public function set alphaWhenDisabled(v:Number):void
		{
			_alphaWhenDisabled = v;
		}
		
		
		/** Indicates if the button can be triggered. */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(v:Boolean):void
		{
			if (v == _enabled) return;
			_enabled = v;
			_contents.alpha = v ? 1.0 : _alphaWhenDisabled;
			resetContents();
		}
		
		
		/** The text that is displayed on the button. */
		public function get text():String
		{
			return _textField ? _textField.text : "";
		}
		public function set text(v:String):void
		{
			createTextField();
			_textField.text = v;
		}
		
		
		/** The name of the font displayed on the button. May be a system font or a registered 
		 * bitmap font. */
		public function get fontName():String
		{
			return _textField ? _textField.fontName : "Verdana";
		}
		public function set fontName(v:String):void
		{
			createTextField();
			_textField.fontName = v;
		}
		
		
		/** The size of the font. */
		public function get fontSize():Number
		{
			return _textField ? _textField.fontSize : 12;
		}
		public function set fontSize(v:Number):void
		{
			createTextField();
			_textField.fontSize = v;
		}
		
		
		/** The color of the font. */
		public function get fontColor():uint
		{
			return _textField ? _textField.color : 0x0;
		}
		public function set fontColor(v:uint):void
		{
			createTextField();
			_textField.color = v;
		}
		
		
		/** Indicates if the font should be bold. */
		public function get fontBold():Boolean
		{
			return _textField ? _textField.bold : false;
		}
		public function set fontBold(v:Boolean):void
		{
			createTextField();
			_textField.bold = v;
		}
		
		
		/** The texture that is displayed when the button is not being touched. */
		public function get upState():Texture2D
		{
			return _upState;
		}
		public function set upState(v:Texture2D):void
		{
			if (v == _upState) return;
			_upState = v;
			if (!_isDown) _background.texture = v;
		}
		
		
		/** The texture that is displayed while the button is touched. */
		public function get downState():Texture2D
		{
			return _downState;
		}
		public function set downState(v:Texture2D):void
		{
			if (v == _downState) return;
			_downState = v;
			if (_isDown) _background.texture = v;
		}
		
		
		/** The bounds of the textfield on the button. Allows moving the text to a custom position. */
		public function get textBounds():Rectangle
		{
			return _textBounds.clone();
		}
		public function set textBounds(v:Rectangle):void
		{
			_textBounds = v.clone();
			createTextField();
		}
		
		
		/** Indicates if the mouse cursor should transform into a hand while it's over the button. 
		 *  @default true */
		public function get useHandCursor():Boolean
		{
			return _useHandCursor;
		}
		public function set useHandCursor(v:Boolean):void
		{
			_useHandCursor = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onTouch(event:TouchEvent2D):void
		{
			Mouse.cursor = (_useHandCursor && _enabled && event.interactsWith(this))
				? MouseCursor.BUTTON
				: MouseCursor.AUTO;
			
			var touch:Touch2D = event.getTouch(this);
			if (!_enabled || !touch) return;
			
			if (touch.phase == TouchPhase2D.BEGAN && !_isDown)
			{
				_background.texture = _downState;
				_contents.scaleX = _contents.scaleY = _scaleWhenDown;
				_contents.x = (1.0 - _scaleWhenDown) / 2.0 * _background.width;
				_contents.y = (1.0 - _scaleWhenDown) / 2.0 * _background.height;
				_isDown = true;
			}
			else if (touch.phase == TouchPhase2D.MOVED && _isDown)
			{
				// reset button when user dragged too far away after pushing
				var buttonRect:Rectangle = getBounds(stage);
				if (touch.globalX < buttonRect.x - MAX_DRAG_DISTANCE || touch.globalY < buttonRect.y - MAX_DRAG_DISTANCE || touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DISTANCE || touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DISTANCE)
				{
					resetContents();
				}
			}
			else if (touch.phase == TouchPhase2D.ENDED && _isDown)
			{
				resetContents();
				dispatchEvent(new Event2D(Event2D.TRIGGERED, true));
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function resetContents():void
		{
			_isDown = false;
			_background.texture = _upState;
			_contents.x = _contents.y = 0;
			_contents.scaleX = _contents.scaleY = 1.0;
		}
		
		
		/**
		 * @private
		 */
		private function createTextField():void
		{
			if (_textField == null)
			{
				_textField = new TextField2D(_textBounds.width, _textBounds.height, "");
				_textField.vAlign = VAlign.CENTER;
				_textField.hAlign = HAlign.CENTER;
				_textField.touchable = false;
				_textField.autoScale = true;
				_contents.addChild(_textField);
			}

			_textField.width = _textBounds.width;
			_textField.height = _textBounds.height;
			_textField.x = _textBounds.x;
			_textField.y = _textBounds.y;
		}
	}
}
