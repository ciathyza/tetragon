/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Copyright (c) 2007-2008 Sascha Balkau / Hexagon Star Softworks
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.view.ui.controls 
{
	import tetragon.view.ui.constants.ButtonLabelPlacement;
	import tetragon.view.ui.managers.IFocusManager;
	import tetragon.view.ui.managers.IFocusManagerGroup;

	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	/**
	 * Dispatched when the radio button instance's <code>selected</code> property changes.
	 * @eventType flash.events.Event.CHANGE
	 */
	[Event(name="change" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the user clicks the radio button with the mouse or spacebar.
	 * @eventType flash.events.MouseEvent.CLICK
	 */
	[Event(name="click" , type="flash.events.MouseEvent")]
	
	[Style(name="icon", type="Class")]
	[Style(name="upIcon", type="Class")]
	[Style(name="downIcon", type="Class")]
	[Style(name="overIcon", type="Class")]
	[Style(name="disabledIcon", type="Class")]
	[Style(name="selectedDisabledIcon", type="Class")]
	[Style(name="selectedUpIcon", type="Class")]
	[Style(name="selectedDownIcon", type="Class")]
	[Style(name="selectedOverIcon", type="Class")]
	[Style(name="textPadding", type="Number", format="Length")]
	
	
	/**
	 * The RadioButton component lets you force a user to make a single selection from
	 * a set of choices. This component must be used in a group of at least two RadioButton
	 * instances. Only one member of the group can be selected at any given time. Selecting
	 * one radio button in a group deselects the currently selected radio button in the
	 * group. You set the <code>groupName</code> parameter to indicate which group a radio
	 * button belongs to. When the user clicks or tabs into a RadioButton component group,
	 * only the selected radio button receives focus.
	 *
	 * <p>A radio button can be enabled or disabled. A disabled radio button does not receive
	 * mouse or keyboard input.</p>
	 *
	 * @see RadioButtonGroup
	 */
	public class RadioButton extends LabelButton implements IFocusManagerGroup
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _value:Object;
		protected var _group:RadioButtonGroup;
		protected var defaultGroupName:String = "RadioButtonGroup";
		
		private static var _defaultStyles:Object =
		{
			icon:					null,
			upIcon:					"RadioButtonUpIcon",
			downIcon:				"RadioButtonDownIcon",
			overIcon:				"RadioButtonOverIcon",
			disabledIcon:			"RadioButtonDisabledIcon",
			selectedDisabledIcon:	"RadioButtonSelectedDisabledIcon",
			selectedUpIcon:			"RadioButtonSelectedUpIcon",
			selectedDownIcon:		"RadioButtonSelectedDownIcon",
			selectedOverIcon:		"RadioButtonSelectedOverIcon",
			focusRectSkin:			null,
			focusRectPadding:		null,
			textFormat:				null,
			disabledTextFormat:		null,
			embedFonts:				null,
			textPadding:			5
		};

		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		
		/**
		 * Creates a new RadioButton component instance.
		 */
		public function RadioButton()
		{
			super();
			_mode = "border";
			groupName = defaultGroupName;
		}
		
		
		/**
		 * Shows or hides the focus indicator around this component instance.
		 *
		 * @param focused Show or hide the focus indicator.
		 */		
		override public function drawFocus(focused:Boolean):void
		{
			super.drawFocus(focused);
			
			/* Size focusRect to fit hitArea, not actual width/height */
			if (focused)
			{
				var focusPadding:Number = Number(getStyleValue("focusRectPadding"));
				_focusRect.x = _bg.x - focusPadding;
				_focusRect.y = _bg.y - focusPadding;
				_focusRect.width = _bg.width + (focusPadding * 2);
				_focusRect.height = _bg.height + (focusPadding * 2);
			}
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		public static function get styleDefinition():Object
		{ 
			return _defaultStyles;
		}
		
		
		/**
		 * A radio button is a toggle button; its <code>toggle</code> property is set to
		 * <code>true</code> in the constructor and cannot be changed.
		 * 
		 * @throws Error This property cannot be set on the RadioButton.
		 * @default true
		 */
		override public function get toggle():Boolean
		{
			return true;
		}
		override public function set toggle(v:Boolean):void
		{
			/* can't turn toggle off in a radiobutton! */
			throw new Error("Warning: You cannot change a RadioButtons toggle.");
		}
		
		
		/**
		 * A radio button never auto-repeats by definition, so the <code>autoRepeat</code>
		 * property is set to <code>false</code> in the constructor and cannot be changed.
		 */
		override public function get autoRepeat():Boolean
		{
			return false;
		}
		override public function set autoRepeat(v:Boolean):void
		{
			return;
		}
		
		
		/**
		 * Indicates whether a radio button is currently selected (<code>true</code>) or
		 * deselected (<code>false</code>). You can only set this value to <code>true</code>;
		 * setting it to <code>false</code> has no effect. To achieve the desired effect,
		 * select a different radio button in the same radio button group.
		 * 
		 * @default false
		 */		
		[Inspectable(defaultValue=false)]
		override public function get selected():Boolean
		{
			return super.selected;
		}
		override public function set selected(v:Boolean):void
		{
			/* can only set to true in RadioButton */
			if (v == false || selected) return; 
			if (_group != null) _group.selection = this; 
			else super.selected = v;
		}
		
		
		/**
		 * The group name for a radio button instance or group. You can use this property to get
		 * or set a group name for a radio button instance or for a radio button group.
		 *
		 * @default "RadioButtonGroup"
		 */        
		[Inspectable(defaultValue="RadioButtonGroup")]
		public function get groupName():String 
		{
			return (_group == null) ? null : _group.name;
		}
		public function set groupName(v:String):void
		{
			if (_group != null)
			{
				_group.removeRadioButton(this);
				_group.removeEventListener(Event.CHANGE, onChange);
			}
			
			_group = (v == null) ? null : RadioButtonGroup.getGroup(v);
			
			if (_group != null)
			{
				/* Default to the easiest option, which is to select a newly added selected rb. */
				_group.addRadioButton(this);
				_group.addEventListener(Event.CHANGE, onChange, false, 0, true);
			}
		}
		
		
		/**
		 * The RadioButtonGroup object to which this RadioButton belongs.
		 */
		public function get group():RadioButtonGroup
		{
			return _group;
		}
		public function set group(v:RadioButtonGroup):void
		{
			groupName = v.name;
		}
		
		
		/**
		 * A user-defined value that is associated with a radio button.
		 * @default null
		 */
		[Inspectable(type="String")]
		public function get value():Object
		{
			return _value;
		}
		public function set value(v:Object):void
		{
			_value = v;
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Event Handlers                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		protected function onChange(e:Event):void
		{
			super.selected = (_group.selection == this);
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		
		/**
		 * @private
		 */
		protected function onClick(e:MouseEvent):void
		{
			if (_group == null) return;
			_group.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true));
		}
		
		
		/**
		 * @private
		 */
		override protected function onKeyFocusDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.DOWN:
					setNext(!e.ctrlKey);
					e.stopPropagation();
					break;
				case Keyboard.UP:
					setPrev(!e.ctrlKey);
					e.stopPropagation();
					break;
				case Keyboard.LEFT:
					setPrev(!e.ctrlKey);
					e.stopPropagation();
					break;
				case Keyboard.RIGHT:
					setNext(!e.ctrlKey);
					e.stopPropagation();
					break;
				case Keyboard.SPACE:
					setThis();
					/* disable toggling behavior for the RadioButton when dealing with
					 * the spacebar since selection is maintained by the group instead */
					_isToggle = false;
					/* fall through, no break */
				default:
					super.onKeyFocusDown(e);
					break;
			}
		}
		
		
		/**
		 * @private
		 */		 
		override protected function onKeyFocusUp(e:KeyboardEvent):void
		{
			super.onKeyFocusUp(e);
			if (e.keyCode == Keyboard.SPACE && !_isToggle)
			{
				/* we disabled _toggle for SPACE because we don't want to allow
				 * de-selection, but now it needs to be re-enabled */
				_isToggle = true;
			}
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Private Methods                                                                    //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */	
		override protected function configUI():void
		{
			super.configUI();
			super.toggle = true;
			
			var bg:Shape = new Shape();
			var g:Graphics = bg.graphics;
			
			g.beginFill(0, 0);
			g.drawRect(0, 0, 100, 100);
			g.endFill();
			_bg = DisplayObject(bg);
			addChildAt(_bg, 0);
			
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		
		/**
		 * @private
		 */
		override protected function draw():void
		{
			super.draw();
		}
		
		
		/**
		 * @private
		 */
		override protected function drawLayout():void
		{
			super.drawLayout();	
			
			var textPadding:Number = Number(getStyleValue("textPadding"));
			
			switch (_labelPlacement)
			{
				case ButtonLabelPlacement.RIGHT:
					_icon.x = textPadding;
					_tf.x = _icon.x + (_icon.width + textPadding);
					_bg.width = _tf.x + _tf.width + textPadding;
					_bg.height = Math.max(_tf.height, _icon.height) + textPadding * 2;
					break;
				case ButtonLabelPlacement.LEFT:
					_icon.x = width - _icon.width - textPadding;
					_tf.x = width - _icon.width - textPadding * 2 - _tf.width;
					_bg.width = _tf.width + _icon.width + textPadding * 3;
					_bg.height = Math.max(_tf.height, _icon.height) + textPadding * 2;
					break;
				case ButtonLabelPlacement.TOP:
				case ButtonLabelPlacement.BOTTOM:
					_bg.width = Math.max(_tf.width, _icon.width) + textPadding * 2;
					_bg.height = _tf.height + _icon.height + textPadding * 3;
					break;
			}
			
			_bg.x = Math.min(_icon.x - textPadding, _tf.x - textPadding);
			_bg.y = Math.min(_icon.y - textPadding, _tf.y - textPadding);
		}
		
		
		/**
		 * @private
		 */
		override protected function drawBackground():void
		{
			/* Do nothing, handled in BaseButton.drawLayout() */
		}
		
		
		/**
		 * @private
		 */
		private function setPrev(moveSelection:Boolean = true):void
		{
			var g:RadioButtonGroup = _group;
			if (g == null) return;
			var fm:IFocusManager = focusManager;
			if (fm) fm.showFocusIndicator = true;
			var indexNumber:int = g.getRadioButtonIndex(this);
			var counter:int = indexNumber;
			
			if (indexNumber != -1)
			{
				do
				{
					counter--;
					counter = (counter == -1) ? g.numRadioButtons - 1 : counter;
					var radioButton:RadioButton = g.getRadioButtonAt(counter);
					
					if (radioButton && radioButton.enabled)
					{
						if (moveSelection)
						{
							g.selection = radioButton;
						}
						radioButton.setFocus();
						return;
					}
					
					if (moveSelection && g.getRadioButtonAt(counter) != g.selection)
					{
						g.selection = this;
					}
					drawFocus(true);
				}
				while (counter != indexNumber);
			}
		}
		
		
		/**
		 * @private
		 */
		private function setNext(moveSelection:Boolean = true):void
		{
			var g:RadioButtonGroup = _group;
			if (g == null) return;
			var fm:IFocusManager = focusManager;
			if (fm) fm.showFocusIndicator = true;
			var indexNumber:int = g.getRadioButtonIndex(this);
			var counter:int = indexNumber;
			
			if (indexNumber != -1)
			{
				do 
				{
					counter++;
					counter = (counter > g.numRadioButtons - 1) ? 0 : counter;
					var radioButton:RadioButton = g.getRadioButtonAt(counter);
					
					if (radioButton && radioButton.enabled)
					{
						if (moveSelection)
						{
							g.selection = radioButton;
						}
						radioButton.setFocus();
						return;
					}
					
					if (moveSelection && g.getRadioButtonAt(counter) != g.selection)
					{
						g.selection = this;
					}
					drawFocus(true);
				}
				while (counter != indexNumber);
			}
		}
		
		
		/**
		 * @private
		 */
		private function setThis():void
		{
			var g:RadioButtonGroup = _group;
			if (g != null)
			{
				if (g.selection != this)
				{
					g.selection = this;
				}
			}
			else
			{
				super.selected = true;
			}
		}
	}
}
