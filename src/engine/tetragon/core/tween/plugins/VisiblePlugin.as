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
package tetragon.core.tween.plugins
{
	import tetragon.core.tween.Tween;
	
	
	/**
	 * Toggles the visibility at the end of a tween. For example, if you want to set
	 * <code>visible</code> to false at the end of the tween, do:<br />
	 * <br />
	 * <code>
	 * 
	 * TweenLite.to(mc, 1, {x:100, visible:false});<br /><br /></code>
	 * 
	 * The <code>visible</code> property is forced to true during the course of the tween. <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.TweenLite; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.VisiblePlugin; <br />
	 * 		TweenPlugin.activate([VisiblePlugin]); // activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
	 * 
	 * 		TweenLite.to(mc, 1, {x:100, visible:false}); <br /><br />
	 * </code>
	 */
	public class VisiblePlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected var _target:Object;
		/** @private **/
		protected var _tween:Tween;
		/** @private **/
		protected var _visible:Boolean;
		/** @private **/
		protected var _initVal:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function VisiblePlugin()
		{
			propertyName = "visible";
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
			if (!target.hasOwnProperty(propertyName)) return false;
			
			_target = target;
			_tween = tween;
			_initVal = _target[propertyName] as Boolean;
			_visible = Boolean(value);
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
			if (v == 1 && (_tween.cachedDuration == _tween.cachedTime || _tween.cachedTime == 0))
			{
				// a changeFactor of 1 doesn't necessarily mean the tween is done
				// - if the ease is Elastic.easeOut or Back.easeOut for example, they
				// could hit 1 mid-tween. The reason we check to see if cachedTime is 0
				// is for from() tweens
				_target[propertyName] = _visible;
			}
			else
			{
				// in case a completed tween is re-rendered at an earlier time.
				_target[propertyName] = _initVal;
			}
		}
	}
}
