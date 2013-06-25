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
	import tetragon.util.potrace.geom.CubicCurve;

	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.geom.Point;


	public class GraphicsDataBackend implements IBackend
	{
		protected var gd:Vector.<IGraphicsData>;
		protected var gp:GraphicsPath;


		public function GraphicsDataBackend(gd:Vector.<IGraphicsData>)
		{
			this.gd = gd;
			this.gp = new GraphicsPath();
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


		public function moveTo(a:Point):void
		{
			gp.moveTo(a.x, a.y);
		}


		public function addBezier(a:Point, cpa:Point, cpb:Point, b:Point):void
		{
			var cubic:CubicCurve = new CubicCurve();
			cubic.drawBezierPts(a, cpa, cpb, b);
			for (var i:int = 0; i < cubic.result.length; i++)
			{
				var quad:Vector.<Point> = cubic.result[i];
				gp.curveTo(quad[1].x, quad[1].y, quad[2].x, quad[2].y);
			}
		}


		public function addLine(a:Point, b:Point):void
		{
			gp.lineTo(b.x, b.y);
		}


		public function exitSubShape():void
		{
		}


		public function exitShape():void
		{
		}


		public function exit():void
		{
			gd.push(gp);
		}
	}
}
