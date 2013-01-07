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
package tetragon.data
{
	import com.hexagonstar.types.IDisposable;
	import com.hexagonstar.util.reflection.getClassNameWithParams;
	
	
	/**
	 * Abstract base class for all data objects.
	 */
	public class DataObject implements IDisposable
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _id:String;
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Returns a string representation of the object. Optionally a number of arguments
		 * can be specified, typically properties that are output together with the object
		 * name to provide additional information about the object.
		 * 
		 * @example
		 * <pre>
		 *    // overriden toString method to include a size property:
		 *    override public function toString(...args):String
		 *    {
		 *        return super.toString("size=" + size);
		 *    }
		 * </pre>
		 * 
		 * @param args an optional, comma-delimited list of class properties that should be
		 *            output together with the object name.
		 * @return A string representation of the object.
		 */
		public function toString(...args):String
		{
			if (args.length < 1) return getClassNameWithParams(this, "id=" + _id);
			return getClassNameWithParams(this, args);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The unique ID of the data object.
		 */
		public function get id():String
		{
			return _id;
		}
		public function set id(v:String):void
		{
			_id = v;
		}
	}
}
