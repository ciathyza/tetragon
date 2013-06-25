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

	import flash.geom.Point;
	import flash.geom.Rectangle;


	/**
	 * Normally, all transformations (scale, rotation, and position) are based on the
	 * DisplayObject's registration point (most often its upper left corner), but
	 * TransformAroundCenter allows you to make the 2D transformations occur around the
	 * DisplayObject's center. Keep in mind, though, that Flash doesn't factor in any
	 * masks when determining the DisplayObject's center.
	 * 
	 * If you define an x or y value in the transformAroundCenter object, it will
	 * correspond to the center which makes it easy to position (as opposed to having to
	 * figure out where the original registration point should tween to). If you prefer to
	 * define the x/y in relation to the original registration point, do so outside the
	 * transformAroundCenter object, like: <br />
	 * <br />
	 * <code>
	 * 
	 * TweenLite.to(mc, 3, {x:50, y:40, transformAroundCenter:{scale:0.5, rotation:30}});<br /><br /></code>
	 * 
	 * TransformAroundCenterPlugin is a <a href="http://www.greensock.com/club/">Club
	 * GreenSock</a> membership benefit. You must have a valid membership to use this
	 * class without violating the terms of use. Visit <a
	 * href="http://www.greensock.com/club/">http://www.greensock.com/club/</a> to sign up
	 * or get more details. <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.TweenLite; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.TransformAroundCenterPlugin; <br />
	 * 		TweenPlugin.activate([TransformAroundCenterPlugin]); // activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
	 * 
	 * 		TweenLite.to(mc, 1, {transformAroundCenter:{scale:1.5, rotation:150}}); <br /><br />
	 * </code>
	 */
	public class TransformAroundCenterPlugin extends TransformAroundPointPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function TransformAroundCenterPlugin()
		{
			propertyName = "transformAroundCenter";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			var bounds:Rectangle = target['getBounds'](target);
			value['point'] = new Point(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2);
			value['pointIsLocal'] = true;
			return super.onInitTween(target, value, tween);
		}
	}
}
