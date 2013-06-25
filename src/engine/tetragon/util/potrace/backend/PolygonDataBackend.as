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
package tetragon.util.potrace.backend
{
	import tetragon.core.types.PointInt;

	import flash.geom.Point;


	public class PolygonDataBackend implements IBackend
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _points:Vector.<PointInt>;
		private var _tolerance:int;
		private var _startPoint:PointInt;
		private var _prevPoint:Point;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function PolygonDataBackend(points:Vector.<PointInt> = null, tolerance:int = 10)
		{
			_points = points;
			_tolerance = tolerance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function moveTo(p:Point):void
		{
			if (!_points) return;
			_startPoint = new PointInt(p.x, p.y);
			_points.push(_startPoint);
		}
		
		
		public function addLine(a:Point, b:Point):void
		{
			if (!_points) return;
			var newPoint:Point = new Point(int(b.x), int(b.y));
			if (!_prevPoint || Point.distance(newPoint, _prevPoint) >= _tolerance)
			{
				_points.push(new PointInt(newPoint.x, newPoint.y));
			}
			_prevPoint = newPoint;
		}
		
		
		public function exitShape():void
		{
			if (!_points) return;
			_points.push(_startPoint);
		}
		
		
		public function init(width:int, height:int):void
		{
		}
		public function initShape():void
		{
		}
		public function initSubShape(positive:Boolean):void
		{
		}
		public function addBezier(a:Point, cpa:Point, cpb:Point, b:Point):void
		{
		}
		public function exitSubShape():void
		{
		}
		public function exit():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get points():Vector.<PointInt>
		{
			return _points;
		}
		public function set points(v:Vector.<PointInt>):void
		{
			_points = v;
		}
		
		
		public function get tolerance():int
		{
			return _tolerance;
		}
		public function set tolerance(v:int):void
		{
			_tolerance = v;
		}
	}
}
