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
	import com.hexagonstar.util.reflection.getClassName;

	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	
	/**
	 * Base class for UI Themes which defines fonts, textformats, UIComponent styles
	 * and sounds of a UI theme.
	 */
	public class UITheme implements IUIComponentTheme
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _themeManager:UIThemeManager;
		/** @private */
		protected var _name:String;
		/** @private */
		protected var _textFormats:TextFormats;
		/** @private */
		protected var _uiStyles:Dictionary;
		/** @private */
		protected var _colors:Object;
		/** @private */
		protected var _sounds:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function UITheme()
		{
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the text format that is mapped with the specified ID or null if
		 * no text format was mapped with that ID.
		 * 
		 * @param id
		 * @return A TextFormat object or null.
		 */
		public function getTextFormat(id:String):TextFormat
		{
			return _textFormats.getFormat(id);
		}
		
		
		/**
		 * Returns the default text format.
		 */
		public function getDefaultTextFormat():TextFormat
		{
			return _textFormats.getFormat(TextFormats.DEFAULT_FORMAT_ID);
		}
		
		
		/**
		 * Returns the debug text format.
		 */
		public function getDebugTextFormat():TextFormat
		{
			return _textFormats.getFormat(TextFormats.DEBUG_FORMAT_ID);
		}
		
		
		public function getColor(colorID:String):uint
		{
			if (!_colors) return 0;
			return _colors[colorID];
		}
		
		
		public function getSound(soundID:String):Class
		{
			if (!_sounds) return null;
			return _sounds[soundID];
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The name of the theme.
		 */
		public function get name():String
		{
			return _name;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get textFormats():TextFormats
		{
			return _textFormats;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get uiStyles():Dictionary
		{
			return _uiStyles;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get colors():Object
		{
			return _colors;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get sounds():Object
		{
			return _sounds;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function init():void
		{
			_themeManager = UIThemeManager.instance;
			_textFormats = new TextFormats();
			
			/* Map default text formats. */
			_textFormats.addFormat(TextFormats.DEFAULT_FORMAT_ID, "Bitstream Vera Sans", 16, 0xDDDDDD);
			_textFormats.addFormat(TextFormats.DEBUG_FORMAT_ID, "Terminalscope", 16, 0xFFFFFF,
				0, 0, null, false, false, false, false, 4, 4, 0);
			
			setup();
			addFonts();
			addTextFormats();
			addUIStyles();
			addColors();
			addSounds();
		}
		
		
		/**
		 * @private
		 */
		protected function setup():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register fonts that are needed for the theme.
		 * @private
		 */
		protected function addFonts():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register text formats that are needed for the theme.
		 * @private
		 */
		protected function addTextFormats():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register UI component styles that are needed for the theme.
		 * @private
		 */
		protected function addUIStyles():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register colors that are needed for the theme.
		 * @private
		 */
		protected function addColors():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register UI sounds that are needed for the theme.
		 * @private
		 */
		protected function addSounds():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Adds a font to the theme.
		 * 
		 * @param fontClass
		 */
		protected function addFont(fontClass:Class):void
		{
			_themeManager.registerFont(fontClass);
		}
		
		
		/**
		 * Adds a text format to the theme.
		 * 
		 * @param id
		 * @param font
		 * @param size
		 * @param color
		 * @param letterSpacing
		 * @param leading
		 * @param align
		 * @param bold
		 * @param italic
		 * @param underline
		 * @param kerning
		 * @param leftMargin
		 * @param rightMargin
		 * @param indent
		 * @return TextFormat object
		 */
		protected function addTextFormat(id:String, font:String, size:int = 12,
			color:uint = 0x000000, letterSpacing:Number = 0, leading:int = 0, align:String = null,
			bold:Boolean = false, italic:Boolean = false, underline:Boolean = false,
			kerning:Boolean = false, leftMargin:int = 0, rightMargin:int = 0,
			indent:int = 0):void
		{
			_textFormats.addFormat(id, font, size, color, letterSpacing, leading,
				align, bold, italic, underline, kerning, leftMargin, rightMargin, indent);
		}
		
		
		/**
		 * Adds a UI style to the theme.
		 * 
		 * @param componentClass
		 * @param styleName
		 * @param styleValue
		 */
		protected function addUIStyle(componentClass:Class, styleName:String, styleValue:*):void
		{
			if (!_uiStyles) _uiStyles = new Dictionary();
			var componentStyles:Object = _uiStyles[componentClass] ? _uiStyles[componentClass] : {};
			componentStyles[styleName] = styleValue;
			_uiStyles[componentClass] = componentStyles;
		}
		
		
		/**
		 * Adds a sound to the theme.
		 * 
		 * @param colorID
		 * @param value
		 */
		protected function addColor(colorID:String, value:uint):void
		{
			if (!_colors) _colors = {};
			_colors[colorID] = value;
		}
		
		
		/**
		 * Adds a sound to the theme.
		 * 
		 * @param soundID
		 * @param soundClass
		 */
		protected function addSound(soundID:String, soundClass:Class):void
		{
			if (!_sounds) _sounds = {};
			_sounds[soundID] = soundClass;
		}
	}
}
