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
package tetragon.view.render2d.display
{
	import tetragon.core.constants.HAlign;
	import tetragon.core.constants.VAlign;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.events.TouchEvent2D;
	import tetragon.view.render2d.text.TextField2D;
	import tetragon.view.render2d.textures.Texture2D;
	import tetragon.view.render2d.touch.Touch2D;
	import tetragon.view.render2d.touch.TouchPhase2D;

	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	
	/** Dispatched when the user triggers the button. Bubbles. */
	[Event(name="triggered", type="tetragon.view.render2d.events.Event2D")]
	/** A simple button composed of an image and, optionally, text.
	 *  
	 *  <p>You can pass a texture for up- and downstate of the button. If you do not provide a down 
	 *  state, the button is simply scaled a little when it is touched.
	 *  In addition, you can overlay a text on the button. To customize the text, almost the 
	 *  same options as those of text fields are provided. In addition, you can move the text to a 
	 *  certain position with the help of the <code>textBounds</code> property.</p>
	 *  
	 *  <p>To react on touches on a button, there is special <code>triggered</code>-event type. Use
	 *  this event instead of normal touch events - that way, users can cancel button activation
	 *  by moving the mouse/finger away from the button before releasing.</p> 
	 */
	public class Button2D extends DisplayObjectContainer2D
	{
		private static const MAX_DRAG_DIST:Number = 50;
		private var mUpState:Texture2D;
		private var mDownState:Texture2D;
		private var mContents:Sprite2D;
		private var mBackground:Image2D;
		private var mTextField:TextField2D;
		private var mTextBounds:Rectangle;
		private var mScaleWhenDown:Number;
		private var mAlphaWhenDisabled:Number;
		private var mEnabled:Boolean;
		private var mIsDown:Boolean;
		private var mUseHandCursor:Boolean;


		/** Creates a button with textures for up- and down-state or text. */
		public function Button2D(upState:Texture2D, text:String = "", downState:Texture2D = null)
		{
			if (upState == null) throw new ArgumentError("Texture cannot be null");

			mUpState = upState;
			mDownState = downState ? downState : upState;
			mBackground = new Image2D(upState);
			mScaleWhenDown = downState ? 1.0 : 0.9;
			mAlphaWhenDisabled = 0.5;
			mEnabled = true;
			mIsDown = false;
			mUseHandCursor = true;
			mTextBounds = new Rectangle(0, 0, upState.width, upState.height);

			mContents = new Sprite2D();
			mContents.addChild(mBackground);
			addChild(mContents);
			addEventListener(TouchEvent2D.TOUCH, onTouch);

			if (text.length != 0) this.text = text;
		}


		private function resetContents():void
		{
			mIsDown = false;
			mBackground.texture = mUpState;
			mContents.x = mContents.y = 0;
			mContents.scaleX = mContents.scaleY = 1.0;
		}


		private function createTextField():void
		{
			if (mTextField == null)
			{
				mTextField = new TextField2D(mTextBounds.width, mTextBounds.height, "");
				mTextField.vAlign = VAlign.CENTER;
				mTextField.hAlign = HAlign.CENTER;
				mTextField.touchable = false;
				mTextField.autoScale = true;
				mContents.addChild(mTextField);
			}

			mTextField.width = mTextBounds.width;
			mTextField.height = mTextBounds.height;
			mTextField.x = mTextBounds.x;
			mTextField.y = mTextBounds.y;
		}


		private function onTouch(event:TouchEvent2D):void
		{
			Mouse.cursor = (mUseHandCursor && mEnabled && event.interactsWith(this)) ? MouseCursor.BUTTON : MouseCursor.AUTO;

			var touch:Touch2D = event.getTouch(this);
			if (!mEnabled || touch == null) return;

			if (touch.phase == TouchPhase2D.BEGAN && !mIsDown)
			{
				mBackground.texture = mDownState;
				mContents.scaleX = mContents.scaleY = mScaleWhenDown;
				mContents.x = (1.0 - mScaleWhenDown) / 2.0 * mBackground.width;
				mContents.y = (1.0 - mScaleWhenDown) / 2.0 * mBackground.height;
				mIsDown = true;
			}
			else if (touch.phase == TouchPhase2D.MOVED && mIsDown)
			{
				// reset button when user dragged too far away after pushing
				var buttonRect:Rectangle = getBounds(stage);
				if (touch.globalX < buttonRect.x - MAX_DRAG_DIST || touch.globalY < buttonRect.y - MAX_DRAG_DIST || touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST || touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST)
				{
					resetContents();
				}
			}
			else if (touch.phase == TouchPhase2D.ENDED && mIsDown)
			{
				resetContents();
				dispatchEventWith(Event2D.TRIGGERED, true);
			}
		}


		/** The scale factor of the button on touch. Per default, a button with a down state 
		 * texture won't scale. */
		public function get scaleWhenDown():Number
		{
			return mScaleWhenDown;
		}


		public function set scaleWhenDown(value:Number):void
		{
			mScaleWhenDown = value;
		}


		/** The alpha value of the button when it is disabled. @default 0.5 */
		public function get alphaWhenDisabled():Number
		{
			return mAlphaWhenDisabled;
		}


		public function set alphaWhenDisabled(value:Number):void
		{
			mAlphaWhenDisabled = value;
		}


		/** Indicates if the button can be triggered. */
		public function get enabled():Boolean
		{
			return mEnabled;
		}


		public function set enabled(value:Boolean):void
		{
			if (mEnabled != value)
			{
				mEnabled = value;
				mContents.alpha = value ? 1.0 : mAlphaWhenDisabled;
				resetContents();
			}
		}


		/** The text that is displayed on the button. */
		public function get text():String
		{
			return mTextField ? mTextField.text : "";
		}


		public function set text(value:String):void
		{
			createTextField();
			mTextField.text = value;
		}


		/** The name of the font displayed on the button. May be a system font or a registered 
		 * bitmap font. */
		public function get fontName():String
		{
			return mTextField ? mTextField.fontName : "Verdana";
		}


		public function set fontName(value:String):void
		{
			createTextField();
			mTextField.fontName = value;
		}


		/** The size of the font. */
		public function get fontSize():Number
		{
			return mTextField ? mTextField.fontSize : 12;
		}


		public function set fontSize(value:Number):void
		{
			createTextField();
			mTextField.fontSize = value;
		}


		/** The color of the font. */
		public function get fontColor():uint
		{
			return mTextField ? mTextField.color : 0x0;
		}


		public function set fontColor(value:uint):void
		{
			createTextField();
			mTextField.color = value;
		}


		/** Indicates if the font should be bold. */
		public function get fontBold():Boolean
		{
			return mTextField ? mTextField.bold : false;
		}


		public function set fontBold(value:Boolean):void
		{
			createTextField();
			mTextField.bold = value;
		}


		/** The texture that is displayed when the button is not being touched. */
		public function get upState():Texture2D
		{
			return mUpState;
		}


		public function set upState(value:Texture2D):void
		{
			if (mUpState != value)
			{
				mUpState = value;
				if (!mIsDown) mBackground.texture = value;
			}
		}


		/** The texture that is displayed while the button is touched. */
		public function get downState():Texture2D
		{
			return mDownState;
		}


		public function set downState(value:Texture2D):void
		{
			if (mDownState != value)
			{
				mDownState = value;
				if (mIsDown) mBackground.texture = value;
			}
		}


		/** The vertical alignment of the text on the button. */
		public function get textVAlign():String
		{
			return mTextField.vAlign;
		}


		public function set textVAlign(value:String):void
		{
			createTextField();
			mTextField.vAlign = value;
		}


		/** The horizontal alignment of the text on the button. */
		public function get textHAlign():String
		{
			return mTextField.hAlign;
		}


		public function set textHAlign(value:String):void
		{
			createTextField();
			mTextField.hAlign = value;
		}


		/** The bounds of the textfield on the button. Allows moving the text to a custom position. */
		public function get textBounds():Rectangle
		{
			return mTextBounds.clone();
		}


		public function set textBounds(value:Rectangle):void
		{
			mTextBounds = value.clone();
			createTextField();
		}


		/** Indicates if the mouse cursor should transform into a hand while it's over the button. 
		 *  @default true */
		public override function get useHandCursor():Boolean
		{
			return mUseHandCursor;
		}


		public override function set useHandCursor(value:Boolean):void
		{
			mUseHandCursor = value;
		}
	}
}