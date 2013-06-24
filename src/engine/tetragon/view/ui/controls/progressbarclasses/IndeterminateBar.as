package tetragon.view.ui.controls.progressbarclasses
{
	import tetragon.view.ui.constants.InvalidationType;
	import tetragon.view.ui.core.UIComponent;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	[Style(name="indeterminateSkin", type="Class")]
	
	
	/**
	 * The IndeterminateBar class handles the drawing of the progress bar component when the 
	 * size of the source that is being loaded is unknown. This class can be replaced with any 
	 * other UIComponent class to render the bar differently. The default implementation uses 
	 * the drawing API create a striped fill to indicate the progress of the load operation.
	 */
	public class IndeterminateBar extends UIComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var animationCount:uint = 0;
		protected var bar:Sprite;
		protected var barMask:Sprite;
		protected var patternBmp:BitmapData;
		
		private static var defaultStyles:Object =
		{
			indeterminateSkin: "ProgressBar_indeterminateSkin"
		};
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the IndeterminateBar component.
		 */
		public function IndeterminateBar()
		{
			super();
			setSize(0, 0);
			startAnimation();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @copy fl.core.UIComponent#getStyleDefinition()
		 * 
		 * @see fl.core.UIComponent#getStyle()
		 * @see fl.core.UIComponent#setStyle()
		 * @see fl.managers.StyleManager
		 */
		public static function getStyleDefinition():Object
		{
			return defaultStyles;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Gets or sets a Boolean value that indicates whether the indeterminate bar is visible.
		 * A value of <code>true</code> indicates that the indeterminate bar is visible; a value
		 * of <code>false</code> indicates that it is not.
		 *
		 * @default true
		 */
		override public function get visible():Boolean
		{
			return super.visible;
		}
		override public function set visible(value:Boolean):void
		{
			if (value)
			{
				startAnimation();
			}
			else
			{
				stopAnimation();
			}
			super.visible = value;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private (protected)
		 */
		protected function handleEnterFrame(event:Event):void
		{
			if (patternBmp == null)
			{
				return;
			}
			animationCount = (animationCount + 2) % patternBmp.width;
			bar.x = -animationCount;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private (protected)
		 */
		protected function startAnimation():void
		{
			addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function stopAnimation():void
		{
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		
		/**
		 * @private (protected)
		 */
		override protected function configUI():void
		{
			bar = new Sprite();
			addChild(bar);
			barMask = new Sprite();
			addChild(barMask);
			bar.mask = barMask;
		}
		
		
		/**
		 * @private (protected)
		 */
		override protected function draw():void
		{
			if (isInvalid(InvalidationType.STYLES))
			{
				drawPattern();
				invalidate(InvalidationType.SIZE, false);
			}
			if (isInvalid(InvalidationType.SIZE))
			{
				drawBar();
				drawMask();
			}
			super.draw();
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function drawPattern():void
		{
			var skin:DisplayObject = getDisplayObjectInstance(getStyleValue("indeterminateSkin"));
			if (patternBmp)
			{
				patternBmp.dispose();
			}
			patternBmp = new BitmapData(skin.width << 0, skin.height << 0, true, 0);
			patternBmp.draw(skin);
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function drawMask():void
		{
			var g:Graphics = barMask.graphics;
			g.clear();
			g.beginFill(0, 0);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
		}
		
		
		/**
		 * @private (protected)
		 */
		protected function drawBar():void
		{
			if (patternBmp == null)
			{
				return;
			}
			var g:Graphics = bar.graphics;
			g.clear();
			g.beginBitmapFill(patternBmp);
			g.drawRect(0, 0, _width + patternBmp.width, _height);
			g.endFill();
		}
	}
}
