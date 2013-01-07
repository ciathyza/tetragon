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
package tetragon.file.writers
{
	import tetragon.Main;
	import tetragon.data.Config;
	import tetragon.debug.Log;
	import tetragon.util.file.getUserDataPath;

	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Timer;
	
	
	/**
	 * LogFileWriter class
	 */
	public final class LogFileWriter
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _file:File;
		/** @private */
		private var _stream:FileStream;
		/** @private */
		private var _open:Boolean;
		/** @private */
		private var _buffer:Vector.<String>;
		/** @private */
		private var _timer:Timer;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function LogFileWriter()
		{
			var main:Main = Main.instance;
			var path:String = getUserDataPath()
				+ File.separator + main.registry.config.getString(Config.USER_LOGS_FOLDER)
				+ File.separator + main.appInfo.filename + ".log";
			
			_file = File.documentsDirectory.resolvePath(path);
			_stream = new FileStream();
			_stream.addEventListener(IOErrorEvent.IO_ERROR, onStreamError);
			_buffer = new Vector.<String>();
			
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Appends text to the log file.
		 */
		public function append(text:String):void
		{
			_buffer.push(text);
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			onTimer(null);
			_stream.removeEventListener(IOErrorEvent.IO_ERROR, onStreamError);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onTimer(e:TimerEvent):void
		{
			if (_buffer.length < 1) return;
			
			/* Prepare write buffer. */
			var text:String = "";
			for (var i:uint = 0; i < _buffer.length; i++)
			{
				text += _buffer[i] + "\n";
			}
			_buffer = new Vector.<String>();
			
			/* Flush buffer to file. */
			if (!_open)
			{
				_stream.openAsync(_file, FileMode.APPEND);
				_open = true;
			}
			_stream.writeUTFBytes(text);
			_stream.close();
			_open = false;
		}
		
		
		/**
		 * @private
		 */
		private function onStreamError(e:IOErrorEvent):void
		{
			Log.error(e.text, this);
		}
	}
}
