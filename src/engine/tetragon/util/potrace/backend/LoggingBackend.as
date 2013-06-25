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
	import tetragon.debug.Log;

	import flash.geom.Point;


	public class LoggingBackend implements IBackend
	{
		public function init(width:int, height:int):void
		{
			Log.trace("Canvas width:" + width + ", height:" + height, this);
		}


		public function initShape():void
		{
			Log.trace("  Shape", this);
		}


		public function initSubShape(positive:Boolean):void
		{
			Log.trace("    SubShape positive:" + positive, this);
		}


		public function moveTo(a:Point):void
		{
			Log.trace("      MoveTo a:" + a, this);
		}


		public function addBezier(a:Point, cpa:Point, cpb:Point, b:Point):void
		{
			Log.trace("      Bezier a:" + a + ", cpa:" + cpa + ", cpb:" + cpb + ", b:" + b, this);
		}


		public function addLine(a:Point, b:Point):void
		{
			Log.trace("      Line a:" + a + ", b:" + b, this);
		}


		public function exitSubShape():void
		{
		}


		public function exitShape():void
		{
		}


		public function exit():void
		{
		}
	}
}
