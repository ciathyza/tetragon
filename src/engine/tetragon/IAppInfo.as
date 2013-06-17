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
package tetragon
{
	/**
	 * Interface for the project-specific AppInfo class.
	 */
	public interface IAppInfo
	{
		/**
		 * The unique ID of the application.
		 */
		function get id():String;
		
		/**
		 * The full name of the application.
		 */
		function get name():String;
		
		/**
		 * The application's description.
		 */
		function get description():String;
		
		/**
		 * The application's version. The version format is: major.minor.maintenance
		 */
		function get version():String;
		
		/**
		 * The build number of the application.
		 */
		function get build():String;
		
		/**
		 * The build date of the application.
		 */
		function get buildDate():String;
		
		/**
		 * The milestone name (optional).
		 */
		function get milestone():String;
		
		/**
		 * The build type. Can be one of the following, depending on the build target:
		 * web, desktop, android or ios.
		 * 
		 * @see tetragon.BuildType
		 */
		function get buildType():String;
		
		/**
		 * The release stage (optional). Typically used are: pre-alpha, alpha, beta,
		 * rc1, rc2, rtm, ga, final, etc.
		 */
		function get releaseStage():String;
		
		/**
		 * Name of application copyright holder.
		 */
		function get copyright():String;
		
		/**
		 * Name of application publisher.
		 */
		function get publisher():String;
		
		/**
		 * Name of application creator (developer).
		 */
		function get creator():String;
		
		/**
		 * Name of any application contributor.
		 */
		function get contributor():String;
		
		/**
		 * The year of the application build.
		 */
		function get year():String;
		
		/**
		 * Website URL for application (optional).
		 */
		function get website():String;
		
		/**
		 * Default language string of the application.
		 */
		function get language():String;
		
		/**
		 * The filename of the application. Must be one string without spaces!
		 */
		function get filename():String;
		
		/**
		 * Filename of the engine config file, usually <code>engine.ini</code>.
		 */
		function get filenameEngineConfig():String;
		
		/**
		 * Filename of the keybindings file, usually <code>keybindings.ini</code>.
		 */
		function get filenameKeyBindings():String;
		
		/**
		 * Filename of the resource index file, usually <code>resources.xml</code>.
		 */
		function get filenameResourceIndex():String;
		
		/**
		 * Name of the config folder, usually <code>config</code>.
		 */
		function get configFolder():String;
		
		/**
		 * Name of the resources folder, usually <code>resources</code>.
		 */
		function get resourcesFolder():String;
		
		/**
		 * Name of the icons folder, usually <code>icons</code>.
		 */
		function get iconsFolder():String;
		
		/**
		 * Name of the extras folder, usually <code>extra</code>.
		 */
		function get extraFolder():String;
		
		/**
		 * The default stage width of the application.
		 */
		function get defaultWidth():int;
		
		/**
		 * The default stage height of the application.
		 */
		function get defaultHeight():int;
		
		/**
		 * The reference stage width of the application.
		 */
		function get referenceWidth():int;
		
		/**
		 * The reference stage height of the application.
		 */
		function get referenceHeight():int;
		
		/**
		 * The version of the SWF format.
		 */
		function get swfVersion():int;
		
		/**
		 * Determines whether the build is a debug build (<code>true</code>) or not
		 * (<code>false</code>).
		 */
		function get isDebug():Boolean;
		
		/**
		 * Determines whether the build uses resource files that are packed (<code>true</code>)
		 * or not (<code>false</code>).
		 */
		function get usePackedResources():Boolean;
		
		/**
		 * Determines whether the build is a web build (true) or not (false).
		 */
		function get isWebBuild():Boolean;
		
		/**
		 * Determines whether the build is a desktop build (true) or not (false).
		 */
		function get isDesktopBuild():Boolean;
		
		/**
		 * Determines whether the build is an iOS build (true) or not (false).
		 */
		function get isIOSBuild():Boolean;
		
		/**
		 * Determines whether the build is an Android build (true) or not (false).
		 */
		function get isAndroidBuild():Boolean;
		
		/**
		 * Determines whether the build is a mobile build (true) or not (false).
		 */
		function get isMobileBuild():Boolean;
	}
}
