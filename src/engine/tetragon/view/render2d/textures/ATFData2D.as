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
package tetragon.view.render2d.textures
{
	import flash.display3D.Context3DTextureFormat;
	import flash.utils.ByteArray;
	
	
	/**
	 * A parser for the ATF data format.
	 */
	internal class ATFData2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _format:String;
		private var _width:int;
		private var _height:int;
		private var _numTextures:int;
		private var _data:ByteArray;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Create a new instance by parsing the given byte array.
		 * 
		 * @param data
		 */
		public function ATFData2D(data:ByteArray)
		{
			var signature:String = String.fromCharCode(data[0], data[1], data[2]);
			if (signature != "ATF") throw new ArgumentError("Invalid ATF data");
			
			switch (data[6])
			{
				case 0:
				case 1:
					_format = Context3DTextureFormat.BGRA;
					break;
				case 2:
				case 3:
					_format = Context3DTextureFormat.COMPRESSED;
					break;
				case 4:
				case 5:
					_format = Context3DTextureFormat.COMPRESSED_ALPHA;
					break;
				default:
					throw new Error("Invalid ATF format!");
			}
			
			_width = Math.pow(2, data[7]);
			_height = Math.pow(2, data[8]);
			_numTextures = data[9];
			_data = data;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get format():String
		{
			return _format;
		}


		public function get width():int
		{
			return _width;
		}


		public function get height():int
		{
			return _height;
		}


		public function get numTextures():int
		{
			return _numTextures;
		}


		public function get data():ByteArray
		{
			return _data;
		}
	}
}
