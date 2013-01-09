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
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;


	/**
	 * The VertexData class manages a raw list of vertex information, allowing direct
	 * upload to Stage3D vertex buffers.
	 * <em>You only have to work with this class if you create display 
	 *  objects with a custom render function. If you don't plan to do that, you can safely 
	 *  ignore it.</em>
	 * 
	 * <p>
	 * To render objects with Stage3D, you have to organize vertex data in so-called
	 * vertex buffers. Those buffers reside in graphics memory and can be accessed very
	 * efficiently by the GPU. Before you can move data into vertex buffers, you have to
	 * set it up in conventional memory - that is, in a Vector object. The vector contains
	 * all vertex information (the coordinates, color, and texture coordinates) - one
	 * vertex after the other.
	 * </p>
	 * 
	 * <p>
	 * To simplify creating and working with such a bulky list, the VertexData class was
	 * created. It contains methods to specify and modify vertex data. The raw Vector
	 * managed by the class can then easily be uploaded to a vertex buffer.
	 * </p>
	 * 
	 * <strong>Premultiplied Alpha</strong>
	 * 
	 * <p>
	 * The color values of the "BitmapData" object contain premultiplied alpha values,
	 * which means that the <code>rgb</code> values were multiplied with the
	 * <code>alpha</code> value before saving them. Since textures are created from bitmap
	 * data, they contain the values in the same style. On rendering, it makes a
	 * difference in which way the alpha value is saved; for that reason, the VertexData
	 * class mimics this behavior. You can choose how the alpha values should be handled
	 * via the <code>premultipliedAlpha</code> property.
	 * </p>
	 * 
	 * <p>
	 * <em>Note that vertex data with premultiplied alpha values will lose all <code>rgb</code>
	 *  information of a vertex with a zero <code>alpha</code> value.</em>
	 * </p>
	 */
	public class VertexData2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** The total number of elements (Numbers) stored per vertex. */
		public static const ELEMENTS_PER_VERTEX:int = 9;
		/** The offset of position data (x, y) within a vertex. */
		public static const POSITION_OFFSET:int = 0;
		/** The offset of color data (r, g, b, a) within a vertex. */
		public static const COLOR_OFFSET:int = 3;
		/** The offset of texture coordinate (u, v) within a vertex. */
		public static const TEXCOORD_OFFSET:int = 7;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _rawData:Vector.<Number>;
		/** @private */
		private var _premultipliedAlpha:Boolean;
		/** @private */
		private var _numVertices:int;
		
		/* Helper object. */
		private static var _positions:Vector.<Number> = new Vector.<Number>(12, true);
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Create a new VertexData object with a specified number of vertices.
		 * 
		 * @param numVertices
		 * @param premultipliedAlpha
		 */
		public function VertexData2D(numVertices:int, premultipliedAlpha:Boolean = false)
		{
			_rawData = new Vector.<Number>(numVertices * ELEMENTS_PER_VERTEX, true);
			_numVertices = numVertices;
			_premultipliedAlpha = premultipliedAlpha;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a duplicate of the vertex data object.
		 */
		public function clone():VertexData2D
		{
			var clone:VertexData2D = new VertexData2D(0, _premultipliedAlpha);
			clone._rawData = _rawData.concat();
			clone._rawData.fixed = true;
			clone._numVertices = _numVertices;
			return clone;
		}
		
		
		/**
		 * Copies the vertex data of this instance to another vertex data object,
		 * starting at a certain index.
		 * 
		 * @param targetData
		 * @param targetVertexID
		 */
		public function copyTo(targetData:VertexData2D, targetVertexID:int = 0):void
		{
			// todo: check/convert pma
			var targetRawData:Vector.<Number> = targetData._rawData;
			var dataLength:int = _numVertices * ELEMENTS_PER_VERTEX;
			var targetStartIndex:int = targetVertexID * ELEMENTS_PER_VERTEX;
			
			for (var i:int = 0; i < dataLength; ++i)
			{
				targetRawData[int(targetStartIndex + i)] = _rawData[i];
			}
		}
		
		
		/**
		 * Appends the vertices from another VertexData object.
		 * 
		 * @param data
		 */
		public function append(data:VertexData2D):void
		{
			_rawData.fixed = false;
			var rawData:Vector.<Number> = data._rawData;
			var rawDataLength:int = rawData.length;
			
			for (var i:int = 0; i < rawDataLength; ++i)
			{
				_rawData.push(rawData[i]);
			}
			
			_numVertices += data.numVertices;
			_rawData.fixed = true;
		}
		
		
		/**
		 * Updates the position values of a vertex.
		 * 
		 * @param vertexID
		 * @param x
		 * @param y
		 * @param z
		 */
		public function setPosition(vertexID:int, x:Number, y:Number, z:Number = 0.0):void
		{
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;
			_rawData[offset] = x;
			_rawData[int(offset + 1)] = y;
			_rawData[int(offset + 2)] = z;
		}
		
		
		/**
		 * Returns the position of a vertex.
		 * 
		 * @param vertexID
		 * @param position
		 */
		public function getPosition(vertexID:int, position:Vector3D):void
		{
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;
			position.x = _rawData[offset];
			position.y = _rawData[int(offset + 1)];
			position.z = _rawData[int(offset + 2)];
		}
		
		
		/**
		 * Updates the color and alpha values of a vertex.
		 * 
		 * @param vertexID
		 * @param color
		 * @param alpha
		 */
		public function setColor(vertexID:int, color:uint, alpha:Number = 1.0):void
		{
			var multiplier:Number = _premultipliedAlpha ? alpha : 1.0;
			var offset:int = getOffset(vertexID) + COLOR_OFFSET;
			_rawData[offset] = ((color >> 16) & 0xff) / 255.0 * multiplier;
			_rawData[int(offset + 1)] = ((color >> 8) & 0xff) / 255.0 * multiplier;
			_rawData[int(offset + 2)] = ( color & 0xff) / 255.0 * multiplier;
			_rawData[int(offset + 3)] = alpha;
		}
		
		
		/**
		 * Returns the RGB color of a vertex (no alpha).
		 * 
		 * @param vertexID
		 * @return uint
		 */
		public function getColor(vertexID:int):uint
		{
			var offset:int = getOffset(vertexID) + COLOR_OFFSET;
			var divisor:Number = _premultipliedAlpha ? _rawData[offset + 3] : 1.0;
			if (divisor == 0)
			{
				return 0;
			}
			else
			{
				var r:Number = _rawData[offset] / divisor;
				var g:Number = _rawData[int(offset + 1)] / divisor;
				var b:Number = _rawData[int(offset + 2)] / divisor;
				return (int(r * 255) << 16) | (int(g * 255) << 8) | int(b * 255);
			}
		}
		
		
		/**
		 * Updates the alpha value of a vertex (range 0-1).
		 * 
		 * @param vertexID
		 * @param alpha
		 */
		public function setAlpha(vertexID:int, alpha:Number):void
		{
			if (_premultipliedAlpha)
			{
				setColor(vertexID, getColor(vertexID), alpha);
			}
			else
			{
				var offset:int = getOffset(vertexID) + COLOR_OFFSET + 3;
				_rawData[offset] = alpha;
			}
		}
		
		
		/**
		 * Returns the alpha value of a vertex in the range 0-1.
		 * 
		 * @param vertexID
		 * @return Number
		 */
		public function getAlpha(vertexID:int):Number
		{
			var offset:int = getOffset(vertexID) + COLOR_OFFSET + 3;
			return _rawData[offset];
		}
		
		
		/**
		 * Updates the texture coordinates of a vertex (range 0-1).
		 * 
		 * @param vertexID
		 * @param u
		 * @param v
		 */
		public function setTexCoords(vertexID:int, u:Number, v:Number):void
		{
			var offset:int = getOffset(vertexID) + TEXCOORD_OFFSET;
			_rawData[offset] = u;
			_rawData[int(offset + 1)] = v;
		}
		
		
		/**
		 * Returns the texture coordinates of a vertex in the range 0-1.
		 * 
		 * @param vertexID
		 * @param texCoords
		 */
		public function getTexCoords(vertexID:int, texCoords:Point):void
		{
			var offset:int = getOffset(vertexID) + TEXCOORD_OFFSET;
			texCoords.x = _rawData[offset];
			texCoords.y = _rawData[int(offset + 1)];
		}
		
		
		/**
		 * Translates the position of a vertex by a certain offset.
		 * 
		 * @param vertexID
		 * @param deltaX
		 * @param deltaY
		 * @param deltaZ
		 */
		public function translateVertex(vertexID:int, deltaX:Number, deltaY:Number, deltaZ:Number = 0.0):void
		{
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;
			_rawData[offset] += deltaX;
			_rawData[int(offset + 1)] += deltaY;
			_rawData[int(offset + 2)] += deltaZ;
		}
		
		
		/**
		 * Transforms the position of subsequent vertices by multiplication with a 
		 * transformation matrix.
		 * 
		 * @param vertexID
		 * @param matrix
		 * @param numVertices
		 */
		public function transformVertex(vertexID:int, matrix:Matrix3D, numVertices:int = 1):void
		{
			var i:int;
			var offset:int = getOffset(vertexID) + POSITION_OFFSET;
			
			for (i = 0; i < numVertices; ++i)
			{
				_positions[int(3 * i)] = _rawData[offset];
				_positions[int(3 * i + 1)] = _rawData[int(offset + 1)];
				_positions[int(3 * i + 2)] = _rawData[int(offset + 2)];
				offset += ELEMENTS_PER_VERTEX;
			}
			
			matrix.transformVectors(_positions, _positions);
			offset -= ELEMENTS_PER_VERTEX * numVertices;
			
			for (i = 0; i < numVertices; ++i)
			{
				_rawData[offset] = _positions[int(3 * i)];
				_rawData[int(offset + 1)] = _positions[int(3 * i + 1)];
				_rawData[int(offset + 2)] = _positions[int(3 * i + 2)];
				offset += ELEMENTS_PER_VERTEX;
			}
		}
		
		
		/**
		 * Sets all vertices of the object to the same color and alpha values.
		 * 
		 * @param color
		 * @param alpha
		 */
		public function setUniformColor(color:uint, alpha:Number = 1.0):void
		{
			for (var i:int = 0; i < _numVertices; ++i)
			{
				setColor(i, color, alpha);
			}
		}
		
		
		/**
		 * Multiplies the alpha value of subsequent vertices with a certain delta.
		 * 
		 * @param vertexID
		 * @param alpha
		 * @param numVertices
		 */
		public function scaleAlpha(vertexID:int, alpha:Number, numVertices:int = 1):void
		{
			var i:int;
			
			if (alpha == 1.0)
			{
				return;
			}
			else if (_premultipliedAlpha)
			{
				for (i = 0; i < numVertices; ++i)
				{
					setColor(vertexID + i, getColor(vertexID + i), getAlpha(vertexID + i) * alpha);
				}
			}
			else
			{
				var offset:int = getOffset(vertexID) + COLOR_OFFSET + 3;
				for (i = 0; i < numVertices; ++i)
				{
					_rawData[int(offset + i * ELEMENTS_PER_VERTEX)] *= alpha;
				}
			}
		}
		
		
		/**
		 * Changes the way alpha and color values are stored. Updates all exisiting vertices.
		 * 
		 * @param flag
		 * @param updateData
		 */
		public function setPremultipliedAlpha(flag:Boolean, updateData:Boolean = true):void
		{
			if (flag == _premultipliedAlpha) return;
			
			if (updateData)
			{
				var dataLength:int = _numVertices * ELEMENTS_PER_VERTEX;
				
				for (var i:int = COLOR_OFFSET; i < dataLength; i += ELEMENTS_PER_VERTEX)
				{
					var alpha:Number = _rawData[i + 3];
					var divisor:Number = _premultipliedAlpha ? alpha : 1.0;
					var multiplier:Number = flag ? alpha : 1.0;
					
					if (divisor != 0)
					{
						_rawData[i] = _rawData[i] / divisor * multiplier;
						_rawData[int(i + 1)] = _rawData[int(i + 1)] / divisor * multiplier;
						_rawData[int(i + 2)] = _rawData[int(i + 2)] / divisor * multiplier;
					}
				}
			}
			
			_premultipliedAlpha = flag;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if the rgb values are stored premultiplied with the alpha value.
		 */
		public function get premultipliedAlpha():Boolean
		{
			return _premultipliedAlpha;
		}
		
		
		/**
		 * The total number of vertices.
		 */
		public function get numVertices():int
		{
			return _numVertices;
		}
		public function set numVertices(v:int):void
		{
			_rawData.fixed = false;
			var delta:int = v * ELEMENTS_PER_VERTEX - _rawData.length;
			var i:int;
			for (i = 0; i < delta; ++i) _rawData.push(0.0);
			for (i = delta; i < 0; ++i) _rawData.pop();
			_numVertices = v;
			_rawData.fixed = true;
		}
		
		
		/**
		 * The raw vertex data; not a copy!
		 */
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
