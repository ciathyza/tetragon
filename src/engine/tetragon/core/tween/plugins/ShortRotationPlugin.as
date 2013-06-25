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
	import tetragon.util.number.isNumber;
	
	
	/**
	 * To tween any rotation property of the target object in the shortest direction, use
	 * "shortRotation" For example, if <code>myObject.rotation</code> is currently 170
	 * degrees and you want to tween it to -170 degrees, a normal rotation tween would
	 * travel a total of 340 degrees in the counter-clockwise direction, but if you use
	 * shortRotation, it would travel 20 degrees in the clockwise direction instead. You
	 * can define any number of rotation properties in the shortRotation object which
	 * makes 3D tweening easier, like:<br />
	 * <br />
	 * <code> 
	 * 		
	 * 		TweenMax.to(mc, 2, {shortRotation:{rotationX:-170, rotationY:35, rotationZ:200}}); <br /><br /></code>
	 * 
	 * Normally shortRotation is defined in degrees, but if you prefer to have it work
	 * with radians instead, simply set the <code>useRadians</code> special property to
	 * <code>true</code> like:<br />
	 * <br />
	 * <code>
	 * 
	 * 		TweenMax.to(myCustomObject, 2, {shortRotation:{customRotationProperty:Math.PI, useRadians:true}});</code>
	 * <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.TweenLite; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.ShortRotationPlugin; <br />
	 * 		TweenPlugin.activate([ShortRotationPlugin]); // activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
	 * 
	 * 		TweenLite.to(mc, 1, {shortRotation:{rotation:-170}});<br /><br />
	 * 		// or for a 3D tween with multiple rotation values...<br />
	 * 		TweenLite.to(mc, 1, {shortRotation:{rotationX:-170, rotationY:35, rotationZ:10}}); <br /><br />
	 * </code>
	 */
	public class ShortRotationPlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function ShortRotationPlugin()
		{
			propertyName = "shortRotation";
			overwriteProperties = [];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			if (isNumber(value)) return false;
			
			var useRadians:Boolean = (value['useRadians'] as Boolean) && (value['useRadians'] as Boolean) == true;
			for (var p:String in value)
			{
				if (p != "useRadians")
				{
					initRotation(target, p, target[p],
						(isNumber(value[p])) ? value[p] : target[p] + value[p], useRadians);
				}
			}
			return true;
		}
		
		
		/**
		 * @private
		 */
		public function initRotation(target:Object, propName:String, start:Number, end:Number,
			useRadians:Boolean = false):void
		{
			var cap:Number = useRadians ? Math.PI * 2 : 360;
			var dif:Number = (end - start) % cap;
			
			if (dif != dif % (cap / 2))
			{
				dif = (dif < 0) ? dif + cap : dif - cap;
			}
			
			addTween(target, propName, start, start + dif, propName);
			overwriteProperties[overwriteProperties.length] = propName;
		}
	}
}
