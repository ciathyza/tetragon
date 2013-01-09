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
package tetragon.view.render2d.core
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import tetragon.view.render2d.core.events.EnterFrameEvent2D;
	import tetragon.view.render2d.core.events.Event2D;

	
	
	/**
	 * A Stage2D represents the root of the display tree. Only objects that are direct or
	 * indirect children of the stage2D will be rendered.
	 * 
	 * <p>
	 * This class represents the Direct2D version of the stage. Don't confuse it with its
	 * Flash equivalent: while the latter contains objects of the type
	 * <code>flash.display.DisplayObject</code>, the Direct2D stage contains only objects
	 * of the type <code>DisplayObject2D</code>. Those classes are not compatible, and you
	 * cannot exchange one type with the other.
	 * </p>
	 * 
	 * <p>
	 * A stage object is created automatically by the <code>Direct2D</code> class. Don't
	 * create a Stage2D instance manually.
	 * </p>
	 * 
	 * <strong>Keyboard Events</strong>
	 * 
	 * <p>
	 * In Direct2D, keyboard events are only dispatched at the stage2D. Add an event
	 * listener directly to the stage2D to be notified of keyboard events.
	 * </p>
	 * 
	 * <strong>Resize Events</strong>
	 * 
	 * <p>
	 * When the Flash player is resized, the stage2D dispatches a <code>ResizeEvent2D</code>.
	 * The event contains properties containing the updated width and height of the Flash
	 * player.
	 * </p>
	 * 
	 * @see direct3d.events.KeyboardEvent2D
	 * @see direct3d.events.ResizeEvent2D
	 */
	public final class Stage2D extends DisplayObjectContainer2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _width:int;
		/** @private */
		private var _height:int;
		/** @private */
		private var _color:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * @param width
		 * @param height
		 * @param color
		 */
		public function Stage2D(width:int, height:int, color:uint = 0x000000)
		{
			_width = width;
			_height = height;
			_color = color;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function advanceTime(passedTime:Number):void
		{
			dispatchEventOnChildren(new EnterFrameEvent2D(Event2D.ENTER_FRAME, passedTime));
		}
		
		
		/**
		 * Returns the object that is found topmost beneath a point in stage coordinates,
		 * or the stage itself if nothing else is found.
		 * 
		 * @param localPoint
		 * @param forTouch
		 * @return DisplayObject2D
		 */
		public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject2D
		{
			if (forTouch && (!visible || !touchable)) return null;
			
			// if nothing else is hit, the stage returns itself as target
			var target:DisplayObject2D = super.hitTest(localPoint, forTouch);
			if (!target) target = this;
			return target;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The background color of the 2D stage.
		 */
		public function get color():uint
		{
			return _color;
		}
		public function set color(v:uint):void
		{
			_color = v;
		}
		
		
		/**
		 * The width of the stage coordinate system. Change it to scale its contents
		 * relative to the <code>viewPort</code> property of the Direct2D object.
		 */
		public function get stageWidth():int
		{
			return _width;
		}
		public function set stageWidth(v:int):void
		{
			_width = v;
		}
		
		
		/**
		 * The height of the stage coordinate system. Change it to scale its contents
		 * relative to the <code>viewPort</code> property of the Direct2D object.
		 */
		public function get stageHeight():int
		{
			return _height;
		}
		public function set stageHeight(v:int):void
		{
			_height = v;
		}
		
		
		/**
		 * @private
		 */
		public override function set width(v:Number):void
		{
			throw new IllegalOperationError("Cannot set width of stage");
		}
		
		
		/**
		 * @private
		 */
		public override function set height(v:Number):void
		{
			throw new IllegalOperationError("Cannot set height of stage");
		}
		
		
		/**
		 * @private
		 */
		public override function set x(v:Number):void
		{
			throw new IllegalOperationError("Cannot set x-coordinate of stage");
		}
		
		
		/**
		 * @private
		 */
		public override function set y(v:Number):void
		{
			throw new IllegalOperationError("Cannot set y-coordinate of stage");
		}
		
		
		/**
		 * @private
		 */
		public override function set scaleX(v:Number):void
		{
			throw new IllegalOperationError("Cannot scale stage");
		}
		
		
		/**
		 * @private
		 */
		public override function set scaleY(v:Number):void
		{
			throw new IllegalOperationError("Cannot scale stage");
		}
		
		
		/**
		 * @private
		 */
		public override function set rotation(v:Number):void
		{
			throw new IllegalOperationError("Cannot rotate stage");
		}
	}
}
