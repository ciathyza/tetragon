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
package setup
{
	import data.GameModel;

	import modules.app.AppModule;

	import tetragon.BuildType;
	import tetragon.data.Config;
	import tetragon.debug.Log;
	import tetragon.setup.Setup;

	import view.away3d.Away3DTestScreen;
	import view.empty.EmptyScreen;
	import view.render2d.Render2DTestScreen;
	import view.splash.SplashScreen;

	import com.hexagonstar.util.env.isDomainPermitted;
	
	
	public class AppBaseSetup extends Setup
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function startupInitial():void
		{
			/* Map default, application-specific config properties. */
			mapApplicationConfigProperties();
			
			/* Create and map the game data object. */
			main.registry.map(GameModel, new GameModel());
			
			complete(INITIAL);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupPostConfig():void
		{
			/* In web builds, check if the app is allowed to run on the current domain. */
			if (main.appInfo.buildType == BuildType.WEB && !checkAllowedDomains()) return;
			
			complete(POST_CONFIG);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupPostSettings():void
		{
			complete(POST_SETTINGS);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupFinal():void
		{
			complete(FINAL);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function shutdown():void
		{
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
			return "appBase";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Can be used to map application-specific default config properties, for instance
		 * the default locale in case the application has a different default locale than
		 * English. In that case set for example:
		 * 
		 * @example
		 * <p><pre>
		 *     config.setProperty(Config.LOCALE_DEFAULT, "de");
		 * </pre></p>
		 * 
		 * <p>Default config properties can (and often should) be overriden by config
		 * properties loaded from the eingine.ini but it's not mandatory for all
		 * config properties.</p>
		 * 
		 * @private
		 */
		private function mapApplicationConfigProperties():void
		{
			config.setProperty(Config.ALLOWED_DOMAINS,
			[
				 /* Add comma,separated list of allowed domain strings, e.g.
				  * "game.com",
				  * "dev.lab",
				  * "hexagonstar.com"
				  */
			]);
		}
		
		
		/**
		 * Executes the application's domain check. Only used for web builds!
		 * @private
		 */
		private function checkAllowedDomains():Boolean
		{
			if (!isDomainPermitted(main.stage, config.getArray(Config.ALLOWED_DOMAINS)))
			{
				Log.fatal("Domain not permitted - Execution halted!");
				/* You can add any custom code here that should execute in case
				 * the current domain is not allowed to run the application. */
				return false;
			}
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerModules():void
		{
			// Un/comment depending on your application's needs!
			registrar.registerModule(AppModule.defaultID, AppModule);
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
			registrar.registerScreen(SplashScreen.ID, SplashScreen);
			registrar.registerScreen(EmptyScreen.ID, EmptyScreen);
			registrar.registerScreen(Render2DTestScreen.ID, Render2DTestScreen);
			registrar.registerScreen(Away3DTestScreen.ID, Away3DTestScreen);
		}
	}
}
