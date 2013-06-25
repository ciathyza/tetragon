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
