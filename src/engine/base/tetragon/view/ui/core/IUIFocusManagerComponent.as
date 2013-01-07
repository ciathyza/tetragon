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
package tetragon.view.ui.core
{
	/**
	 * The IFocusManagerComponent interface provides methods and properties that give
	 * components the capability to receive focus. Components must implement this
	 * interface to receive focus from the FocusManager.
	 * 
	 * <p>
	 * The UIComponent class provides a base implementation of this interface but does not
	 * fully implement it because not all UIComponent objects receive focus. Components
	 * that are derived from the UIComponent class must implement this interface to be
	 * capable of receiving focus. To enable focus, add the statement
	 * <code>implements IFocusManagerComponent</code> to the class definition of a
	 * component that is derived from the UIComponent class.
	 * </p>
	 * 
	 * @see FocusManager
	 */
	public interface IUIFocusManagerComponent
	{
		function setFocus():void;
		function drawFocus(focused:Boolean):void;
		
		function get focusEnabled():Boolean;
		function set focusEnabled(v:Boolean):void;
		function get mouseFocusEnabled():Boolean;
		function get tabEnabled():Boolean;
		function get tabIndex():int;
	}
}
