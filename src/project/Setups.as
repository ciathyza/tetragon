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
	import setup.*;

	import tetragon.setup.*;
	
	
	/**
	 * A class that contains a list of base/extra setup classes which are being
	 * initialized during the application init phase.
	 * 
	 * <p>The InitApplicationCommand uses this class briefly to get all setup classes that
	 * are compiled into the build and instantiates them so that the setup packages can be
	 * connected to the base engine.</p>
	 * 
	 * <p>TODO Utimately make this class being auto-generated through the build process
	 * and find a way to conviently set in the build properties which setup classes should
	 * be included in the build. (If Ant only would support iteration!!)</p>
	 */
	public final class Setups
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _list:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Setups()
		{
			_list = [];
			
			/* Add the base setup. */
			_list.push(BaseSetup);
			
			/* Add base setups for specific build targets (Do not change!) */
			CONFIG::IS_DESKTOP_BUILD
			{
				_list.push(DesktopSetup);
			}
			/* Add Android-specific setup(s) here. */
			CONFIG::IS_ANDROID_BUILD
			{
				_list.push(AndroidSetup);
			}
			/* Add iOS-specific setup(s) here. */
			CONFIG::IS_IOS_BUILD
			{
				_list.push(IOSSetup);
			}
			
			/* Enable or disable any engine extra setup(s) here depending on your requirements. */
			//_list.push(GameExtraSetup);
			//_list.push(Game2DExtraSetup);
			//_list.push(Game3DExtraSetup);
			
			/* Add application base setup(s) here. */
			_list.push(AppBaseSetup);
			
			/* Add Desktop-specific setup(s) here. */
			CONFIG::IS_DESKTOP_BUILD
			{
				_list.push(AppDesktopSetup);
			}
			/* Add Android-specific setup(s) here. */
			CONFIG::IS_ANDROID_BUILD
			{
				_list.push(AppAndroidSetup);
			}
			/* Add iOS-specific setup(s) here. */
			CONFIG::IS_IOS_BUILD
			{
				_list.push(AppIOSSetup);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * An array of qualified class names to setup classes that set up additional
		 * base and extra packages for use with the game.
		 */
		public function get list():Array
		{
			return _list;
		}
	}
}
