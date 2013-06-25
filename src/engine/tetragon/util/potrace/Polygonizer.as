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
package tetragon.util.potrace
{
	import tetragon.core.types.PointInt;
	import tetragon.util.potrace.backend.PolygonDataBackend;

	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	
	/**
	 * Polygonizer
	 */
	public class Polygonizer
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _softening:int;
		private var _tolerance:int;
		private var _blurFilter:BlurFilter;
		private var _point:Point;
		
		private var _poTrace:POTrace;
		private var _poParams:POTraceParams;
		private var _poBackend:PolygonDataBackend;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param softening Higher values = fewer corners.
		 * @param tolerance Higher value = fewer points.
		 */
		public function Polygonizer(softening:int = 4, tolerance:int = 5)
		{
			_blurFilter = new BlurFilter(softening, softening, 3);
			_point = new Point(0, 0);
			
			_poParams = new POTraceParams();
			_poParams.alphaMax = 0;
			_poParams.threshold = 0x000000;
			_poParams.thresholdOperator = ">";
			_poParams.turdSize = 100;
			_poParams.curveOptimizing = true;
			_poParams.optTolerance = 100;
			
			_poBackend = new PolygonDataBackend(null, tolerance);
			_poTrace = new POTrace(_poParams, _poBackend);
			
			this.softening = softening;
			this.tolerance = tolerance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function polygonize(b:BitmapData):Vector.<PointInt>
		{
			if (!b) return null;
			
			_poBackend.points = new <PointInt>[];
			var clone:BitmapData = b.clone();
			clone.applyFilter(clone, clone.rect, _point, _blurFilter);
			_poTrace.trace(clone);
			return _poBackend.points;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get softening():int
		{
			return _softening;
		}
		public function set softening(v:int):void
		{
			if (v == _softening) return;
			_softening = v;
			_blurFilter.blurX = _blurFilter.blurY = _softening;
		}
		
		
		public function get tolerance():int
		{
			return _tolerance;
		}
		public function set tolerance(v:int):void
		{
			if (v == _tolerance) return;
			_tolerance = v;
			_poBackend.tolerance = _tolerance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
