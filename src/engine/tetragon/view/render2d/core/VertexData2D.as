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
	import com.hexagonstar.util.geom.MatrixUtil;

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * The VertexData class manages a raw list of vertex information, allowing direct
	 * upload to Stage3D vertex buffers.
	 * <em>You only have to work with this class if you create display 
	 *  objects with a custom render function. If you don't plan to do that, you can safely 
	 *  ignore it.</em>
	 * <p>
	 * To render objects with Stage3D, you have to organize vertex data in so-called
	 * vertex buffers. Those buffers reside in graphics memory and can be accessed very
	 * efficiently by the GPU. Before you can move data into vertex buffers, you have to
	 * set it up in conventional memory - that is, in a Vector object. The vector contains
	 * all vertex information (the coordinates, color, and texture coordinates) - one
	 * vertex after the other.
	 * </p>
	 * <p>
	 * To simplify creating and working with such a bulky list, the VertexData class was
	 * created. It contains methods to specify and modify vertex data. The raw Vector
	 * managed by the class can then easily be uploaded to a vertex buffer.
	 * </p>
	 * <strong>Premultiplied Alpha</strong>
	 * <p>
	 * The color values of the "BitmapData" object contain premultiplied alpha values,
	 * which means that the <code>rgb</code> values were multiplied with the
	 * <code>alpha</code> value before saving them. Since textures are created from bitmap
	 * data, they contain the values in the same style. On rendering, it makes a
	 * difference in which way the alpha value is saved; for that reason, the VertexData
	 * class mimics this behavior. You can choose how the alpha values should be handled
	 * via the <code>premultipliedAlpha</code> property.
	 * </p>
	 */
	public class VertexData2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** The total number of elements (Numbers) stored per vertex. */
		public static const ELEMENTS_PER_VERTEX:int = 8;
		/** The offset of position data (x, y) within a vertex. */
		public static const POSITION_OFFSET:int = 0;
		/** The offset of color data (r, g, b, a) within a vertex. */
		public static const COLOR_OFFSET:int = 2;
		/** The offset of texture coordinate (u, v) within a vertex. */
		public static const TEXCOORD_OFFSET:int = 6;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _rawData:Vector.<Number>;
		private var _premultipliedAlpha:Boolean;
		private var _numVertices:int;
		
		/** Helper object. */
		private static var _helperPoint:Point = new Point();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/** Create a new VertexData object with a specified number of vertices. */
		public function VertexData2D(numVertices:int, premultipliedAlpha:Boolean = false)
		{
			_rawData = new <Number>[];
			_premultipliedAlpha = premultipliedAlpha;
			this.numVertices = numVertices;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/** Creates a duplicate of either the complete vertex data object, or of a subset. 
		 *  To clone all vertices, set 'numVertices' to '-1'. */
		public function clone(vertexID:int = 0, numVertices:int = -1):VertexData2D
		{
			if (numVertices < 0 || vertexID + numVertices > _numVertices)
				numVertices = _numVertices - vertexID;

			var clone:VertexData2D = new VertexData2D(0, _premultipliedAlpha);
			clone._numVertices = numVertices;
			clone._rawData = _rawData.slice(vertexID * ELEMENTS_PER_VERTEX, numVertices * ELEMENTS_PER_VERTEX);
			clone._rawData.fixed = true;
			return clone;
		}


		/** Copies the vertex data (or a range of it, defined by 'vertexID' and 'numVertices') 
		 *  of this instance to another vertex data object, starting at a certain index. */
		public function copyTo(targetData:VertexData2D, targetVertexID:int = 0, vertexID:int = 0, numVertices:int = -1):void
		{
			if (numVertices < 0 || vertexID + numVertices > _numVertices)
				numVertices = _numVertices - vertexID;

			// todo: check/convert pma

			var targetRawData:Vector.<Number> = targetData._rawData;
			var targetIndex:int = targetVertexID * ELEMENTS_PER_VERTEX;
			var sourceIndex:int = vertexID * ELEMENTS_PER_VERTEX;
			var dataLength:int = numVertices * ELEMENTS_PER_VERTEX;

			for (var i:int = sourceIndex; i < dataLength; ++i)
				targetRawData[int(targetIndex++)] = _rawData[i];
		}


		/** Appends the vertices from another VertexData object. */
		public function append(data:VertexData2D):void
		{
			_rawData.fixed = false;

			var targetIndex:int = _rawData.length;
			var rawData:Vector.<Number> = data._rawData;
			var rawDataLength:int = rawData.length;

			for (var i:int = 0; i < rawDataLength; ++i)
				_rawData[int(targetIndex++)] = rawData[i];

			_numVertices += data.numVertices;
			_rawData.fixed = true;
		}


		// functions
		/** Updates the position values of a vertex. */
		public function setPosition(vertexID:int, x:Number, y:Number):void
		{
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;
			_rawData[offset] = x;
			_rawData[int(offset + 1)] = y;
		}


		/** Returns the position of a vertex. */
		public function getPosition(vertexID:int, position:Point):void
		{
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;
			position.x = _rawData[offset];
			position.y = _rawData[int(offset + 1)];
		}


		/** Updates the RGB color values of a vertex. */
		public function setColor(vertexID:int, color:uint):void
		{
			var offset:int = getOffset(vertexID) + COLOR_OFFSET;
			var multiplier:Number = _premultipliedAlpha ? _rawData[int(offset + 3)] : 1.0;
			_rawData[offset] = ((color >> 16) & 0xff) / 255.0 * multiplier;
			_rawData[int(offset + 1)] = ((color >> 8) & 0xff) / 255.0 * multiplier;
			_rawData[int(offset + 2)] = ( color & 0xff) / 255.0 * multiplier;
		}


		/** Returns the RGB color of a vertex (no alpha). */
		public function getColor(vertexID:int):uint
		{
			var offset:int = getOffset(vertexID) + COLOR_OFFSET;
			var divisor:Number = _premultipliedAlpha ? _rawData[int(offset + 3)] : 1.0;

			if (divisor == 0) return 0;
			else
			{
				var red:Number = _rawData[offset] / divisor;
				var green:Number = _rawData[int(offset + 1)] / divisor;
				var blue:Number = _rawData[int(offset + 2)] / divisor;

				return (int(red * 255) << 16) | (int(green * 255) << 8) | int(blue * 255);
			}
		}


		/** Updates the alpha value of a vertex (range 0-1). */
		public function setAlpha(vertexID:int, alpha:Number):void
		{
			var offset:int = getOffset(vertexID) + COLOR_OFFSET + 3;

			if (_premultipliedAlpha)
			{
				if (alpha < 0.001) alpha = 0.001;
				// zero alpha would wipe out all color data
				var color:uint = getColor(vertexID);
				_rawData[offset] = alpha;
				setColor(vertexID, color);
			}
			else
			{
				_rawData[offset] = alpha;
			}
		}


		/** Returns the alpha value of a vertex in the range 0-1. */
		public function getAlpha(vertexID:int):Number
		{
			var offset:int = getOffset(vertexID) + COLOR_OFFSET + 3;
			return _rawData[offset];
		}


		/** Updates the texture coordinates of a vertex (range 0-1). */
		public function setTexCoords(vertexID:int, u:Number, v:Number):void
		{
			var offset:int = getOffset(vertexID) + TEXCOORD_OFFSET;
			_rawData[offset] = u;
			_rawData[int(offset + 1)] = v;
		}


		/** Returns the texture coordinates of a vertex in the range 0-1. */
		public function getTexCoords(vertexID:int, texCoords:Point):void
		{
			var offset:int = getOffset(vertexID) + TEXCOORD_OFFSET;
			texCoords.x = _rawData[offset];
			texCoords.y = _rawData[int(offset + 1)];
		}


		// utility functions
		/** Translate the position of a vertex by a certain offset. */
		public function translateVertex(vertexID:int, deltaX:Number, deltaY:Number):void
		{
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;
			_rawData[offset] += deltaX;
			_rawData[int(offset + 1)] += deltaY;
		}


		/** Transforms the position of subsequent vertices by multiplication with a 
		 *  transformation matrix. */
		public function transformVertex(vertexID:int, matrix:Matrix, numVertices:int = 1):void
		{
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;

			for (var i:int = 0; i < numVertices; ++i)
			{
				var x:Number = _rawData[offset];
				var y:Number = _rawData[int(offset + 1)];

				_rawData[offset] = matrix.a * x + matrix.c * y + matrix.tx;
				_rawData[int(offset + 1)] = matrix.d * y + matrix.b * x + matrix.ty;

				offset += ELEMENTS_PER_VERTEX;
			}
		}


		/** Sets all vertices of the object to the same color values. */
		public function setUniformColor(color:uint):void
		{
			for (var i:int = 0; i < _numVertices; ++i)
				setColor(i, color);
		}


		/** Sets all vertices of the object to the same alpha values. */
		public function setUniformAlpha(alpha:Number):void
		{
			for (var i:int = 0; i < _numVertices; ++i)
				setAlpha(i, alpha);
		}


		/** Multiplies the alpha value of subsequent vertices with a certain delta. */
		public function scaleAlpha(vertexID:int, alpha:Number, numVertices:int = 1):void
		{
			if (alpha == 1.0) return;
			if (numVertices < 0 || vertexID + numVertices > _numVertices)
				numVertices = _numVertices - vertexID;

			var i:int;

			if (_premultipliedAlpha)
			{
				for (i = 0; i < numVertices; ++i)
					setAlpha(vertexID + i, getAlpha(vertexID + i) * alpha);
			}
			else
			{
				var offset:int = getOffset(vertexID) + COLOR_OFFSET + 3;
				for (i = 0; i < numVertices; ++i)
					_rawData[int(offset + i * ELEMENTS_PER_VERTEX)] *= alpha;
			}
		}
		
		
		/** Calculates the bounds of the vertices, which are optionally transformed by a matrix. 
		 *  If you pass a 'resultRect', the result will be stored in this rectangle 
		 *  instead of creating a new object. To use all vertices for the calculation, set
		 *  'numVertices' to '-1'. */
		public function getBounds(transformationMatrix:Matrix = null, vertexID:int = 0, numVertices:int = -1, resultRect:Rectangle = null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			if (numVertices < 0 || vertexID + numVertices > _numVertices)
				numVertices = _numVertices - vertexID;

			var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;
			var x:Number, y:Number, i:int;

			if (transformationMatrix == null)
			{
				for (i = vertexID; i < numVertices; ++i)
				{
					x = _rawData[offset];
					y = _rawData[int(offset + 1)];
					offset += ELEMENTS_PER_VERTEX;

					minX = minX < x ? minX : x;
					maxX = maxX > x ? maxX : x;
					minY = minY < y ? minY : y;
					maxY = maxY > y ? maxY : y;
				}
			}
			else
			{
				for (i = vertexID; i < numVertices; ++i)
				{
					x = _rawData[offset];
					y = _rawData[int(offset + 1)];
					offset += ELEMENTS_PER_VERTEX;

					MatrixUtil.transformCoords(transformationMatrix, x, y, _helperPoint);
					minX = minX < _helperPoint.x ? minX : _helperPoint.x;
					maxX = maxX > _helperPoint.x ? maxX : _helperPoint.x;
					minY = minY < _helperPoint.y ? minY : _helperPoint.y;
					maxY = maxY > _helperPoint.y ? maxY : _helperPoint.y;
				}
			}

			resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
			return resultRect;
		}


		/** Changes the way alpha and color values are stored. Updates all exisiting vertices. */
		public function setPremultipliedAlpha(value:Boolean, updateData:Boolean = true):void
		{
			if (value == _premultipliedAlpha) return;

			if (updateData)
			{
				var dataLength:int = _numVertices * ELEMENTS_PER_VERTEX;

				for (var i:int = COLOR_OFFSET; i < dataLength; i += ELEMENTS_PER_VERTEX)
				{
					var alpha:Number = _rawData[int(i + 3)];
					var divisor:Number = _premultipliedAlpha ? alpha : 1.0;
					var multiplier:Number = value ? alpha : 1.0;

					if (divisor != 0)
					{
						_rawData[i] = _rawData[i] / divisor * multiplier;
						_rawData[int(i + 1)] = _rawData[int(i + 1)] / divisor * multiplier;
						_rawData[int(i + 2)] = _rawData[int(i + 2)] / divisor * multiplier;
					}
				}
			}

			_premultipliedAlpha = value;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/** Indicates if any vertices have a non-white color or are not fully opaque. */
		public function get tinted():Boolean
		{
			var offset:int = COLOR_OFFSET;

			for (var i:int = 0; i < _numVertices; ++i)
			{
				for (var j:int = 0; j < 4; ++j)
					if (_rawData[int(offset + j)] != 1.0) return true;

				offset += ELEMENTS_PER_VERTEX;
			}

			return false;
		}
		
		
		/** Indicates if the rgb values are stored premultiplied with the alpha value. */
		public function get premultipliedAlpha():Boolean
		{
			return _premultipliedAlpha;
		}


		/** The total number of vertices. */
		public function get numVertices():int
		{
			return _numVertices;
		}
		public function set numVertices(v:int):void
		{
			_rawData.fixed = false;
			var i:int, delta:int = v - _numVertices;
			for (i = 0; i < delta; ++i)
			{
				_rawData.push(0, 0, 0, 0, 0, 1, 0, 0); // alpha should be '1' per default
			}
			for (i = 0; i < -(delta * ELEMENTS_PER_VERTEX); ++i)
			{
				_rawData.pop();
			}
			_numVertices = v;
			_rawData.fixed = true;
		}
		
		
		/** The raw vertex data; not a copy! */
		public function get rawData():Vector.<Number>
		{
			return _rawData;
		}
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function getOffset(vertexID:int):int
		{
			return vertexID * ELEMENTS_PER_VERTEX;
		}
	}
}
