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
	import com.hexagonstar.util.geom.transform2DCoords;

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	
	/**
	 * A Quad represents a rectangle with a uniform color or a color gradient.
	 * 
	 * <p>
	 * You can set one color per vertex. The colors will smoothly fade into each other
	 * over the area of the quad. To display a simple linear color gradient, assign one
	 * color to vertices 0 and 1 and another color to vertices 2 and 3.
	 * </p>
	 * 
	 * <p>
	 * The indices of the vertices are arranged like this:
	 * </p>
	 * 
	 * <pre>
	 *  0 - 1
	 *  | / |
	 *  2 - 3
	 * </pre>
	 * 
	 * @see Image2D
	 */
	public class Quad2D extends DisplayObject2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The raw vertex data of the quad.
		 * @private
		 */
		protected var _vertexData:VertexData2D;
		
		/* Helper objects. */
		
		/** @private */
		private static var _position:Vector3D = new Vector3D();
		/** @private */
		private static var _helperPoint:Point = new Point();
		/** @private */
		private static var _helperMatrix:Matrix = new Matrix();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a quad with a certain size and color. The last parameter controls if
		 * the alpha value should be premultiplied into the color values on rendering,
		 * which can influence blending output. You can use the default value in most
		 * cases.
		 * 
		 * @param width
		 * @param height
		 * @param color
		 * @param premultipliedAlpha
		 */
		public function Quad2D(width:Number, height:Number, color:uint = 0xFFFFFF,
			premultipliedAlpha:Boolean = true)
		{
			_vertexData = new VertexData2D(4, premultipliedAlpha);
			updateVertexData(width, height, color, premultipliedAlpha);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Updates the vertex data with specific values for dimensions and color.
		 * 
		 * @param width
		 * @param height
		 * @param color
		 * @param premultipliedAlpha
		 */
		protected function updateVertexData(width:Number, height:Number, color:uint,
			premultipliedAlpha:Boolean):void
		{
			_vertexData.setPremultipliedAlpha(premultipliedAlpha);
			_vertexData.setPosition(0, 0.0, 0.0);
			_vertexData.setPosition(1, width, 0.0);
			_vertexData.setPosition(2, 0.0, height);
			_vertexData.setPosition(3, width, height);
			_vertexData.setUniformColor(color);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function getBounds(targetSpace:DisplayObject2D,
			resultRect:Rectangle = null):Rectangle
		{
			if (!resultRect) resultRect = new Rectangle();
			
			var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
			var i:int;
			
			if (targetSpace == this) // optimization
			{
				for (i = 0; i < 4; ++i)
				{
					_vertexData.getPosition(i, _position);
					minX = minX < _position.x ? minX : _position.x;
					maxX = maxX > _position.x ? maxX : _position.x;
					minY = minY < _position.y ? minY : _position.y;
					maxY = maxY > _position.y ? maxY : _position.y;
				}
			}
			else
			{
				getTransformationMatrix(targetSpace, _helperMatrix);
				for (i = 0; i < 4; ++i)
				{
					_vertexData.getPosition(i, _position);
					transform2DCoords(_helperMatrix, _position.x, _position.y, _helperPoint);
					minX = minX < _helperPoint.x ? minX : _helperPoint.x;
					maxX = maxX > _helperPoint.x ? maxX : _helperPoint.x;
					minY = minY < _helperPoint.y ? minY : _helperPoint.y;
					maxY = maxY > _helperPoint.y ? maxY : _helperPoint.y;
				}
			}
			
			resultRect.x = minX;
			resultRect.y = minY;
			resultRect.width = maxX - minX;
			resultRect.height = maxY - minY;
			
			return resultRect;
		}
		
		
		/**
		 * Returns the color of a vertex at a certain index.
		 * 
		 * @param vertexID
		 * @return uint
		 */
		public function getVertexColor(vertexID:int):uint
		{
			return _vertexData.getColor(vertexID);
		}
		
		
		/**
		 * Sets the color of a vertex at a certain index.
		 * 
		 * @param vertexID
		 * @param color
		 */
		public function setVertexColor(vertexID:int, color:uint):void
		{
			_vertexData.setColor(vertexID, color);
		}
		
		
		/**
		 * Returns the alpha value of a vertex at a certain index.
		 * 
		 * @param vertexID
		 * @return Number
		 */
		public function getVertexAlpha(vertexID:int):Number
		{
			return _vertexData.getAlpha(vertexID);
		}
		
		
		/**
		 * Sets the alpha value of a vertex at a certain index.
		 * 
		 * @param vertexID
		 * @param alpha
		 */
		public function setVertexAlpha(vertexID:int, alpha:Number):void
		{
			_vertexData.setAlpha(vertexID, alpha);
		}
		
		
		/**
		 * Copies the raw vertex data to a VertexData instance.
		 * 
		 * @param targetData
		 * @param targetVertexID
		 */
		public function copyVertexDataTo(targetData:VertexData2D, targetVertexID:int = 0):void
		{
			_vertexData.copyTo(targetData, targetVertexID);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function renderWithSupport(support:Render2DRenderSupport, alpha:Number):void
		{
			support.batchQuad(this, alpha);
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
		}
	}
}
