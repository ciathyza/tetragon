/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package tetragon.view.render2d.display
{
	import tetragon.Main;
	import tetragon.view.IView;
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.events.Event2D;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * View2D class
	 *
	 * @author hexagon
	 */
	public class View2D extends DisplayObjectContainer2D implements IView
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		protected var _main:Main;
		protected var _clipRect:Rectangle;
		protected var _background:Quad2D;
		
		protected var _clipped:Boolean = true;
		
		protected var _frameWidth:int;
		protected var _frameHeight:int;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function View2D()
		{
			_main = Main.instance;
			_frameWidth = _main.stage.stageWidth;
			_frameHeight = _main.stage.stageHeight;
			
			super();
			
			setup();
			updateFrame();
			
			addEventListener(Event2D.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function render(support:RenderSupport2D, alpha:Number):void
		{
			/* Render background, which is not in the child collection. */
			if (_background)
			{
				support.pushMatrix();
				support.transformMatrix(_background);
				_background.render(support, alpha);
				support.popMatrix();
			}
			
			if (!_clipped)
			{
				super.render(support, alpha);
				return;
			}
			
			support.finishQuadBatch();
			support.scissorRectangle = _clipRect;
			super.render(support, alpha);
			support.finishQuadBatch();
			support.scissorRectangle = null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject2D
		{
			if (!_clipped)
			{
				return super.hitTest(localPoint, forTouch);
			}
			
			// on a touch test, invisible or untouchable objects cause the test to fail
			if (forTouch && (!visible || !touchable))
			{
				return null;
			}
			
			if (_clipRect.containsPoint(localToGlobal(localPoint)))
			{
				return super.hitTest(localPoint, forTouch);
			}
			else
			{
				return null;
			}
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		override public function set x(v:Number):void
		{
			if (v == super.x) return;
			super.x = v;
			updateFrame();
		}
		
		
		override public function set y(v:Number):void
		{
			if (v == super.y) return;
			super.y = v;
			updateFrame();
		}
		
		
		public function get frameWidth():int
		{
			return _frameWidth;
		}
		public function set frameWidth(v:int):void
		{
			if (v == _frameWidth) return;
			_frameWidth = v;
			updateFrame();
		}
		
		
		public function get frameHeight():int
		{
			return _frameHeight;
		}
		public function set frameHeight(v:int):void
		{
			if (v == _frameHeight) return;
			_frameHeight = v;
			updateFrame();
		}
		
		
		public function get clipped():Boolean
		{
			return _clipped;
		}
		public function set clipped(v:Boolean):void
		{
			if (v == _clipped) return;
			_clipped = v;
			updateFrame();
		}
		
		
		public function get background():Quad2D
		{
			return _background;
		}
		public function set background(v:Quad2D):void
		{
			if (v == _background) return;
			_background = v;
			updateFrame();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Callback Handlers
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onAddedToStage(e:Event2D):void
		{
			removeEventListener(Event2D.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function setup():void
		{
		}
		
		
		/**
		 * @private
		 */
		protected function updateFrame():void
		{
			if (_clipped)
			{
				if (_clipRect) _clipRect.setTo(x, y, _frameWidth, _frameHeight);
				else _clipRect = new Rectangle(x, y, _frameWidth, _frameHeight);
			}
			else
			{
				_clipRect = null;
			}
			
			if (_background)
			{
				_background.width = _frameWidth;
				_background.height = _frameHeight;
			}
		}
	}
}
