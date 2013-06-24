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
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * Dispatched when the selected RadioButton instance in a group changes.
	 * @eventType flash.events.Event.CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]

	/**
	 * Dispatched when a RadioButton instance is clicked.
	 * @eventType flash.events.MouseEvent.CLICK
	 */
	[Event(name="click", type="flash.events.MouseEvent")]

	
	/**
	 * The RadioButtonGroup class defines a group of RadioButton components 
	 * to act as a single component. When one radio button is selected, no other
	 * radio buttons from the same group can be selected.
	 *
	 * @see RadioButton
	 */
	public class RadioButtonGroup extends EventDispatcher
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected static var _groups:Object;
		protected static var _groupCount:uint = 0;
		
		protected var _name:String;
		protected var _radioButtons:Vector.<RadioButton>;
		protected var _selection:RadioButton;
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new RadioButtonGroup instance. This is usually done
		 * automatically when a radio button is instantiated.
		 * 
		 * Should be a private constructor, but not allowed in AS3, so instead
		 * we'll make it work properly if you create a new RadioButtonGroup manually.
		 * 
		 * @param name The name of the radio button group.
		 */
		public function RadioButtonGroup(name:String)
		{
			_name = name;
			_radioButtons = new Vector.<RadioButton>();
			registerGroup(this);
		}
		
		
		/**
		 * Retrieves a reference to the specified radio button group.
		 *
		 * @param name The name of the group for which to retrieve a reference.
		 * @return A reference to the specified RadioButtonGroup.
		 */
		public static function getGroup(name:String):RadioButtonGroup
		{
			if (_groups == null) _groups = {}; 
			var group:RadioButtonGroup = RadioButtonGroup(_groups[name]);
			
			if (group == null)
			{
				group = new RadioButtonGroup(name);
				/* every so often, we should clean up old groups */
				if ((++_groupCount) % 20 == 0) cleanUpGroups();
			}
			return group;
		}
		
		
		/**
		 * Adds a radio button to the internal radio button array for use with radio
		 * button group indexing, which allows for the selection of a single radio button
		 * in a group of radio buttons. This method is used automatically by radio buttons, 
		 * but can also be manually used to explicitly add a radio button to a group.
		 *
		 * @param radioButton The RadioButton instance to be added to the current radio
		 *         button group.
		 */
		public function addRadioButton(radioButton:RadioButton):void
		{
			if (radioButton.groupName != _name)
			{
				radioButton.groupName = _name;
				return;
			}
			
			_radioButtons.push(radioButton);
			if (radioButton.selected) selection = radioButton; 
		}
		
		
		/**
		 * Clears the RadioButton instance from the internal list of radio buttons.
		 *
		 * @param radioButton The RadioButton instance to remove.
		 */
		public function removeRadioButton(radioButton:RadioButton):void
		{
			var i:int = getRadioButtonIndex(radioButton);
			if (i != -1) _radioButtons.splice(i, 1);
			if (_selection == radioButton) _selection = null; 
		}
		
		
		/**
		 * Returns the index of the specified RadioButton instance.
		 *
		 * @param radioButton The RadioButton instance to locate in the current
		 *         RadioButtonGroup.
		 * @return The index of the specified RadioButton component, or -1 if the
		 *          specified RadioButton was not found.
		 */
		public function getRadioButtonIndex(radioButton:RadioButton):int
		{
			for (var i:int = 0; i < _radioButtons.length; i++)
			{
				var rb:RadioButton = RadioButton(_radioButtons[i]);
				if (rb == radioButton) return i;
			}
			return -1;
		}
		
		
		/**
		 * Retrieves the RadioButton component at the specified index location.
		 *
		 * @param index The index of the RadioButton component in the RadioButtonGroup
		 *         component, where the index of the first component is 0.
		 * @return The specified RadioButton component.
		 * @throws RangeError The specified index is less than 0 or greater than or equal
		 *          to the length of the data provider.
		 */
		public function getRadioButtonAt(index:int):RadioButton
		{
			return RadioButton(_radioButtons[index]);
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Gets the instance name of the radio button.
		 * @default "RadioButtonGroup"
		 */
		public function get name():String
		{
			return _name;
		}
		
		
		/**
		 * Gets or sets a reference to the radio button that is currently selected 
		 * from the radio button group.
		 */
		public function get selection():RadioButton
		{
			return _selection;
		}
		public function set selection(v:RadioButton):void
		{
			if (_selection == v || v == null || getRadioButtonIndex(v) == -1) return;
			_selection = v;
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		
		/**
		 * Gets or sets the selected radio button's <code>value</code> property.
		 * If no radio button is currently selected, this property is <code>null</code>.
		 */
		public function get selectedData():Object
		{
			var s:RadioButton = _selection;
			return (s == null) ? null : s.value;
		}
		public function set selectedData(v:Object):void
		{
			for (var i:int = 0; i < _radioButtons.length; i++)
			{
				var rb:RadioButton = RadioButton(_radioButtons[i]);
				if (rb.value == v)
				{
					selection = rb;
					return;
				}
			}
		}
		
		
		/**
		 * Gets the number of radio buttons in this radio button group.
		 * @default 0
		 */
		public function get numRadioButtons():int
		{
			return _radioButtons.length;
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Private Methods                                                                    //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		protected static function registerGroup(group:RadioButtonGroup):void
		{
			if (_groups == null) _groups = {};
			_groups[group.name] = group;
		}
		
		
		/**
		 * @private
		 */
		protected static function cleanUpGroups():void
		{
			for (var n:String in _groups)
			{
				var group:RadioButtonGroup = RadioButtonGroup(_groups[n]);
				if (group._radioButtons.length == 0)
				{
					delete(_groups[n]);
				}
			}
		}
	}
}
