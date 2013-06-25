/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.types
{
	import flash.geom.Point;

	public class Vector2D
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		public var x:Number;
		public var y:Number;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		function Vector2D(x:Number = 0, y:Number = 0)
		{
			this.x = x;
			this.y = y;
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		public function scale(value:Number):void
		{
			x *= value;
			y *= value;
		}
		
		
		public function addEquals(vector:Vector2D):void
		{
			x += vector.x;
			y += vector.y;
		}
		
		
		public function add(vector:Vector2D):Vector2D
		{
			return new Vector2D(x + vector.x, y + vector.y);
		}
		
		
		public function subtract(vector:Vector2D):Vector2D
		{
			return new Vector2D(x - vector.x, y - vector.y);
		}
		
		
		public function multiply(value:Number):Vector2D
		{
			return new Vector2D(x * value, y * value);
		}
		
		
		public function dotProduct(vector:Vector2D):Number
		{
			var normal:Vector2D = vector.normal;
			return x * normal.x + y * normal.y;
		}
		
		
		public function project(vector:Vector2D):Vector2D
		{
			var dp:Number = dotProduct(vector);
			var normal:Vector2D = vector.normal;
			return new Vector2D(dp * normal.x, dp * normal.y);
		}
		
		
		public function orientate(vector:Vector2D):Vector2D
		{
			var rightNormal:Vector2D = vector.rightHandNormal;
			var xVector:Vector2D = new Vector2D(vector.x * y, vector.y * y);
			var yVector:Vector2D = new Vector2D(rightNormal.x * x, rightNormal.y * y);
			return xVector.add(yVector);
		}
		
		
		public function clone():Vector2D
		{
			return new Vector2D(x, y);
		}
		
		
		public function toPoint():Point
		{
			return new Point(x, y);
		}
		
		
		public function toString():String
		{
			return "[Vector2D, x=" + x + ", y=" + y + "]";
		}
		
		
		public static function generate(angle:Number, size:Number):Vector2D
		{
			var rad:Number = degToRad(angle);
			return new Vector2D(Math.cos(rad) * -size, Math.sin(rad) * -size);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Getters & Setters
		// -----------------------------------------------------------------------------------------
		
		public function get length():Number
		{
			return Math.sqrt(x * x + y * y);
		}
		
		
		public function get normal():Vector2D
		{
			var s:Number = length;
			if (s > 0) return new Vector2D(x / s, y / s);
			else return new Vector2D(0, 0);
		}
		
		
		public function get leftHandNormal():Vector2D
		{
			return new Vector2D(y, -x);
		}
		
		
		public function get rightHandNormal():Vector2D
		{
			return new Vector2D(-y, x);
		}
		
		
		public function get angle():Number
		{
			return radToDeg(Math.atan2(x, y));
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		
		protected static function radToDeg(rad:Number):Number
		{
			return rad * 180 / Math.PI;
		}
		
		
		protected static function degToRad(deg:Number):Number
		{
			return deg * Math.PI / 180;
		}
	}
}
