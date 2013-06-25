/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.types
{
	/**
	 * Holds a int value safely to stop it being sniffed out and changed. Only use this
	 * for important numbers as there is a cost to it. It's much slower than using a
	 * normal var (mainly because of the getter/setter access).
	 * 
	 * @internal Based on SafeInt class by Damian Connolly - http://divillysausages.com
	 */
	public final class SafeInt
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
		{SafeInt.init();}
		
		/**
		 * Creates a new SafeInt
		 * 
		 * @param value	The initial value to set it at
		 */
		public function SafeInt(value:int = 0)
		{
			this.value = value;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The value for this int. When being set, a new key is used to save it, and when being
		 * retrieved, the inverse key is used to decrypt it
		 */
		public function get value():int
		{
			return int(_value * SafeInt._invKeys[_index] + 0.5);
		}
		public function set value(v:int):void
		{
			_index = SafeInt._currIndex++;
			if (SafeInt._currIndex >= SafeInt._keys.length) SafeInt._currIndex = 0;
			_value = v * SafeInt._keys[_index];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Inits the SafeInt class, filling up our arrays. NOTE: We can't prepend the vars
		 * with "SafeInt" as it comes out as null (not created yet?)
		 */
		private static function init():void
		{
			var max:int = 100;
			_keys = new Vector.<Number>(max, true);
			_invKeys = new Vector.<Number>(max, true);

			/* pre-generate random numbers so it's accessed quicker */
			for (var i:int = 0; i < max; i++)
			{
				var num:Number = -100.0 + Math.random() * 200.0;
				_keys[i] = num;
				_invKeys[i] = 1.0 / num;
			}
		}
	}
}
