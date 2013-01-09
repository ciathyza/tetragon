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
package tetragon.input
{
	/**
	 * Represents a combination of keys that are being pressed or held down at the
	 * same time to trigger a callback.
	 */
	public final class KeyCombination
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The unique ID of the key combination.
		 */
		public var id:String;
		
		/**
		 * A list containing the key codes.
		 */
		public var codes:Vector.<uint>;
		
		/**
		 * The key mode of the key combination.
		 * @see base.io.key.KeyCodes
		 */
		public var mode:int;
		
		/**
		 * The callback function that is called when they key combination is triggered.
		 */
		public var callback:Function;
		
		/**
		 * Optional parameters for the callback function.
		 */
		public var params:Array;
		
		/**
		 * Keyboard location of the SHIFT key, if the key combination has any.
		 */
		public var shiftKeyLocation:uint = 0;
		
		/**
		 * Keyboard location of the CONTROL key, if the key combination has any.
		 */
		public var ctrlKeyLocation:uint = 0;
		
		/**
		 * Keyboard location of the ALT key, if the key combination has any.
		 */
		public var altKeyLocation:uint = 0;
		
		/** @private */
		internal var hasShiftKey:Boolean;
		/** @private */
		internal var hasCtrlKey:Boolean;
		/** @private */
		internal var hasAltKey:Boolean;
		/** @private */
		internal var isTriggered:Boolean;
		/** @private */
		internal var consoleAllow:Boolean;
	}
}
