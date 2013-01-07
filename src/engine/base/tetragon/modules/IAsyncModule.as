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
package tetragon.modules
{
	import com.hexagonstar.signals.Signal;
	
	
	/**
	 * Interface that should be implemented by asynchonous Tetragon Module classes.
	 * 
	 * An asynchronous module performs tasks that might run while the rest of the
	 * application continues it's processing path. One such example is the UpdaterModule
	 * which invokes the application updater. The application updater however runs
	 * asynchronously and dispatches a signal when finished. For the app to be able to
	 * know when the UpdaterModule has finished, the module needs to be asynchronous
	 * and dispatch the asyncCompleteSignal.
	 */
	public interface IAsyncModule extends IModule
	{
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the asynchronous module has completed it's task.
		 */
		function get asyncComplete():Boolean;
		
		
		/**
		 * A signal that can be used to notify a listener that the module has completed
		 * a task that was executed asynchronously.
		 */
		function get asyncCompleteSignal():Signal;
	}
}
