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
package tetragon.env.preload
{
	/**
	 * An interface that needs to be implemented by concrete preload display classes that
	 * are being wrapped by the <code>Preloader</code> class.
	 * 
	 * <p>A preload display is a display object class that is used by the engine's preload
	 * architecture to show preload progress while the application is being preloaded from
	 * a web server.</p>
	 * 
	 * <p>To create your own preload display class you need to implement this interface in
	 * your class and then provide an instance of it to the preloadDisplay property in the
	 * <code>AppPreloader</code> class.</p>
	 * 
	 * @see Preloader
	 */
	public interface IPreloadDisplay
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Starts the preload display. Called automatically by the wrapping Preloader.
		 */
		function start():void;
		
		
		/**
		 * Disposes the preload display. Called automatically by the wrapping Preloader
		 * after preloading is finished.
		 */
		function dispose():void;
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * This value determines how many frames to wait before the preload display is
		 * actually starting to fade out. This is useful to make the transition between
		 * preloader and main application less abrupt.
		 */
		function set fadeOutDelay(v:int):void;
		
		/**
		 * Sets the color value used for text and graphics in the preload display.
		 */
		function set color(v:uint):void;
		
		/**
		 * Determines how the preload display is positioned horizontally.
		 */
		function set horizontalAlignment(v:String):void;
		
		/**
		 * Determines how the preload display is positioned vertically.
		 */
		function set verticalAlignment(v:String):void;
		
		/**
		 * Determines the distance of the preload display from the stage border.
		 */
		function set padding(v:int):void;
		
		/**
		 * If set to true the preload display is in test mode so it is visible
		 * even when run locally.
		 */
		function set testMode(v:Boolean):void;
	}
}
