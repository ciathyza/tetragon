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
package tetragon.core.file
{
	import tetragon.core.file.types.IFile;
	
	
	/**
	 * A value object used to transmit file bulk progress statistics.
	 */
	public class BulkProgress
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		internal var _file:IFile;
		/** @private */
		internal var _filesLoading:uint;
		/** @private */
		internal var _filesLoaded:uint;
		/** @private */
		internal var _filesFailed:uint;
		/** @private */
		internal var _filesTotal:uint;
		/** @private */
		internal var _bytesLoaded:Number;
		/** @private */
		internal var _bytesTotal:Number;
		/** @private */
		internal var _weightedPercentage:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function BulkProgress(filesTotal:uint)
		{
			_filesTotal = filesTotal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function dump():String
		{
			var s:String = "---------------------------------------";
			s += "\nCurrent File:\t" + _file.path;
			s += "\nfilesTotal:\t\t" + _filesTotal;
			s += "\nfilesLoaded:\t" + _filesLoaded;
			s += "\nfilesFailed:\t" + _filesFailed;
			s += "\nfilesLoading:\t" + _filesLoading;
			s += "\nbytesLoaded:\t" + _bytesLoaded;
			s += "\nbytesTotal:\t\t" + _bytesTotal;
			s += "\npercentage:\t\t" + percentage + "%";
			s += "\nratio:\t\t\t" + ratio;
			s += "\nratioPercent:\t" + ratioPercentage + "%";
			s += "\nweightPercent:\t" + _weightedPercentage + "%";
			return s;
		}
		
		
		/**
		 * @private
		 */
		internal function reset():void
		{
			_filesLoading = _filesLoaded = _filesFailed = _bytesLoaded = _bytesTotal =
			_weightedPercentage = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The file in the bulk that is currently loading.
		 */
		public function get file():IFile
		{
			return _file;
		}
		
		
		/**
		 * The number of files in the bulk that are currently loading.
		 */
		public function get filesLoading():uint
		{
			return _filesLoading;
		}
		
		
		/**
		 * The number of files in the bulk that have been loaded.
		 */
		public function get filesLoaded():uint
		{
			return _filesLoaded;
		}
		
		
		/**
		 * The number of files in the bulk that have failed to load.
		 */
		public function get filesFailed():uint
		{
			return _filesFailed;
		}
		
		
		/**
		 * The total number of files in the bulk.
		 */
		public function get filesTotal():uint
		{
			return _filesTotal;
		}
		
		
		/**
		 * The number of bytes that have so far been loaded, including all files in the bulk.
		 */
		public function get bytesLoaded():Number
		{
			return _bytesLoaded;
		}
		
		
		/**
		 * The number of total bytes of all files in the bulk.
		 */
		public function get bytesTotal():Number
		{
			return _bytesTotal;
		}
		
		
		/**
		 * The percentage of loaded bytes, including all files in the bulk.
		 */
		public function get percentage():uint
		{
			return (_bytesLoaded / _bytesTotal) * 100;
		}
		
		
		/**
		 * The ratio of loaded files, including all files in the bulk.
		 */
		public function get ratio():Number
		{
			return _filesLoaded / _filesTotal;
		}
		
		
		/**
		 * The ratio of loaded files in percent, including all files in the bulk.
		 */
		public function get ratioPercentage():uint
		{
			return ratio * 100;
		}
		
		
		public function get weightedPercentage():uint
		{
			return _weightedPercentage;
		}
	}
}
