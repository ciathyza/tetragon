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
package tetragon.util.agal.macro
{
	import flash.utils.Dictionary;


	public class VM
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public var vars:Dictionary = new Dictionary();
		public var stack:Array = new Array();
		
		private var _ifIsTrue:Vector.<Boolean> = new Vector.<Boolean>();
		private var _ifWasTrue:Vector.<Boolean> = new Vector.<Boolean>();
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function pushIf():void
		{
			_ifIsTrue.push(false);
			_ifWasTrue.push(false);
		}
		
		
		public function popEndif():void
		{
			_ifIsTrue.pop();
			_ifWasTrue.pop();
		}
		
		
		public function setIf(value:Number):void
		{
			_ifIsTrue[_ifIsTrue.length - 1] = (value != 0);
			_ifWasTrue[_ifIsTrue.length - 1] = (value != 0);
		}
		
		
		public function ifWasTrue():Boolean
		{
			return _ifWasTrue[_ifIsTrue.length - 1];
		}
		
		
		public function ifIsTrue():Boolean
		{
			if (_ifIsTrue.length == 0) return true;
			
			// All ifs on the stack must be true for current true.
			for (var i:int = 0; i < _ifIsTrue.length; ++i)
			{
				if (!_ifIsTrue[i]) return false;
			}
			return true;
		}
	}
}
