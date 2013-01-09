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
package tetragon.view.render2d.core.events
{
	import com.hexagonstar.exception.AbstractClassException;
	
	
	/** A class that provides constant values for the phases of a touch object. 
	 *  
	 *  <p>A touch moves through at least the following phases in its life:</p>
	 *  
	 *  <code>BEGAN -> MOVED -> ENDED</code>
	 *  
	 *  <p>Furthermore, a touch can enter a <code>STATIONARY</code> phase. That phase will not 
	 *  trigger an event itself, but you might receive it when another touch does so.</p> 
	 *  
	 *  <p>Finally, there's the <code>HOVER</code> phase, which is exclusive to mouse input. It is
	 *  the equivalent of a <code>MouseOver</code> event in Flash when the mouse button is
	 *  <em>not</em> pressed.</p> 
	 */
	public final class TouchPhase2D
	{
		/** @private */
		public function TouchPhase2D()
		{
			throw new AbstractClassException(this);
		}


		/** Only available for mouse input: the cursor hovers over an object <em>without</em> a 
		 *  pressed button. */
		public static const HOVER:String = "hover";
		/** The finger touched the screen just now, or the mouse button was pressed. */
		public static const BEGAN:String = "began";
		/** The finger moves around on the screen, or the mouse is moved while the button is 
		 *  pressed. */
		public static const MOVED:String = "moved";
		/** The finger or mouse (with pressed button) has not moved since the last frame. */
		public static const STATIONARY:String = "stationary";
		/** The finger was lifted from the screen or from the mouse button. */
		public static const ENDED:String = "ended";
	}
}
