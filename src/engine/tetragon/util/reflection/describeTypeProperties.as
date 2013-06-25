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
	import flash.utils.describeType;
	
	
	/**
	 * Returns an object map that has all properties (public variables and accessors)
	 * of the specified object mapped with the property name as the key and the
	 * property type as the value.
	 * 
	 * @param object Object to get property list from.
	 * @param ignoreReadOnly If true only properties with read and write access will
	 *        be returned but not read only properties.
	 * @return An object with mapped key-value pairs.
	 */
	public function describeTypeProperties(object:Object, ignoreReadOnly:Boolean = false):Object
	{
		var xml:XML = describeType(object);
		var obj:Object = {};
		for each (var x:XML in xml.*)
		{
			if ((x.name() == "variable" || x.name() == "accessor") && x.@access != "writeonly")
			{
				if (ignoreReadOnly && x.@access == "readonly") continue;
				obj[x.@name] = x.@type;
			}
		}
		return obj;
	}
}
