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
	import tetragon.view.ui.constants.InvalidationType;
	import tetragon.view.ui.constants.ScrollBarDirection;
	import tetragon.view.ui.core.UIComponent;
	import tetragon.view.ui.event.UIScrollEvent;

	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;

	
	/**
	 * The TextScrollBar class includes all of the scroll bar functionality, but adds
	 * a <code>scrollTarget()</code> method so it can be attached to a TextField
	 * component instance.
	 *
	 * <p><strong>Note:</strong> When you use ActionScript to update properties of 
	 * the TextField component that affect the text layout, you must call the <code>
	 * update()</code> method on the TextScrollBar component instance to refresh its scroll 
	 * properties. Examples of text layout properties that belong to the TextField
	 * component include <code>width</code>, <code>height</code>, and <code>wordWrap
	 * </code>.</p>
	 */
	public class TextScrollBar extends ScrollBarLite
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _scrollTarget:TextField;
		protected var _isEditing:Boolean = false;
		protected var _isScrolling:Boolean = false;
		
		private static var _defaultStyles:Object = {};
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new TextScrollBar instance.
		 */
		public function TextScrollBar()
		{
			super();
		}
		
		
		/**
		 * Forces the scroll bar to update its scroll properties immediately. This is
		 * necessary after text in the specified <code>scrollTarget</code> text field
		 * is added using ActionScript, and the scroll bar needs to be refreshed.
		 *
		 * @see #scrollTarget
		 */
		public function update():void
		{
			_isEditing = true;
			updateScrollTargetProperties();
			_isEditing = false;
		}
		
		
		/**
		 * @copy com.hexagonstar.ui.controls.ScrollBar#setScrollProperties()
		 *
		 * @see ScrollBar#pageSize ScrollBar.pageSize
		 * @see ScrollBar#minScrollPosition ScrollBar.minScrollPosition
		 * @see ScrollBar#maxScrollPosition ScrollBar.maxScrollPosition
		 * @see ScrollBar#pageScrollSize ScrollBar.pageScrollSize
		 */
		override public function setScrollProperties(pageSize:Number,
														minScrollPos:Number,
														maxScrollPos:Number,
														pageScrollSize:Number = 0):void
		{
			var maxSP:Number = maxScrollPos;
			var minSP:Number = (minScrollPos < 0) ? 0 : minScrollPos;
			
			if (_scrollTarget)
			{
				if (direction == ScrollBarDirection.HORIZONTAL)
				{
					maxSP = (maxScrollPos > _scrollTarget.maxScrollH)
						? _scrollTarget.maxScrollH
						: maxSP;
				} 
				else 
				{
					maxSP = (maxScrollPos > _scrollTarget.maxScrollV)
						? _scrollTarget.maxScrollV
						: maxSP;
				}
			}
			super.setScrollProperties(pageSize, minSP, maxSP, pageScrollSize);
		}
		
		
		/**
		 * @private
		 */
		override public function setScrollPosition(scrollPos:Number,
														fireEvent:Boolean = true):void
		{
			super.setScrollPosition(scrollPos, fireEvent);
			if (!_scrollTarget)
			{
				_isScrolling = false;
				return;
			}
			updateTargetScroll();
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @copy com.hexagonstar.ui.core.UIComponent#getStyleDefinition()
		 *
		 * @see com.hexagonstar.ui.core.UIComponent#getStyle() UIComponent#getStyle()
		 * @see com.hexagonstar.ui.core.UIComponent#setStyle() UIComponent#setStyle()
		 * @see com.hexagonstar.ui.managers.StyleManager StyleManager
		 */
		public static function get styleDefinition():Object
		{ 
			return UIComponent.mergeStyles(_defaultStyles, ScrollBarLite.styleDefinition);
		}
		
		
		/**
		 * @private
		 */
		override public function set minScrollPosition(v:Number):void
		{
			super.minScrollPosition = (v < 0) ? 0 : v;
		}
		
		
		/**
		 * @private
		 */
		override public function set maxScrollPosition(v:Number):void
		{
			if (_scrollTarget)
			{
				if (direction == ScrollBarDirection.HORIZONTAL)
					v = (v > _scrollTarget.maxScrollH) ? _scrollTarget.maxScrollH : v;
				else
					v = (v > _scrollTarget.maxScrollV) ? _scrollTarget.maxScrollV : v;
			}
			super.maxScrollPosition = v;
		}
		
		
		/**
		 * Registers a TextField component instance with the ScrollBar component instance.
		 * @see #update()
		 */
		public function get scrollTarget():TextField
		{
			return _scrollTarget;
		}
		
		public function set scrollTarget(v:TextField):void
		{
			if (_scrollTarget)
			{
				_scrollTarget.removeEventListener(Event.CHANGE, onTargetChange, false);
				_scrollTarget.removeEventListener(TextEvent.TEXT_INPUT, onTargetChange,
					false);
				_scrollTarget.removeEventListener(Event.SCROLL, onTargetScroll, false);
				removeEventListener(UIScrollEvent.SCROLL, updateTargetScroll, false);
			}
			_scrollTarget = v;
			if (_scrollTarget)
			{
				_scrollTarget.addEventListener(Event.CHANGE, onTargetChange, false, 0, true);
				_scrollTarget.addEventListener(TextEvent.TEXT_INPUT, onTargetChange,
					false, 0, true);
				_scrollTarget.addEventListener(Event.SCROLL, onTargetScroll, false, 0, true);
				addEventListener(UIScrollEvent.SCROLL, updateTargetScroll, false, 0, true);
			}
			invalidate(InvalidationType.DATA);
		}
		
		
		/**
		 * @private
		 * @internal For specifying in inspectable, and setting dropTarget
		 */
		public function get scrollTargetName():String
		{
			return _scrollTarget.name;
		}
		
		public function set scrollTargetName(v:String):void
		{
			try 
			{
				scrollTarget = parent.getChildByName(v) as TextField;
			}
			catch (e:Error) 
			{
				throw new Error("ScrollTarget not found, or is not a TextField");
			}
		}
		
		
		/**
		 * @copy com.hexagonstar.ui.controls.ScrollBar#direction
		 * @see ScrollBarDirection
		 */
		override public function get direction():String
		{
			return super.direction;
		}
		
		override public function set direction(v:String):void
		{
			super.direction = v;
			updateScrollTargetProperties();
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Event Handlers                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		protected function onTargetChange(e:Event):void
		{
			_isEditing = true;
			setScrollPosition((direction == ScrollBarDirection.HORIZONTAL)
				? _scrollTarget.scrollH
				: _scrollTarget.scrollV, true);
			updateScrollTargetProperties();
			_isEditing = false;
		}
		
		
		/**
		 * @private
		 */
		protected function onTargetScroll(e:Event):void
		{
			if (_isDragging) return; 
			if (!enabled) return;
			_isEditing = true;
			/* This needs to be done first! */
			updateScrollTargetProperties();
			scrollPosition = (direction == ScrollBarDirection.HORIZONTAL)
				? _scrollTarget.scrollH
				: _scrollTarget.scrollV;
			_isEditing = false;
		}
		
		
		/**
		 * event default is null, so when user calls setScrollPosition, the text
		 * is updated, and we don't pass an event
		 * @private
		 */
		protected function updateTargetScroll(e:UIScrollEvent = null):void
		{
			/* Update came from the user input. Ignore. */
			if (_isEditing) return;
			
			if (direction == ScrollBarDirection.HORIZONTAL)
				_scrollTarget.scrollH = scrollPosition;
			else
				_scrollTarget.scrollV = scrollPosition;
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Private Methods                                                                    //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		override protected function draw():void
		{
			if (isInvalid(InvalidationType.DATA)) updateScrollTargetProperties();
			super.draw();
		}
		
		
		/**
		 * @private
		 */
		protected function updateScrollTargetProperties():void
		{
			if (!_scrollTarget)
			{
				setScrollProperties(pageSize, minScrollPosition, maxScrollPosition,
					pageScrollSize);
				scrollPosition = 0;
			}
			else 
			{
				var h:Boolean = (direction == ScrollBarDirection.HORIZONTAL);
				var psize:Number = h ? _scrollTarget.width : 10;
				setScrollProperties(psize, (h ? 0 : 1),
					h ? _scrollTarget.maxScrollH : _scrollTarget.maxScrollV, pageScrollSize);
				scrollPosition = h ? _scrollTarget.scrollH : _scrollTarget.scrollV;
			}
		}
	}
}
