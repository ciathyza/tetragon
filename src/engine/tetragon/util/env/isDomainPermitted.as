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
package tetragon.util.env
{
	import flash.display.DisplayObject;
	
	
	/**
	 * Check if the web domain the SWF is currently running on is permitted to
	 * play the SWF. When not ran on a web server always returns true.
	 * 
	 * @param location Location of the loaderInfo.url, usually stage.
	 * @param allowedDomains An array of allowed domains, or domain parts.
	 * @return true or false.
	 */
	public function isDomainPermitted(location:DisplayObject, allowedDomains:Array):Boolean
	{
		if (!location || !isWeb(location)) return true;
		if (!allowedDomains || allowedDomains.length == 0) return true;
		
		var locked:Boolean = true;
		for each (var s:String in allowedDomains)
		{
			if (isDomain(location, s))
			{
				locked = false;
				break;
			}
		}
		return !locked;
	}
}
