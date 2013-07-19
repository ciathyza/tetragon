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
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.events.Event2D;

	import flash.geom.Matrix;
	
	
	/** Dispatched on all children when the object is flattened. */
	[Event(name="flatten", type="tetragon.view.render2d.events.Event2D")]
	
	
	/**
	 * A Sprite is the most lightweight, non-abstract container class.
	 * <p>
	 * Use it as a simple means of grouping objects together in one coordinate system, or
	 * as the base class for custom display objects.
	 * </p>
	 * <strong>Flattened Sprites</strong>
	 * <p>
	 * The <code>flatten</code>-method allows you to optimize the rendering of static
	 * parts of your display list.
	 * </p>
	 * <p>
	 * It analyzes the tree of children attached to the sprite and optimizes the rendering
	 * calls in a way that makes rendering extremely fast. The speed-up comes at a price,
	 * though: you will no longer see any changes in the properties of the children
	 * (position, rotation, alpha, etc.). To update the object after changes have
	 * happened, simply call <code>flatten</code> again, or <code>unflatten</code> the
	 * object.
	 * </p>
	 * 
	 * @see DisplayObject2D
	 * @see DisplayObjectContainer2D
	 */
	public class Sprite2D extends DisplayObjectContainer2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _flattenedContents:Vector.<QuadBatch2D>;
		private var _flattenRequested:Boolean;
		
		
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
			disposeFlattenedContents();
			super.dispose();
		}
		
		
		/**
		 * Optimizes the sprite for optimal rendering performance. Changes in the children
		 * of a flattened sprite will not be displayed any longer. For this to happen,
		 * either call <code>flatten</code> again, or <code>unflatten</code> the sprite.
		 * Beware that the actual flattening will not happen right away, but right before
		 * the next rendering.
		 */
		public function flatten():void
		{
			if (isFlattened) return;
			_flattenRequested = true;
			broadcastEventWith(Event2D.FLATTEN);
		}
		
		
		/**
		 * Removes the rendering optimizations that were created when flattening the
		 * sprite. Changes to the sprite's children will immediately become visible again.
		 */
		public function unflatten():void
		{
			if (!isFlattened) return;
			_flattenRequested = false;
			disposeFlattenedContents();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function render(support:RenderSupport2D, parentAlpha:Number):void
		{
			if (_flattenedContents || _flattenRequested)
			{
				if (!_flattenedContents) _flattenedContents = new <QuadBatch2D>[];
				
				if (_flattenRequested)
				{
					QuadBatch2D.compile(this, _flattenedContents);
					_flattenRequested = false;
				}
				
				var alpha:Number = parentAlpha * this.alpha;
				var numBatches:int = _flattenedContents.length;
				var mvpMatrix:Matrix = support.mvpMatrix;
				
				support.finishQuadBatch();
				support.raiseDrawCount(numBatches);
				
				for (var i:int = 0; i < numBatches; ++i)
				{
					var quadBatch:QuadBatch2D = _flattenedContents[i];
					var blendMode:String = quadBatch.blendMode == BlendMode2D.AUTO
						? support.blendMode
						: quadBatch.blendMode;
					quadBatch.renderCustom(mvpMatrix, alpha, blendMode);
				}
			}
			else
			{
				super.render(support, parentAlpha);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if the sprite was flattened.
		 */
		public function get isFlattened():Boolean
		{
			return (_flattenedContents != null) || _flattenRequested;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function disposeFlattenedContents():void
		{
			if (!_flattenedContents) return;
			for (var i:int = 0, max:int = _flattenedContents.length; i < max; ++i)
			{
				_flattenedContents[i].dispose();
			}
			_flattenedContents = null;
		}
	}
}
