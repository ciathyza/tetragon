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
	import com.hexagonstar.exception.AbstractClassException;


	/**
	 * The Transitions class contains static methods that define easing functions. Those
	 * functions will be used by the Tween class to execute animations.
	 * 
	 * Find a visual representation of the transitions at this <a href=
	 * "http://www.sparrow-framework.org/wp-content/uploads/2010/06/transitions.png"
	 * >link</a>.
	 * 
	 * <p>
	 * You can define your own transitions through the "registerTransition" function. A
	 * transition function must have the following signature, where <code>ratio</code> is
	 * in the range 0-1:
	 * </p>
	 * 
	 * <pre>
	 * function myTransition(ratio:Number):Number
	 * </pre>
	 */
	public class Transitions2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const LINEAR:String = "linear";
		public static const EASE_IN:String = "easeIn";
		public static const EASE_OUT:String = "easeOut";
		public static const EASE_IN_OUT:String = "easeInOut";
		public static const EASE_OUT_IN:String = "easeOutIn";
		public static const EASE_IN_BACK:String = "easeInBack";
		public static const EASE_OUT_BACK:String = "easeOutBack";
		public static const EASE_IN_OUT_BACK:String = "easeInOutBack";
		public static const EASE_OUT_IN_BACK:String = "easeOutInBack";
		public static const EASE_IN_ELASTIC:String = "easeInElastic";
		public static const EASE_OUT_ELASTIC:String = "easeOutElastic";
		public static const EASE_IN_OUT_ELASTIC:String = "easeInOutElastic";
		public static const EASE_OUT_IN_ELASTIC:String = "easeOutInElastic";
		public static const EASE_IN_BOUNCE:String = "easeInBounce";
		public static const EASE_OUT_BOUNCE:String = "easeOutBounce";
		public static const EASE_IN_OUT_BOUNCE:String = "easeInOutBounce";
		public static const EASE_OUT_IN_BOUNCE:String = "easeOutInBounce";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _transitions:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function Transitions2D()
		{
			throw new AbstractClassException(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a new transition function under a certain name.
		 * 
		 * @param name
		 * @param func
		 */
		public static function registerTransition(name:String, func:Function):void
		{
			if (!_transitions) registerDefaultTransitions();
			_transitions[name] = func;
		}
		
		
		/**
		 * Returns the transition function that was registered under a certain name.
		 * 
		 * @param name
		 * @return Function
		 */
		public static function getTransition(name:String):Function
		{
			if (!_transitions) registerDefaultTransitions();
			return _transitions[name];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function registerDefaultTransitions():void
		{
			_transitions = {};
			
			registerTransition(LINEAR, linear);
			registerTransition(EASE_IN, easeIn);
			registerTransition(EASE_OUT, easeOut);
			registerTransition(EASE_IN_OUT, easeInOut);
			registerTransition(EASE_OUT_IN, easeOutIn);
			registerTransition(EASE_IN_BACK, easeInBack);
			registerTransition(EASE_OUT_BACK, easeOutBack);
			registerTransition(EASE_IN_OUT_BACK, easeInOutBack);
			registerTransition(EASE_OUT_IN_BACK, easeOutInBack);
			registerTransition(EASE_IN_ELASTIC, easeInElastic);
			registerTransition(EASE_OUT_ELASTIC, easeOutElastic);
			registerTransition(EASE_IN_OUT_ELASTIC, easeInOutElastic);
			registerTransition(EASE_OUT_IN_ELASTIC, easeOutInElastic);
			registerTransition(EASE_IN_BOUNCE, easeInBounce);
			registerTransition(EASE_OUT_BOUNCE, easeOutBounce);
			registerTransition(EASE_IN_OUT_BOUNCE, easeInOutBounce);
			registerTransition(EASE_OUT_IN_BOUNCE, easeOutInBounce);
		}
		
		
		/**
		 * @private
		 */
		private static function linear(ratio:Number):Number
		{
			return ratio;
		}


		/**
		 * @private
		 */
		private static function easeIn(ratio:Number):Number
		{
			return ratio * ratio * ratio;
		}


		/**
		 * @private
		 */
		private static function easeOut(ratio:Number):Number
		{
			var invRatio:Number = ratio - 1.0;
			return invRatio * invRatio * invRatio + 1;
		}


		/**
		 * @private
		 */
		private static function easeInOut(ratio:Number):Number
		{
			return easeCombined(easeIn, easeOut, ratio);
		}


		/**
		 * @private
		 */
		private static function easeOutIn(ratio:Number):Number
		{
			return easeCombined(easeOut, easeIn, ratio);
		}


		/**
		 * @private
		 */
		private static function easeInBack(ratio:Number):Number
		{
			var s:Number = 1.70158;
			return Math.pow(ratio, 2) * ((s + 1.0) * ratio - s);
		}


		/**
		 * @private
		 */
		private static function easeOutBack(ratio:Number):Number
		{
			var invRatio:Number = ratio - 1.0;
			var s:Number = 1.70158;
			return Math.pow(invRatio, 2) * ((s + 1.0) * invRatio + s) + 1.0;
		}


		/**
		 * @private
		 */
		private static function easeInOutBack(ratio:Number):Number
		{
			return easeCombined(easeInBack, easeOutBack, ratio);
		}


		/**
		 * @private
		 */
		private static function easeOutInBack(ratio:Number):Number
		{
			return easeCombined(easeOutBack, easeInBack, ratio);
		}


		/**
		 * @private
		 */
		private static function easeInElastic(ratio:Number):Number
		{
			if (ratio == 0 || ratio == 1) return ratio;
			else
			{
				var p:Number = 0.3;
				var s:Number = p / 4.0;
				var invRatio:Number = ratio - 1;
				return -1.0 * Math.pow(2.0, 10.0 * invRatio) * Math.sin((invRatio - s) * (2.0 * Math.PI) / p);
			}
		}


		/**
		 * @private
		 */
		private static function easeOutElastic(ratio:Number):Number
		{
			if (ratio == 0 || ratio == 1) return ratio;
			else
			{
				var p:Number = 0.3;
				var s:Number = p / 4.0;
				return Math.pow(2.0, -10.0 * ratio) * Math.sin((ratio - s) * (2.0 * Math.PI) / p) + 1;
			}
		}


		/**
		 * @private
		 */
		private static function easeInOutElastic(ratio:Number):Number
		{
			return easeCombined(easeInElastic, easeOutElastic, ratio);
		}


		/**
		 * @private
		 */
		private static function easeOutInElastic(ratio:Number):Number
		{
			return easeCombined(easeOutElastic, easeInElastic, ratio);
		}


		/**
		 * @private
		 */
		private static function easeInBounce(ratio:Number):Number
		{
			return 1.0 - easeOutBounce(1.0 - ratio);
		}


		/**
		 * @private
		 */
		private static function easeOutBounce(ratio:Number):Number
		{
			var s:Number = 7.5625;
			var p:Number = 2.75;
			var l:Number;
			if (ratio < (1.0 / p))
			{
				l = s * Math.pow(ratio, 2);
			}
			else
			{
				if (ratio < (2.0 / p))
				{
					ratio -= 1.5 / p;
					l = s * Math.pow(ratio, 2) + 0.75;
				}
				else
				{
					if (ratio < 2.5 / p)
					{
						ratio -= 2.25 / p;
						l = s * Math.pow(ratio, 2) + 0.9375;
					}
					else
					{
						ratio -= 2.625 / p;
						l = s * Math.pow(ratio, 2) + 0.984375;
					}
				}
			}
			return l;
		}


		/**
		 * @private
		 */
		private static function easeInOutBounce(ratio:Number):Number
		{
			return easeCombined(easeInBounce, easeOutBounce, ratio);
		}


		/**
		 * @private
		 */
		private static function easeOutInBounce(ratio:Number):Number
		{
			return easeCombined(easeOutBounce, easeInBounce, ratio);
		}


		/**
		 * @private
		 */
		private static function easeCombined(startFunc:Function, endFunc:Function, ratio:Number):Number
		{
			if (ratio < 0.5) return 0.5 * startFunc(ratio * 2.0);
			else return 0.5 * endFunc((ratio - 0.5) * 2.0) + 0.5;
		}
	}
}
