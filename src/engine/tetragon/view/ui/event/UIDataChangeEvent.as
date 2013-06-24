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
package tetragon.view.ui.event
{
	import flash.events.Event;

	
	/**
	 * The DataChangeEvent class defines the event that is dispatched when the data
	 * that is associated with a component changes. This event is used by the List,
	 * DataGrid, TileList, and ComboBox components.
	 * 
	 * @see DataChangeType
	 */
	public class UIDataChangeEvent extends Event 
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Constants                                                                          //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Defines the value of the <code>type</code> property of a <code>dataChange</code>
		 * event object.
		 *
		 * <p>This event has the following properties:</p>
		 * <table class="innertable" width="100%"><tr><th>Property</th><th>Value</th></tr>
		 * <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 * <tr><td><code>cancelable</code></td><td><code>false</code>; there is no default
		 * behavior to cancel.</td></tr><tr><td><code>changeType</code></td><td>Identifies
		 * the type of change that was made.</td></tr><tr><td><code>currentTarget</code>
		 * </td><td>The object that is actively processing the event object with an event
		 * listener.</td></tr><tr><td><code>endIndex</code></td><td>Identifies the index of
		 * the last changed item.</td></tr><tr><td><code>items</code></td><td>An array that
		 * lists the items that were changed.</td></tr><tr><td><code>startIndex</code></td>
		 * <td>Identifies the index of the first changed item.</td></tr><tr><td><code>target
		 * </code></td><td>The object that dispatched the event. The target is not always the
		 * object listening for the event. Use the <code>currentTarget</code> property to
		 * access the object that is listening for the event.</td></tr></table>
		 *
		 * @eventType dataChange
		 * @see #PRE_DATA_CHANGE
		 */
		public static const DATA_CHANGE:String = "dataChange";
		
		/**
		 * Defines the value of the <code>type</code> property of a <code>preDataChange</code>
		 * event object. This event object is dispatched before a change is made to component data.
		 *
		 * <p>This event has the following properties:</p>
		 * <table class="innertable" width="100%"><tr><th>Property</th><th>Value</th></tr>
		 * <tr><td><code>bubbles</code></td><td><code>false</code></td></tr><tr><td><code>
		 * cancelable</code></td><td><code>false</code>; there is no default behavior to
		 * cancel.</td></tr><tr><td><code>changeType</code></td><td>Identifies the type of
		 * change to be made.</td></tr><tr><td><code>currentTarget</code></td><td>The object
		 * that is actively processing the event object with an event listener.</td></tr>
		 * <tr><td><code>endIndex</code></td><td>Identifies the index of the last item to be
		 * changed.</td></tr><tr><td><code>items</code></td><td>An array that lists the items
		 * to be changed.</td></tr><tr><td><code>startIndex</code></td><td>Identifies the
		 * index of the first item to be changed.</td></tr><tr><td><code>target</code></td>
		 * <td>The object that dispatched the event. The target is not always the object
		 * listening for the event. Use the <code>currentTarget</code> property to access
		 * the object that is listening for the event.</td></tr></table>
		 * 
		 * @eventType preDataChange
		 * @see #DATA_CHANGE
		 */
		public static const PRE_DATA_CHANGE:String = "preDataChange";
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _startIndex:uint;
		protected var _endIndex:uint;
		protected var _changeType:String;
		protected var _items:Array;
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new DataChangeEvent object with the specified parameters.
		 *
		 * @param eventType The type of change event.
		 * @param changeType The type of change that was made. The DataChangeType class
		 *         defines the possible values for this parameter.
		 * @param items A list of items that were changed.
		 * @param startIndex The index of the first item that was changed.
		 * @param endIndex The index of the last item that was changed.
		 */
		public function UIDataChangeEvent(eventType:String,
											changeType:String,
											items:Array,
											startIndex:int = -1,
											endIndex:int = -1):void
		{
			super(eventType);
			
			_changeType = changeType;
			_startIndex = startIndex;
			_items = items;
			_endIndex = (endIndex == -1) ? _startIndex : endIndex;
		}
		
		
		/**
		 * Creates a copy of the DataEvent object and sets the value of each parameter
		 * to match that of the original.
		 *
		 * @return A new DataChangeEvent object with property values that match those of the
		 *          original.
		 */
		override public function clone():Event
		{
			return new UIDataChangeEvent(type, _changeType, _items, _startIndex, _endIndex);
		}
		
		
		/**
		 * Returns a string that contains all the properties of the DataChangeEvent object.
		 * The string is in the following format:
		 * 
		 * <p>[<code>DataChangeEvent type=<em>value</em> changeType=<em>value</em> 
		 * startIndex=<em>value</em> endIndex=<em>value</em> bubbles=<em>value</em>
		 * cancelable=<em>value</em></code>]</p>
		 *
		 * @return A string that contains all the properties of the DataChangeEvent object.
		 */
		override public function toString():String
		{
			return formatToString("DataChangeEvent", "type", "changeType", "startIndex",
				"endIndex", "bubbles", "cancelable");
		}

		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Gets the type of the change that triggered the event. The DataChangeType class 
		 * defines the possible values for this property.
		 *
		 * @see DataChangeType
		 */
		public function get changeType():String
		{
			return _changeType;
		}
		
		
		/**
		 * Gets an array that contains the changed items.
		 */
		public function get items():Array
		{
			return _items;
		}
		
		
		/**
		 * Gets the index of the first changed item in the array of items 
		 * that were changed.
		 *
		 * @see #endIndex
		 */
		public function get startIndex():uint
		{
			return _startIndex;
		}
		
		
		/**
		 * Gets the index of the last changed item in the array of items
		 * that were changed.
		 *
		 * @see #startIndex
		 */
		public function get endIndex():uint
		{
			return _endIndex;
		}
	}
}
