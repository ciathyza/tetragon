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
	import tetragon.BuildType;
	import tetragon.IAppInfo;
	
	
	/**
	 * Provides general meta information about the application.
	 * NOTE: Ant auto-generated application information class. Do not edit!
	 */
	public final class AppInfo implements IAppInfo
	{
		/** @inheritDoc */
		public function get id():String {return "com.hexagonstar.tetragon";}
		/** @inheritDoc */
		public function get name():String {return "Tetragon Demo";}
		/** @inheritDoc */
		public function get description():String { return "Tetragon Demo Application Test Build";}
		/** @inheritDoc */
		public function get version():String {return "1.0.0";}
		/** @inheritDoc */
		public function get build():String {return "12958";}
		/** @inheritDoc */
		public function get buildDate():String {return "02-August-2013 19:08";}
		/** @inheritDoc */
		public function get milestone():String {return "";}
		/** @inheritDoc */
		public function get buildType():String {return "desktop";}
		/** @inheritDoc */
		public function get releaseStage():String {return "alpha";}
		/** @inheritDoc */
		public function get copyright():String {return "Hexagon Star Softworks";}
		/** @inheritDoc */
		public function get publisher():String {return "Hexagon Star Softworks";}
		/** @inheritDoc */
		public function get creator():String {return "Hexagon Star Softworks";}
		/** @inheritDoc */
		public function get contributor():String {return "Hexagon Star Softworks";}
		/** @inheritDoc */
		public function get year():String {return "2013";}
		/** @inheritDoc */
		public function get website():String {return "http://www.tetragonengine.com/";}
		/** @inheritDoc */
		public function get language():String {return "en";}
		
		/** @inheritDoc */
		public function get filename():String {return "tetragon";}
		/** @inheritDoc */
		public function get filenameEngineConfig():String {return "engine.ini";}
		/** @inheritDoc */
		public function get filenameKeyBindings():String {return "keybindings.ini";}
		/** @inheritDoc */
		public function get filenameResourceIndex():String {return "resources.xml";}
		
		/** @inheritDoc */
		public function get configFolder():String {return "config";}
		/** @inheritDoc */
		public function get resourcesFolder():String {return "resources";}
		/** @inheritDoc */
		public function get iconsFolder():String {return "icons";}
		/** @inheritDoc */
		public function get extraFolder():String {return "extra";}
		
		/** @inheritDoc */
		public function get defaultWidth():int {return 1024;}
		/** @inheritDoc */
		public function get defaultHeight():int {return 768;}
		/** @inheritDoc */
		public function get referenceWidth():int {return 1024;}
		/** @inheritDoc */
		public function get referenceHeight():int {return 768;}
		
		/** @inheritDoc */
		public function get swfVersion():int {return 19;}
		
		/** @inheritDoc */
		public function get isDebug():Boolean {return true;}
		
		/** @inheritDoc */
		public function get usePackedResources():Boolean {return false;}
		
		/** @inheritDoc */
		public function get isWebBuild():Boolean
		{
			return buildType == BuildType.WEB;
		}
		
		/** @inheritDoc */
		public function get isDesktopBuild():Boolean
		{
			return buildType == BuildType.DESKTOP;
		}
		
		/** @inheritDoc */
		public function get isIOSBuild():Boolean
		{
			return buildType == BuildType.IOS;
		}
		
		/** @inheritDoc */
		public function get isAndroidBuild():Boolean
		{
			return buildType == BuildType.ANDROID;
		}
		
		/** @inheritDoc */
		public function get isMobileBuild():Boolean
		{
			return buildType == BuildType.IOS || buildType == BuildType.ANDROID;
		}
	}
}
