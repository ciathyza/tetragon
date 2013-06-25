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
package tetragon.util.json
{
	public final class JSONToken
	{
		/**
		 * The type of the token.
		 */
		public var type:int;
		/**
		 * The value of the token
		 */
		public var value:Object;


		/**
		 * Creates a new JSONToken with a specific token type and value.
		 *
		 * @param type The JSONTokenType of the token
		 * @param value The value of the token
		 */
		public function JSONToken(type:int = -1 /* JSONTokenType.UNKNOWN */, value:Object = null)
		{
			this.type = type;
			this.value = value;
		}


		/**
		 * Reusable token instance.
		 * 
		 * @see #create()
		 */
		internal static const token:JSONToken = new JSONToken();


		/**
		 * Factory method to create instances.  Because we don't need more than one instance
		 * of a token at a time, we can always use the same instance to improve performance
		 * and reduce memory consumption during decoding.
		 */
		internal static function create(type:int = -1 /* JSONTokenType.UNKNOWN */, value:Object = null):JSONToken
		{
			token.type = type;
			token.value = value;

			return token;
		}
	}
}
