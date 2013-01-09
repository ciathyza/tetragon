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
package tetragon.view.render2d.core
{
	/**
	 * The IAnimatable2D interface describes objects that are animated depending on the
	 * passed time. Any object that implements this interface can be added to a juggler.
	 * 
	 * <p>
	 * When an object should no longer be animated, it has to be removed from the juggler.
	 * To do this, you can manually remove it via the method
	 * <code>juggler.remove(object)</code>, or the object can request to be removed by
	 * dispatching a Starling event with the type <code>Event.REMOVE_FROM_JUGGLER</code>.
	 * The "Tween" class is an example of a class that dispatches such an event; you don't
	 * have to remove tweens manually from the juggler.
	 * </p>
	 * 
	 * @see Juggler2D
	 * @see Tween2D
	 */
    public interface IAnimatable2D 
    {
		/**
		 * Advance the time by a number of seconds.
		 * 
		 * @param time in seconds.
		 */
        function advanceTime(time:Number):void;
    }
}
