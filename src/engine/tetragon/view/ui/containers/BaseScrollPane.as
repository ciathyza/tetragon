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
package tetragon.view.ui.containers
{
	import tetragon.view.ui.controls.ScrollBar;
	import tetragon.view.ui.controls.ScrollBarDirection;
	import tetragon.view.ui.controls.ScrollPolicy;
	import tetragon.view.ui.core.InvalidationType;
	import tetragon.view.ui.core.UIComponent;
	import tetragon.view.ui.event.UIScrollEvent;

	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * Dispatched when the user scrolls content by using the scroll bars on the
	 * component or the wheel on a mouse device.
	 *
	 * @eventType fl.events.ScrollEvent.SCROLL
	 */
	//[Event(name="scroll", type="fl.events.ScrollEvent")]

	[Style(name="downArrowDisabledSkin", type="Class")]
	[Style(name="downArrowDownSkin", type="Class")]
	[Style(name="downArrowOverSkin", type="Class")]
	[Style(name="downArrowUpSkin", type="Class")]
	[Style(name="thumbDisabledSkin", type="Class")]
	[Style(name="thumbDownSkin", type="Class")]
	[Style(name="thumbOverSkin", type="Class")]
	[Style(name="thumbUpSkin", type="Class")]
	[Style(name="trackDisabledSkin", type="Class")]
	[Style(name="trackDownSkin", type="Class")]
	[Style(name="trackOverSkin", type="Class")]
	[Style(name="trackUpSkin", type="Class")]
	[Style(name="upArrowDisabledSkin", type="Class")]
	[Style(name="upArrowDownSkin", type="Class")]
	[Style(name="upArrowOverSkin", type="Class")]
	[Style(name="upArrowUpSkin", type="Class")]
	[Style(name="thumbIcon", type="Class")]
	[Style(name="repeatDelay", type="Number", format="Time")]
	[Style(name="repeatInterval", type="Number", format="Time")]
	[Style(name="skin", type="Class")]
	[Style(name="contentPadding", type="Number", format="Length")]
	[Style(name="disabledAlpha", type="Number", format="Length")]
	
	/**
	 * The BaseScrollPane class handles basic scroll pane functionality including events,
	 * styling, drawing the mask and background, the layout of scroll bars, and the handling
	 * of scroll positions.
	 * 
	 * <p>By default, the BaseScrollPane class is extended by the ScrollPane and SelectableList
	 * classes, for all list-based components. This means that any component that uses
	 * horizontal or vertical scrolling does not need to implement any scrolling, masking or
	 * layout logic, except for behavior that is specific to the component.</p>
	 */
	public class BaseScrollPane extends UIComponent
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _vScrollBar:ScrollBar;
		protected var _hScrollBar:ScrollBar;
		protected var _contentScrollRect:Rectangle;
		protected var _disabledOverlay:Shape;
		protected var _bg:DisplayObject;
		
		protected var _contentWidth:Number = 0;
		protected var _contentHeight:Number = 0;
		protected var _contentPadding:Number = 0;
		protected var _availableWidth:Number;
		protected var _availableHeight:Number;
		protected var _vOffset:Number = 0;
		protected var _maxHScrollPosition:Number = 0;		
		protected var _hPageScrollSize:Number = 0;	
		protected var _vPageScrollSize:Number = 0;
		protected var _defaultLineScrollSize:Number = 4;
		
		protected var _hScrollPolicy:String;
		protected var _vScrollPolicy:String;
		
		protected var _hasVScrollBar:Boolean;
		protected var _hasHScrollBar:Boolean;
		protected var _useBitmapScrolling:Boolean = false;
		
		/* if false, uses contentWidth to determine hScroll, otherwise uses fixed
		 * _maxHorizontalScroll value */
		protected var _useFixedHScrolling:Boolean = false;
		
		protected static const SCROLL_BAR_STYLES:Object =
		{
			upArrowDisabledSkin:	"upArrowDisabledSkin",
			upArrowDownSkin:		"upArrowDownSkin",
			upArrowOverSkin:		"upArrowOverSkin",
			upArrowUpSkin:			"upArrowUpSkin",
			downArrowDisabledSkin:	"downArrowDisabledSkin",
			downArrowDownSkin:		"downArrowDownSkin",
			downArrowOverSkin:		"downArrowOverSkin",
			downArrowUpSkin:		"downArrowUpSkin",
			thumbDisabledSkin:		"thumbDisabledSkin",
			thumbDownSkin:			"thumbDownSkin",
			thumbOverSkin:			"thumbOverSkin",
			thumbUpSkin:			"thumbUpSkin",
			thumbIcon:				"thumbIcon",
			trackDisabledSkin:		"trackDisabledSkin",
			trackDownSkin:			"trackDownSkin",
			trackOverSkin:			"trackOverSkin",
			trackUpSkin:			"trackUpSkin",
			repeatDelay:			"repeatDelay",
			repeatInterval:			"repeatInterval"
		};
		
		private static var defaultStyles:Object =
		{
			repeatDelay:		500,
			repeatInterval:		35,
			skin:				"ScrollPaneUpSkin",
			contentPadding:		0,
			disabledAlpha:		0.5
		};
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new BaseScrollPane component instance.
		 */
		public function BaseScrollPane()
		{
			super();
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		public static function get styleDefinition():Object
		{ 
			return mergeStyles(defaultStyles, ScrollBar.styleDefinition);
		}
		
		
		/**
		 * @private
		 */
		[Inspectable(defaultValue=true, verbose=1)]
		override public function set enabled(v:Boolean):void
		{
			if (enabled == v) return;
			_vScrollBar.enabled = v;
			_hScrollBar.enabled = v;
			super.enabled = v;
		}
		
		
		/**
		 * Gets or sets a value that indicates the state of the horizontal scroll
		 * bar. A value of <code>ScrollPolicy.ON</code> indicates that the horizontal 
		 * scroll bar is always on; a value of <code>ScrollPolicy.OFF</code> indicates
		 * that the horizontal scroll bar is always off; and a value of <code>
		 * ScrollPolicy.AUTO</code> indicates that its state automatically changes. This
		 * property is used with other scrolling properties to set the <code>
		 * setScrollProperties()</code> method of the scroll bar.
		 *
		 * @default ScrollPolicy.AUTO
		 * @see #verticalScrollPolicy
		 * @see fl.controls.ScrollPolicy ScrollPolicy
		 */
		[Inspectable(defaultValue="auto",enumeration="on,off,auto")]
		public function get horizontalScrollPolicy():String
		{
			return _hScrollPolicy;
		}
		public function set horizontalScrollPolicy(v:String):void
		{
			_hScrollPolicy = v;
			invalidate(InvalidationType.SIZE);
		}
		
		
		/**
		 * Gets or sets a value that indicates the state of the vertical scroll
		 * bar. A value of <code>ScrollPolicy.ON</code> indicates that the vertical
		 * scroll bar is always on; a value of <code>ScrollPolicy.OFF</code> indicates
		 * that the vertical scroll bar is always off; and a value of <code>ScrollPolicy.AUTO
		 * </code> indicates that its state automatically changes. This property is used with 
		 * other scrolling properties to set the <code>setScrollProperties()</code> method
		 * of the scroll bar.
		 *
		 * @default ScrollPolicy.AUTO
		 * @see #horizontalScrollPolicy
		 * @see fl.controls.ScrollPolicy ScrollPolicy
		 */
		[Inspectable(defaultValue="auto",enumeration="on,off,auto")]
		public function get verticalScrollPolicy():String
		{
			return _vScrollPolicy;
		}
		public function set verticalScrollPolicy(v:String):void
		{
			_vScrollPolicy = v;
			invalidate(InvalidationType.SIZE);
		}
		
		
		/**
		 * Gets or sets a value that describes the amount of content to be scrolled,
		 * horizontally, when a scroll arrow is clicked. This value is measured in pixels.
		 *
		 * @default 4
		 * @see #horizontalPageScrollSize
		 * @see #verticalLineScrollSize
		 */
		[Inspectable(defaultValue=4)]
		public function get horizontalLineScrollSize():Number
		{
			return _hScrollBar.lineScrollSize;
		}
		public function set horizontalLineScrollSize(v:Number):void
		{
			_hScrollBar.lineScrollSize = v;
		}
		
		
		/**
		 * Gets or sets a value that describes how many pixels to scroll vertically
		 * when a scroll arrow is clicked. 
		 *
		 * @default 4
		 * @see #horizontalLineScrollSize
		 * @see #verticalPageScrollSize
		 */
		[Inspectable(defaultValue=4)]
		public function get verticalLineScrollSize():Number
		{
			return _vScrollBar.lineScrollSize;
		}
		public function set verticalLineScrollSize(v:Number):void
		{
			_vScrollBar.lineScrollSize = v;
		}
		
		
		/**
		 * Gets or sets a value that describes the horizontal position of the 
		 * horizontal scroll bar in the scroll pane, in pixels.
		 *
		 * @default 0
		 * @see #maxHorizontalScrollPosition
		 * @see #verticalScrollPosition
		 */
		public function get horizontalScrollPosition():Number
		{
			return _hScrollBar.scrollPosition;
		}
		public function set horizontalScrollPosition(v:Number):void
		{
			/* We must force a redraw to ensure that the size is up to date. */
			drawNow();
			_hScrollBar.scrollPosition = v;
			setHorizontalScrollPosition(_hScrollBar.scrollPosition, false);
		}
		
		
		/**
		 * Gets or sets a value that describes the vertical position of the 
		 * vertical scroll bar in the scroll pane, in pixels.
		 *
		 * @default 0
		 * @see #horizontalScrollPosition
		 * @see #maxVerticalScrollPosition
		 */
		public function get verticalScrollPosition():Number
		{
			return _vScrollBar.scrollPosition;
		}
		public function set verticalScrollPosition(v:Number):void
		{
			/* We must force a redraw to ensure that the size is up to date. */
			drawNow();
			_vScrollBar.scrollPosition = v;
			setVerticalScrollPosition(_vScrollBar.scrollPosition, false);
		}
		
		
		/**
		 * Gets the maximum horizontal scroll position for the current content, in pixels.
		 *
		 * @see #horizontalScrollPosition
		 * @see #maxVerticalScrollPosition
		 */
		public function get maxHorizontalScrollPosition():Number
		{
			drawNow();
			return Math.max(0, _contentWidth - _availableWidth);
		}
		
		
		/**
		 * Gets the maximum vertical scroll position for the current content, in pixels.
		 *
		 * @see #maxHorizontalScrollPosition
		 * @see #verticalScrollPosition
		 */
		public function get maxVerticalScrollPosition():Number
		{
			drawNow();
			return Math.max(0, _contentHeight - _availableHeight);
		}
		
		
		/**
		 * When set to <code>true</code>, the <code>cacheAsBitmap</code> property for the
		 * scrolling content is set to <code>true</code>; when set to <code>false</code>
		 * this value is turned off. <p><strong>Note:</strong> Setting this property to
		 * <code>true</code> increases scrolling performance.</p>
		 *
		 * @default false
		 */
		public function get useBitmapScrolling():Boolean
		{
			return _useBitmapScrolling;
		}
		public function set useBitmapScrolling(v:Boolean):void
		{
			_useBitmapScrolling = v;
			invalidate(InvalidationType.STATE);
		}
		
		
		/**
		 * Gets or sets the count of pixels by which to move the scroll thumb 
		 * on the horizontal scroll bar when the scroll bar track is pressed. When 
		 * this value is 0, this property retrieves the available width of the component.
		 *
		 * @default 0
		 * @see #horizontalLineScrollSize
		 * @see #verticalPageScrollSize
		 */
		[Inspectable(defaultValue=0)]
		public function get horizontalPageScrollSize():Number
		{
			if (isNaN(_availableWidth)) drawNow();
			return (_hPageScrollSize == 0 && !isNaN(_availableWidth))
				? _availableWidth : _hPageScrollSize;
		}
		public function set horizontalPageScrollSize(v:Number):void
		{
			_hPageScrollSize = v;
			invalidate(InvalidationType.SIZE);
		}
		
		
		/**
		 * Gets or sets the count of pixels by which to move the scroll thumb 
		 * on the vertical scroll bar when the scroll bar track is pressed. When 
		 * this value is 0, this property retrieves the available height of the component.
		 *
		 * @default 0
		 * @see #horizontalPageScrollSize
		 * @see #verticalLineScrollSize
		 */
		[Inspectable(defaultValue=0)]
		public function get verticalPageScrollSize():Number
		{
			if (isNaN(_availableHeight)) drawNow(); 
			return (_vPageScrollSize == 0 && !isNaN(_availableHeight))
				? _availableHeight : _vPageScrollSize;
		}
		public function set verticalPageScrollSize(v:Number):void
		{
			_vPageScrollSize = v;
			invalidate(InvalidationType.SIZE);
		}
		
		
		/**
		 * Gets a reference to the horizontal scroll bar.
		 * @see #verticalScrollBar
		 */
		public function get horizontalScrollBar():ScrollBar
		{
			return _hScrollBar;
		}
		
		
		/**
		 * Gets a reference to the vertical scroll bar.
		 * @see #horizontalScrollBar
		 */
		public function get verticalScrollBar():ScrollBar
		{
			return _vScrollBar;
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Event Handlers                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		protected function onScroll(e:UIScrollEvent):void
		{
			if (e.target == _vScrollBar)
				setVerticalScrollPosition(e.position);
			else
				setHorizontalScrollPosition(e.position);
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseWheel(e:MouseEvent):void
		{
			if (!enabled || !_vScrollBar.visible || _contentHeight <= _availableHeight)
			{
				return;
			}
			
			_vScrollBar.scrollPosition -= e.delta * verticalLineScrollSize;
			setVerticalScrollPosition(_vScrollBar.scrollPosition);
			dispatchEvent(new UIScrollEvent(ScrollBarDirection.VERTICAL, e.delta,
				horizontalScrollPosition));
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
			
			/* contentScrollRect is not actually used by BaseScrollPane, only by subclasses. */
			_contentScrollRect = new Rectangle(0, 0, 1, 1);
			
			/* set up vertical scroll bar */
			_vScrollBar = new ScrollBar();
			_vScrollBar.addEventListener(UIScrollEvent.SCROLL, onScroll, false, 0, true);
			_vScrollBar.visible = false;
			_vScrollBar.lineScrollSize = _defaultLineScrollSize;
			addChild(_vScrollBar);
			copyStylesToChild(_vScrollBar, SCROLL_BAR_STYLES);
			
			/* set up horizontal scroll bar */
			_hScrollBar = new ScrollBar();
			_hScrollBar.direction = ScrollBarDirection.HORIZONTAL;
			_hScrollBar.addEventListener(UIScrollEvent.SCROLL, onScroll, false, 0, true);
			_hScrollBar.visible = false;
			_hScrollBar.lineScrollSize = _defaultLineScrollSize;
			addChild(_hScrollBar);
			copyStylesToChild(_hScrollBar, SCROLL_BAR_STYLES);
			
			/* Create the disabled overlay */
			_disabledOverlay = new Shape();
			var g:Graphics = _disabledOverlay.graphics;
			g.beginFill(0xFFFFFF);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
		}
		
		
		/**
		 * @private
		 */
		override protected function draw():void
		{
			if (isInvalid(InvalidationType.STYLES))
			{
				setStyles();
				drawBackground();
				
				/* drawLayout is expensive, so only do it if padding has changed */
				if (_contentPadding != getStyleValue("contentPadding"))
				{
					invalidate(InvalidationType.SIZE, false);
				}
			}
			
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STATE))
			{
				drawLayout();
			}
			
			/* Call drawNow() on nested components to get around problems
			 * with nested render events */
			updateChildren();
			
			super.draw();
		}
		
		
		/**
		 * @private
		 */
		protected function setContentSize(width:Number,height:Number):void
		{
			if ((_contentWidth == width || _useFixedHScrolling) && _contentHeight == height)
			{
				return;
			}
			
			_contentWidth = width;
			_contentHeight = height;
			invalidate(InvalidationType.SIZE);
		}
		
		
		/* ----------------------------------------------------------------------------------- */
		/* These are meant to be overriden by subclasses ------------------------------------- */
		/* ----------------------------------------------------------------------------------- */
		
		/**
		 * @private
		 */
		protected function setHorizontalScrollPosition(scroll:Number,
			fireEvent:Boolean = false):void
		{
		}
		
		
		/**
		 * @private
		 */
		protected function setVerticalScrollPosition(scroll:Number,
			fireEvent:Boolean = false):void 
		{
		}
		
		
		/**
		 * @private
		 */
		protected function setStyles():void
		{
			copyStylesToChild(_vScrollBar, SCROLL_BAR_STYLES);
			copyStylesToChild(_hScrollBar, SCROLL_BAR_STYLES);
		}
		
		
		/**
		 * @private
		 */
		protected function drawBackground():void
		{
			var bg:DisplayObject = _bg;
			_bg = getDisplayObjectInstance(getStyleValue("skin"));
			_bg.width = width;
			_bg.height = height;
			addChildAt(_bg, 0);
			
			if (bg != null && bg != _bg) removeChild(bg); 
		}
		
		
		/**
		 * @private
		 */
		protected function drawLayout():void
		{
			calculateAvailableSize();
			calculateContentWidth();
			
			_bg.width = width;
			_bg.height = height;

			if (_hasVScrollBar)
			{
				_vScrollBar.visible = true;
				_vScrollBar.x = width - ScrollBar.WIDTH - _contentPadding;
				_vScrollBar.y = _contentPadding;
				_vScrollBar.height = _availableHeight;
			}
			else
			{
				_vScrollBar.visible = false;
			}
			
			_vScrollBar.setScrollProperties(_availableHeight, 0,
				(_contentHeight - _availableHeight), verticalPageScrollSize);
			setVerticalScrollPosition(_vScrollBar.scrollPosition, false);
			
			if (_hasHScrollBar)
			{
				_hScrollBar.visible = true;
				_hScrollBar.x = _contentPadding;
				_hScrollBar.y = height - ScrollBar.WIDTH - _contentPadding;
				_hScrollBar.width = _availableWidth;
			}
			else
			{
				_hScrollBar.visible = false;
			}
			
			_hScrollBar.setScrollProperties(_availableWidth, 0,
				(_useFixedHScrolling)
				? _maxHScrollPosition
				: (_contentWidth - _availableWidth), horizontalPageScrollSize);
			
			setHorizontalScrollPosition(_hScrollBar.scrollPosition, false);
			drawDisabledOverlay();
		}
		
		
		/**
		 * @private
		 */
		protected function drawDisabledOverlay():void
		{
			if (enabled)
			{
				if (contains(_disabledOverlay)) removeChild(_disabledOverlay);
			}
			else
			{
				_disabledOverlay.x = _disabledOverlay.y = _contentPadding;
				_disabledOverlay.width = _availableWidth;
				_disabledOverlay.height = _availableHeight;
				_disabledOverlay.alpha = Number(getStyleValue("disabledAlpha"));
				addChild(_disabledOverlay);
			}
		}
		
		
		/**
		 * @private
		 */
		protected function calculateAvailableSize():void
		{
			var scrollBarWidth:Number = ScrollBar.WIDTH;
			var padding:Number = _contentPadding = Number(getStyleValue("contentPadding"));
			
			/* figure out which scrollbars we need */
			var availHeight:Number = height - 2 * padding - _vOffset;
			_hasVScrollBar = (_vScrollPolicy == ScrollPolicy.ON)
				|| (_vScrollPolicy == ScrollPolicy.AUTO && _contentHeight > availHeight);
			
			var availWidth:Number = width - (_hasVScrollBar ? scrollBarWidth : 0) - 2 * padding;
			var maxHScroll:Number = (_useFixedHScrolling)
				? _maxHScrollPosition
				: _contentWidth - availWidth;
			
			_hasHScrollBar = (_hScrollPolicy == ScrollPolicy.ON)
				|| (_hScrollPolicy == ScrollPolicy.AUTO && maxHScroll > 0);
			
			if (_hasHScrollBar)
			{
				availHeight -= scrollBarWidth;
			}
			
			/* catch the edge case of the horizontal scroll bar necessitating a vertical one */
			if (_hasHScrollBar && !_hasVScrollBar && _vScrollPolicy == ScrollPolicy.AUTO
				&& _contentHeight > availHeight)
			{
				_hasVScrollBar = true;
				availWidth -= scrollBarWidth;
			}
			
			_availableHeight = availHeight + _vOffset;
			_availableWidth = availWidth;
		}
		
		
		/**
		 * @private
		 */
		protected function calculateContentWidth():void
		{
			/* Meant to be overriden by subclasses */
		}
		
		
		/**
		 * @private
		 */
		protected function updateChildren():void
		{
			_vScrollBar.enabled = _hScrollBar.enabled = enabled;
			_vScrollBar.drawNow();
			_hScrollBar.drawNow();
		}
	}
}
