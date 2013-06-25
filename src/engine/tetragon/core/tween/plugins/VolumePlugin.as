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

	import flash.media.SoundTransform;


	/**
	 * Tweens the volume of an object with a soundTransform property
	 * (MovieClip/SoundChannel/NetStream, etc.). <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.TweenLite; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.VolumePlugin; <br />
	 * 		TweenPlugin.activate([VolumePlugin]); // activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
	 * 
	 * 		TweenLite.to(mc, 1, {volume:0}); <br /><br />
	 * </code>
	 */
	public class VolumePlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected var _target:Object;
		/** @private **/
		protected var _soundTransform:SoundTransform;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function VolumePlugin()
		{
			propertyName = "volume";
			overwriteProperties = [propertyName];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			if (isNaN(value) || target.hasOwnProperty(propertyName)
				|| !target.hasOwnProperty("soundTransform"))
			{
				return false;
			}
			
			_target = target;
			_soundTransform = _target['soundTransform'];
			addTween(_soundTransform, propertyName, _soundTransform.volume, value, propertyName);
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set changeFactor(v:Number):void
		{
			updateTweens(v);
			_target['soundTransform'] = _soundTransform;
		}
	}
}
