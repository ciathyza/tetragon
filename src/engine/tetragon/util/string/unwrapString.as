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
package tetragon.util.string
{
	/**
	 * Unwraps a string that contains multiline text. Any leading and trailing spaces or
	 * tabs are removed from each line, then the lines are unwrapped (LFs and CRs are
	 * removed) and then the function adds a space to every line that doesn't end with a
	 * 'br' HTML tag.
	 * 
	 * @param string The string to unwrap.
	 * @return The unwrapped string or <code>null</code> if the specified string is null.
	 */
	public function unwrapString(string:String):String
	{
		if (string == null) return null;
		var lines:Array = string.split("\n");
		for (var i:uint = 0; i < lines.length; i++)
		{
			lines[i] = String(lines[i]).replace(/^\s+|\s+$/g, "");
			if (!(RegExp(/<br\/>$/).test(String(lines[i]))))
			{
				lines[i] += " ";
			}
		}
		string = lines.join("");
		if (string.substr(-1, 1) == " ") string = string.substr(0, string.length - 1);
		return string;
	}
}
