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
package tetragon.util.tween
{
	import tetragon.util.tween.plugins.TweenPlugin;
	
	
	/**
	 * Stores information about an individual property tween. There is no reason to use
	 * this class directly - Tween, TweenPro, and some plugins use it internally.
	 */
	public final class TweenVO
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Tween target object.
		 */
		public var target:Object;
		
		/**
		 * Name of the property that is being tweened.
		 */
		public var property:String;
		
		/**
		 * Starting value.
		 */
		public var start:Number;
		
		/**
		 * Amount to change (basically, the difference between the starting value
		 * and ending value).
		 */
		public var change:Number;
		
		/**
		 * Alias to associate with the PropTween which is typically the same as the
		 * property, but can be different, particularly for plugins.
		 */
		public var name:String;
		
		/**
		 * Priority in the rendering queue. The lower the value the later it will be
		 * tweened. Typically all PropTweens get a priority of 0, but some plugins
		 * must be rendered later (or earlier).
		 */
		public var priority:int;
		
		/**
		 * If the VO is for a TweenPlugin, this stores the plugin reference directly.
		 */
		public var plugin:TweenPlugin;
		
		/**
		 * Next PropTween in the linked list.
		 */
		public var next:TweenVO;
		
		/**
		 * Previous PropTween in the linked list.
		 */
		public var prev:TweenVO;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param target Target object.
		 * @param property Name of the property that is being tweened.
		 * @param start Starting value.
		 * @param change Amount to change (basically, the difference between the starting
		 *            value and ending value).
		 * @param name Alias to associate with the PropTween which is typically the same
		 *            as the property, but can be different, particularly for plugins.
		 * @param isPlugin If the target of the PropTween is a TweenPlugin, isPlugin
		 *            should be true.
		 * @param nextNode Next PropTween in the linked list.
		 * @param priority Priority in the rendering queue. The lower the value the later
		 *            it will be tweened. Typically all PropTweens get a priority of 0,
		 *            but some plugins must be rendered later (or earlier).
		 */
		public function TweenVO(target:Object, property:String, start:Number, change:Number,
			name:String, plugin:TweenPlugin = null, next:TweenVO = null, priority:int = 0)
		{
			this.target = target;
			this.property = property;
			this.start = start;
			this.change = change;
			this.name = name;
			this.plugin = plugin;
			this.priority = priority;
			if (next)
			{
				next.prev = this;
				this.next = next;
			}
		}
	}
}
