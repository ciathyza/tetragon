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
	import tetragon.view.ui.controls.listclasses.ICellRenderer;
	import tetragon.view.ui.controls.listclasses.ListData;
	import tetragon.view.ui.core.InvalidationType;
	import tetragon.view.ui.core.UIComponent;
	import tetragon.view.ui.managers.IFocusManagerComponent;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	
	/**
	 * The List component displays list-based information and is ideally suited for the
	 * display of arrays of information. <p>The List component consists of items, rows, and
	 * a data provider, which are described as follows:</p> <ul> <li>Item: An ActionScript
	 * object that usually contains a descriptive <code>label</code> property and a
	 * <code>data</code> property that stores the data associated with that item. </li>
	 * <li>Row: A component that is used to display the item. </li> <li>Data provider: A
	 * component that models the items that the List component displays.</li> </ul> <p>By
	 * default, the List component uses the CellRenderer class to supply the rows in which
	 * list items are displayed. You can create these rows programmatically; this is usually
	 * done by subclassing the CellRenderer class. The CellRenderer class implements the
	 * ICellRenderer interface, which provides the set of properties and methods that the
	 * List component uses to manipulate its rows and to send data and state information to
	 * each row for display. This includes information about data sizing and selection.</p>
	 * <p>The List component provides methods that act on its data provider--for example,
	 * the <code>addItem()</code> and <code>removeItem()</code> methods. You can use these
	 * and other methods to manipulate the data of any array that exists in the same frame
	 * as a List component and then broadcast the changes to multiple views. If a List
	 * component is not provided with an external data provider, these methods automatically
	 * create an instance of a data provider and expose it through the
	 * <code>List.dataProvider</code> property. The List component renders each row by using
	 * a Sprite that implements the ICellRenderer interface. To specify this renderer, use
	 * the <code>List.cellRenderer</code> property. You can also build an Array instance or
	 * get one from a server and use it as a data model for multiple lists, combo boxes,
	 * data grids, and so on. </p>
	 */
	public class List extends SelectableList implements IFocusManagerComponent
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _rowHeight:Number = 20;
		protected var _cellRenderer:Object;
		protected var _labelField:String = "label";
		protected var _labelFunction:Function;
		protected var _iconField:String = "icon";
		protected var _iconFunction:Function;
		
		private static var defaultStyles:Object =
		{
			focusRectSkin:		null,
			focusRectPadding:	null
		};
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new List component instance.
		 */
		public function List()
		{
			super();
		}
		
		
		/**
		 * Retrieves the string that the renderer displays for the given data object based
		 * on the <code>labelField</code> and <code>labelFunction</code> properties.
		 * <p><strong>Note:</strong> The <code>labelField</code> is not used if the
		 * <code>labelFunction</code> property is set to a callback function.</p>
		 * 
		 * @param item The object to be rendered.
		 * @return The string to be displayed based on the data.
		 */
		override public function itemToLabel(item:Object):String
		{
			if (_labelFunction != null)
			{
				return String(_labelFunction(item));
			}
			else
			{
				return (item[_labelField] != null) ? String(item[_labelField]) : "";
			}
		}
		
		
		/**
		 * Scrolls the list to the item at the specified index. If the index 
		 * is out of range, the scroll position does not change.
		 *
		 * @param newCaretIndex The index location to scroll to.
		 */
		override public function scrollToIndex(newCaretIndex:int):void
		{
			drawNow();
			
			var lastVisibleItemIndex:uint =
				Math.floor((_verticalScrollPosition + _availableHeight) / rowHeight) - 1;
			var firstVisibleItemIndex:uint = Math.ceil(_verticalScrollPosition / rowHeight);
			
			if (newCaretIndex < firstVisibleItemIndex)
			{
				verticalScrollPosition = newCaretIndex * rowHeight;
			}
			else if (newCaretIndex > lastVisibleItemIndex)
			{
				verticalScrollPosition = (newCaretIndex + 1) * rowHeight - _availableHeight;
			}
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		public static function get styleDefinition():Object
		{ 
			return mergeStyles(defaultStyles, SelectableList.styleDefinition);
		}
		
		
		/**
		 * Gets or sets the name of the field in the <code>dataProvider</code> object to be
		 * displayed as the label for the TextInput field and drop-down list. <p>By default,
		 * the component displays the <code>label</code> property of each
		 * <code>dataProvider</code> item. If the <code>dataProvider</code> items do not
		 * contain a <code>label</code> property, you can set the <code>labelField</code>
		 * property to use a different property.</p> <p><strong>Note:</strong> The
		 * <code>labelField</code> property is not used if the <code>labelFunction</code>
		 * property is set to a callback function.</p>
		 * 
		 * @default "label"
		 * @see #labelFunction
		 */
		public function get labelField():String
		{
			return _labelField;
		}
		public function set labelField(v:String):void
		{
			if (v == _labelField) return;
			_labelField = v;
			invalidate(InvalidationType.DATA);
		}
		
		
		/**
		 * Gets or sets the function to be used to obtain the label for the item. <p>By
		 * default, the component displays the <code>label</code> property for a
		 * <code>dataProvider</code> item. But some data sets may not have a
		 * <code>label</code> field or may not have a field whose value can be used as a
		 * label without modification. For example, a given data set might store full names
		 * but maintain them in <code>lastName</code> and <code>firstName</code> fields. In
		 * such a case, this property could be used to set a callback function that
		 * concatenates the values of the <code>lastName</code> and <code>firstName</code>
		 * fields into a full name string to be displayed.</p> <p><strong>Note:</strong> The
		 * <code>labelField</code> property is not used if the <code>labelFunction</code>
		 * property is set to a callback function.</p>
		 * 
		 * @default null
		 */
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		public function set labelFunction(v:Function):void
		{
			if (_labelFunction == v) return;
			_labelFunction = v;
			invalidate(InvalidationType.DATA);
		}
		
		
		/**
		 * Gets or sets the item field that provides the icon for the item.
		 * <p><strong>Note:</strong> The <code>iconField</code> is not used if the
		 * <code>iconFunction</code> property is set to a callback function.</p>
		 * 
		 * @default "icon"
		 */
 		public function get iconField():String
		{
			return _iconField;
		}
		public function set iconField(v:String):void
		{
			if (v == _iconField) return;
			_iconField = v;
			invalidate(InvalidationType.DATA);
		}
		
		
		/**
		 * Gets or sets the function to be used to obtain the icon for the item.
		 * <p><strong>Note:</strong> The <code>iconField</code> is not used if the
		 * <code>iconFunction</code> property is set to a callback function.</p>
		 * 
		 * @default null
		 */
		public function get iconFunction():Function 
		{
			return _iconFunction;
		}
		public function set iconFunction(v:Function):void
		{
			if (_iconFunction == v) return;
			_iconFunction = v;
			invalidate(InvalidationType.DATA);
		}
		
		
		/**
		 * Gets or sets the number of rows that are at least partially visible in the 
		 * list.
		 */
		override public function get rowCount():uint
		{
			/* This is low right now (ie. doesn't count two half items as a whole) */
			return Math.ceil(calculateAvailableHeight() / rowHeight);
		}
		public function set rowCount(v:uint):void
		{
			var pad:Number = Number(getStyleValue("contentPadding"));
			var scrollBarHeight:Number = (_hScrollPolicy == ScrollPolicy.ON
				|| (_hScrollPolicy == ScrollPolicy.AUTO && _maxHScrollPosition > 0)) ? 15 : 0;
			height = rowHeight * v + 2 * pad + scrollBarHeight;
		}
		
		
		/**
		 * Gets or sets the height of each row in the list, in pixels.
		 *
		 * @default 20
		 */
		public function get rowHeight():Number
		{
			return _rowHeight;
		}
		public function set rowHeight(v:Number):void
		{
			_rowHeight = v;
			invalidate(InvalidationType.SIZE);
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Event Handlers                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		override protected function onKeyFocusDown(e:KeyboardEvent):void
		{
			if (!selectable) return; 
			
			switch (e.keyCode) 
			{
				case Keyboard.UP:
				case Keyboard.DOWN:
				case Keyboard.END:
				case Keyboard.HOME:
				case Keyboard.PAGE_UP:
				case Keyboard.PAGE_DOWN:
					moveSelectionVertically(e.keyCode, e.shiftKey && _allowMultipleSelection,
						e.ctrlKey && _allowMultipleSelection);
					break;
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					moveSelectionHorizontally(e.keyCode, e.shiftKey && _allowMultipleSelection,
						e.ctrlKey && _allowMultipleSelection);
					break;
				case Keyboard.SPACE:
					if (_caretIndex == -1) _caretIndex = 0;
					doKeySelection(_caretIndex, e.shiftKey, e.ctrlKey);
					scrollToSelected();
					break;
				default:
					var nextIndex:int = getNextIndexAtLetter(String.fromCharCode(e.keyCode),
						selectedIndex);
					if (nextIndex > -1)
					{
						selectedIndex = nextIndex;
						scrollToSelected();
					}
					break;
			}
			e.stopPropagation();
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Private Methods                                                                    //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		override protected function configUI():void
		{
			_useFixedHScrolling = true;
			_hScrollPolicy = ScrollPolicy.AUTO;
			_vScrollPolicy = ScrollPolicy.AUTO;
			
			super.configUI();
		}
		
		
		/**
		 * @private
		 */
		protected function calculateAvailableHeight():Number
		{
			var pad:Number = Number(getStyleValue("contentPadding"));
			return height - pad * 2 - ((_hScrollPolicy == ScrollPolicy.ON
				|| (_hScrollPolicy == ScrollPolicy.AUTO && _maxHScrollPosition > 0)) ? 15 : 0);
		}
		
		
		/**
		 * @private
		 */
		override protected function setHorizontalScrollPosition(value:Number,
															fireEvent:Boolean = false):void
		{
			_list.x = -value;
			super.setHorizontalScrollPosition(value, true);
		}
		
		
		/**
		 * @private
		 */
		override protected function setVerticalScrollPosition(scroll:Number,
																fireEvent:Boolean = false):void 
		{
			/* This causes problems. It seems like the render event
			 * can get "blocked" if it's called from within a callLater */
			invalidate(InvalidationType.SCROLL);
			super.setVerticalScrollPosition(scroll, true);
		}

		
		/**
		 * @private
		 */
		override protected function draw():void
		{
			var contentHeightChanged:Boolean = (_contentHeight != rowHeight * length);
			_contentHeight = rowHeight * length;
			
			if (isInvalid(InvalidationType.STYLES))
			{
				setStyles();
				drawBackground();
				
				/* drawLayout is expensive, so only do it if padding has changed */
				if (_contentPadding != getStyleValue("contentPadding"))
				{
					invalidate(InvalidationType.SIZE, false);
				}
				/* redrawing all the cell renderers is even more expensive,
				 * so we really only want to do it if necessary */
				if (_cellRenderer != getStyleValue("cellRenderer"))
				{
					/* remove all the existing renderers */
					_invalidateList();
					_cellRenderer = getStyleValue("cellRenderer");
				}
			}
			
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STATE)
				|| contentHeightChanged)
			{
				drawLayout();
			}
			
			if (isInvalid(InvalidationType.RENDERER_STYLES))
			{
				updateRendererStyles();	
			}
			
			if (isInvalid(InvalidationType.STYLES, InvalidationType.SIZE,
				InvalidationType.DATA, InvalidationType.SCROLL, InvalidationType.SELECTED))
			{
				drawList();
			}
			
			/* Call drawNow on nested components to get around problems with nested render events */
			updateChildren();
			
			/* Not calling super.draw, because we're handling everything here.
			 * Instead we'll just call validate() */
			validate();
		}
		
		
		/**
		 * @private
		 */
		override protected function drawList():void
		{
			/* List is very environmentally friendly, it reuses existing
			 * renderers for old data, and recycles old renderers for new data. */

			/* set horizontal scroll */
			_listHolder.x = _listHolder.y = _contentPadding + 2;
			
			var r:Rectangle = _listHolder.scrollRect;
			r.x = _horizontalScrollPosition;
			
			/* On Probation! correct the scrollRect size so that it doesn't overlap
			 * the component skin (but only do it once at first method call) */
			if (_listHolder.width == 0)
			{
				r.width -= 4;
				r.height -= 4;
			}
			
			/* set pixel scroll */
			r.y = Math.floor(_verticalScrollPosition) % rowHeight;
			_listHolder.scrollRect = r;
			_listHolder.cacheAsBitmap = _useBitmapScrolling;
			
			/* figure out what we have to render */
			var startIndex:uint = Math.floor(_verticalScrollPosition / rowHeight);
			var endIndex:uint = Math.min(length, startIndex + rowCount + 1);
			
			/* these vars get reused in different loops */
			var i:uint;
			var item:Object;
			var renderer:ICellRenderer;
			
			/* create a dictionary for looking up the new "displayed" items */
			var itemHash:Dictionary = _renderedItems = new Dictionary(true);
			for (i = startIndex; i < endIndex; i++)
			{
				itemHash[_dataProvider.getItemAt(i)] = true;
			}
			
			/* find cell renderers that are still active, and make those
			 * that aren't active available */
			var itemToRendererHash:Dictionary = new Dictionary(true);
			while (_activeCellRenderers.length > 0)
			{
				renderer = ICellRenderer(_activeCellRenderers.pop());
				item = renderer.data;
				if (itemHash[item] == null || _invalidItems[item] == true)
				{
					_availableCellRenderers.push(renderer);
				}
				else
				{
					itemToRendererHash[item] = renderer;
					/* prevent problems with duplicate objects */
					_invalidItems[item] = true;
				}
				_list.removeChild(DisplayObject(renderer));
			}
			_invalidItems = new Dictionary(true);
			
			/* draw cell renderers */
			for (i = startIndex; i < endIndex; i++)
			{
				var reused:Boolean = false;
				item = _dataProvider.getItemAt(i);
				if (itemToRendererHash[item] != null)
				{
					/* existing renderer for this item we can reuse */
					reused = true;
					renderer = itemToRendererHash[item];
					delete(itemToRendererHash[item]);
				}
				else if (_availableCellRenderers.length > 0)
				{
					/* recycle an old renderer */
					renderer = ICellRenderer(_availableCellRenderers.pop());
				} 
				else
				{
					/* out of renderers, create a new one */
					renderer = ICellRenderer(getDisplayObjectInstance(getStyleValue("cellRenderer")));
					var rendererSprite:Sprite = Sprite(renderer);
					
					if (rendererSprite != null)
					{
						rendererSprite.addEventListener(MouseEvent.CLICK, onCellRendererClick, false, 0, true);
						rendererSprite.addEventListener(MouseEvent.ROLL_OVER, onCellRendererMouseEvent, false, 0, true);
						rendererSprite.addEventListener(MouseEvent.ROLL_OUT, onCellRendererMouseEvent, false, 0, true);
						rendererSprite.addEventListener(Event.CHANGE, onCellRendererChange, false, 0, true);
						rendererSprite.doubleClickEnabled = true;
						rendererSprite.addEventListener(MouseEvent.DOUBLE_CLICK, onCellRendererDoubleClick, false, 0, true);
						
						if (rendererSprite.hasOwnProperty("setStyle"))
						{
							for (var n:String in _rendererStyles)
							{
								rendererSprite["setStyle"](n, _rendererStyles[n]);
							}
						}
					}
				}
				
				_list.addChild(Sprite(renderer));
				_activeCellRenderers.push(renderer);
				
				renderer.y = rowHeight * (i - startIndex);
				renderer.setSize(_availableWidth + _maxHScrollPosition, rowHeight);
				
				var label:String = itemToLabel(item);
				var icon:Object = null;
				
				if (_iconFunction != null)
				{
					icon = _iconFunction(item);
				}
				else if (_iconField != null)
				{
					icon = item[_iconField];
				}
				
				if (!reused)
				{
					renderer.data = item;
				}
				
				renderer.listData = new ListData(label, icon, this, i, i, 0);
				renderer.selected = (_selectedIndices.indexOf(i) != -1);
				
				/* force an immediate draw (because render event will not
				 * be called on the renderer) */
				if (renderer is UIComponent)
				{
					UIComponent(renderer).drawNow();
				}
			}
		}
		
		
		/**
		 * Moves the selection in a horizontal direction in response to the user selecting
		 * items using the left-arrow or right-arrow keys and modifiers such as the Shift
		 * and Ctrl keys. <p>Not implemented in List because the default list is single
		 * column and therefore doesn't scroll horizontally.</p>
		 * 
		 * @private
		 * @param code The key that was pressed (e.g. Keyboard.LEFT)
		 * @param shiftKey <code>true</code> if the shift key was held down when the
		 *            keyboard key was pressed.
		 * @param ctrlKey <code>true</code> if the ctrl key was held down when the keyboard
		 *            key was pressed.
		 */
		override protected function moveSelectionHorizontally(code:uint,
													shiftKey:Boolean, ctrlKey:Boolean):void
		{
		}
		
		
		/**
		 * Moves the selection in a vertical direction in response to the user selecting
		 * items using the up-arrow or down-arrow Keys and modifiers such as the Shift and
		 * Ctrl keys.
		 * 
		 * @private
		 * @param code The key that was pressed (e.g. Keyboard.DOWN)
		 * @param shiftKey <code>true</code> if the shift key was held down when the
		 *            keyboard key was pressed.
		 * @param ctrlKey <code>true</code> if the ctrl key was held down when the keyboard
		 *            key was pressed.
		 */
		override protected function moveSelectionVertically(code:uint,
													shiftKey:Boolean, ctrlKey:Boolean):void
		{
			var pageSize:int = Math.max(Math.floor(calculateAvailableHeight() / rowHeight), 1);
			var newCaretIndex:int = -1;
			
			switch (code)
			{
				case Keyboard.UP:
					if (_caretIndex > 0) newCaretIndex = _caretIndex - 1;
					break;
				case Keyboard.DOWN:
					if (_caretIndex < length - 1) newCaretIndex = _caretIndex + 1;
					break;
				case Keyboard.PAGE_UP:
					if (_caretIndex > 0) newCaretIndex = Math.max(_caretIndex - pageSize, 0);
					break;
				case Keyboard.PAGE_DOWN:
					if (_caretIndex < length - 1)
						newCaretIndex = Math.min(_caretIndex + pageSize, length - 1);
					break;
				case Keyboard.HOME:
					if (_caretIndex > 0) newCaretIndex = 0;
					break;
				case Keyboard.END:
					if (_caretIndex < length - 1) newCaretIndex = length - 1;
					break;
			}
			
			if (newCaretIndex >= 0)
			{
				doKeySelection(newCaretIndex, shiftKey, ctrlKey);
				scrollToSelected();
			}
		}
		
		
		/**
		 * @private
		 */		
		protected function doKeySelection(newCaretIndex:int, shiftKey:Boolean,
											ctrlKey:Boolean):void
		{
			var selChanged:Boolean = false;
			
			if (shiftKey)
			{
				var i:int;
				var selIndices:Array = [];
				var startIndex:int = _lastCaretIndex;
				var endIndex:int = newCaretIndex;
				
				if (startIndex == -1)
				{
					startIndex = _caretIndex != -1 ? _caretIndex : newCaretIndex;
				}
				
				if (startIndex > endIndex)
				{
					endIndex = startIndex;
					startIndex = newCaretIndex;
				}
				
				for (i = startIndex; i <= endIndex; i++)
				{
					selIndices.push(i);
				}
				
				selectedIndices = selIndices;
				_caretIndex = newCaretIndex;
				selChanged = true;
			}
			else
			{
				selectedIndex = newCaretIndex;
				_caretIndex = _lastCaretIndex = newCaretIndex;
				selChanged = true;
			}
			
			if (selChanged)
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			invalidate(InvalidationType.DATA);
		}
	}
}
