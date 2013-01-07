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
package tetragon.input
{
	/**
	 * Static class that holds a table of common key name/key code pairs.
	 */
	public final class KeyCodes
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const CHAR_RANGE_START:int = 32;
		public static const CHAR_RANGE_END:int = 255;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _keyCodes:Object =
		{
			"backspace":	8,
			"tab":			9,
			"return":		13,
			"enter":		13,
			"shift":		16,
			"lshift":		16,
			"rshift":		16,
			"ctrl":			17,
			"lctrl":		17,
			"rctrl":		17,
			"control":		17,
			"lcontrol":		17,
			"rcontrol":		17,
			"alt":			18,
			"lalt":			18,
			"ralt":			18,
			"pause":		19,
			"capslock":		20,
			"escape":		27,
			"esc":			27,
			"space":		32,
			"pageup":		33,
			"pagedown":		34,
			"end":			35,
			"home":			36,
			"cursorleft":	37,
			"cursorup":		38,
			"cursorright":	39,
			"cursordown":	40,
			"insert":		45,
			"delete":		46,
			"del":			46,
			
			"0":			48,
			"1":			49,
			"2":			50,
			"3":			51,
			"4":			52,
			"5":			53,
			"6":			54,
			"7":			55,
			"8":			56,
			"9":			57,
			
			"a":			65,
			"b":			66,
			"c":			67,
			"d":			68,
			"e":			69,
			"f":			70,
			"g":			71,
			"h":			72,
			"i":			73,
			"j":			74,
			"k":			75,
			"l":			76,
			"m":			77,
			"n":			78,
			"o":			79,
			"p":			80,
			"q":			81,
			"r":			82,
			"s":			83,
			"t":			84,
			"u":			85,
			"v":			86,
			"w":			87,
			"x":			88,
			"y":			89,
			"z":			90,
			
			"winkey":		91,
			"win":			91,
			"winleft":		91,
			"winright":		92,
			
			"numpad0":		96,
			"numpad1":		97,
			"numpad2":		98,
			"numpad3":		99,
			"numpad4":		100,
			"numpad5":		101,
			"numpad6":		102,
			"numpad7":		103,
			"numpad8":		104,
			"numpad9":		105,
			"numpad*":		106,
			"numpadplus":	107,
			"numpad-":		109,
			"numpad.":		110,
			"numpad/":		111,
			
			"f1":			112,
			"f2":			113,
			"f3":			114,
			"f4":			115,
			"f5":			116,
			"f6":			117,
			"f7":			118,
			"f8":			119,
			"f9":			120,
			"f10":			121,
			"f11":			122,
			"f12":			123,
			"numlock":		144,
			"scrolllock":	145,
			
			";":			186,
			"=":			187,
			",":			188,
			"-":			189,
			".":			190,
			"/":			191,
			"tilde":		192,
			"[":			219,
			"\\":			220,
			"]":			221,
			"'":			222
		};
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the keycode for the specified key name if it is found in
		 * the key codes table. A key name is a standard identifier used to
		 * identify keys or key combinations (e.g. 'page_up'). The character
		 * case is irrelevant here, i.e. PAGE_UP is the same as page_up.
		 * 
		 * @param keyString the name of the key for that the key code should be returned.
		 * @return the key code or -1 if the key name was not found in the code table.
		 */
		public static function getKeyCode(keyString:String):int
		{
			if (keyString == null || keyString.length < 1) return -1;
			var code:* = _keyCodes[keyString.toLowerCase()];
			if (!code) return -1;
			return code;
		}
		
		
		/**
		 * Returns the key string for the specified key code.
		 */
		public static function getKeyString(keyCode:uint):String
		{
			for (var s:String in _keyCodes)
			{
				if (_keyCodes[s] == keyCode) return s;
			}
			return null;
		}
		
		
		/**
		 * Checks if the specified keyCode belongs to a printable ASCII character.
		 * 
		 * @param keyCode The key code to be checked.
		 * @return true if the key code is a printable character, false if not.
		 */
		public static function isCharacter(keyCode:int):Boolean
		{
			if (keyCode >= CHAR_RANGE_START && keyCode <= CHAR_RANGE_END) return true;
			return false;
		}
	}
}
