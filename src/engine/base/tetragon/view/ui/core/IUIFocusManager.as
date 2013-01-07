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
	import com.hexagonstar.ui.controls.Button;

	import flash.display.InteractiveObject;

	
	/**
	 * Implement the IFocusManager interface to create a custom focus manager. A focus
	 * manager enables an application to transfer focus among components when the user
	 * moves the mouse or presses the Tab key.
	 */
	public interface IUIFocusManager
	{
		function getFocus():InteractiveObject;
		function setFocus(o:InteractiveObject):void;
		
		function showFocus():void;
		function hideFocus():void;
		
		function activate():void;
		function deactivate():void;
		
		function findFocusManagerComponent(component:InteractiveObject):InteractiveObject;
		function getNextFocusManagerComponent(backward:Boolean = false):InteractiveObject;
		
		function get nextTabIndex():int;
		
		function get defaultButton():Button;
		function set defaultButton(v:Button):void;
		
		function get defaultButtonEnabled():Boolean;
		function set defaultButtonEnabled(v:Boolean):void;
		
		function get showFocusIndicator():Boolean;
		function set showFocusIndicator(v:Boolean):void;
	}
}
