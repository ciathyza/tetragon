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
package
{
	import tetragon.Main;
	import tetragon.env.preload.IPreloadable;
	import tetragon.env.preload.IPreloader;

	import flash.display.DisplayObjectContainer;
	
	
	[SWF(width="1024", height="768", backgroundColor="#000000", frameRate="60")]
	
	/**
	 * Entry acts as the entry point and base display object container (or: context view) for
	 * the application. This is the class that the compiler is being told to compile and from
	 * which all other application logic is being initiated, in particular Main which acts as
	 * the main hub for the application.
	 * 
	 * <p>IMPORTANT: Auto-generated class. Do not edit!</p>
	 */
	public final class Entry implements IPreloadable
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _main:Main;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked by the preloader after the application has been fully preloaded.
		 * 
		 * @param preloader a reference to the preloader.
		 */
		public function onApplicationPreloaded(preloader:IPreloader):void
		{
			_main = Main.instance;
			_main.init(preloader as DisplayObjectContainer, new AppInfo(), new Setups().list,
				AppResourceBundle);
		}
	}
}
