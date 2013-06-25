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
	import tetragon.core.tween.TweenVO;


	/**
	 * TweenPlugin is the base class for all TweenLite/TweenMax plugins. <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * 
	 * To create your own plugin, extend TweenPlugin and override whichever methods you
	 * need. Typically, you only need to override onInitTween() and the changeFactor
	 * setter. I'd recommend looking at a simple plugin like FramePlugin or ScalePlugin
	 * and using it as a template of sorts. There are a few key concepts to keep in mind:
	 * <ol>
	 * <li>In the constructor, set this.propName to whatever special property you want
	 * your plugin to handle.</li>
	 * 
	 * <li>When a tween that uses your plugin initializes its tween values (normally when
	 * it starts), a new instance of your plugin will be created and the onInitTween()
	 * method will be called. That's where you'll want to store any initial values and
	 * prepare for the tween. onInitTween() should return a Boolean value that essentially
	 * indicates whether or not the plugin initted successfully. If you return false,
	 * TweenLite/Max will just use a normal tween for the value, ignoring the plugin for
	 * that particular tween.</li>
	 * 
	 * <li>The changeFactor setter will be updated on every frame during the course of the
	 * tween with a multiplier that describes the amount of change based on how far along
	 * the tween is and the ease applied. It will be zero at the beginning of the tween
	 * and 1 at the end, but inbetween it could be any value based on the ease applied
	 * (for example, an Elastic.easeOut tween would cause the value to shoot past 1 and
	 * back again before the end of the tween). So if the tween uses the Linear.easeNone
	 * easing equation, when it's halfway finished, the changeFactor will be 0.5.</li>
	 * 
	 * <li>The overwriteProps is an Array that should contain the properties that your
	 * plugin should overwrite when OverwriteManager's mode is AUTO and a tween of the
	 * same object is created. For example, the autoAlpha plugin controls the "visible"
	 * and "alpha" properties of an object, so if another tween is created that controls
	 * the alpha of the target object, your plugin's killProps() will be called which
	 * should handle killing the "alpha" part of the tween. It is your responsibility to
	 * populate (and depopulate) the overwriteProps Array. Failure to do so properly can
	 * cause odd overwriting behavior.</li>
	 * 
	 * <li>Note that there's a "round" property that indicates whether or not values in
	 * your plugin should be rounded to the nearest integer (compatible with TweenMax
	 * only). If you use the _tweens Array, populating it through the addTween() method,
	 * rounding will happen automatically (if necessary) in the updateTweens() method, but
	 * if you don't use addTween() and prefer to manually calculate tween values in your
	 * changeFactor setter, just remember to accommodate the "round" flag if it makes
	 * sense in your plugin.</li>
	 * 
	 * <li>If you need to run a block of code when the tween has finished, point the
	 * onComplete property to a method you created inside your plugin.</li>
	 * 
	 * <li>If you need to run a function when the tween gets disabled, point the onDisable
	 * property to a method you created inside your plugin. Same for onEnable if you need
	 * to run code when a tween is enabled. (A tween gets disabled when it gets
	 * overwritten or finishes or when its timeline gets disabled)</li>
	 * 
	 * <li>Please use the same naming convention as the rest of the plugins, like
	 * MySpecialPropertyNamePlugin.</li>
	 * 
	 * <li>IMPORTANT: The plugin framework is brand new, so there is a chance that it will
	 * change slightly over time and you may need to adjust your custom plugins if the
	 * framework changes. I'll try to minimize the changes, but I'd highly recommend
	 * getting a membership to Club GreenSock to make sure you get update notifications.
	 * See http://blog.greensock.com/club/ for details.</li>
	 * </ol>
	 */
	public class TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * If the API/Framework for plugins changes in the future, this number helps determine
		 * compatibility.
		 * @private
		 */
		public static const VERSION:Number = 1.4;
		
		/** @private */
		public static const ON_INIT_ALL_PROPERTIES:String = "onInitAllProperties";
		/** @private */
		public static const ON_COMPLETE:String = "onComplete";
		/** @private */
		public static const ON_DISABLE:String = "onDisable";
		/** @private */
		public static const ON_ENABLE:String = "onEnable";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public var propertyName:String;
		
		/**
		 * Array containing the names of the properties that should be overwritten in
		 * OverwriteManager's AUTO mode. Typically the only value in this Array is the
		 * propName, but there are cases when it may be different. For example, a bezier
		 * tween's propName is "bezier" but it can manage many different properties like
		 * x, y, etc. depending on what's passed in to the tween.
		 * 
		 * @private
		 */
		public var overwriteProperties:Array;
		
		/**
		 * Priority level in the render queue.
		 * @private
		 */
		public var priority:int;
		
		/**
		 * If the values should be rounded to the nearest integer, set this to true.
		 * @private
		 */
		public var roundProperties:Boolean;
		
		/**
		 * if the plugin actively changes properties of the target when it gets disabled
		 * (like the MotionBlurPlugin swaps out a temporary BitmapData for the target),
		 * activeDisplay should be true. Otherwise it should be false (it is much more
		 * common for it to be false). This is important because if it gets overwritten by
		 * another tween, that tween may init() with stale values - if activeDisable is
		 * true, it will force the new tween to re-init() when this plugin is overwritten
		 * (if ever).
		 * 
		 * @private
		 */
		public var activeDisable:Boolean;
		
		/**
		 * Called when the tween has finished initting all of the properties in the vars
		 * object (useful for things like roundProps which must wait for everything else
		 * to init). IMPORTANT: in order for the onInitAllProps to get called properly,
		 * you MUST set the TweenPlugin's "priority" property to a non-zero value (this is
		 * for optimization and file size purposes).
		 * 
		 * @private
		 */
		public var onInitAllProperties:Function;
		
		/**
		 * Called when the tween is complete.
		 * @private
		 */
		public var onComplete:Function;
		
		/**
		 * Called when the tween gets re-enabled after having been initted. Like if it
		 * finishes and then gets restarted later.
		 * @private
		 */
		public var onEnable:Function;
		
		/**
		 * Called either when the plugin gets overwritten or when its parent tween gets
		 * killed/disabled.
		 * @private
		 */
		public var onDisable:Function;
		
		/** @private **/
		protected var _tweens:Array = [];
		
		/** @private **/
		protected var _changeFactor:Number = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Gets called when any tween of the special property begins. Store any initial
		 * values and/or variables that will be used in the "changeFactor" setter when
		 * this method runs.
		 * 
		 * @private
		 * 
		 * @param target target object of the TweenLite instance using this plugin
		 * @param value The value that is passed in through the special property in the
		 *            tween.
		 * @param tween The TweenLite or TweenMax instance using this plugin.
		 * @return If the initialization failed, it returns false. Otherwise true. It may
		 *         fail if, for example, the plugin requires that the target be a
		 *         DisplayObject or has some other unmet criteria in which case the plugin
		 *         is skipped and a normal property tween is used inside TweenLite
		 */
		public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			addTween(target, propertyName, target[propertyName], value, propertyName);
			return true;
		}
		
		
		/**
		 * Gets called on plugins that have multiple overwritable properties by
		 * OverwriteManager when in AUTO mode. Basically, it instructs the plugin to
		 * overwrite certain properties. For example, if a bezier tween is affecting x, y,
		 * and width, and then a new tween is created while the bezier tween is in
		 * progress, and the new tween affects the "x" property, we need a way to kill
		 * just the "x" part of the bezier tween.
		 * 
		 * @private
		 * 
		 * @param lookup An object containing properties that should be overwritten. We
		 *            don't pass in an Array because looking up properties on the object
		 *            is usually faster because it gives us random access. So to overwrite
		 *            the "x" and "y" properties, a {x:true, y:true} object would be
		 *            passed in.
		 */
		public function killProperties(lookup:Object):void
		{
			var i:int = overwriteProperties.length;
			while (--i > -1)
			{
				if (overwriteProperties[i] in lookup)
				{
					overwriteProperties.splice(i, 1);
				}
			}
			
			i = _tweens.length;
			while (--i > -1)
			{
				if ((_tweens[i] as TweenVO).name in lookup)
				{
					_tweens.splice(i, 1);
				}
			}
		}
		
		
		/**
		 * Handles integrating the plugin into the tweening platform.
		 * 
		 * @private
		 * 
		 * @param plugin An Array of Plugin classes (that all extend TweenPlugin) to be
		 *            activated. For example, TweenPlugin.activate([FrameLabelPlugin,
		 *            ShortRotationPlugin, TintPlugin]);
		 */
		public static function activate(plugins:Array):Boolean
		{
			if (!plugins) return false;
			Tween.onPluginEvent = onTweenEvent;
			var i:int = plugins.length;
			
			while (i--)
			{
				var clazz:Class = plugins[i];
				var instance:Object = new clazz();
				if (instance is TweenPlugin)
				{
					//trace("instance: " + instance);
					Tween.plugins[(instance as TweenPlugin).propertyName] = clazz;
				}
			}
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * In most cases, your custom updating code should go here. The changeFactor value
		 * describes the amount of change based on how far along the tween is and the ease
		 * applied. It will be zero at the beginning of the tween and 1 at the end, but
		 * inbetween it could be any value based on the ease applied (for example, an
		 * Elastic tween would cause the value to shoot past 1 and back again before the
		 * end of the tween) This value gets updated on every frame during the course of
		 * the tween.
		 * 
		 * @private
		 * 
		 * @param v Multiplier describing the amount of change that should be applied. It
		 *            will be zero at the beginning of the tween and 1 at the end, but
		 *            inbetween it could be any value based on the ease applied (for
		 *            example, an Elastic tween would cause the value to shoot past 1 and
		 *            back again before the end of the tween)
		 */
		public function get changeFactor():Number
		{
			return _changeFactor;
		}
		public function set changeFactor(v:Number):void
		{
			updateTweens(v);
			_changeFactor = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * This method is called inside TweenLite after significant events occur, like
		 * when a tween has finished initializing, when it has completed, and when its
		 * "enabled" property changes. For example, the MotionBlurPlugin must run after
		 * normal x/y/alpha PropTweens are rendered, so the "init" event reorders the
		 * PropTweens linked list in order of priority. Some plugins need to do things
		 * when a tween completes or when it gets disabled. Again, this method is only for
		 * internal use inside TweenLite. It is separated into this static method in order
		 * to minimize file size inside TweenLite.
		 * 
		 * @private
		 * 
		 * @param type The type of event "onInitAllProps", "onComplete", "onEnable", or
		 *            "onDisable"
		 * @param tween The TweenLite/Max instance to which the event pertains
		 * @return A Boolean value indicating whether or not properties of the tween's
		 *         target may have changed as a result of the event
		 */
		private static function onTweenEvent(type:String, tween:Tween):Boolean
		{
			var vo:TweenVO = tween.cachedVO;
			var changed:Boolean = false;
			
			if (type == ON_INIT_ALL_PROPERTIES)
			{
				/* Sorts the PropTween linked list in order of priority because some
				 * plugins need to render earlier/later than others, like MotionBlurPlugin
				 * applies its effects after all x/y/alpha tweens have rendered on each frame. */
				var tweens:Array = [];
				var i:int = 0;
				while (vo)
				{
					tweens[i++] = vo;
					vo = vo.next;
				}
				tweens.sortOn("priority", Array.NUMERIC | Array.DESCENDING);
				while (--i > -1)
				{
					TweenVO(tweens[i]).next = tweens[i + 1];
					TweenVO(tweens[i]).prev = tweens[i - 1];
				}
				vo = tween.cachedVO = tweens[0];
			}
			
			while (vo)
			{
				if (vo.plugin && vo.target[type])
				{
					if (vo.plugin.activeDisable) changed = true;
					vo.plugin[type]();
				}
				vo = vo.next;
			}
			return changed;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Offers a simple way to add tweening values to the plugin. You don't need to use
		 * this, but it is convenient because the tweens get updated in the updateTweens()
		 * method which also handles rounding. killProps() nicely integrates with most
		 * tweens added via addTween() as well, but if you prefer to handle this manually
		 * in your plugin, you're welcome to.
		 * 
		 * @private
		 * 
		 * @param object target object whose property you'd like to tween. (i.e. myClip)
		 * @param propertyName the property name that should be tweened. (i.e. "x")
		 * @param start starting value
		 * @param end end value (can be either numeric or a string value. If it's a
		 *            string, it will be interpreted as relative to the starting value)
		 * @param overwriteProperty name of the property that should be associated with the
		 *            tween for overwriting purposes. Normally, it's the same as propName,
		 *            but not always. For example, you may tween the "changeFactor"
		 *            property of a VisiblePlugin, but the property that it's actually
		 *            controling in the end is "visible", so if a new overlapping tween of
		 *            the target object is created that affects its "visible" property,
		 *            this allows the plugin to kill the appropriate tween(s) when
		 *            killProps() is called.
		 */
		protected function addTween(object:Object, propertyName:String, start:Number, end:*,
			overwriteProperty:String = null):void
		{
			if (end != null)
			{
				var change:Number = (typeof(end) == "number") ? Number(end) - start : Number(end);
				/* Don't tween values that aren't changing! It's a waste of CPU cycles */
				if (change != 0)
				{
					_tweens[_tweens.length] = new TweenVO(object, propertyName, start, change,
						overwriteProperty || propertyName);
				}
			}
		}
		
		
		/**
		 * Updates all the tweens in the tweens Array.
		 * 
		 * @private
		 * 
		 * @param changeFactor Multiplier describing the amount of change that should be
		 *            applied. It will be zero at the beginning of the tween and 1 at the
		 *            end, but inbetween it could be any value based on the ease applied
		 *            (for example, an Elastic tween would cause the value to shoot past 1
		 *            and back again before the end of the tween)
		 */
		protected function updateTweens(changeFactor:Number):void
		{
			var i:int = _tweens.length;
			
			if (roundProperties)
			{
				while (--i > -1)
				{
					var vo:TweenVO = _tweens[i];
					var v:Number = vo.start + (vo.change * changeFactor);
					if (v > 0)
					{
						// 4 times as fast as Math.round()
						vo.target[vo.property] = (v + 0.5) >> 0;
					}
					else
					{
						// 4 times as fast as Math.round()
						vo.target[vo.property] = (v - 0.5) >> 0;
					}
				}
			}
			else
			{
				while (--i > -1)
				{
					vo = _tweens[i];
					vo.target[vo.property] = vo.start + (vo.change * changeFactor);
				}
			}
		}
	}
}
