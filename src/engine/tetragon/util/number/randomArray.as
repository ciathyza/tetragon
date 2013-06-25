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
package tetragon.util.number
{
	import tetragon.core.exception.IllegalArgumentException;
	
	
	/**
	 * Returns an array that contains random integers.
	 * 
	 * @param length The length of the array.
	 * @param min The lowest possible value to return.
	 * @param max The highest possible value to return.
	 * @param uniqueValues If set to true, generated numbers are unique.
	 * @param excludedValues An optional array of integers which will NOT be returned.
	 * @return An array with pseudo-random integers between min and max.
	 */
	public function randomArray(length:uint, min:int = 0, max:int = int.MAX_VALUE,
		uniqueValues:Boolean = false, excludedValues:Array = null):Array
	{
		/* If no doubles are allowed and the length is larger than possible unique
		 * values could fill, make sure that we don't hang up with an endless loop. */
		if (uniqueValues && (max - min + 1) < length)
		{
			// TODO This check doesn't work yet if min or max is a negative value!
			throw new IllegalArgumentException("randomArray(): The length of the requested array is"
				+ " larger than the range of possible unique values (length: " + length
				+ ", min: " + min + ", max: " + max + ").");
			return null;
		}
		
		var a:Array = [];
		if (uniqueValues && !excludedValues) excludedValues = [];
		for (var i:uint = 0; i < length; i++)
		{
			var r:int = random(min, max, excludedValues);
			if (uniqueValues) excludedValues.push(r);
			a.push(r);
		}
		return a;
	}
}
