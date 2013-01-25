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
	import tetragon.view.render2d.core.Render2D;
	import tetragon.view.render2d.core.RenderSupport2D;

	import com.hexagonstar.exception.MissingContext3DException;

	import flash.display3D.Context3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * A Sprite2D that can be clipped (masked).
	 */
	public class ClippedSprite2D extends Sprite2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _clipRect:Rectangle;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a clipped sprite.
		 */
		public function ClippedSprite2D(clipRect:Rectangle = null)
		{
			this.clipRect = clipRect;
			super();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function render(support:RenderSupport2D, alpha:Number):void
		{
			if (!_clipRect)
			{
				super.render(support, alpha);
			}
			else
			{
				var context:Context3D = Render2D.context;
				if (!context) throw new MissingContext3DException();
				
				support.finishQuadBatch();
				support.scissorRectangle = _clipRect;
				
				super.render(support, alpha);
				
				support.finishQuadBatch();
				support.scissorRectangle = null;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject2D
		{
			// without a clip rect, the sprite should behave just like before
			if (!_clipRect) return super.hitTest(localPoint, forTouch);
			
			// on a touch test, invisible or untouchable objects cause the test to fail
			if (forTouch && (!visible || !touchable)) return null;
			
			if (_clipRect.containsPoint(localToGlobal(localPoint)))
			{
				return super.hitTest(localPoint, forTouch);
			}
			else
			{
				return null;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get clipRect():Rectangle
		{
			return _clipRect;
		}
		public function set clipRect(v:Rectangle):void
		{
			if (v)
			{
				if (!_clipRect) _clipRect = v.clone();
				else _clipRect.setTo(v.x, v.y, v.width, v.height);
			}
			else
			{
				_clipRect = null;
			}
		}
	}
}
