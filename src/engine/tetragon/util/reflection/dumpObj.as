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
package tetragon.util.reflection
{
	/**
	 * Iterates through a dynamic object and returns a String dump of all it's
	 * properties and values.
	 * 
	 * @param object Object to dump.
	 * @return A string dump.
	 */
	public function dumpObj(object:Object):String
	{
		var rows:Array = [];
		var i:uint;
		
		for (var k:String in object)
		{
			var row:String = "";
			var p:* = object[k];
			
			if (p is Array)
			{
				var a:Array = p;
				row += k + " (Array, length: " + a.length + ")\n";
				for (i = 0; i < a.length; i++)
				{
					row += "\t" + i + ". " + a[i] + "\n";
				}
			}
			else if (p is Vector)
			{
				var v:Array = p;
				row += k + " (Vector, length: " + v.length + ")\n";
				for (i = 0; i < v.length; i++)
				{
					row += "\t" + i + ". " + v[i] + "\n";
				}
			}
			else if (p is String || p is Number || p is int || p is uint || p is Boolean || p == null)
			{
				row += k + ": " + p + "\n";
			}
			else
			{
				row += dumpObj(p);
			}
			
			rows.push(row);
		}
		
		rows = rows.sort(Array.CASEINSENSITIVE);
		var result:String = "";
		for (i = 0; i < rows.length; i++)
		{
			result += rows[i];
		}
		
		return result;
	}
}
