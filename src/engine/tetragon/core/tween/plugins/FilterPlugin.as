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
	import tetragon.core.tween.TweenVO;

	import flash.display.DisplayObject;
	import flash.filters.BitmapFilter;


	/**
	 * Base class for all filter plugins (like blurFilter, colorMatrixFilter, glowFilter, etc.).
	 * Handles common routines. There is no reason to use this class directly.
	 */
	public class FilterPlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected var _target:DisplayObject;
		/** @private **/
		protected var _type:Class;
		/** @private **/
		protected var _filter:BitmapFilter;
		/** @private **/
		protected var _index:int;
		/** @private **/
		protected var _remove:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function FilterPlugin()
		{
			super();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set changeFactor(n:Number):void
		{
			var i:int = _tweens.length, vo:TweenVO, filters:Array = _target.filters;
			
			while (i--)
			{
				vo = _tweens[i];
				vo.target[vo.property] = vo.start + (vo.change * n);
			}
			
			if (!(filters[_index] is _type))
			{
				// a filter may have been added or removed since the tween began, changing the index.
				i = _index = filters.length;
				// default (in case it was removed)
				while (i--)
				{
					if (filters[i] is _type)
					{
						_index = i;
						break;
					}
				}
			}
			
			filters[_index] = _filter;
			_target.filters = filters;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function onCompleteTween():void
		{
			if (_remove)
			{
				var filters:Array = _target.filters;
				if (!(filters[_index] is _type))
				{
					// a filter may have been added or removed since the tween began, changing the index.
					var i:int = filters.length;
					while (i--)
					{
						if (filters[i] is _type)
						{
							filters.splice(i, 1);
							break;
						}
					}
				}
				else
				{
					filters.splice(_index, 1);
				}
				_target.filters = filters;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function initFilter(properties:Object, defaultFilter:BitmapFilter, propertyNames:Array):void
		{
			var filters:Array = _target.filters, p:String, i:int, colorTween:HexColorsPlugin;
			var extras:Object = (properties is BitmapFilter) ? {} : properties;
			_index = -1;
			
			if (extras['index'])
			{
				_index = extras['index'];
			}
			else
			{
				i = filters.length;
				while (i--)
				{
					if (filters[i] is _type)
					{
						_index = i;
						break;
					}
				}
			}
			
			if (_index == -1 || filters[_index] == null || extras['addFilter'] == true)
			{
				_index = extras['index'] ? extras['index'] : filters.length;
				filters[_index] = defaultFilter;
				_target.filters = filters;
			}
			
			_filter = filters[_index];
			
			if (extras['remove'] == true)
			{
				_remove = true;
				onComplete = onCompleteTween;
			}
			
			i = propertyNames.length;
			
			while (i--)
			{
				p = propertyNames[i];
				if (p in properties && _filter[p] != properties[p])
				{
					if (p == "color" || p == "highlightColor" || p == "shadowColor")
					{
						colorTween = new HexColorsPlugin();
						colorTween.initColor(_filter, p, _filter[p], properties[p]);
						_tweens[_tweens.length] = new TweenVO(colorTween, "changeFactor", 0, 1, p, this);
					}
					else if (p == "quality" || p == "inner" || p == "knockout" || p == "hideObject")
					{
						_filter[p] = properties[p];
					}
					else
					{
						addTween(_filter, p, _filter[p], properties[p], p);
					}
				}
			}
		}
	}
}
