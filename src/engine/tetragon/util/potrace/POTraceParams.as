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
package tetragon.util.potrace
{
	public class POTraceParams
	{
		// For a detailed description of all parameters, see:
		// http://potrace.sourceforge.net/potracelib.pdf
		// Note that differing from the original, the
		// curveOptimizing parameter is set to false here.
		public function POTraceParams(threshold:uint = 0x888888, thresholdOperator:String = "<=", turdSize:int = 2, alphaMax:Number = 1, curveOptimizing:Boolean = false, optTolerance:Number = 0.2)
		{
			this.threshold = threshold;
			this.thresholdOperator = thresholdOperator;
			this.turdSize = turdSize;
			this.alphaMax = alphaMax;
			this.curveOptimizing = curveOptimizing;
			this.optTolerance = optTolerance;
		}


		// Color value for threshold filter applied to bitmap before processing.
		// Defaults to 0x888888
		public var threshold:uint;
		// The operator to use when the threshold is applied (ex. "<=", ">", etc).
		// Defaults to "<="
		public var thresholdOperator:String;
		// Area of largest path to be ignored (in pixels)
		// Defaults to 2
		public var turdSize:int;
		// Corner threshold, controls the smoothness of the curve.
		// The useful range of this parameter is from 0 (polygon) to 1.3333 (no corners).
		// Defaults to 1
		public var alphaMax:Number;
		// Whether to optimize curves or not.
		// Replace sequences of Bezier segments by a single segment when possible.
		// Defaults to false
		public var curveOptimizing:Boolean;
		// Curve optimizing tolerance
		// Larger values tend to decrease the number of segments, at the expense of less accuracy.
		// The useful range is from 0 to infinty, although in practice one would hardly choose values greater than 1 or so.
		// Defaults to 0.2
		public var optTolerance:Number;
	}
}
