package tetragon.view.ui.controls
{
	import tetragon.view.ui.constants.InvalidationType;
	import tetragon.view.ui.constants.ProgressBarDirection;
	import tetragon.view.ui.constants.ProgressBarMode;
	import tetragon.view.ui.controls.progressbarclasses.IndeterminateBar;
	import tetragon.view.ui.core.UIComponent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	
	[Event("complete", type="flash.events.Event")]
	[Event("progress", type="flash.events.ProgressEvent")]
	
	
	[Style(name="icon", type="Class")]
	[Style(name="trackSkin", type="Class")]
	[Style(name="barSkin", type="Class")]
	[Style(name="indeterminateSkin", type="Class")]
	[Style(name="indeterminateBar", type="Class")]
	[Style(name="barPadding", type="Number", format="Length")]
	
	
	/**
	 * The ProgressBar component displays the progress of content that is 
	 * being loaded. The ProgressBar is typically used to display the status of 
	 * images, as well as portions of applications, while they are loading. 
	 * The loading process can be determinate or indeterminate. A determinate 
	 * progress bar is a linear representation of the progress of a task over 
	 * time and is used when the amount of content to load is known. An indeterminate 
	 * progress bar has a striped fill and a loading source of unknown size.
	 *
	 * @see ProgressBarDirection
	 * @see ProgressBarMode
	 */
	public class ProgressBar extends UIComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _track:DisplayObject;
		protected var _determinateBar:DisplayObject;
		protected var _indeterminateBar:UIComponent;
		protected var _source:IProgressBarSource;
		protected var _direction:String = ProgressBarDirection.RIGHT;
		protected var _mode:String = ProgressBarMode.EVENT;
		protected var _indeterminate:Boolean = true;
		protected var _minimum:Number = 0;
		protected var _maximum:Number = 0;
		protected var _value:Number = 0;
		protected var _loaded:Number;
		
		private static var _defaultStyles:Object =
		{
			trackSkin:			"ProgressBarTrackSkin",
			barSkin:			"ProgressBarBarSkin",
			indeterminateSkin:	"ProgressBarIndeterminateSkin",
			indeterminateBar:	IndeterminateBar,
			barPadding:			0
		};
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------

		/**
		 * Creates a new ProgressBar component instance.
		 */
		public function ProgressBar(x:Number = 0, y:Number = 0, width:Number = 100,
			height:Number = 12)
		{
			super();
			
			if (x != 0 || y != 0) move(x, y);
			if (width > 0) _width = width;
			if (height > 0) _height = height;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets the state of the bar to reflect the amount of progress made when 
		 * using manual mode. The <code>value</code> argument is assigned to the 
		 * <code>value</code> property and the <code>maximum</code> argument is
		 * assigned to the <code>maximum</code> property. The <code>minimum</code> 
		 * property is not altered.
		 *
		 * @param value A value describing the progress that has been made. 
		 * @param maximum The maximum progress value of the progress bar.
		 * @see #maximum
		 * @see #value
		 * @see ProgressBarMode#MANUAL ProgressBarMode.manual
		 */
		public function setProgress(value:Number, maximum:Number):void
		{
			if (_mode != ProgressBarMode.MANUAL)
			{
				return;
			}
			setProgr(value, maximum);
		}
		
		
		/**
		 * Resets the progress bar for a new load operation.
		 */
		public function reset():void
		{
			setProgr(0, 0);
			var tmp:IProgressBarSource = _source;
			_source = null;
			source = tmp;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @copy fl.core.UIComponent#getStyleDefinition()
		 */
		public static function get styleDefinition():Object
		{
			return _defaultStyles;
		}
		
		
		/**
		 * Indicates the fill direction for the progress bar. A value of 
		 * <code>ProgressBarDirection.RIGHT</code> indicates that the progress 
		 * bar is filled from left to right. A value of <code>ProgressBarDirection.LEFT</code>
		 * indicates that the progress bar is filled from right to left.
		 *
		 * @default ProgressBarDirection.RIGHT
		 * @see ProgressBarDirection
		 */
		public function get direction():String
		{
			return _direction;
		}
		public function set direction(v:String):void
		{
			_direction = v;
			invalidate(InvalidationType.DATA);
		}
		
		
		/**
		 * Gets or sets a value that indicates the type of fill that the progress 
		 * bar uses and whether the loading source is known or unknown. A value of 
		 * <code>true</code> indicates that the progress bar has a striped fill 
		 * and a loading source of unknown size. A value of <code>false</code> 
		 * indicates that the progress bar has a solid fill and a loading source 
		 * of known size. 
		 *
		 * <p>This property can only be set when the progress bar mode 
		 * is set to <code>ProgressBarMode.MANUAL</code>.</p>
		 *
		 * @default true
		 * @see #mode
		 * @see ProgressBarMode
		 * @see fl.controls.progressBarClasses.IndeterminateBar IndeterminateBar
		 */
		public function get indeterminate():Boolean
		{
			return _indeterminate;
		}
		public function set indeterminate(v:Boolean):void
		{
			if (_mode != ProgressBarMode.MANUAL || _indeterminate == v) return;
			setIndeterminate(v);
		}
		
		
		/**
		 * Gets or sets the minimum value for the progress bar when the 
		 * <code>ProgressBar.mode</code> property is set to <code>ProgressBarMode.MANUAL</code>.
		 *
		 * @default 0
		 * @see #maximum
		 * @see #percentComplete
		 * @see #value
		 * @see ProgressBarMode#MANUAL
		 */
		public function get minimum():Number
		{
			return _minimum;
		}
		public function set minimum(v:Number):void
		{
			if (_mode != ProgressBarMode.MANUAL) return;
			_minimum = v;
			invalidate(InvalidationType.DATA);
		}
		
		
		/**
		 * Gets or sets the maximum value for the progress bar when the 
		 * <code>ProgressBar.mode</code> property is set to <code>ProgressBarMode.MANUAL</code>.
		 *
		 * @default 0
		 * @see #minimum
		 * @see #percentComplete
		 * @see #value
		 * @see ProgressBarMode#MANUAL
		 */
		public function get maximum():Number
		{
			return _maximum;
		}
		public function set maximum(v:Number):void
		{
			setProgress(_value, v);
		}
		
		
		/**
		 * Gets or sets a value that indicates the amount of progress that has 
		 * been made in the load operation. This value is a number between the 
		 * <code>minimum</code> and <code>maximum</code> values.
		 *
		 * @default 0
		 * @see #maximum
		 * @see #minimum
		 * @see #percentComplete
		 */
		public function get value():Number
		{
			return _value;
		}
		public function set value(v:Number):void
		{
			setProgress(v, _maximum);
		}
		
		
		/**
		 * @private (internal)
		 */
		public function set sourceName(v:String):void
		{
			if (v == null || v == "") return;
			var target:IProgressBarSource = IProgressBarSource(parent.getChildByName(v));
			if (target == null) throw new Error("Source clip '" + v + "' not found on parent.");
			source = target;
		}
		
		
		/**
		 * Gets or sets a reference to the content that is being loaded and for
		 * which the ProgressBar is measuring the progress of the load operation. 
		 * A typical usage of this property is to set it to a UILoader component.
		 *
		 * <p>Use this property only in event mode and polled mode.</p>
		 *
		 * @default null
		 */
		public function get source():IProgressBarSource
		{
			return _source;
		}
		public function set source(v:IProgressBarSource):void
		{
			if (_source == v) return;
			if (_mode != ProgressBarMode.MANUAL) resetProgress();
			_source = v;
			if (_source == null) return;
			// Can not poll or add listeners to a null source!
			if (_mode == ProgressBarMode.EVENT)
				setupSourceEvents();
			else if (_mode == ProgressBarMode.POLLED)
				addEventListener(Event.ENTER_FRAME, onPollSource, false, 0, true);
		}
		
		
		/**
		 * Gets a number between 0 and 100 that indicates the percentage 
		 * of the content has already loaded. 
		 *
		 * <p>To change the percentage value, use the <code>setProgress()</code> method.</p>
		 *
		 * @default 0
		 * @see #maximum
		 * @see #minimum
		 * @see #setProgress()
		 * @see #value
		 */
		public function get percentComplete():Number
		{
			return (_maximum <= _minimum || _value <= _minimum) ? 0 : Math.max(0, Math.min(100, (_value - _minimum) / (_maximum - _minimum) * 100));
		}
		
		
		/**
		 * Gets or sets the method to be used to update the progress bar. 
		 *
		 * <p>The following values are valid for this property:</p> 
		 * <ul>
		 *     <li><code>ProgressBarMode.EVENT</code></li>
		 *     <li><code>ProgressBarMode.POLLED</code></li>
		 *     <li><code>ProgressBarMode.MANUAL</code></li>
		 * </ul>
		 *
		 * <p>Event mode and polled mode are the most common modes. In event mode, 
		 * the <code>source</code> property specifies loading content that generates  
		 * <code>progress</code> and <code>complete</code> events; you should use 
		 * a UILoader object in this mode. In polled mode, the <code>source</code> 
		 * property specifies loading content, such as a custom class, that exposes 
		 * <code>bytesLoaded</code> and <code>bytesTotal</code> properties. Any object 
		 * that exposes these properties can be used as a source in polled mode.</p>
		 *
		 * <p>You can also use the ProgressBar component in manual mode by manually 
		 * setting the <code>maximum</code> and <code>minimum</code> properties and 
		 * making calls to the <code>ProgressBar.setProgress()</code> method.</p>
		 *
		 * @default ProgressBarMode.EVENT
		 * @see ProgressBarMode
		 */
		public function get mode():String
		{
			return _mode;
		}
		public function set mode(v:String):void
		{
			if (_mode == v) return;
			resetProgress();
			_mode = v;
			if (v == ProgressBarMode.EVENT && _source != null)
				setupSourceEvents();
			else if (v == ProgressBarMode.POLLED)
				addEventListener(Event.ENTER_FRAME, onPollSource, false, 0, true);
			setIndeterminate(_mode != ProgressBarMode.MANUAL);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private (protected)
		 */
		protected function onPollSource(v:Event):void
		{
			if (_source == null)
			{
				return;
			}
			setProgr(_source.bytesLoaded, _source.bytesTotal, true);
			if (_maximum > 0 && _maximum == _value)
			{
				removeEventListener(Event.ENTER_FRAME, onPollSource);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function onProgress(e:ProgressEvent):void
		{
			setProgr(e.bytesLoaded, e.bytesTotal, true);
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function onComplete(e:Event):void
		{
			setProgr(_maximum, _maximum, true);
			dispatchEvent(e);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private (protected)
		 */
		protected function setProgr(value:Number, maximum:Number, fireEvent:Boolean = false):void
		{
			if (value == _value && maximum == _maximum) return;
			_value = value;
			_maximum = maximum;
			if (_value != _loaded && fireEvent)
			{
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _value, _maximum));
				_loaded = _value;
			}
			if (_mode != ProgressBarMode.MANUAL) setIndeterminate(maximum == 0);
			invalidate(InvalidationType.DATA);
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function setIndeterminate(value:Boolean):void
		{
			if (_indeterminate == value) return;
			_indeterminate = value;
			invalidate(InvalidationType.STATE);
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function resetProgress():void
		{
			if (_mode == ProgressBarMode.EVENT && _source != null) cleanupSourceEvents();
			else if (_mode == ProgressBarMode.POLLED) removeEventListener(Event.ENTER_FRAME, onPollSource);
			else if (_source != null) _source = null;
			_minimum = _maximum = _value = 0;
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function setupSourceEvents():void
		{
			_source.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
			_source.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function cleanupSourceEvents():void
		{
			_source.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_source.removeEventListener(Event.COMPLETE, onComplete);
		}
		
		
		/**
		 * @private (protected)
		 */
		override protected function draw():void
		{
			if (isInvalid(InvalidationType.STYLES))
			{
				drawTrack();
				drawBars();
				invalidate(InvalidationType.STATE, false);
				invalidate(InvalidationType.SIZE, false);
			}
			if (isInvalid(InvalidationType.STATE))
			{
				_indeterminateBar.visible = _indeterminate;
				_determinateBar.visible = !_indeterminate;
				invalidate(InvalidationType.DATA, false);
			}

			if (isInvalid(InvalidationType.SIZE))
			{
				drawLayout();
				invalidate(InvalidationType.DATA, false);
			}

			if (isInvalid(InvalidationType.DATA) && !_indeterminate)
			{
				drawDeterminateBar();
			}
			super.draw();
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function drawTrack():void
		{
			var oldTrack:DisplayObject = _track;
			_track = getDisplayObjectInstance(getStyleValue("trackSkin"));
			addChildAt(_track, 0);
			if (oldTrack != null && oldTrack != _track)
			{
				removeChild(oldTrack);
			}
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function drawBars():void
		{
			var oldDeterminateBar:DisplayObject = _determinateBar;
			var oldIndeterminateBar:DisplayObject = _indeterminateBar;

			_determinateBar = getDisplayObjectInstance(getStyleValue("barSkin"));
			addChild(_determinateBar);

			_indeterminateBar = getDisplayObjectInstance(getStyleValue("indeterminateBar")) as UIComponent;
			_indeterminateBar.setStyle("indeterminateSkin", getStyleValue("indeterminateSkin"));
			addChild(_indeterminateBar);

			if (oldDeterminateBar != null && oldDeterminateBar != _determinateBar)
			{
				removeChild(oldDeterminateBar);
			}
			if (oldIndeterminateBar != null && oldIndeterminateBar != _determinateBar)
			{
				removeChild(oldIndeterminateBar);
			}
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function drawDeterminateBar():void
		{
			var p:Number = percentComplete / 100;
			var barPad:Number = Number(getStyleValue("barPadding"));
			_determinateBar.width = Math.round((width - barPad * 2) * p);
			_determinateBar.x = (_direction == ProgressBarDirection.LEFT) ? width - barPad - _determinateBar.width : barPad;
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function drawLayout():void
		{
			var barPadding:Number = Number(getStyleValue("barPadding"));
			_track.width = width;
			_track.height = height;
			_indeterminateBar.setSize(width - barPadding * 2, height - barPadding * 2);
			_indeterminateBar.move(barPadding, barPadding);
			_indeterminateBar.drawNow();
			_determinateBar.height = height - barPadding * 2;
			_determinateBar.y = barPadding;
		}
		
		
		/**
		 * @private (protected)
		 */
		override protected function configUI():void
		{
			super.configUI();
		}
	}
}
