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
package tetragon.util.reflection
{
	import tetragon.util.string.TabularText;
	
	
	/**
	 * Creates and returns a tabular-formatted string that lists all public properties
	 * and accessors of the specified object. If includeType is true the type of each
	 * property is listed as well.
	 * 
	 * @param object The oblect to create a properties list from.
	 * @param includeType If true the property type is included in the list.
	 * @return A tabular-formatted string of all public properties of the object.
	 */
	public function getClassPropertyList(object:Object, includeType:Boolean = true):String
	{
		var p:Object = describeTypeProperties(object);
		var t:TabularText = includeType
			? new TabularText(3, true, "  ", null, "  ", 0, ["PROPERTY", "TYPE", "VALUE"])
			: new TabularText(2, true, "  ", null, "  ", 0, ["PROPERTY", "VALUE"]);
		for (var k:String in p)
		{
			if (includeType) t.add([k, p[k], object[k]]);
			else t.add([k, object[k]]);
		}
		return t.toString();
	}
}
