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

	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;


	/**
	 * Tweens a GlowFilter. The following properties are available (you only need to
	 * define the ones you want to tween): <code>
	 * <ul>
	 * 		<li> color : uint [0x000000]</li>
	 * 		<li> alpha :Number [0]</li>
	 * 		<li> blurX : Number [0]</li>
	 * 		<li> blurY : Number [0]</li>
	 * 		<li> strength : Number [1]</li>
	 * 		<li> quality : uint [2]</li>
	 * 		<li> inner : Boolean [false]</li>
	 * 		<li> knockout : Boolean [false]</li>
	 * 		<li> index : uint</li>
	 * 		<li> addFilter : Boolean [false]</li>
	 * 		<li> remove : Boolean [false]</li>
	 * </ul>
	 * </code>
	 * 
	 * Set <code>remove</code> to true if you want the filter to be removed when the tween
	 * completes. <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.Tween; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.GlowFilterPlugin; <br />
	 * 		TweenPlugin.activate([GlowFilterPlugin]); // activation is permanent in the SWF, so
	 * 		this line only needs to be run once.<br /><br />
	 * 
	 * 		Tween.to(mc, 1, {glowFilter:{color:0x00FF00, blurX:10, blurY:10, strength:1,
	 * 		alpha:1}});<br /><br />
	 * </code>
	 */
	public class GlowFilterPlugin extends FilterPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		private static var _propertyNames:Array =
		[
			"color",
			"alpha",
			"blurX",
			"blurY",
			"strength",
			"quality",
			"inner",
			"knockout"
		];
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function GlowFilterPlugin()
		{
			super();
			propertyName = "glowFilter";
			overwriteProperties = ["glowFilter"];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			_target = target as DisplayObject;
			_type = GlowFilter;
			initFilter(value, new GlowFilter(0xFFFFFF, 0, 0, 0,
				value['strength'] || 1,
				value['quality'] || 2,
				(value['inner'] as Boolean),
				(value['knockout'] as Boolean)), _propertyNames);
			return true;
		}
	}
}
