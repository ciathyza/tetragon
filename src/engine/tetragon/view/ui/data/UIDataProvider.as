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
package tetragon.view.ui.data
{
	import tetragon.view.ui.event.UIDataChangeEvent;
	import tetragon.view.ui.event.UIDataChangeType;

	import flash.events.EventDispatcher;
	
	
	/**
	 * Dispatched before the data is changed.
	 * @see #event:dataChange dataChange event
	 * @eventType fl.events.DataChangeEvent.PRE_DATA_CHANGE
	 */
	[Event(name="preDataChange", type="tetragon.view.ui.event.UIDataChangeEvent")]

	/**
	 * Dispatched after the data is changed.
	 * @see #event:preDataChange preDataChange event
	 * @eventType fl.events.DataChangeEvent.DATA_CHANGE
	 */
	[Event(name="dataChange", type="tetragon.view.ui.event.UIDataChangeEvent")]
	
	
	/**
	 * The DataProvider class provides methods and properties that allow you to query and
	 * modify the data in any list-based component--for example, in a List, DataGrid,
	 * TileList, or ComboBox component. <p>A <em>data provider</em> is a linear collection
	 * of items that serve as a data source--for example, an array. Each item in a data
	 * provider is an object or XML object that contains one or more fields of data. You can
	 * access the items that are contained in a data provider by index, by using the
	 * <code>DataProvider.getItemAt()</code> method.</p>
	 */
	public class UIDataProvider extends EventDispatcher
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var data:Array;
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new DataProvider object using a list, XML instance or an array of data
		 * objects as the data source.
		 * 
		 * @param data The data that is used to create the DataProvider.
		 */
		public function UIDataProvider(value:Object = null)
		{			
			if (value == null) data = [];
			else data = getDataFromObject(value);
		}
		
		
		/**
		 * Invalidates the item at the specified index. An item is invalidated after it is
		 * changed; the DataProvider automatically redraws the invalidated item.
		 * 
		 * @param index Index of the item to be invalidated.
		 * @throws RangeError The specified index is less than 0 or greater than or equal to
		 *             the length of the data provider.
		 * @see #invalidate()
		 * @see #invalidateItem()
		 */
		public function invalidateItemAt(index:int):void
		{
			checkIndex(index, data.length - 1);
			dispatchChangeEvent(UIDataChangeType.INVALIDATE, [data[index]], index, index);
		}
		
		
		/**
		 * Invalidates the specified item. An item is invalidated after it is changed; the
		 * DataProvider automatically redraws the invalidated item.
		 * 
		 * @param item Item to be invalidated.
		 * @see #invalidate()
		 * @see #invalidateItemAt()
		 */
		public function invalidateItem(item:Object):void
		{
			var index:uint = getItemIndex(item);
			if (index == -1) return; 
			invalidateItemAt(index);
		}
		
		
		/**
		 * Invalidates all the data items that the DataProvider contains and dispatches a
		 * <code>DataChangeEvent.INVALIDATE_ALL</code> event. Items are invalidated after
		 * they are changed; the DataProvider automatically redraws the invalidated items.
		 * 
		 * @see #invalidateItem()
		 * @see #invalidateItemAt()
		 */
		public function invalidate():void
		{
			dispatchEvent(new UIDataChangeEvent(UIDataChangeEvent.DATA_CHANGE,
				UIDataChangeType.INVALIDATE_ALL, data.concat(), 0, data.length));
		}
		
		
		/**
		 * Adds a new item to the data provider at the specified index. If the index that is
		 * specified exceeds the length of the data provider, the index is ignored.
		 * 
		 * @param item An object that contains the data for the item to be added.
		 * @param index The index at which the item is to be added.
		 * @throws RangeError The specified index is less than 0 or greater than or equal to
		 *             the length of the data provider.
		 * @see #addItem()
		 * @see #addItems()
		 * @see #addItemsAt()
		 * @see #getItemAt()
		 * @see #removeItemAt()
		 */
		public function addItemAt(item:Object, index:uint):void
		{
			checkIndex(index, data.length);
			dispatchPreChangeEvent(UIDataChangeType.ADD, [item], index, index);
			data.splice(index, 0, item);
			dispatchChangeEvent(UIDataChangeType.ADD, [item], index, index);
		}
		
		
		/**
		 * Appends an item to the end of the data provider.
		 * 
		 * @param item The item to be appended to the end of the current data provider.
		 * @see #addItemAt()
		 * @see #addItems()
		 * @see #addItemsAt()
		 */
		public function addItem(item:Object):void
		{
			dispatchPreChangeEvent(UIDataChangeType.ADD, [item], data.length - 1,
				data.length - 1);
			data.push(item);
			dispatchChangeEvent(UIDataChangeType.ADD, [item], data.length - 1, data.length - 1);
		}
		
		
		/**
		 * Adds several items to the data provider at the specified index and dispatches a
		 * <code>DataChangeType.ADD</code> event.
		 * 
		 * @param items The items to be added to the data provider.
		 * @param index The index at which the items are to be inserted.
		 * @throws RangeError The specified index is less than 0 or greater than or equal to
		 *             the length of the data provider.
		 * @see #addItem()
		 * @see #addItemAt()
		 * @see #addItems()
		 */
		public function addItemsAt(items:Object, index:uint):void
		{
			checkIndex(index, data.length);
			var a:Array = getDataFromObject(items);
			dispatchPreChangeEvent(UIDataChangeType.ADD, a, index, index + a.length - 1);
			data.splice.apply(data, [index,0].concat(a));
			dispatchChangeEvent(UIDataChangeType.ADD, a, index, index + a.length - 1);
		}
		
		
		/**
		 * Appends multiple items to the end of the DataProvider and dispatches a
		 * <code>DataChangeType.ADD</code> event. The items are added in the order in which
		 * they are specified.
		 * 
		 * @param items The items to be appended to the data provider.
		 * @see #addItem()
		 * @see #addItemAt()
		 * @see #addItemsAt()
		 */
		public function addItems(items:Object):void
		{
			addItemsAt(items, data.length);
		}
		
		
		/**
		 * Concatenates the specified items to the end of the current data provider. This
		 * method dispatches a <code>DataChangeType.ADD</code> event.
		 * 
		 * @param items The items to be added to the data provider.
		 * @see #addItems()
		 * @see #merge()
		 */
		public function concat(items:Object):void
		{
			addItems(items);
		}
		
		
		/**
		 * Appends the specified data into the data that the data provider contains and
		 * removes any duplicate items. This method dispatches a
		 * <code>DataChangeType.ADD</code> event.
		 * 
		 * @param data Data to be merged into the data provider.
		 * @see #concat()
		 */
		public function merge(newData:Object):void
		{
			var arr:Array = getDataFromObject(newData);
			var l:uint = arr.length;
			var startLength:uint = data.length;
			
			dispatchPreChangeEvent(UIDataChangeType.ADD, data.slice(startLength,
				data.length), startLength, data.length - 1);
			
			for (var i:int = 0; i < l; i++)
			{
				var item:Object = arr[i];
				if (getItemIndex(item) == -1) data.push(item);
			}
			
			if (data.length > startLength)
			{
				dispatchChangeEvent(UIDataChangeType.ADD, data.slice(startLength,
					data.length), startLength, data.length - 1);
			}
			else 
			{
				dispatchChangeEvent(UIDataChangeType.ADD, [], -1, -1);
			}
		}
		
		
		/**
		 * Returns the item at the specified index.
		 * 
		 * @param index Location of the item to be returned.
		 * @return The item at the specified index.
		 * @throws RangeError The specified index is less than 0 or greater than or equal to
		 *             the length of the data provider.
		 * @see #getItemIndex()
		 * @see #removeItemAt()
		 */
		public function getItemAt(index:uint):Object
		{
			checkIndex(index, data.length - 1);
			return data[index];
		}
		
		
		/**
		 * Returns the index of the specified item.
		 * 
		 * @param item The item to be located.
		 * @return The index of the specified item, or -1 if the specified item is not
		 *         found.
		 * @see #getItemAt()
		 */
		public function getItemIndex(item:Object):int
		{
			return data.indexOf(item);
		}
		
		
		/**
		 * Removes the item at the specified index and dispatches a
		 * <code>DataChangeType.REMOVE</code> event.
		 * 
		 * @param index Index of the item to be removed.
		 * @return The item that was removed.
		 * @throws RangeError The specified index is less than 0 or greater than or equal to
		 *             the length of the data provider.
		 * @see #removeAll()
		 * @see #removeItem()
		 */
		public function removeItemAt(index:uint):Object
		{
			checkIndex(index, data.length - 1);
			dispatchPreChangeEvent(UIDataChangeType.REMOVE, data.slice(index, index + 1),
				index, index);
			var a:Array = data.splice(index, 1);
			dispatchChangeEvent(UIDataChangeType.REMOVE, a, index, index);
			return a[0];
		}
		
		
		/**
		 * Removes the specified item from the data provider and dispatches a
		 * <code>DataChangeType.REMOVE</code> event.
		 * 
		 * @param item Item to be removed.
		 * @return The item that was removed.
		 * @see #removeAll()
		 * @see #removeItemAt()
		 */
		public function removeItem(item:Object):Object
		{
			var index:int = getItemIndex(item);
			if (index != -1) return removeItemAt(index);
			return null;
		}
		
		
		/**
		 * Removes all items from the data provider and dispatches a
		 * <code>DataChangeType.REMOVE_ALL</code> event.
		 * 
		 * @see #removeItem()
		 * @see #removeItemAt()
		 */
		public function removeAll():void
		{
			var a:Array = data.concat();
			dispatchPreChangeEvent(UIDataChangeType.REMOVE_ALL, a, 0, a.length);
			data = [];
			dispatchChangeEvent(UIDataChangeType.REMOVE_ALL, a, 0, a.length);
		}
		
		
		/**
		 * Replaces an existing item with a new item and dispatches a
		 * <code>DataChangeType.REPLACE</code> event.
		 * 
		 * @param oldItem The item to be replaced.
		 * @param newItem The replacement item.
		 * @return The item that was replaced.
		 * @throws RangeError The item could not be found in the data provider.
		 * @see #replaceItemAt()
		 */
		public function replaceItem(newItem:Object, oldItem:Object):Object
		{
			var index:int = getItemIndex(oldItem);
			if (index != -1) return replaceItemAt(newItem, index);
			return null;
		}
		
		
		/**
		 * Replaces the item at the specified index and dispatches a
		 * <code>DataChangeType.REPLACE</code> event.
		 * 
		 * @param newItem The replacement item.
		 * @param index The index of the item to be replaced.
		 * @return The item that was replaced.
		 * @throws RangeError The specified index is less than 0 or greater than or equal to
		 *             the length of the data provider.
		 * @see #replaceItem()
		 */
		public function replaceItemAt(newItem:Object, index:uint):Object
		{
			checkIndex(index, data.length - 1);
			var a:Array = [data[index]];
			dispatchPreChangeEvent(UIDataChangeType.REPLACE, a, index, index);
			data[index] = newItem;
			dispatchChangeEvent(UIDataChangeType.REPLACE, a, index, index);
			return a[0];
		}
		
		
		/**
		 * Sorts the items that the data provider contains and dispatches a
		 * <code>DataChangeType.SORT</code> event.
		 * 
		 * @param sortArg The arguments to use for sorting.
		 * @return The return value depends on whether the method receives any arguments.
		 *         See the <code>Array.sort()</code> method for more information. This
		 *         method returns 0 when the <code>sortOption</code> property is set to
		 *         <code>Array.UNIQUESORT</code>.
		 * @see #sortOn()
		 * @see Array#sort() Array.sort()
		 */
		public function sort(...sortArgs:Array):*
		{
			dispatchPreChangeEvent(UIDataChangeType.SORT, data.concat(), 0, data.length - 1);
			var a:Array = data.sort.apply(data, sortArgs);
			dispatchChangeEvent(UIDataChangeType.SORT, data.concat(), 0, data.length - 1);
			return a;
		}
		
		
		/**
		 * Sorts the items that the data provider contains by the specified field and
		 * dispatches a <code>DataChangeType.SORT</code> event. The specified field can be a
		 * string, or an array of string values that designate multiple fields to sort on in
		 * order of precedence.
		 * 
		 * @param fieldName The item field by which to sort. This value can be a string or
		 *            an array of string values.
		 * @param options Options for sorting.
		 * @return The return value depends on whether the method receives any arguments.
		 *         For more information, see the <code>Array.sortOn()</code> method. If the
		 *         <code>sortOption</code> property is set to <code>Array.UNIQUESORT</code>,
		 *         this method returns 0.
		 * @see #sort()
		 * @see Array#sortOn() Array.sortOn()
		 */
		public function sortOn(fieldName:Object, options:Object = null):*
		{
			dispatchPreChangeEvent(UIDataChangeType.SORT, data.concat(), 0, data.length - 1);
			var a:Array = data.sortOn(fieldName, options);
			dispatchChangeEvent(UIDataChangeType.SORT, data.concat(), 0, data.length - 1);
			return a;
		}
		
		
		/**
		 * Creates a copy of the current DataProvider object.
		 * 
		 * @return A new instance of this DataProvider object.
		 */
		public function clone():UIDataProvider
		{
			return new UIDataProvider(data);
		}
		
		
		/**
		 * Creates an Array object representation of the data that the data provider
		 * contains.
		 * 
		 * @return An Array object representation of the data that the data provider
		 *         contains.
		 */
		public function toArray():Array
		{
			return data.concat();
		}
		
		
		/**
		 * Creates a string representation of the data that the data provider contains.
		 * 
		 * @return A string representation of the data that the data provider contains.
		 */
		override public function toString():String
		{
			return "DataProvider [" + data.join(", ") + "]";
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * The number of items that the data provider contains.
		 */
		public function get length():uint
		{
			return data.length;
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Private Methods                                                                    //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		protected function getDataFromObject(obj:Object):Array
		{
			var result:Array;
			
			if (obj is Array)
			{
				var a:Array = obj as Array;
				if (a.length > 0)
				{
					if (a[0] is String || a[0] is Number)
					{
						result = [];
						/* convert to object array. */
						var len:int = a.length;
						for (var i:int = 0; i < len; i++)
						{
							var o:Object = {label: String(a[i]), data: a[i]};
							result.push(o);
						}
						return result;
					}
				}
				return a.concat();
			}
			else if (obj is UIDataProvider)
			{
				return UIDataProvider(obj).toArray();
			}
			else if (obj is XML)
			{
				var xml:XML = XML(obj);
				var nodes:XMLList = xml.*;
				result = [];
				
				for each (var node:XML in nodes)
				{
					var ob:Object = {};
					var attrs:XMLList = node.attributes();
					
					for each (var attr:XML in attrs)
					{
						ob[attr.localName()] = attr.toString();
					}
					var propNodes:XMLList = node.*;
					for each (var propNode:XML in propNodes)
					{
						if (propNode.hasSimpleContent())
						{
							ob[propNode.localName()] = propNode.toString();
						}
					}
					result.push(ob);
				}
				return result;
			}
			else
			{
				throw new TypeError("[DataProvider] Error: Type Coercion failed: cannot convert "
					+ obj + " to Array or DataProvider.");
				return null;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function checkIndex(index:int, maximum:int):void
		{
			if (index > maximum || index < 0)
			{
				throw new RangeError("[DataProvider] Index (" + index
					+ ") is not in acceptable range (0 - " + maximum + ")");
			}
		}
		
		
		/**
		 * @private
		 */
		protected function dispatchChangeEvent(evtType:String,
													items:Array,
													startIndex:int,
													endIndex:int):void
		{
			dispatchEvent(new UIDataChangeEvent(UIDataChangeEvent.DATA_CHANGE,
				evtType, items, startIndex, endIndex));
		}
		
		
		/**
		 * @private
		 */
		protected function dispatchPreChangeEvent(evtType:String,
														items:Array,
														startIndex:int,
														endIndex:int):void
		{
			dispatchEvent(new UIDataChangeEvent(UIDataChangeEvent.PRE_DATA_CHANGE,
				evtType, items, startIndex, endIndex));
		}
	}
}
