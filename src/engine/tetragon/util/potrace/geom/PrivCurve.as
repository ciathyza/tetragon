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
package tetragon.util.potrace.geom
{
	import flash.geom.Point;


	public class PrivCurve
	{
		public var n:int;
		public var tag:Vector.<int>;
		public var controlPoints:Vector.<Vector.<Point>>;
		public var vertex:Vector.<Point>;
		public var alpha:Vector.<Number>;
		public var alpha0:Vector.<Number>;
		public var beta:Vector.<Number>;


		public function PrivCurve(count:int)
		{
			// Number of segments
			n = count;

			// tag[n] = POTRACE_CORNER or POTRACE_CURVETO
			tag = new Vector.<int>(n);

			// c[n][i]: control points.
			// c[n][0] is unused for tag[n] = POTRACE_CORNER
			controlPoints = new Vector.<Vector.<Point>>(n);
			for (var i:int = 0; i < n; i++)
			{
				controlPoints[i] = new Vector.<Point>(3);
			}

			// for POTRACE_CORNER, this equals c[1].
			vertex = new Vector.<Point>(n);

			// only for POTRACE_CURVETO
			alpha = new Vector.<Number>(n);

			// for debug output only
			// "uncropped" alpha parameter
			alpha0 = new Vector.<Number>(n);

			beta = new Vector.<Number>(n);
		}
	}
}
