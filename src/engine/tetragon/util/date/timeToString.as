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
package tetragon.util.date
{
	/**
	 * Formats a specified amount of seconds as a time string with the format
	 * MM:SS or HH:MM:SS.
	 * 
	 * @param seconds The seconds value to format.
	 * @param showHours Whether to show hours or not.
	 * @param div The divider character.
	 * @return A time formatted string.
	 */
	public function timeToString(seconds:Number, showHours:Boolean = false, div:String = ":"):String
	{
		var h:String = "";
		if (showHours)
		{
			var ehs:uint = 0;
			if (seconds > 86399) ehs = 24 * (seconds / (24 * 60 * 60));
			h = "" + uint(ehs + ((seconds / (60 * 60)) % 24));
			if (h.length < 2) h = "0" + h;
			h += div;
		}
		var m:String = "" + uint((seconds / 60) % 60);
		var s:String = "" + uint(seconds % 60);
		if (m.length < 2) m = "0" + m;
		if (s.length < 2) s = "0" + s;
		return h + m + div + s;
	}
}
