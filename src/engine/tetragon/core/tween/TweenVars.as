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
package tetragon.core.tween
{
	/**
	 * TweenVars class
	 */
	public dynamic class TweenVars
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/* Flags */
		public var reversed:Boolean;
		public var yoyo:Boolean;
		public var paused:Boolean;
		public var immediateRender:Boolean;
		public var useFrames:Boolean;
		public var runBackwards:Boolean;
		public var isGSVars:Boolean;
		public var autoRemoveChildren:Boolean;
		
		public var repeat:int;
		public var overwriteMode:int;
		
		public var delay:Number = 0.0;
		public var repeatDelay:Number = 0.0;
		public var timeScale:Number = 1.0;
		public var stagger:Number;
		public var currentTime:Number;
		
		public var align:String;
		
		public var timeline:TimelineBase;
		public var vars:TweenVars;
		public var startAt:TweenVars;
		
		public var tweens:Array;
		public var roundProperties:Array;
		
		public var data:*;
		
		public var ease:Function;
		public var proxiedEase:Function;
		
		public var onInit:Function;
		public var onStart:Function;
		public var onUpdate:Function;
		public var onComplete:Function;
		public var onReverseComplete:Function;
		public var onRepeat:Function;
		
		public var onInitListener:Function;
		public var onStartListener:Function;
		public var onUpdateListener:Function;
		public var onCompleteListener:Function;
		public var onReverseCompleteListener:Function;
		public var onRepeatListener:Function;
		
		/* Params */
		public var easeParams:Array;
		public var initParams:Array;
		public var startParams:Array;
		public var updateParams:Array;
		public var completeParams:Array;
		public var reverseCompleteParams:Array;
		public var repeatParams:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param properties An object with property key-value assignments.
		 */
		public function TweenVars(properties:Object = null)
		{
			if (properties) setProperties(properties);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Resets the tween vars to it's initial state.
		 */
		public function reset():void
		{
			reversed = yoyo = paused = immediateRender = useFrames = runBackwards = isGSVars
				= autoRemoveChildren = false;
			repeat = overwriteMode = 0;
			delay = repeatDelay = 0.0;
			timeScale = 1.0;
			stagger = currentTime = NaN;
			align = null;
			timeline = null;
			vars = startAt = null;
			tweens = roundProperties = data = ease = proxiedEase = onInit = onStart = onUpdate
				= onComplete = onReverseComplete = onRepeat = onInitListener = onStartListener
				= onUpdateListener = onCompleteListener = onReverseCompleteListener
				= onRepeatListener = null;
			easeParams = initParams = startParams = updateParams = completeParams
			= reverseCompleteParams = repeatParams = null;
			
			/* Reset dynamic properties. */
			for (var p:String in this)
			{
				delete this[p];
			}
		}
		
		
		/**
		 * Sets a dynamic property that should be tweened.
		 * 
		 * @param name
		 * @param value
		 */
		public function setProperty(name:String, value:*):void
		{
			this[name] = value;
		}
		
		
		/**
		 * Allows to set several properties at once.
		 * 
		 * @param properties An object with property key-value assignments.
		 */
		public function setProperties(properties:Object):void
		{
			for (var p:String in properties)
			{
				this[p] = properties[p];
			}
		}
	}
}
