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
package tetragon.command.env
{
	import tetragon.BuildType;
	import tetragon.command.CLICommand;
	import tetragon.debug.Log;
	import tetragon.env.desktop.WindowBoundsManager;
	import tetragon.setup.Setup;

	import com.hexagonstar.util.env.isPlugin;
	import com.hexagonstar.util.env.isStandAlone;

	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.system.fscommand;
	import flash.utils.setTimeout;
	
	
	/**
	 * CLI command to exit the application.
	 */
	public class ShutdownApplicationCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _setups:Vector.<SetupVO>;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Execute the command.
		 */ 
		override public function execute():void
		{
			Log.info("Shutting down...", this);
			createSetups();
			shutdownSetups();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "Shutdown";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "shutdownApplication";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onSetupsShutdownComplete(setupStep:String, setupName:String):void
		{
			/* Check that all setups have completed. */
			var i:uint;
			for (i = 0; i < _setups.length; i++)
			{
				var vo:SetupVO = _setups[i];
				if (!vo.complete && vo.setup.name == setupName)
				{
					vo.complete = true;
				}
			}
			for (i = 0; i < _setups.length; i++)
			{
				if (!_setups[i].complete) return;
			}
			Log.info("Shutdown complete.", this);
			
			if (main.appInfo.buildType == BuildType.DESKTOP) storeWindowBounds();
			Log.info("Exiting ...", this);
			
			setTimeout(exit, 200);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function createSetups():void
		{
			var i:int;
			_setups = new Vector.<SetupVO>();
			
			/* Add any additional setups that are listed in AppSetups ... */
			var a:Array = main.setups;
			for (i = 0; i < a.length; i++)
			{
				var clazz:Class = a[i];
				_setups.push(new SetupVO(new clazz()));
			}
		}
		
		
		private function shutdownSetups():void
		{
			for (var i:int = _setups.length - 1; i > -1; i--)
			{
				var vo:SetupVO = _setups[i];
				var s:Setup = vo.setup;
				Log.debug("Executing shutdown on " + s.name + " ...", this);
				s.stepCompleteCallback = onSetupsShutdownComplete;
				s.shutdown();
			}
		}
		
		
		/**
		 * This must be in it's own method, otherwise web build would stop execution
		 * when they hit this code!
		 */
		private function storeWindowBounds():void
		{
			WindowBoundsManager.instance.storeWindowBounds(main.baseWindow, "base");
		}
		
		
		private function exit():void
		{
			if (isPlugin())
			{
				Log.debug("Exiting not supported on this runtime.", this);
				return;
			}
			if (main.appInfo.buildType == BuildType.WEB)
			{
				if (isStandAlone()) fscommand("quit");
			}
			else
			{
				if (NativeWindow.isSupported) main.contextView.stage.nativeWindow.visible = false;
				NativeApplication.nativeApplication.exit();
			}
		}
	}
}


import tetragon.setup.Setup;

/**
 * @private
 */
final class SetupVO
{
	public var setup:Setup;
	public var complete:Boolean = false;
	
	public function SetupVO(setup:Setup = null)
	{
		this.setup = setup;
	}
}
