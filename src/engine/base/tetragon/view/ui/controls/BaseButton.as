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
package tetragon.view.ui.controls
{
	import tetragon.view.ui.core.UIComponent;
	import tetragon.view.ui.core.UIInvalidationType;
	import tetragon.view.ui.signal.UIComponentSignal;
	import tetragon.view.ui.theme.UIStyleNames;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	/**
	 * The BaseButton class is the base class for all button components, defining
	 * properties and methods that are common to all buttons. This class handles drawing
	 * states and the dispatching of button events.
	 */
	public class BaseButton extends UIComponent
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		protected static const STATE_UP:String = "up";
		protected static const STATE_OVER:String = "over";
		protected static const STATE_DOWN:String = "down";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _bg:DisplayObject;
		protected var _timer:Timer;
		protected var _mouseState:String;
		private var _unlockedMouseState:String;
		
		protected var _isSelected:Boolean;
		protected var _isAutoRepeat:Boolean;
		private var _isMouseStateLocked:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function BaseButton(id:String = null)
		{
			super(id);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Set the mouse state via ActionScript. The BaseButton class uses this
		 * property internally, but it can also be invoked manually, and will
		 * set the mouse state visually.
		 * 
		 * @param state A string that specifies a mouse state. Supported values
		 *         are "up", "over", and "down".
		 */
		public function setMouseState(state:String):void
		{
			if (_isMouseStateLocked)
			{
				_unlockedMouseState = state;
				return;
			}
			
			if (_mouseState == state) return;
			_mouseState = state;
			invalidate(UIInvalidationType.STATE);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			_timer.removeEventListener(TimerEvent.TIMER, onButtonDown);
			removeEventListener(MouseEvent.ROLL_OVER, onMouseEvent);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			removeEventListener(MouseEvent.ROLL_OUT, onMouseEvent);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Gets or sets a value that indicates whether the component can accept user 
		 * input. A value of <code>true</code> indicates that the component can accept
		 * user input; a value of <code>false</code> indicates that it cannot.
		 * 
		 * <p>When this property is set to <code>false</code>, the button is disabled.
		 * This means that although it is visible, it cannot be clicked. This property is 
		 * useful for disabling a specific part of the user interface. For example, a
		 * button that is used to trigger the reloading of a web page could be disabled
		 * by using this technique.</p>
		 */
		override public function get enabled():Boolean
		{
			return super.enabled;
		}
		override public function set enabled(v:Boolean):void
		{
			super.enabled = v;
			mouseEnabled = v;
		}
		
		
		/**
		 * Gets or sets a Boolean value that indicates whether a toggle button is
		 * selected. A value of <code>true</code> indicates that the button is selected;
		 * a value of <code>false</code> indicates that it is not. This property has no
		 * effect if the <code>toggle</code> property is not set to <code>true</code>.
		 * 
		 * <p>For a CheckBox component, this value indicates whether the box is checked.
		 * For a RadioButton component, this value indicates whether the component is
		 * selected.</p>
		 * 
		 * <p>This value changes when the user clicks the component but can also be
		 * changed programmatically. If the <code>toggle</code> property is set to
		 * <code>true</code>, changing this property causes a <code>change</code> event
		 * object to be dispatched.</p>
		 */
		public function get selected():Boolean
		{
			return _isSelected;
		}
		public function set selected(v:Boolean):void
		{
			if (_isSelected == v) return;
			_isSelected = v;
			invalidate(UIInvalidationType.STATE);
		}
		
		
		/**
		 * Gets or sets a Boolean value that indicates whether the <code>buttonDown</code>
		 * event is dispatched more than one time when the user holds the mouse button down
		 * over the component. A value of <code>true</code> indicates that the <code>
		 * buttonDown</code> event is dispatched repeatedly while the mouse button remains
		 * down; a value of <code>false</code> indicates that the event is dispatched only
		 * one time.
		 * 
		 * <p>If this value is <code>true</code>, after the delay specified by the <code>
		 * repeatDelay</code> style, the <code>buttonDown</code> event is dispatched at the
		 * interval that is specified by the <code>repeatInterval</code> style.</p>
		 */
		public function get autoRepeat():Boolean
		{
			return _isAutoRepeat;
		}
		public function set autoRepeat(v:Boolean):void
		{
			_isAutoRepeat = v;
		}
		
		
		/**
		 * @private
		 */
		internal function set mouseStateLocked(v:Boolean):void
		{
			_isMouseStateLocked = v;
			if (!v) setMouseState(_unlockedMouseState);
			else _unlockedMouseState = _mouseState;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onButtonDown(e:TimerEvent):void
		{
			if (!_isAutoRepeat)
			{
				endPress();
				return;
			}
			
			if (_timer.currentCount == 1) _timer.delay = getStyleValue(UIStyleNames.REPEAT_INTERVAL);
			if (_signal) _signal.dispatch(UIComponentSignal.BUTTON_DOWN, this);
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseEvent(e:MouseEvent):void
		{
			switch (e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					setMouseState(STATE_DOWN);
					startPress();
					break;
				case MouseEvent.ROLL_OVER:
				case MouseEvent.MOUSE_UP:
					setMouseState(STATE_OVER);
					endPress();
					break;
				case MouseEvent.ROLL_OUT:
					setMouseState(STATE_UP);
					endPress();
					break;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function setup():void
		{
			super.setup();
			
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			setupMouseEvents();
			setMouseState(STATE_UP);

			_timer = new Timer(1, 0);
			_timer.addEventListener(TimerEvent.TIMER, onButtonDown);
		}
		
		
		/**
		 * @private
		 */
		protected function setupMouseEvents():void
		{
			addEventListener(MouseEvent.ROLL_OVER, onMouseEvent);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			addEventListener(MouseEvent.ROLL_OUT, onMouseEvent);
		}
		
		
		/**
		 * @private
		 */
		protected function startPress():void
		{
			if (_isAutoRepeat)
			{
				_timer.delay = getStyleValue(UIStyleNames.REPEAT_DELAY);
				_timer.start();
			}
			if (_signal) _signal.dispatch(UIComponentSignal.BUTTON_DOWN, this);
		}
		
		
		/**
		 * @private
		 */
		protected function endPress():void
		{
			_timer.reset();
		}
		
		
		/**
		 * @private
		 */
		override protected function draw():void
		{
			if (isInvalid(UIInvalidationType.STYLES, UIInvalidationType.STATE))
			{
				drawBackground();
				/* invalidates size without calling draw next frame. */
				invalidate(UIInvalidationType.SIZE, false);
			}
			if (isInvalid(UIInvalidationType.SIZE))
			{
				drawLayout();
			}
			super.draw();
		}
		
		
		/**
		 * @private
		 */
		protected function drawBackground():void
		{
			var styleName:String = enabled ? _mouseState : "disabled";
			if (selected)
			{ 
				styleName = "selected" + styleName.substr(0, 1).toUpperCase() + styleName.substr(1);
			}
			
			styleName += "Skin";
			var bg:DisplayObject = _bg;
			_bg = getSkinInstance(getStyleValue(styleName), this);
			addChildAt(_bg, 0);
			
			if (bg && bg != _bg) removeChild(bg);
		}
		
		
		/**
		 * @private
		 */
		protected function drawLayout():void
		{
			_bg.width = width;
			_bg.height = height;
		}
	}
}
