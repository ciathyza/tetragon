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
package tetragon.util.json
{
	/**
	 * Class containing constant values for the different types of tokens in a JSON
	 * encoded string.
	 */
	public final class JSONTokenType
	{
		// -----------------------------------------------------------------------------------------
		// Constants
		// -----------------------------------------------------------------------------------------
		
		public static const UNKNOWN:int = -1;
		public static const COMMA:int = 0;
		public static const LEFT_BRACE:int = 1;
		public static const RIGHT_BRACE:int = 2;
		public static const LEFT_BRACKET:int = 3;
		public static const RIGHT_BRACKET:int = 4;
		public static const COLON:int = 6;
		public static const TRUE:int = 7;
		public static const FALSE:int = 8;
		public static const NULL:int = 9;
		public static const STRING:int = 10;
		public static const NUMBER:int = 11;
		public static const NAN:int = 12;
	}
}
