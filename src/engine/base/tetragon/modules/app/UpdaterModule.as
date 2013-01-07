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
package tetragon.modules.app
{
	import tetragon.command.Command;
	import tetragon.command.env.CheckUpdateCommand;
	import tetragon.data.Config;
	import tetragon.modules.AsyncModule;
	import tetragon.modules.IAsyncModule;
	import tetragon.modules.IModuleInfo;
	
	
	/**
	 * Module that checks for updates after application startup. For desktop builds only!
	 */
	public final class UpdaterModule extends AsyncModule implements IAsyncModule
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			_asyncComplete = false;
			
			if (main.registry.config.getBoolean(Config.UPDATE_ENABLED))
			{
				var url:String = main.registry.config.getString(Config.UPDATE_URL);
				if (url != null && url.length > 0)
				{
					main.commandManager.execute(new CheckUpdateCommand(), onUpdateCheckComplete);
					return;
				}
			}
			onUpdateCheckComplete(null);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public static function get defaultID():String
		{
			return "updaterModule";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get moduleInfo():IModuleInfo
		{
			return new UpdaterModuleInfo();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked once the update check has completed.
		 */
		private function onUpdateCheckComplete(command:Command):void
		{
			_asyncComplete = true;
			if (_asyncCompleteSignal) _asyncCompleteSignal.dispatch();
		}
	}
}
