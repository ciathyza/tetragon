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
	 * The ListEvent class defines events for list-based components including the List,
	 * DataGrid, TileList, and ComboBox components. These events include the following: <ul>
	 * <li><code>ListEvent.ITEM_CLICK</code>: dispatched after the user clicks the mouse
	 * over an item in the component.</li> <li><code>ListEvent.ITEM_DOUBLE_CLICK</code>:
	 * dispatched after the user clicks the mouse twice in rapid succession over an item in
	 * the component.</li> <li><code>ListEvent.ITEM_ROLL_OUT</code>: dispatched after the
	 * user rolls the mouse pointer out of an item in the component.</li> <li><code>
	 * ListEvent.ITEM_ROLL_OVER</code>: dispatched after the user rolls the mouse pointer
	 * over an item in the component.</li> </ul>
	 * 
	 * @see fl.controls.List List
	 * @see fl.controls.SelectableList SelectableList
	 */
	public class UIListEvent extends Event
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Constants                                                                          //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Defines the value of the <code>type</code> property of an <code>itemRollOut</code>
		 * event object. <p> This event has the following properties: </p> <table
		 * class="innertable" width="100%"> <tr> <th>Property</th> <th>Value</th> </tr> <tr>
		 * <td><code>bubbles</code></td> <td><code>false</code></td> </tr> <tr>
		 * <td><code>cancelable</code></td> <td><code>false</code>; there is no default behavior
		 * to cancel.</td> </tr> <tr> <td><code>columnIndex</code></td> <td>The zero-based index
		 * of the column that contains the renderer.</td> </tr> <tr> <td><code>currentTarget
		 * </code></td> <td>The object that is actively processing the event object with an
		 * event listener.</td> </tr> <tr> <td><code>index</code></td> <td>The zero-based index
		 * in the DataProvider that contains the renderer.</td> </tr> <tr>
		 * <td><code>item</code></td> <td>A reference to the data that belongs to the
		 * renderer.</td> </tr> <tr> <td><code>rowIndex</code></td> <td>The zero-based index of
		 * the row that contains the renderer.</td> </tr> <tr> <td><code>target</code></td>
		 * <td>The object that dispatched the event. The target is not always the object
		 * listening for the event. Use the <code>currentTarget</code> property to access the
		 * object that is listening for the event.</td> </tr> </table>
		 * 
		 * @eventType itemRollOut
		 * @see #ITEM_ROLL_OVER
		 */
		public static const ITEM_ROLL_OUT:String = "itemRollOut";
		
		/**
		 * Defines the value of the <code>type</code> property of an
		 * <code>itemRollOver</code> event object. <p>This event has the following
		 * properties:</p> <table class="innertable" width="100%">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 * <tr><td><code>cancelable</code></td><td><code>false</code>; there is no default
		 * behavior to cancel.</td></tr> <tr><td><code>columnIndex</code></td><td>The
		 * zero-based index of the column that contains the renderer.</td></tr>
		 * <tr><td><code>currentTarget</code></td><td>The object that is actively processing
		 * the event object with an event listener.</td></tr>
		 * <tr><td><code>index</code></td><td>The zero-based index in the DataProvider that
		 * contains the renderer.</td></tr> <tr><td><code>item</code></td><td>A reference to
		 * the data that belongs to the renderer.</td></tr>
		 * <tr><td><code>rowIndex</code></td><td>The zero-based index of the row that
		 * contains the renderer.</td></tr> <tr><td><code>target</code></td><td>The object
		 * that dispatched the event. The target is not always the object listening for the
		 * event. Use the <code>currentTarget</code> property to access the object that is
		 * listening for the event.</td></tr> </table>
		 * 
		 * @eventType itemRollOver
		 * @see #ITEM_ROLL_OUT
		 */
		public static const ITEM_ROLL_OVER:String = "itemRollOver";
		
		/**
		 * Defines the value of the <code>type</code> property of an <code>itemClick</code>
		 * event object. <p>This event has the following properties:</p> <table
		 * class="innertable" width="100%"> <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 * <tr><td><code>cancelable</code></td><td><code>true</code></td></tr>
		 * <tr><td><code>columnIndex</code></td><td>The zero-based index of the column that
		 * contains the renderer.</td></tr> <tr><td><code>currentTarget</code></td><td>The
		 * object that is actively processing the event object with an event
		 * listener.</td></tr> <tr><td><code>index</code></td><td>The zero-based index in
		 * the DataProvider that contains the renderer.</td></tr>
		 * <tr><td><code>item</code></td><td>A reference to the data that belongs to the
		 * renderer. </td></tr> <tr><td><code>rowIndex</code></td><td>The zero-based index
		 * of the row that contains the renderer.</td></tr>
		 * <tr><td><code>target</code></td><td>The object that dispatched the event. The
		 * target is not always the object listening for the event. Use the
		 * <code>currentTarget</code> property to access the object that is listening for
		 * the event.</td></tr> </table>
		 * 
		 * @eventType itemClick
		 */
		public static const ITEM_CLICK:String = "itemClick";
		
		/**
		 * Defines the value of the <code>type</code> property of an
		 * <code>itemDoubleClick</code> event object. <p>This event has the following
		 * properties:</p> <table class="innertable" width="100%">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 * <tr><td><code>cancelable</code></td><td><code>true</code></td></tr>
		 * <tr><td><code>columnIndex</code></td><td>The zero-based index of the column that
		 * contains the renderer.</td></tr> <tr><td><code>currentTarget</code></td><td>The
		 * object that is actively processing the event object with an event
		 * listener.</td></tr> <tr><td><code>index</code></td><td>The zero-based index in
		 * the DataProvider that contains the renderer.</td></tr>
		 * <tr><td><code>item</code></td><td>A reference to the data that belongs to the
		 * renderer. </td></tr> <tr><td><code>rowIndex</code></td><td>The zero-based index
		 * of the row that contains the renderer.</td></tr>
		 * <tr><td><code>target</code></td><td>The object that dispatched the event. The
		 * target is not always the object listening for the event. Use the
		 * <code>currentTarget</code> property to access the object that is listening for
		 * the event.</td></tr> </table>
		 * 
		 * @eventType itemDoubleClick
		 */
		public static const ITEM_DOUBLE_CLICK:String = "itemDoubleClick";
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _rowIndex:int;
		protected var _columnIndex:int;
		protected var _index:int;
		protected var _item:Object;
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new ListEvent object with the specified parameters.
		 * 
		 * @param type The event type; this value identifies the action that caused the
		 *            event.
		 * @param bubbles Indicates whether the event can bubble up the display list
		 *            hierarchy.
		 * @param cancelable Indicates whether the behavior associated with the event can be
		 *            prevented.
		 * @param columnIndex The zero-based index of the column that contains the renderer
		 *            or visual representation of the data in the column.
		 * @param rowIndex The zero-based index of the row that contains the renderer or
		 *            visual representation of the data in the row.
		 * @param index The zero-based index of the item in the DataProvider.
		 * @param item A reference to the data that belongs to the renderer.
		 */
		public function UIListEvent(type:String,
									 bubbles:Boolean = false,
									 cancelable:Boolean = false,
									 columnIndex:int = -1,
									 rowIndex:int = -1,
									 index:int = -1,
									 item:Object = null)
		{
			super(type, bubbles, cancelable);
			
			_rowIndex = rowIndex;
			_columnIndex = columnIndex;
			_index = index;
			_item = item;
		}
		
		
		/**
		 * Creates a copy of the ListEvent object and sets the value of each parameter to
		 * match the original.
		 * 
		 * @return A new ListEvent object with parameter values that match those of the
		 *         original.
		 */
		override public function clone():Event
		{
			return new UIListEvent(type, bubbles, cancelable, _columnIndex, _rowIndex);
		}
		
		
		/**
		 * Returns a string that contains all the properties of the ListEvent object. The
		 * string is in the following format: <p>[<code>ListEvent type=<em>value</em>
		 * bubbles=<em>value</em> cancelable=<em>value</em> columnIndex=<em>value</em>
		 * rowIndex=<em>value</em></code>]</p>
		 * 
		 * @return A string representation of the ListEvent object.
		 */
		override public function toString():String 
		{
			return formatToString("ListEvent", "type", "bubbles", "cancelable",
				"columnIndex", "rowIndex", "index", "item");
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Gets the row index of the item that is associated with this event.
		 * 
		 * @see #columnIndex
		 */
		public function get rowIndex():Object 
		{
			return _rowIndex;
		}
		
		
		/**
		 * Gets the column index of the item that is associated with this event.
		 * 
		 * @see #rowIndex
		 */
		public function get columnIndex():int 
		{
			return _columnIndex;
		}
		
		
		/**
		 * Gets the zero-based index of the cell that contains the renderer.
		 */
		public function get index():int 
		{
			return _index;
		}
		
		
		/**
		 * Gets the data that belongs to the current cell renderer.
		 */
		public function get item():Object 
		{
			return _item;
		}
	}
}
