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
	import tetragon.debug.Log;

	import com.hexagonstar.util.color.colorHexToString;
	import com.hexagonstar.util.string.TabularText;

	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	public final class TextFormats
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const DEFAULT_FORMAT_ID:String = "defaultFormat";
		public static const DEBUG_FORMAT_ID:String = "debugFormat";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Map with TextFormat objects.
		 * @private
		 */
		private var _formats:Object;
		
		/**
		 * Mapped textformat count.
		 * @private
		 */
		private var _count:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function TextFormats()
		{
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to add text formats. Only used internally, add new text formats vis the
		 * setup classes!
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
		 * @return true or false.
		 */
		public function addFormat(id:String, font:String, size:int = 12,
			color:uint = 0x000000, letterSpacing:Number = 0, leading:int = 0, align:String = null,
			bold:Boolean = false, italic:Boolean = false, underline:Boolean = false,
			kerning:Boolean = false, leftMargin:int = 0, rightMargin:int = 0,
			indent:int = 0):Boolean
		{
			if (_formats[id])
			{
				return false;
			}
			
			if (align == null) align = TextFormatAlign.LEFT;
			var format:TextFormat = new TextFormat(font, size, color, bold, italic, underline, null,
				null, align, leftMargin, rightMargin, indent, leading);
			format.letterSpacing = letterSpacing;
			format.kerning = kerning;
			_formats[id] = format;
			_count++;
			
			return true;
		}
		
		
		/**
		 * Returns the text format that is mapped with the specified ID or null if
		 * no text format was mapped with that ID.
		 * 
		 * @param id
		 * @return A TextFormat object or null.
		 */
		public function getFormat(id:String):TextFormat
		{
			if (_formats[id]) return _formats[id];
			
			Log.warn("getFormat(" + id + "): Text format not found! Using default format instead.", this);
			return _formats[DEFAULT_FORMAT_ID];
		}
		
		
		/**
		 * Removes a mapped text format.
		 * 
		 * @param id
		 */
		public function removeFormat(id:String):void
		{
			if (_formats[id])
			{
				delete _formats[id];
				_count--;
			}
		}
		
		
		/**
		 * Returns a string dump of all mapped text formats.
		 */
		public function dump():String
		{
			var t:TabularText = new TabularText(6, true, "  ", null, "  ", 0, ["ID", "FONT", "SIZE", "COLOR", "BOLD", "ITALIC"]);
			for (var id:String in _formats)
			{
				var f:TextFormat = _formats[id];
				var c:String = f.color ? "0x" + colorHexToString(uint(f.color)) : "null";
				t.add([id, f.font, f.size, c, f.bold, f.italic]);
			}
			return toString() + " (" + _count + "):\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "TextFormats";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Map of registered text formats. Contains TextFormat objects.
		 */
		public function get formats():Object
		{
			return _formats;
		}
		
		
		/**
		 * Amount of currently mapped text formats.
		 */
		public function get count():uint
		{
			return _count;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			_formats = {};
			_count = 0;
		}
	}
}
