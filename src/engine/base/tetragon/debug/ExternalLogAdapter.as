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
package tetragon.debug
{
	import com.hexagonstar.util.debug.Debug;

	import flash.display.Stage;
	
	
	/**
	 * ExternalLogAdapter is a wrapper class that can be used to adapt and connect an
	 * external Logger to the tetragon logging mechanism. It makes it possible to send
	 * logging information to an external logger, in addition to tetragon's own logging
	 * console.
	 * 
	 * <p>The logging API supports the following log filter levels: trace, debug, info,
	 * warn, error and fatal. Additionally an external monitoring mechanism can be called.
	 * </p>
	 * 
	 * <p>To adapt your own logger simply add calls to your external logging API to the
	 * calls inside this class' methods or replace the existing ones. By default Alcon
	 * is used as an additional external Logger. You can replace, remove or add to the
	 * existing logger as your project requires it.</p>
	 */
	public class ExternalLogAdapter
	{
		 // TODO Since this class is now part of a pre-packed SWC it needs to be changed to
		 // allow users to change the logger externally.
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Tells the external logger to monitor the application.
		 * 
		 * @param stage Stage object required for monitoring.
		 */
		public function monitor(stage:Stage):void
		{
			Debug.monitor(stage);
		}
		
		
		/**
		 * Sends trace data to the external logger.
		 * 
		 * @param data The data to log.
		 */
		public function trace(data:*):void
		{
			Debug.trace(data, Debug.LEVEL_DEBUG);
		}
		
		
		/**
		 * Sends debug data to the external logger.
		 * 
		 * @param data The data to log.
		 */
		public function debug(data:*):void
		{
			Debug.trace(data, Debug.LEVEL_DEBUG);
		}
		
		
		/**
		 * Sends info data to the external logger.
		 * 
		 * @param data The data to log.
		 */
		public function info(data:*):void
		{
			Debug.trace(data, Debug.LEVEL_INFO);
		}
		
		
		/**
		 * Sends notice data to the external logger.
		 * 
		 * @param data The data to log.
		 */
		public function notice(data:*):void
		{
			Debug.trace(data, Debug.LEVEL_INFO);
		}
		
		
		/**
		 * Sends warn data to the external logger.
		 * 
		 * @param data The data to log.
		 */
		public function warn(data:*):void
		{
			Debug.trace(data, Debug.LEVEL_WARN);
		}
		
		
		/**
		 * Sends error data to the external logger.
		 * 
		 * @param data The data to log.
		 */
		public function error(data:*):void
		{
			Debug.trace(data, Debug.LEVEL_ERROR);
		}
		
		
		/**
		 * Sends fatal data to the external logger.
		 * 
		 * @param data The data to log.
		 */
		public function fatal(data:*):void
		{
			Debug.trace(data, Debug.LEVEL_FATAL);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines wether the external logger is enabled or not.
		 */
		public function get enabled():Boolean
		{
			return Debug.enabled;
		}
		public function set enabled(v:Boolean):void
		{
			Debug.enabled = v;
		}
	}
}
