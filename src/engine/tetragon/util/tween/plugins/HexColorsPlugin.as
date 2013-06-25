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
package tetragon.util.tween.plugins
{
	import tetragon.util.tween.Tween;
	
	
	/**
	 * Although hex colors are technically numbers, if you try to tween them
	 * conventionally, you'll notice that they don't tween smoothly. To tween them
	 * properly, the red, green, and blue components must be extracted and tweened
	 * independently. The HexColorsPlugin makes it easy. To tween a property of your
	 * object that's a hex color to another hex color, just pass a hexColors Object with
	 * properties named the same as your object's hex color properties. For example, if
	 * myObject has a "myHexColor" property that you'd like to tween to red (
	 * <code>0xFF0000</code>) over the course of 2 seconds, you'd do:<br />
	 * <br />
	 * <code>
	 * 	
	 * 	TweenPro.to(myObject, 2, {hexColors:{myHexColor:0xFF0000}});<br /><br /></code>
	 * 
	 * You can pass in any number of hexColor properties. <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.Tween; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.HexColorsPlugin; <br />
	 * 		TweenPlugin.activate([HexColorsPlugin]); // activation is permanent in the SWF,
	 * 		so this line only needs to be run once.<br /><br />
	 * 
	 * 		Tween.to(myObject, 2, {hexColors:{myHexColor:0xFF0000}}); <br /><br /></code>
	 * 
	 * Or if you just want to tween a color and apply it somewhere on every frame, you
	 * could do:<br />
	 * <br />
	 * <code>
	 * 
	 * var myColor:Object = {hex:0xFF0000};<br />
	 * Tween.to(myColor, 2, {hexColors:{hex:0x0000FF}, onUpdate:applyColor});<br />
	 * function applyColor():void {<br />
	 * 		mc.graphics.clear();<br />
	 * 		mc.graphics.beginFill(myColor.hex, 1);<br />
	 * 		mc.graphics.drawRect(0, 0, 100, 100);<br />
	 * 		mc.graphics.endFill();<br />
	 * }<br /><br />
	 * </code>
	 */
	public class HexColorsPlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected var _colors:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function HexColorsPlugin()
		{
			super();
			propertyName = "hexColors";
			overwriteProperties = [];
			_colors = [];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			for (var p:String in value)
			{
				initColor(target, p, uint(target[p]), uint(value[p]));
			}
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function killProperties(lookup:Object):void
		{
			for (var i:int = _colors.length - 1; i > -1; i--)
			{
				if (lookup[_colors[i][1]] != undefined) _colors.splice(i, 1);
			}
			super.killProperties(lookup);
		}
		
		
		public function initColor(target:Object, propertyName:String, start:uint, end:uint):void
		{
			if (start != end)
			{
				var r:Number = start >> 16;
				var g:Number = (start >> 8) & 0xff;
				var b:Number = start & 0xff;
				
				_colors[_colors.length] =
				[
					target,
					propertyName,
					r,
					(end >> 16) - r,
					g,
					((end >> 8) & 0xff) - g,
					b,
					(end & 0xff) - b
				];
				
				overwriteProperties[overwriteProperties.length] = propertyName;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set changeFactor(n:Number):void
		{
			var i:int = _colors.length, a:Array;
			while (--i > -1)
			{
				a = _colors[i];
				a[0][a[1]] = ((a[2] + (n * a[3])) << 16 | (a[4] + (n * a[5])) << 8 | (a[6] + (n * a[7])));
			}
		}
	}
}
