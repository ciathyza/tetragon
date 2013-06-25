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
package tetragon.core.types
{
	/**
	 * Holds a number value safely to stop it being sniffed out and changed. Only use this
	 * for important numbers as there is a cost to it. It's much slower than using a
	 * normal var (mainly because of the getter/setter access). There's also a small
	 * margin for error because of the conversion
	 * 
	 * @internal Based on SafeInt class by Damian Connolly - http://divillysausages.com
	 */
	public final class SafeNumber
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private static var _keys:Vector.<Number>;
		private static var _invKeys:Vector.<Number>;
		private static var _currIndex:int = 0;
		
		private var _value:Number = 0.0;
		private var _index:int = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/* Static constructor */
		{SafeNumber.init();}
		
		/**
		 * Creates a new SafeNumber
		 * 
		 * @param value	The initial value to set it at
		 */
		public function SafeNumber(value:Number = 0.0)
		{
			this.value = value;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The value for this Number. When being set, a new key is used to save it, and when being
		 * retrieved, the inverse key is used to decrypt it
		 */
		public function get value():Number
		{
			return _value * SafeNumber._invKeys[_index];
		}
		public function set value(n:Number):void
		{
			_index = SafeNumber._currIndex++;
			if (SafeNumber._currIndex >= SafeNumber._keys.length) SafeNumber._currIndex = 0;
			_value = n * SafeNumber._keys[_index];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Inits the SafeNumber class, filling up our arrays. NOTE: We can't prepend the
		 * vars with "SafeNumber" as it comes out as null (not created yet?)
		 */
		private static function init():void
		{
			var max:int = 100;
			_keys = new Vector.<Number>(max, true);
			_invKeys = new Vector.<Number>(max, true);
			
			/* Pre-generate random numbers so it's accessed quicker */
			for (var i:int = 0; i < max; i++)
			{
				var num:Number = -100.0 + Math.random() * 200.0;
				_keys[i] = num;
				_invKeys[i] = 1.0 / num;
			}
		}
	}
}
