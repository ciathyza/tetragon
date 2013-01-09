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
	import tetragon.view.render2d.core.events.Event2D;
	import tetragon.view.render2d.core.events.EventDispatcher2D;
	
	
	/**
	 * A Tween animates numeric properties of objects. It uses different transition
	 * functions to give the animations various styles.
	 * 
	 * <p>
	 * The primary use of this class is to do standard animations like movement, fading,
	 * rotation, etc. But there are no limits on what to animate; as long as the property
	 * you want to animate is numeric (<code>int, uint, Number</code>), the tween can
	 * handle it. For a list of available Transition types, look at the "Transitions"
	 * class.
	 * </p>
	 * 
	 * <p>
	 * Here is an example of a tween that moves an object to the right, rotates it, and
	 * fades it out:
	 * </p>
	 * 
	 * <pre>
	 *  var tween:Tween = new Tween(object, 2.0, Transitions.EASE_IN_OUT);
	 *  tween.animate("x", object.x + 50);
	 *  tween.animate("rotation", deg2rad(45));
	 *  tween.fadeTo(0);    // equivalent to 'animate("alpha", 0)'
	 *  Starling.juggler.add(tween);
	 * </pre>
	 * 
	 * <p>
	 * Note that the object is added to a juggler at the end of this sample. That's
	 * because a tween will only be executed if its "advanceTime" method is executed
	 * regularly - the juggler will do that for you, and will remove the tween when it is
	 * finished.
	 * </p>
	 * 
	 * @see Juggler
	 * @see Transitions
	 */
	public class Tween2D extends EventDispatcher2D implements IAnimatable2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _target:Object;
		/** @private */
		private var _transition:String;
		/** @private */
		private var _properties:Vector.<String>;
		/** @private */
		private var _startValues:Vector.<Number>;
		/** @private */
		private var _endValues:Vector.<Number>;
		/** @private */
		private var _onStart:Function;
		/** @private */
		private var _onUpdate:Function;
		/** @private */
		private var _onComplete:Function;
		/** @private */
		private var _onStartArgs:Array;
		/** @private */
		private var _onUpdateArgs:Array;
		/** @private */
		private var _onCompleteArgs:Array;
		/** @private */
		private var _totalTime:Number;
		/** @private */
		private var _currentTime:Number;
		/** @private */
		private var _delay:Number;
		/** @private */
		private var _roundToInt:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a tween with a target, duration (in seconds) and a transition function.
		 * 
		 * @param target
		 * @param time
		 * @param transition
		 */
		public function Tween2D(target:Object, time:Number, transition:String = "linear")
		{
			_target = target;
			_currentTime = 0;
			_totalTime = Math.max(0.0001, time);
			_delay = 0;
			_transition = transition;
			_roundToInt = false;
			_properties = new <String>[];
			_startValues = new <Number>[];
			_endValues = new <Number>[];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Animates the property of an object to a target value. You can call this method multiple
		 * times on one tween.
		 * 
		 * @param property
		 * @param targetValue
		 */
		public function animate(property:String, targetValue:Number):void
		{
			if (!_target) return;
			_properties.push(property);
			_startValues.push(Number.NaN);
			_endValues.push(targetValue);
		}
		
		
		/**
		 * Animates the 'scaleX' and 'scaleY' properties of an object simultaneously.
		 * 
		 * @param factor
		 */
		public function scaleTo(factor:Number):void
		{
			animate("scaleX", factor);
			animate("scaleY", factor);
		}
		
		
		/**
		 * Animates the 'x' and 'y' properties of an object simultaneously.
		 * 
		 * @param x
		 * @param y
		 */
		public function moveTo(x:Number, y:Number):void
		{
			animate("x", x);
			animate("y", y);
		}
		
		
		/**
		 * Animates the 'alpha' property of an object to a certain target value.
		 * 
		 * @param alpha
		 */
		public function fadeTo(alpha:Number):void
		{
			animate("alpha", alpha);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function advanceTime(time:Number):void
		{
			if (time == 0) return;
			
			var previousTime:Number = _currentTime;
			_currentTime += time;
			
			if (_currentTime < 0 || previousTime >= _totalTime) return;
			if (onStart != null && previousTime <= 0 && _currentTime >= 0)
			{
				onStart.apply(null, _onStartArgs);
			}
			
			var ratio:Number = Math.min(_totalTime, _currentTime) / _totalTime;
			var numAnimatedProperties:uint = _startValues.length;
			
			for (var i:uint = 0; i < numAnimatedProperties; ++i)
			{
				if (isNaN(_startValues[i])) _startValues[i] = _target[_properties[i]] as Number;
				var start:Number = _startValues[i];
				var end:Number = _endValues[i];
				var delta:Number = end - start;
				var transitionFunc:Function = Transitions2D.getTransition(_transition);
				var currentValue:Number = start + transitionFunc(ratio) * delta;
				if (_roundToInt) currentValue = Math.round(currentValue);
				_target[_properties[i]] = currentValue;
			}
			
			if (onUpdate != null) onUpdate.apply(null, _onUpdateArgs);
			if (previousTime < _totalTime && _currentTime >= _totalTime)
			{
				dispatchEvent(new Event2D(Event2D.REMOVE_FROM_JUGGLER));
				if (onComplete != null) onComplete.apply(null, _onCompleteArgs);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if the tween is finished.
		 */
		public function get isComplete():Boolean
		{
			return _currentTime >= _totalTime;
		}
		
		
		/**
		 * The target object that is animated.
		 */
		public function get target():Object
		{
			return _target;
		}
		
		
		/**
		 * The transition method used for the animation.
		 * 
		 * @see Transitions
		 */
		public function get transition():String
		{
			return _transition;
		}
		
		
		/**
		 * The total time the tween will take (in seconds).
		 */
		public function get totalTime():Number
		{
			return _totalTime;
		}
		
		
		/**
		 * The time that has passed since the tween was created.
		 */
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		
		/**
		 * The delay before the tween is started.
		 */
		public function get delay():Number
		{
			return _delay;
		}
		public function set delay(v:Number):void
		{
			_currentTime = _currentTime + _delay - v;
			_delay = v;
		}
		
		
		/**
		 * Indicates if the numeric values should be cast to Integers.
		 * 
		 * @default false
		 */
		public function get roundToInt():Boolean
		{
			return _roundToInt;
		}
		public function set roundToInt(v:Boolean):void
		{
			_roundToInt = v;
		}
		
		
		/**
		 * A function that will be called when the tween starts (after a possible delay).
		 */
		public function get onStart():Function
		{
			return _onStart;
		}
		public function set onStart(v:Function):void
		{
			_onStart = v;
		}
		
		
		/**
		 * A function that will be called each time the tween is advanced.
		 */
		public function get onUpdate():Function
		{
			return _onUpdate;
		}
		public function set onUpdate(v:Function):void
		{
			_onUpdate = v;
		}
		
		
		/**
		 * A function that will be called when the tween is complete.
		 */
		public function get onComplete():Function
		{
			return _onComplete;
		}
		public function set onComplete(v:Function):void
		{
			_onComplete = v;
		}
		
		
		/**
		 * The arguments that will be passed to the 'onStart' function.
		 */
		public function get onStartArgs():Array
		{
			return _onStartArgs;
		}
		public function set onStartArgs(v:Array):void
		{
			_onStartArgs = v;
		}
		
		
		/**
		 * The arguments that will be passed to the 'onUpdate' function.
		 */
		public function get onUpdateArgs():Array
		{
			return _onUpdateArgs;
		}
		public function set onUpdateArgs(v:Array):void
		{
			_onUpdateArgs = v;
		}
		
		
		/**
		 * The arguments that will be passed to the 'onComplete' function.
		 */
		public function get onCompleteArgs():Array
		{
			return _onCompleteArgs;
		}
		public function set onCompleteArgs(v:Array):void
		{
			_onCompleteArgs = v;
		}
	}
}
