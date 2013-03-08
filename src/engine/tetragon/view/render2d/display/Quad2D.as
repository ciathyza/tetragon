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
	import tetragon.view.render2d.core.VertexData2D;

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	/**
	 * A rectangular polygon whose vertices can have an arbitrary coordinate.
	 */
	public class Quad2D extends DisplayObject2D implements IQuad2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _tinted:Boolean;
		/** The raw vertex data of the quad. */
		protected var _vertexData:VertexData2D;
		
		/** Helper objects. */
		private static var _helperPoint:Point = new Point();
		private static var _helperMatrix:Matrix = new Matrix();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function Quad2D(x1:Number = 0, y1:Number = 0, x2:Number = 0, y2:Number = 0,
			x3:Number = 0, y3:Number = 0, x4:Number = 0, y4:Number = 0, color:uint = 0xFFFFFF,
			premultipliedAlpha:Boolean = true)
		{
			_tinted = color != 0xFFFFFF;
			
			_vertexData = new VertexData2D(4, premultipliedAlpha);
			_vertexData.setPosition(0, x1, y1);
			_vertexData.setPosition(1, x2, y2);
			_vertexData.setPosition(2, x4, y4);
			_vertexData.setPosition(3, x3, y3);
			_vertexData.setUniformColor(color);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function getBounds(targetSpace:DisplayObject2D,
			resultRect:Rectangle = null):Rectangle
		{
			if (!resultRect) resultRect = new Rectangle();
			if (targetSpace == this) // optimization
			{
				_vertexData.getPosition(3, _helperPoint);
				resultRect.setTo(0.0, 0.0, _helperPoint.x, _helperPoint.y);
			}
			else if (targetSpace == parent && rotation == 0.0) // optimization
			{
				var scaleX:Number = this.scaleX;
				var scaleY:Number = this.scaleY;
				_vertexData.getPosition(3, _helperPoint);
				resultRect.setTo(x - pivotX * scaleX, y - pivotY * scaleY,
					_helperPoint.x * scaleX, _helperPoint.y * scaleY);
				if (scaleX < 0)
				{
					resultRect.width *= -1;
					resultRect.x -= resultRect.width;
				}
				if (scaleY < 0)
				{
					resultRect.height *= -1;
					resultRect.y -= resultRect.height;
				}
			}
			else
			{
				getTransformationMatrix(targetSpace, _helperMatrix);
				_vertexData.getBounds(_helperMatrix, 0, 4, resultRect);
			}
			
			return resultRect;
		}
		
		
		public function getVertexColor(vertexID:int):uint
		{
			return _vertexData.getColor(vertexID);
		}
		
		
		public function setVertexColor(vertexID:int, color:uint):void
		{
			_vertexData.setColor(vertexID, color);
			if (color != 0xFFFFFF) _tinted = true;
			else _tinted = _vertexData.tinted;
		}
		
		
		public function getVertexAlpha(vertexID:int):Number
		{
			return _vertexData.getAlpha(vertexID);
		}
		
		
		public function setVertexAlpha(vertexID:int, alpha:Number):void
		{
			_vertexData.setAlpha(vertexID, alpha);
			if (alpha != 1.0) _tinted = true;
			else _tinted = _vertexData.tinted;
		}
		
		
		public function copyVertexDataTo(targetData:VertexData2D, targetVertexID:int = 0):void
		{
			_vertexData.copyTo(targetData, targetVertexID);
		}
		
		
		public override function render(support:RenderSupport2D, parentAlpha:Number):void
		{
			support.batchQuad(this, parentAlpha);
		}
		
		
		public function update(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number,
			x4:Number, y4:Number, color:uint):void
		{
			_vertexData.setPosition(0, x1, y1);
			_vertexData.setPosition(1, x2, y2);
			_vertexData.setPosition(2, x4, y4);
			_vertexData.setPosition(3, x3, y3);
			_vertexData.setUniformColor(color);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the color of the quad, or of vertex 0 if vertices have different colors.
		 */
		public function get color():uint
		{
			return _vertexData.getColor(0);
		}
		/**
		 * Sets the colors of all vertices to a certain value.
		 */
		public function set color(v:uint):void
		{
			for (var i:int = 0; i < 4; ++i)
			{
				setVertexColor(i, v);
			}
			if (v != 0xFFFFFF || alpha != 1.0) _tinted = true;
			else _tinted = _vertexData.tinted;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function set alpha(v:Number):void
		{
			super.alpha = v;
			if (v < 1.0) _tinted = true;
			else _tinted = _vertexData.tinted;
		}
		
		
		/**
		 * Returns true if the quad (or any of its vertices) is non-white or non-opaque.
		 */
		public function get tinted():Boolean
		{
			return _tinted;
		}
	}
}
