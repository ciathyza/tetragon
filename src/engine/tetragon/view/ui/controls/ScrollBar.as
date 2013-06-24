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
	import tetragon.view.ui.core.InvalidationType;
	import tetragon.view.ui.core.UIComponent;
	import tetragon.view.ui.event.UIComponentEvent;
	import tetragon.view.ui.event.UIScrollEvent;

	import flash.events.MouseEvent;

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
	
	
	/**
	 * The ScrollBar component provides the end user with a way to control the portion
	 * of data that is displayed when there is too much data to fit in the display area.
	 * The scroll bar consists of four parts: two arrow buttons, a track, and a thumb.
	 * The position of the thumb and display of the buttons depends on the current state
	 * of the scroll bar. The scroll bar uses four parameters to calculate its display
	 * state: a minimum range value; a maximum range value; a current position that must
	 * be within the range values; and a viewport size that must be equal to or less than
	 * the range and represents the number of items in the range that can be displayed at
	 * the same time.
	 */
	public class ScrollBar extends UIComponent
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Constants                                                                          //
		////////////////////////////////////////////////////////////////////////////////////////
		
		public static const WIDTH:Number = 12;
		
		protected static const DOWN_ARROW_STYLES:Object =
		{
			disabledSkin:	"downArrowDisabledSkin",
			downSkin:		"downArrowDownSkin",
			overSkin:		"downArrowOverSkin",
			upSkin:			"downArrowUpSkin",
			repeatDelay:	"repeatDelay",
			repeatInterval:	"repeatInterval"
		};
		
		protected static const THUMB_STYLES:Object =
		{
			disabledSkin:	"thumbDisabledSkin",
			downSkin:		"thumbDownSkin",
			overSkin:		"thumbOverSkin",
			upSkin:			"thumbUpSkin",
			icon:			"thumbIcon",
			textPadding:	0
		};
		
		protected static const TRACK_STYLES:Object =
		{
			disabledSkin:	"trackDisabledSkin",
			downSkin:		"trackDownSkin",
			overSkin:		"trackOverSkin",
			upSkin:			"trackUpSkin",
			repeatDelay:	"repeatDelay",
			repeatInterval:	"repeatInterval"
		};
		
		protected static const UP_ARROW_STYLES:Object =
		{
			disabledSkin:	"upArrowDisabledSkin",
			downSkin:		"upArrowDownSkin",
			overSkin:		"upArrowOverSkin",
			upSkin:			"upArrowUpSkin",
			repeatDelay:	"repeatDelay",
			repeatInterval:	"repeatInterval"
		};
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _upArrow:BaseButton;
		protected var _downArrow:BaseButton;
		protected var _thumb:LabelButton;
		protected var _track:BaseButton;
		protected var _isDragging:Boolean = false;
		
		private var _pageSize:Number = 10;
		private var _pageScrollSize:Number = 0;
		private var _lineScrollSize:Number = 1;
		private var _minScrollPos:Number = 0;
		private var _maxScrollPos:Number = 0;
		private var _scrollPos:Number = 0;
		private var _thumbScrollOffset:Number;
		private var _direction:String = ScrollBarDirection.VERTICAL;
		
		private static var _defaultStyles:Object =
		{
			downArrowDisabledSkin:	"ScrollArrowDownDisabled",
			downArrowDownSkin:		"ScrollArrowDownDown",
			downArrowOverSkin:		"ScrollArrowDownOver",
			downArrowUpSkin:		"ScrollArrowDownUp",
			thumbDisabledSkin:		"ScrollThumbUp",
			thumbDownSkin:			"ScrollThumbDown",
			thumbOverSkin:			"ScrollThumbOver",
			thumbUpSkin:			"ScrollThumbUp",
			trackDisabledSkin:		"ScrollTrack",
			trackDownSkin:			"ScrollTrack",
			trackOverSkin:			"ScrollTrack",
			trackUpSkin:			"ScrollTrack",
			upArrowDisabledSkin:	"ScrollArrowUpDisabled",
			upArrowDownSkin:		"ScrollArrowUpDown",
			upArrowOverSkin:		"ScrollArrowUpOver",
			upArrowUpSkin:			"ScrollArrowUpUp",
			thumbIcon:				"ScrollBarThumbIcon",
			repeatDelay:			500,
			repeatInterval:			35
		};
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new ScrollBar instance.
		 */
		public function ScrollBar()
		{
			super();
			setStyles();
			focusEnabled = false;
		}
		
		
		/**
		 * @copy com.hexagonstar.ui.core.UIComponent#setSize()
		 *
		 * @see #height
		 * @see #width
		 */
		override public function setSize(width:Number, height:Number):void
		{
			if (_direction == ScrollBarDirection.HORIZONTAL)
				super.setSize(height, width);
			else
				super.setSize(width, height);
		}
		
		
		/**
		 * Sets the range and viewport size of the ScrollBar component. The ScrollBar 
		 * component updates the state of the arrow buttons and size of the scroll thumb
		 * accordingly. All of the scroll properties are relative to the scale of the
		 * <code>minScrollPosition</code> and the <code>maxScrollPosition</code>. Each
		 * number between the maximum and minumum values represents one scroll position.
		 * 
		 * @param pageSize Size of one page. Determines the size of the thumb, and the
		 *         increment by which the scroll bar moves when the arrows are clicked.
		 * @param minScrollPosition Bottom of the scrolling range.
		 * @param maxScrollPosition Top of the scrolling range.
		 * @param pageScrollSize Increment to move when a track is pressed, in pixels.
		 * @see #maxScrollPosition
		 * @see #minScrollPosition
		 * @see #pageScrollSize
		 * @see #pageSize
		 */
		public function setScrollProperties(pageSize:Number,
												 minScrollPosition:Number,
												 maxScrollPosition:Number,
												 pageScrollSize:Number = 0):void
		{
			this.pageSize = pageSize;
			_minScrollPos = minScrollPosition;
			_maxScrollPos = maxScrollPosition;
			if (pageScrollSize >= 0) _pageScrollSize = pageScrollSize;
			enabled = (_maxScrollPos > _minScrollPos);
			/* ensure our scroll position is still in range */
			setScrollPosition(_scrollPos, false);
			updateThumb();
		}
		
		
		/**
		 * @private
		 */
		public function setScrollPosition(newScrollPos:Number,
											  fireEvent:Boolean = true):void
		{
			var oldPos:Number = scrollPosition;
			_scrollPos = Math.max(_minScrollPos, Math.min(_maxScrollPos, newScrollPos));
			if (oldPos == _scrollPos) return;
			if (fireEvent) dispatchEvent(new UIScrollEvent(_direction,
				scrollPosition - oldPos, scrollPosition));
			updateThumb();
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
			return _defaultStyles;
		}
		
		
		/**
		 * @copy com.hexagonstar.ui.core..UIComponent#width
		 *
		 * @see #height
		 * @see #setSize()
		 */
		override public function get width():Number
		{
			return (_direction == ScrollBarDirection.HORIZONTAL) ? super.height : super.width;
		}
		
		
		/**
		 * @copy com.hexagonstar.ui.core..UIComponent#height
		 *
		 * @see #setSize()
		 * @see #width
		 */
		override public function get height():Number
		{
			return (_direction == ScrollBarDirection.HORIZONTAL) ? super.width : super.height;
		}
		
		
		/**
		 * Gets or sets a Boolean value that indicates whether the scroll bar is enabled.
		 * A value of <code>true</code> indicates that the scroll bar is enabled; a value of
		 * <code>false</code> indicates that it is not.
		 */
		override public function get enabled():Boolean
		{
			return super.enabled;
		}
		
		override public function set enabled(v:Boolean):void
		{
			super.enabled = v;
			_downArrow.enabled = _track.enabled = _thumb.enabled =
			_upArrow.enabled = (enabled && _maxScrollPos > _minScrollPos);
			updateThumb();
		}
		
		
		/**
		 * Gets or sets the current scroll position and updates the position of the thumb.
		 * The <code>scrollPosition</code> value represents a relative position between
		 * the <code>minScrollPosition</code> and <code>maxScrollPosition</code> values.
		 * 
		 * @see #setScrollProperties()
		 * @see #minScrollPosition
		 * @see #maxScrollPosition
		 */
		public function get scrollPosition():Number
		{ 
			return _scrollPos;
		}
		
		public function set scrollPosition(v:Number):void
		{
			setScrollPosition(v, true);
		}
		
		
		/**
		 * Gets or sets a number that represents the minimum scroll position.  The 
		 * <code>scrollPosition</code> value represents a relative position between the
		 * <code>minScrollPosition</code> and the <code>maxScrollPosition</code> values.
		 * This property is set by the component that contains the scroll bar,
		 * and is usually zero.
		 *
		 * @see #setScrollProperties()
		 * @see #maxScrollPosition
		 * @see #scrollPosition
		 */
		public function get minScrollPosition():Number
		{
			return _minScrollPos;
		}
		
		public function set minScrollPosition(v:Number):void
		{
			/* This uses setScrollProperties because it needs to update thumb and enabled. */
			setScrollProperties(_pageSize, v, _maxScrollPos);
		}
		
		
		/**
		 * Gets or sets a number that represents the maximum scroll position. The
		 * <code>scrollPosition</code> value represents a relative position between the
		 * <code>minScrollPosition</code> and the <code>maxScrollPosition</code> values.
		 * This property is set by the component that contains the scroll bar,
		 * and is the maximum value. Usually this property describes the number
		 * of pixels between the bottom of the component and the bottom of
		 * the content, but this property is often set to a different value to change the
		 * behavior of the scrolling.  For example, the TextArea component sets this
		 * property to the <code>maxScrollH</code> value of the text field, so that the 
		 * scroll bar scrolls appropriately by line of text.
		 *
		 * @see #setScrollProperties()
		 * @see #minScrollPosition
		 * @see #scrollPosition
		 */
		public function get maxScrollPosition():Number
		{
			return _maxScrollPos;
		}
		
		public function set maxScrollPosition(v:Number):void
		{
			/* This uses setScrollProperties because it needs to update thumb and enabled. */
			setScrollProperties(_pageSize, _minScrollPos, v);
		}
		
		
		/**
		 * Gets or sets the number of lines that a page contains. The <code>lineScrollSize
		 * </code> is measured in increments between the <code>minScrollPosition</code> and 
		 * the <code>maxScrollPosition</code>. If this property is 0, the scroll bar 
		 * will not scroll.
		 * 
		 * @see #maxScrollPosition
		 * @see #minScrollPosition
		 * @see #setScrollProperties()
		 */
		public function get pageSize():Number
		{
			return _pageSize;
		}
		
		public function set pageSize(v:Number):void
		{
			if (v > 0) _pageSize = v;
		}
		
		
		/**
		 * Gets or sets a value that represents the increment by which the page is scrolled
		 * when the scroll bar track is pressed. The <code>pageScrollSize</code> value is 
		 * measured in increments between the <code>minScrollPosition</code> and the 
		 * <code>maxScrollPosition</code> values. If this value is set to 0, the value of the
		 * <code>pageSize</code> property is used.
		 *
		 * @see #maxScrollPosition
		 * @see #minScrollPosition
		 */
		public function get pageScrollSize():Number
		{
			return (_pageScrollSize == 0) ? _pageSize : _pageScrollSize;
		}
		
		public function set pageScrollSize(v:Number):void
		{
			if (v >= 0) _pageScrollSize = v;
		}
		
		
		/**
		 * Gets or sets a value that represents the increment by which to scroll the page
		 * when the scroll bar track is pressed. The <code>pageScrollSize</code> is measured 
		 * in increments between the <code>minScrollPosition</code> and the <code>
		 * maxScrollPosition</code> values. If this value is set to 0, the value of the
		 * <code>pageSize</code> property is used.
		 * 
		 * @see #maxScrollPosition
		 * @see #minScrollPosition
		 */
		public function get lineScrollSize():Number
		{
			return _lineScrollSize;
		}
		
		public function set lineScrollSize(v:Number):void
		{
			if (v > 0) _lineScrollSize = v;
		}
		
		
		/**
		 * Gets or sets a value that indicates whether the scroll bar scrolls horizontally
		 * or vertically. Valid values are <code>ScrollBarDirection.HORIZONTAL</code> and 
		 * <code>ScrollBarDirection.VERTICAL</code>.
		 *
		 * @see com.hexagonstar.ui.controls.ScrollBarDirection ScrollBarDirection
		 */
		public function get direction():String
		{
			return _direction;
		}
		
		public function set direction(v:String):void
		{
			if (_direction == v) return; 
			_direction = v;
			setScaleY(1);
			
			var h:Boolean = _direction == ScrollBarDirection.HORIZONTAL;
			if (h && rotation == 0)
			{
				rotation = -90;
				setScaleX(-1);
			}
			else if (!h && rotation == -90)
			{
				rotation = 0;
				setScaleX(1);
			}
			
			invalidate(InvalidationType.SIZE);
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Event Handlers                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		protected function onScrollPress(e:UIComponentEvent):void
		{
			e.stopImmediatePropagation();
			
			if (e.currentTarget == _upArrow)
			{
				setScrollPosition(_scrollPos - _lineScrollSize);
			}
			else if (e.currentTarget == _downArrow)
			{
				setScrollPosition(_scrollPos + _lineScrollSize);
			}
			else
			{
				var mousePos:Number = (_track.mouseY) / _track.height *
					(_maxScrollPos - _minScrollPos) + _minScrollPos;
				var pgScroll:Number = (pageScrollSize == 0) ? pageSize : pageScrollSize;
				
				if (_scrollPos < mousePos)
					setScrollPosition(Math.min(mousePos, _scrollPos + pgScroll));
				else if (_scrollPos > mousePos)
					setScrollPosition(Math.max(mousePos, _scrollPos - pgScroll));
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onThumbPress(e:MouseEvent):void
		{
			_isDragging = true;
			_thumbScrollOffset = mouseY - _thumb.y;
			_thumb.mouseStateLocked = true;
			/* Should be able to do stage.mouseChildren, but doesn't seem to work. */
			mouseChildren = false;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onThumbDrag, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onThumbRelease, false, 0, true);
		}
		
		
		/**
		 * @private
		 */
		protected function onThumbDrag(e:MouseEvent):void
		{
			var pos:Number = Math.max(0, Math.min(_track.height - _thumb.height,
				mouseY - _track.y - _thumbScrollOffset));
			setScrollPosition(pos / (_track.height - _thumb.height) *
				(_maxScrollPos - _minScrollPos) + _minScrollPos);
		}
		
		
		/**
		 * @private
		 */
		protected function onThumbRelease(e:MouseEvent):void
		{
			_isDragging = false;
			mouseChildren = true;
			_thumb.mouseStateLocked = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbRelease);
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
			
			if (_direction == ScrollBarDirection.HORIZONTAL) _height = WIDTH;
			else _width = WIDTH;
			
			_track = new BaseButton();
			_track.move(0, 14);
			_track.useHandCursor = false;
			_track.autoRepeat = true;
			_track.focusEnabled = false;
			addChild(_track);
			
			_thumb = new LabelButton();
			_thumb.label = "";
			_thumb.setSize(WIDTH - 2, 15);
			_thumb.move(0, 15);
			_thumb.useHandCursor = false;
			_thumb.focusEnabled = false;
			addChild(_thumb);
			
			_downArrow = new BaseButton();
			_downArrow.setSize(WIDTH, 14);
			_downArrow.autoRepeat = true;
			_downArrow.focusEnabled = false;
			addChild(_downArrow);
			
			_upArrow = new BaseButton();
			_upArrow.setSize(WIDTH, 14);
			_upArrow.move(0, 0);
			_upArrow.autoRepeat = true;
			_upArrow.focusEnabled = false;
			addChild(_upArrow);
			
			_upArrow.addEventListener(UIComponentEvent.BUTTON_DOWN, onScrollPress,
				false, 0, true);
			_downArrow.addEventListener(UIComponentEvent.BUTTON_DOWN, onScrollPress,
				false, 0, true);
			_track.addEventListener(UIComponentEvent.BUTTON_DOWN, onScrollPress,
				false, 0, true);
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbPress,
				false, 0, true);
			
			enabled = false;
		}
		
		
		/**
		 * @private
		 */
		override protected function draw():void
		{
			if (isInvalid(InvalidationType.SIZE))
			{
				var h:Number = super.height;
				_downArrow.move(0, Math.max(_upArrow.height, h - _downArrow.height));
				_track.setSize(WIDTH, Math.max(0, h - (_downArrow.height + _upArrow.height)));
				updateThumb();
			}
			
			if (isInvalid(InvalidationType.STYLES, InvalidationType.STATE)) setStyles();
			
			/* Call drawNow on nested components to get around problems
			 * with nested render events */
			_downArrow.drawNow();
			_upArrow.drawNow();
			_track.drawNow();
			_thumb.drawNow();
			validate();
		}
		
		
		/**
		 * @private
		 */
		protected function setStyles():void
		{
			copyStylesToChild(_downArrow, DOWN_ARROW_STYLES);
			copyStylesToChild(_thumb, THUMB_STYLES);
			copyStylesToChild(_track, TRACK_STYLES);
			copyStylesToChild(_upArrow, UP_ARROW_STYLES);
		}
		
		
		/**
		 * @private
		 */
		protected function updateThumb():void
		{
			var p:Number = _maxScrollPos - _minScrollPos + _pageSize;
			
			if (_track.height <= 12 || _maxScrollPos <= _minScrollPos || (p == 0 || isNaN(p)))
			{
				_thumb.height = 12;
				_thumb.visible = false;
			}
			else
			{
				_thumb.height = Math.max(13, _pageSize / p * _track.height);
				_thumb.y = _track.y + (_track.height - _thumb.height) *
					((_scrollPos - _minScrollPos) / (_maxScrollPos - _minScrollPos));
				_thumb.visible = enabled;
			}
		}
	}
}
