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
	import tetragon.core.tween.TweenVO;

	import flash.display.*;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;


	/**
	 * To change a DisplayObject's tint/color, set this to the hex value of the tint you'd like
	 * to end up at (or begin at if you're using <code>TweenMax.from()</code>). An example hex value would be <code>0xFF0000</code>.<br /><br />
	 * 
	 * To remove a tint completely, use the RemoveTintPlugin (after activating it, you can just set <code>removeTint:true</code>) <br /><br />
	 * 
	 * <b>USAGE:</b><br /><br />
	 * <code>
	 * 		import com.greensock.TweenLite; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.TintPlugin; <br />
	 * 		TweenPlugin.activate([TintPlugin]); // activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
	 * 
	 * 		TweenLite.to(mc, 1, {tint:0xFF0000}); <br /><br />
	 * </code>
	 */
	public class TintPlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected static var _props:Array =
		[
			"redMultiplier",
			"greenMultiplier",
			"blueMultiplier",
			"alphaMultiplier",
			"redOffset",
			"greenOffset",
			"blueOffset",
			"alphaOffset"
		];
		
		/** @private **/
		protected var _transform:Transform;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function TintPlugin()
		{
			propertyName = "tint";
			overwriteProperties = [propertyName];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override public function set changeFactor(n:Number):void
		{
			if (_transform)
			{
				var ct:ColorTransform = _transform.colorTransform;
				var i:int = _tweens.length;
				var vo:TweenVO;
				
				while (--i > -1)
				{
					vo = _tweens[i];
					ct[vo.property] = vo.start + (vo.change * n);
				}
				_transform.colorTransform = ct;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			if (!(target is DisplayObject)) return false;
			
			var end:ColorTransform = new ColorTransform();
			if (value && tween.vars['removeTint'] != true)
			{
				end.color = uint(value);
			}
			
			_transform = (target as DisplayObject).transform;
			var start:ColorTransform = _transform.colorTransform;
			end.alphaMultiplier = start.alphaMultiplier;
			end.alphaOffset = start.alphaOffset;
			init(start, end);
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function init(start:ColorTransform, end:ColorTransform):void
		{
			var i:int = _props.length;
			var c:int = _tweens.length;
			var p:String;
			
			while (i--)
			{
				p = _props[i];
				if (start[p] != end[p])
				{
					_tweens[c++] = new TweenVO(start, p, start[p], end[p] - start[p], "tint");
				}
			}
		}
	}
}
