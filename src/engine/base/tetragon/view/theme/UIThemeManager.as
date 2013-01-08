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
package tetragon.view.theme
{
	import lib.fonts.BitstreamVeraSansBoldFont;
	import lib.fonts.BitstreamVeraSansFont;
	import lib.fonts.TerminalscopeFont;
	import lib.fonts.TerminalscopeInverseFont;

	import tetragon.debug.Log;

	import com.hexagonstar.exception.SingletonException;
	import com.hexagonstar.util.string.stringIsEmptyOrNull;

	import flash.text.Font;
	import flash.utils.Dictionary;
	
	
	/**
	 * UIThemeManager class
	 */
	public class UIThemeManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _instance:UIThemeManager;
		/** @private */
		private static var _singletonLock:Boolean;
		
		/** @private */
		private var _fonts:Dictionary;
		
		/** @private */
		private var _themes:Object;
		/** @private */
		private var _currentTheme:UITheme;
		/** @private */
		private var _currentThemeID:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function UIThemeManager()
		{
			if (!_singletonLock) throw new SingletonException(this);
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a theme for later use.
		 * 
		 * @param themeID
		 * @param themeClass
		 * @param activate If true, activates the theme instantly.
		 * @return true of false.
		 */
		public function registerTheme(themeID:String, themeClass:Class,
			activate:Boolean = false):Boolean
		{
			_themes[themeID] = themeClass;
			if (activate) activateTheme(themeID);
			return true;
		}
		
		
		/**
		 * @param themeID
		 * @return A Class object or null.
		 */
		public function getThemeClass(themeID:String):Class
		{
			return _themes[themeID];
		}
		
		
		/**
		 * Sets the currently used theme.
		 * 
		 * @param themeID
		 * @return true or false.
		 */
		public function activateTheme(themeID:String):Boolean
		{
			if (stringIsEmptyOrNull(themeID) || themeID == _currentThemeID)
			{
				return false;
			}
			
			if (!_themes[themeID])
			{
				Log.warn("Could not activate theme \"" + themeID
					+ "\". No theme with this ID has been registered.", this);
				return false;
			}
			else if (!(_themes[themeID] is Class))
			{
				Log.warn("Could not activate theme \"" + themeID
					+ "\". Registered entry with this ID is not a class object.", this);
				return false;
			}
			
			var clazz:Class = _themes[themeID];
			var obj:* = new clazz();
			
			if (!(obj is UITheme))
			{
				Log.warn("Could not activate theme \"" + themeID
					+ "\". Registered class with this ID is not of type UITheme.", this);
				return false;
			}
			
			_currentThemeID = themeID;
			_currentTheme = obj;
			Log.verbose("Activated theme \"" + themeID + "\".", this);
			return true;
		}
		
		
		/**
		 * @param fontClass
		 */
		public function registerFont(fontClass:Class):void
		{
			/* Check if font was already registered. */
			if (_fonts[fontClass]) return;
			_fonts[fontClass] = true;
			Font.registerFont(fontClass);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "UIThemeManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the singleton instance of the class.
		 */
		public static function get instance():UIThemeManager
		{
			if (_instance == null)
			{
				_singletonLock = true;
				_instance = new UIThemeManager();
				_singletonLock = false;
			}
			return _instance;
		}
		
		
		/**
		 * The currently used theme.
		 */
		public function get currentTheme():UITheme
		{
			if (!_currentTheme)
			{
				activateTheme(DefaultTheme.ID);
			}
			
			return _currentTheme;
		}
		
		
		/**
		 * The ID of the currently used theme.
		 */
		public function get currentThemeID():String
		{
			return _currentThemeID;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			_fonts = new Dictionary();
			_themes = {};
			
			/* Register default fonts. */
			registerFont(TerminalscopeFont);
			registerFont(TerminalscopeInverseFont);
			registerFont(BitstreamVeraSansFont);
			registerFont(BitstreamVeraSansBoldFont);
			
			/* Register default theme. */
			registerTheme(DefaultTheme.ID, DefaultTheme, false);
		}
	}
}
