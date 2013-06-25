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
package tetragon.util.date
{
	/**
	 * Simple function to format a numeric date as a string.
	 * 
	 * @param date Date to format.
	 * @param delimiter Delimiter String.
	 * @param order Order of date string, either "mdy", "dmy" or "ymd". The default is "mdy".
	 * @return String with formatted date.
	 */
	public function formatDateAsString(date:Date, delimiter:String = ".",
		order:String = "mdy"):String
	{
		if (!date) return null;
		var day:String = date.date.toString();
		var month:String = (date.month + 1).toString();
		var year:Number = date.fullYear;
		
		if (day.length == 1) day = "0" + day;
		if (month.length == 1) month = "0" + month;
		
		if (order == "dmy") return day + delimiter + month + delimiter + year;
		else if (order == "ymd") return year + delimiter + month + delimiter + day;
		return month + delimiter + day + delimiter + year;
	}
}
