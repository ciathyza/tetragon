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
	 * Detects if the SWF's embed location matches the specified domain.
	 *
	 * @param location The DisplayObject to compare location of.
	 * @param domain The web domain.
	 * @return true if the file's embed location matched passed domain; otherwise false.
	 * 
	 * @example
	 * To check for domain:
	 * <pre>
	 *     trace(isDomain(_root, "google.com"));
	 *     trace(isDomain(_root, "bbc.co.uk"));
	 * </pre>
	 * 
	 * You can also check for subdomains:
	 * <pre>
	 *     trace(isDomain(_root, "subdomain.foo.com"))
	 * </pre>
	 */
	public function isDomain(location:DisplayObject, domain:String):Boolean
	{
		return getDomain(location).slice(-domain.length) == domain;
	}
}
