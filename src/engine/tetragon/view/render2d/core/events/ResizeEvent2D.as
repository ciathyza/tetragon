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
    /** A ResizeEvent is dispatched by the stage when the size of the Flash container changes.
     *  Use it to update the Starling viewport and the stage size.
     *  
     *  <p>The event contains properties containing the updated width and height of the Flash 
     *  player. If you want to scale the contents of your stage to fill the screen, update the 
     *  <code>Starling.current.viewPort</code> rectangle accordingly. If you want to make use of
     *  the additional screen estate, update the values of <code>stage.stageWidth</code> and 
     *  <code>stage.stageHeight</code> as well.</p>
     *  
     *  @see starling.display.Stage
     *  @see starling.core.Starling
     */
	public class ResizeEvent2D extends Event2D
	{
		/** Event type for a resized Flash player. */
        public static const RESIZE:String = "resize";
		
		private var mWidth:int;
		private var mHeight:int;
		
        /** Creates a new ResizeEvent. */
		public function ResizeEvent2D(type:String, width:int, height:int, bubbles:Boolean=false)
		{
			super(type, bubbles);
			mWidth = width;
			mHeight = height;
		}
		
        /** The updated width of the player. */
		public function get width():int { return mWidth; }
        
        /** The updated height of the player. */
		public function get height():int { return mHeight; }
	}
}