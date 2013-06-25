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
package tetragon.util.tween.easing
{
	/**
	 * Most easing equations give a smooth, gradual transition between the start and end values, but SteppedEase provides
	 * an easy way to define a specific number of steps that the transition should take. For example, if mc.x is 0 and you 
	 * want to tween it to 100 with 5 steps (20, 40, 60, 80, and 100) over the course of 2 seconds, you'd do:<br /><br /><code>
	 * 
	 * TweenLite.to(mc, 2, {x:100, ease:SteppedEase.create(5)});<br /><br /></code>
	 * 
	 * <b>EXAMPLE CODE</b><br /><br /><code>
	 * import com.greensock.TweenLite;<br />
	 * import com.greensock.easing.SteppedEase;<br /><br />
	 * 
	 * TweenLite.to(mc, 2, {x:100, ease:SteppedEase.create(5)});<br /><br />
	 * 
	 * // or create an instance directly<br />
	 * var steppedEase:SteppedEase = new SteppedEase(5);<br />
	 * TweenLite.to(mc, 3, {y:300, ease:steppedEase.ease});
	 * </code><br /><br />
	 * 
	 * Note: SteppedEase is optimized for use with the GreenSock tweenining platform, so it isn't intended to be used with other engines. 
	 * Specifically, its easing equation always returns values between 0 and 1.<br /><br />
	 * 
	 * <b>Copyright 2011, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
	 * 
	 * @author Jack Doyle, jack@greensock.com
	 */
	public final class SteppedEase
	{
		/** @private **/
		private var _steps:int;
		/** @private **/
		private var _stepAmount:Number;


		/**
		 * Constructor
		 * 
		 * @param steps Number of steps between the start and the end values. 
		 */
		public function SteppedEase(steps:int)
		{
			_stepAmount = 1 / steps;
			_steps = steps + 1;
		}


		/**
		 * This static function provides a quick way to create a SteppedEase and immediately reference its ease function 
		 * in a tween, like:<br /><br /><code>
		 * 
		 * TweenLite.to(mc, 2, {x:100, ease:SteppedEase.create(5)});<br />
		 * </code>
		 * 
		 * @param steps Number of steps between the start and the end values. 
		 * @return The easing function that can be plugged into a tween
		 */
		public static function create(steps:int):Function
		{
			var se:SteppedEase = new SteppedEase(steps);
			return se.ease;
		}


		/**
		 * Easing function that interpolates values. 
		 * 
		 * @param t time
		 * @param b start (should always be 0)
		 * @param c change (should always be 1)
		 * @param d duration
		 * @return Result of the ease
		 */
		public function ease(t:Number, b:Number, c:Number, d:Number):Number
		{
			var ratio:Number = t / d;
			if (ratio < 0)
			{
				ratio = 0;
			}
			else if (ratio >= 1)
			{
				ratio = 0.999999999;
			}
			return ((_steps * ratio) >> 0) * _stepAmount;
		}


		/** Number of steps between the start and the end values. **/
		public function get steps():int
		{
			return _steps - 1;
		}
	}
}
