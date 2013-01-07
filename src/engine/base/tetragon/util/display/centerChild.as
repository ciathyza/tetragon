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
package tetragon.util.display
{
	import tetragon.Main;
	import tetragon.view.ScreenManager;

	import flash.display.DisplayObject;
	
	
	/**
	 * Convenience method that can be used to center displays horizontally and/or
	 * vertically on the screen.
	 * 
	 * @param view The child view to center.
	 * @param h Whether to center the view horizontally or not.
	 * @param v Whether to center the view vertically or not.
	 * @param hOffset Optional offset for horizontal centering.
	 * @param vOffset Optional offset for vertical centering.
	 */
	public function centerChild(child:DisplayObject, h:Boolean = true, v:Boolean = true,
		hOffset:int = 0, vOffset:int = 0):void
	{
		var sm:ScreenManager = Main.instance.screenManager;
		if (h) child.x = Math.round(sm.hCenter - (child.width * 0.5)) + hOffset;
		if (v) child.y = Math.round(sm.vCenter - (child.height * 0.5)) + vOffset;
	}
}
