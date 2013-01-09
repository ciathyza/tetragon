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
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import tetragon.view.render2d.core.events.Event2D;
	import tetragon.view.render2d.core.events.TouchEvent2D;

	
	
	/**
	 * A Sprite is the most lightweight, non-abstract container class.
	 * <p>
	 * Use it as a simple means of grouping objects together in one coordinate system, or
	 * as the base class for custom display objects.
	 * </p>
	 * 
	 * <strong>Flattened Sprites</strong>
	 * 
	 * <p>
	 * The <code>flatten</code>-method allows you to optimize the rendering of static
	 * parts of your display list.
	 * </p>
	 * 
	 * <p>
	 * It analyzes the tree of children attached to the sprite and optimizes the rendering
	 * calls in a way that makes rendering extremely fast. The speed-up comes at a price,
	 * though: you will no longer see any changes in the properties of the children
	 * (position, rotation, alpha, etc.). To update the object after changes have
	 * happened, simply call <code>flatten</code> again, or <code>unflatten</code> the
	 * object.
	 * </p>
	 * 
	 * @see DisplayObject@D
	 * @see DisplayObjectContainer@D
	 */
	public class Sprite2D extends DisplayObjectContainer2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _flattenedContents:Vector.<QuadBatch2D>;
		/** @private */
		private var _useHandCursor:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates an empty sprite.
		 */
		public function Sprite2D()
		{
			super();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function dispose():void
		{
			unflatten();
			super.dispose();
		}
		
		
		/**
		 * Optimizes the sprite for optimal rendering performance. Changes in the children
		 * of a flattened sprite will not be displayed any longer. For this to happen,
		 * either call <code>flatten</code> again, or <code>unflatten</code> the sprite.
		 */
		public function flatten():void
		{
			dispatchEventOnChildren(new Event2D(Event2D.FLATTEN));
			if (!_flattenedContents)
			{
				_flattenedContents = new <QuadBatch2D>[];
				Render2D.current.addEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated);
			}
			QuadBatch2D.compile(this, _flattenedContents);
		}
		
		
		/**
		 * Removes the rendering optimizations that were created when flattening the
		 * sprite. Changes to the sprite's children will become immediately visible again.
		 */
		public function unflatten():void
		{
			if (_flattenedContents)
			{
				Render2D.current.removeEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated);
				var numBatches:int = _flattenedContents.length;
				for (var i:int = 0; i < numBatches; ++i)
				{
					_flattenedContents[i].dispose();
				}
				_flattenedContents = null;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function renderWithSupport(support:Render2DRenderSupport, alpha:Number):void
		{
			if (_flattenedContents)
			{
				support.finishQuadBatch();
				alpha *= this.alpha;
				var numBatches:int = _flattenedContents.length;
				for (var i:int = 0; i < numBatches; ++i)
				{
					_flattenedContents[i].render(support.mvpMatrix, alpha);
				}
				return;
			}
			
			super.renderWithSupport(support, alpha);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if the mouse cursor should transform into a hand while it's over the
		 * sprite.
		 * 
		 * @default false
		 */
		public function get useHandCursor():Boolean
		{
			return _useHandCursor;
		}
		public function set useHandCursor(v:Boolean):void
		{
			if (v == _useHandCursor) return;
			_useHandCursor = v;
			if (_useHandCursor) addEventListener(TouchEvent2D.TOUCH, onTouch);
			else removeEventListener(TouchEvent2D.TOUCH, onTouch);
		}
		
		
		/**
		 * Indicates if the sprite was flattened.
		 */
		public function get isFlattened():Boolean
		{
			return _flattenedContents != null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onTouch(e:TouchEvent2D):void
		{
			Mouse.cursor = e.interactsWith(this) ? MouseCursor.BUTTON : MouseCursor.AUTO;
		}
		
		
		/**
		 * @private
		 */
		private function onContextCreated(e:Event2D):void
		{
			if (_flattenedContents)
			{
				_flattenedContents = new <QuadBatch2D>[];
				flatten();
			}
		}
	}
}
