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
	 * This class provides encoding and decoding of the JSON format.
	 *
	 * Example usage:
	 * <code>
	 * 		// create a JSON string from an internal object
	 * 		JSON.encode( myObject );
	 *
	 *		// read a JSON string into an internal object
	 *		var myObject:Object = JSON.decode( jsonString );
	 *	</code>
	 */
	public final class LegacyJSON
	{
		/**
		 * Encodes a object into a JSON string.
		 *
		 * @param o The object to create a JSON string for
		 * @return the JSON string representing o
		 */
		public static function encode(o:Object):String
		{
			return new JSONEncoder(o).getString();
		}


		/**
		 * Decodes a JSON string into a native object.
		 *
		 * @param s The JSON string representing the object
		 * @param strict Flag indicating if the decoder should strictly adhere
		 * 		to the JSON standard or not.  The default of <code>true</code>
		 * 		throws errors if the format does not match the JSON syntax exactly.
		 * 		Pass <code>false</code> to allow for non-properly-formatted JSON
		 * 		strings to be decoded with more leniancy.
		 * @return A native object as specified by s
		 * @throw JSONParseError
		 */
		public static function decode(s:String, strict:Boolean = true):*
		{
			return new JSONDecoder(s, strict).getValue();
		}
	}
}
