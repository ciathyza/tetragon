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
package tetragon.core.tween.plugins
{
	import tetragon.core.tween.Tween;
	
	
	/**
	 * Tweens numbers in an Array. <br /><br />
	 * 
	 * <b>USAGE:</b><br /><br />
	 * <code>
	 * 		import com.greensock.TweenLite; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.EndArrayPlugin; <br />
	 * 		TweenPlugin.activate([EndArrayPlugin]); // activation is permanent in the SWF,
	 * 		so this line only needs to be run once.<br /><br />
	 * 
	 * 		var myArray:Array = [1,2,3,4];<br />
	 * 		TweenLite.to(myArray, 1.5, {endArray:[10,20,30,40]}); <br /><br />
	 * </code>
	 */
	public class EndArrayPlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected var _a:Array;
		/** @private **/
		protected var _info:Array = [];
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function EndArrayPlugin()
		{
			propertyName = "endArray";
			overwriteProperties = ["endArray"];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			if (!(target is Array) || !(value is Array)) return false;
			init(target as Array, value);
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function init(start:Array, end:Array):void
		{
			_a = start;
			var i:int = end.length;
			while (i--)
			{
				if (start[i] != end[i] && start[i] != null)
				{
					_info[_info.length] = new ArrayTweenInfo(i, _a[i], end[i] - _a[i]);
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set changeFactor(v:Number):void
		{
			var i:int = _info.length;
			var ti:ArrayTweenInfo;
			
			if (roundProperties)
			{
				var val:Number;
				while (i--)
				{
					ti = _info[i];
					val = ti.start + (ti.change * v);
					if (val > 0)
					{
						_a[ti.index] = (val + 0.5) >> 0; // 4 times as fast as Math.round()
					}
					else
					{
						_a[ti.index] = (val - 0.5) >> 0;
					}
				}
			}
			else
			{
				while (i--)
				{
					ti = _info[i];
					_a[ti.index] = ti.start + (ti.change * v);
				}
			}
		}
	}
}


/**
 * @private
 */
final class ArrayTweenInfo
{
	public var index:uint;
	public var start:Number;
	public var change:Number;
	
	public function ArrayTweenInfo(index:uint, start:Number, change:Number)
	{
		this.index = index;
		this.start = start;
		this.change = change;
	}
}
