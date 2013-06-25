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
package tetragon.util.time
{
	import tetragon.util.display.StageReference;

	import flash.events.Event;
	
	
	/**
	 * A static class that allows to add function callbacks which should be delayed
	 * until the next frame is entered. Useful for methods that should wait to be
	 * called after one frame.
	 * 
	 * The class will automatically dispose created arrays and event hooks after the
	 * next frame is called, unless autoDispose is set to false.
	 */
	public class CallLater
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private static var _callbacks:Vector.<Function>;
		private static var _arguments:Vector.<Array>;
		
		private static var _initialized:Boolean;
		private static var _autoDispose:Boolean = true;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a function callback to be called on the next frame.
		 * 
		 * @param callback
		 * @param args
		 */
		public static function add(callback:Function, args:Array = null):void
		{
			if (!_initialized)
			{
				_initialized = true;
				_callbacks = new Vector.<Function>();
				_arguments = new Vector.<Array>();
				StageReference.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			
			_callbacks.push(callback);
			_arguments.push(args);
		}
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the CallLater class is automatically disposed after the next
		 * frame. This can be set to false when CallLater is used often to prevent object
		 * creation with each add(0 call.
		 * 
		 * @default true
		 */
		public static function get autoDispose():Boolean
		{
			return _autoDispose;
		}
		public static function set autoDispose(v:Boolean):void
		{
			_autoDispose = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function onEnterFrame(e:Event):void
		{
			var callbacks:Vector.<Function> = _callbacks;
			var arguments:Vector.<Array> = _arguments;
			
			if (_autoDispose)
			{
				StageReference.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_callbacks = null;
				_arguments = null;
				_initialized = false;
			}
			
			for (var i:uint = 0; i < callbacks.length; i++)
			{
				callbacks[i].apply(null, arguments[i]);
			}
			
			if (!_autoDispose)
			{
				_callbacks.length = _arguments.length = 0;
			}
		}
	}
}
