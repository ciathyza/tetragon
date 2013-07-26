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
package tetragon.setup
{
	import tetragon.command.env.*;
	import tetragon.command.file.*;
	import tetragon.data.Config;
	import tetragon.env.desktop.WindowBoundsManager;
	import tetragon.modules.app.AIRModule;
	import tetragon.modules.app.DesktopModule;

	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	
	/**
	 * DesktopSetup contains setup instructions exclusively for desktop-based applications.
	 */
	public class DesktopSetup extends Setup
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function startupInitial():void
		{
			/* set this to false, when we close the application we first do an update. */
			NativeApplication.nativeApplication.autoExit = false;
			
			main.commandManager.execute(new CreateUserDataFoldersCommand());
			
			// TODO To be changed! Fullscreen state should not be stored in app.ini
			// but in user settings file!
			//main.config.useFullscreen = WindowBoundsManager.instance.fullscreen;
			
			complete(INITIAL);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupFinal():void
		{
			/* Correct stage dimensions which might be wrong due to system chrome. */
			windowBoundsManager.calculateWindowChromeExtra();
			
			/* Recall app window bounds. */
			windowBoundsManager.recallWindowBounds(main.baseWindow, "base");
			
			/* Check if we want to start in fullscreen mode. */
			if (registry.config.getBoolean(Config.ENV_START_FULLSCREEN) && !main.isFullscreen)
			{
				main.commandManager.execute(new ToggleFullscreenCommand());
			}
			
			/* Make application visible. */
			if (NativeWindow.isSupported)
			{
				main.stage.nativeWindow.visible = true;
				main.stage.nativeWindow.activate();
			}
			
			complete(FINAL);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function shutdown():void
		{
			var m:DesktopModule = main.moduleManager.getModule(DesktopModule.defaultID);
			m.dispose();
			complete(SHUTDOWN);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "desktop";
		}
		
		
		protected function get windowBoundsManager():WindowBoundsManager
		{
			return WindowBoundsManager.instance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function registerModules():void
		{
			registrar.registerModule(AIRModule.defaultID, AIRModule, null);
			registrar.registerModule(DesktopModule.defaultID, DesktopModule, null);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerThemes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerCLICommands():void
		{
			registrar.registerCommand("env", "resetwinbounds", "rwb", ResetWinBoundsCommand, "Resets the window size and position.");
			registrar.registerCommand("env", "checkupdate", "cup", CheckUpdateCommand, "Checks if an update of the application is available.");
			registrar.registerCommand("file", "listpackages", "pak", ListPackagesCommand, "Outputs a list of all resource package files (paks).");
			registrar.registerCommand("file", "listpackagecontents", "pkc", ListPackageContentsCommand, "Outputs a list of the contents of a resource package file.");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerResourceFileTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerComplexTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerDataTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerResourceProcessors():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerEntitySystems():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerEntityComponents():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerStates():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerScreens():void
		{
		}
	}
}
