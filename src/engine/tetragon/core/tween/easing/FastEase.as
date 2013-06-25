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
package tetragon.core.tween.easing
{
	import tetragon.core.tween.Tween;


	/**
	 * TweenMax (AS3 only) has built-in algorithms that speed up the processing of certain
	 * easing equations but in order to take advantage of those optimizations, you must
	 * activate the easing equations first (you only need to activate them ONCE in your
	 * swf). The following easing equations from the com.greensock.easing package are
	 * eligible for activation: <code> <ul> <li>Linear (easeIn, easeOut, easeInOut, and
	 * easeNone)</li> <li>Quad (easeIn, easeOut, and easeInOut)</li> <li>Cubic (easeIn,
	 * easeOut, and easeInOut)</li> <li>Quart (easeIn, easeOut, and easeInOut)</li>
	 * <li>Quint (easeIn, easeOut, and easeInOut)</li> <li>Strong (easeIn, easeOut, and
	 * easeInOut)</li> </ul><br /> </code>
	 * 
	 * <b>EXAMPLE</b><br /><br />
	 * 
	 * <code> import com.greensock.easing.*;<br /><br />
	 * 
	 * // activate the optimized ease classes<br /> FastEase.activate([Strong, Linear,
	 * Quad]);<br /><br />
	 * 
	 * // then tween as usual (you don't have to do anything special in your tweens)<br />
	 * TweenMax.to(mc, 2, {x:200, ease:Linear.easeNone});<br /><br /> </code>
	 * 
	 * Once activated, the easing calculations run about <b>35-80% faster!</b> Keep in
	 * mind that the easing calculations are only one small part of the tweening engine,
	 * so you may only see a 2-15% improvement overall depending on the equation and
	 * quantity of simultaneous tweens.
	 * 
	 * Notes: <br /> <ul> <li>TweenLite does <b>NOT</b> have the internal algorithms in
	 * place to take advantage of optimized eases at this time (to conserve file
	 * size).</li> <li>Activating an ease multiple times doesn't hurt or help</li> </ul>
	 * 
	 * @param easeClasses An Array containing the easing classes to activate, like
	 *            [Strong, Linear, Quad]. It will automatically activate the easeIn,
	 *            easeOut, easeInOut, and (if available) easeNone easing equations for
	 *            each class in the Array.
	 */
	public final class FastEase
	{
		/**
		 * Normally you should use the <code>FastEase.activate()</code> method to activate
		 * optimized eases, but if you want to activate an ease that is NOT in the
		 * com.greensock.easing package (for example
		 * <code>fl.motion.easing.Quadratic</code>), you can register individual easing
		 * equations with this method. For example:
		 * 
		 * <code> import fl.motion.easing.Quadratic;<br /> import
		 * com.greensock.easing.FastEase;<br /><br />
		 * 
		 * FastEase.activateEase(Quadratic.easeIn, 1, 1); </code>
		 * 
		 * @param ease The easing equation (function) to activate. For example,
		 *            Quadratic.easeIn
		 * @param type The type of ease (in, out, or inOut) where easeIn is 1, easeOut is
		 *            2, and easeInOut is 3.
		 * @param power The magnitude or power of the ease. For example, Linear is 0, Quad
		 *            is 1, Cubic is 2, Quart is 3 and Quint and Strong are 4.
		 */
		public static function activateEase(ease:Function, type:int, power:uint):void
		{
			Tween.fastEaseLookup[ease] = [type, power];
		}
		
		
		/**
		 * TweenMax (AS3 only) has built-in algorithms that speed up the processing of certain
		 * easing equations but in order to take advantage of those optimizations, you must
		 * activate the easing equations first (you only need to activate them ONCE in your
		 * swf). The following easing equations from the com.greensock.easing package are
		 * eligible for activation: <code> <ul> <li>Linear (easeIn, easeOut, easeInOut, and
		 * easeNone)</li> <li>Quad (easeIn, easeOut, and easeInOut)</li> <li>Cubic (easeIn,
		 * easeOut, and easeInOut)</li> <li>Quart (easeIn, easeOut, and easeInOut)</li>
		 * <li>Quint (easeIn, easeOut, and easeInOut)</li> <li>Strong (easeIn, easeOut, and
		 * easeInOut)</li> </ul><br /> </code>
		 * 
		 * <b>EXAMPLE</b><br /><br />
		 * 
		 * <code> import com.greensock.easing.*;<br /><br />
		 * 
		 * FastEase.activate([Strong, Linear, Quad]);<br /><br /> </code>
		 * 
		 * Notes: <br /> <ul> <li>TweenLite does <b>NOT</b> have the internal algorithms in
		 * place to take advantage of optimized eases at this time (to conserve file
		 * size).</li> <li>Activating an ease multiple times doesn't hurt or help</li> </ul>
		 * 
		 * @param easeClasses An Array containing the easing classes to activate, like
		 *            [Strong, Linear, Quad]. It will automatically activate the easeIn,
		 *            easeOut, easeInOut, and (if available) easeNone easing equations for
		 *            each class in the Array.
		 */
		public static function activate(easeClasses:Array):void
		{
			var i:int = easeClasses.length, easeClass:Object;
			while (i--)
			{
				easeClass = easeClasses[i];
				if (easeClass.hasOwnProperty("POWER"))
				{
					activateEase(easeClass['easeIn'], 1, easeClass['POWER']);
					activateEase(easeClass['easeOut'], 2, easeClass['POWER']);
					activateEase(easeClass['easeInOut'], 3, easeClass['POWER']);
					if (easeClass.hasOwnProperty("easeNone"))
					{
						activateEase(easeClass['easeNone'], 1, 0);
					}
				}
			}
		}
	}
}
