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
package tetragon.core.tween.easing
{
	/**
	 * Ease enables you to find the easing function associated with a particular
	 * name (String), like "strongEaseOut" which can be useful when loading in XML data
	 * that comes in as Strings but needs to be translated to native function references.
	 */
	public final class Ease
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const BACK:String			= "back";
		public static const BOUNCE:String		= "bounce";
		public static const CIRCULAR:String		= "circular";
		public static const CUBIC:String		= "cubic";
		public static const ELASTIC:String		= "elastic";
		public static const EXPO:String			= "expo";
		public static const LINEAR:String		= "linear";
		public static const QUAD:String			= "quad";
		public static const QUART:String		= "quart";
		public static const QUINT:String		= "quint";
		public static const SINE:String			= "sine";
		
		public static const EASE_IN:String		= "easeIn";
		public static const EASE_OUT:String		= "easeOut";
		public static const EASE_INOUT:String	= "easeInOut";
		public static const EASE_NONE:String	= "easeNone";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static var _lookup:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Gets the easing function associated with a particular name (String), like
		 * "strongEaseOut". This can be useful when loading in XML data that comes in as
		 * Strings but needs to be translated to native function references. You can pass
		 * in the name with or without the period, and it is case insensitive, so any of
		 * the following will find the Strong.easeOut function: <br /><br /><code>
		 * EaseLookup.find("Strong.easeOut") <br /> EaseLookup.find("strongEaseOut") <br
		 * /> EaseLookup.find("strongeaseout") <br /><br /></code>
		 * 
		 * You can translate Strings directly when tweening, like this: <br /><code>
		 * TweenLite.to(mc, 1, {x:100, ease:EaseLookup.find(myString)});<br /><br
		 * /></code>
		 * 
		 * @param name The name of the easing function, case insensitive.
		 * @param mode Mode of the ease.
		 * @return The easing function associated with the name.
		 */
		public static function get(name:String, mode:String = EASE_OUT):Function
		{
			if (!_lookup) buildLookup();
			return _lookup[(name + "." + mode).toLowerCase()];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function buildLookup():void
		{
			_lookup = {};
			addInOut(Back,		[BACK]);
			addInOut(Bounce,	[BOUNCE]);
			addInOut(Circ,		[CIRCULAR,	"circ"]);
			addInOut(Cubic,		[CUBIC]);
			addInOut(Elastic,	[ELASTIC]);
			addInOut(Expo,		[EXPO,		"exponential"]);
			addInOut(Linear,	[LINEAR]);
			addInOut(Quad,		[QUAD,		"quadratic"]);
			addInOut(Quart,		[QUART,		"quartic"]);
			addInOut(Quint,		[QUINT,		"quintic", "strong"]);
			addInOut(Sine,		[SINE]);
			_lookup["linear.easenone"] = Linear.easeNone;
		}
		
		
		/**
		 * @private
		 * 
		 * @param easeClass
		 * @param names
		 */
		private static function addInOut(easeClass:Class, names:Array):void
		{
			var i:int = names.length;
			while (i-- > 0)
			{
				var name:String = (names[i] as String).toLowerCase();
				_lookup[name + ".easein"] = easeClass['easeIn'];
				_lookup[name + ".easeout"] = easeClass['easeOut'];
				_lookup[name + ".easeinout"] = easeClass['easeInOut'];
			}
		}
	}
}
