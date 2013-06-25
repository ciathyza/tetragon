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
	import tetragon.core.tween.TweenBase;
	import tetragon.core.tween.TweenVO;
	
	
	/**
	 * If you'd like the inbetween values in a tween to always get rounded to the nearest
	 * integer, use the roundProps special property. Just pass in an Array containing the
	 * property names that you'd like rounded. For example, if you're tweening the x, y,
	 * and alpha properties of mc and you want to round the x and y values (not alpha)
	 * every time the tween is rendered, you'd do: <br />
	 * <br />
	 * <code>
	 * 	
	 * 	TweenMax.to(mc, 2, {x:300, y:200, alpha:0.5, roundProps:["x","y"]});<br /><br /></code>
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.TweenMax; <br /> 
	 * 		import com.greensock.plugins.RoundPropsPlugin; <br />
	 * 		TweenPlugin.activate([RoundPropsPlugin]); // activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
	 * 
	 * 		TweenMax.to(mc, 2, {x:300, y:200, alpha:0.5, roundProps:["x","y"]}); <br /><br />
	 * </code>
	 */
	public class RoundPropertiesPlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected var _tween:Tween;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function RoundPropertiesPlugin()
		{
			propertyName = "roundProperties";
			overwriteProperties = ["roundProperties"];
			roundProperties = true;
			priority = -1;
			onInitAllProperties = initAllProperties;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			_tween = tween;
			overwriteProperties = overwriteProperties.concat(value as Array);
			return true;
		}
		
		
		/**
		 * @private
		 */
		public function add(object:Object, propName:String, start:Number, change:Number):void
		{
			addTween(object, propName, start, start + change, propName);
			overwriteProperties[overwriteProperties.length] = propName;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function initAllProperties():void
		{
			if (!_tween.vars.roundProperties) return;
			
			var rp:Array = _tween.vars.roundProperties;
			var vo:TweenVO;
			
			/* Round all available properties if "*" is used. */
			if (rp.indexOf("*") > -1)
			{
				rp = [];
				vo = _tween.cachedVO;
				if (vo.name != TweenBase.MULTIPLE) rp.push(vo.name);
				while (vo.next)
				{
					vo = vo.next;
					if (vo.name != TweenBase.MULTIPLE) rp.push(vo.name);
				}
			}
			
			var i:int = rp.length;
			while (--i > -1)
			{
				var property:String = rp[i];
				vo = _tween.cachedVO;
				
				while (vo)
				{
					if (vo.name == property)
					{
						if (vo.plugin)
						{
							vo.plugin.roundProperties = true;
						}
						else
						{
							add(vo.target, property, vo.start, vo.change);
							removeVO(vo);
							_tween.voLookup[property] = _tween.voLookup[propertyName];
						}
					}
					else if (vo.plugin && vo.name == TweenBase.MULTIPLE && !vo.plugin.roundProperties)
					{
						var multiProps:String = " " + vo.plugin.overwriteProperties.join(" ") + " ";
						if (multiProps.indexOf(" " + property + " ") != -1)
						{
							vo.plugin.roundProperties = true;
						}
					}
					vo = vo.next;
				}
			}
		}
		
		
		/**
		 * @private
		 */
		protected function removeVO(vo:TweenVO):void
		{
			if (vo.next)
			{
				vo.next.prev = vo.prev;
			}
			if (vo.prev)
			{
				vo.prev.next = vo.next;
			}
			else if (_tween.cachedVO == vo)
			{
				_tween.cachedVO = vo.next;
			}
			if (vo.plugin && vo.plugin.onDisable != null)
			{
				// some plugins need to be notified so they can perform cleanup tasks first
				vo.plugin.onDisable();
			}
		}
	}
}