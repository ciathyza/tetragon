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
	import tetragon.BuildType;
	import tetragon.Main;
	import tetragon.command.cli.*;
	import tetragon.command.ecs.*;
	import tetragon.command.env.ChangeLocaleCommand;
	import tetragon.command.env.EnterStateCommand;
	import tetragon.command.env.ForceGCCommand;
	import tetragon.command.env.ListScreensCommand;
	import tetragon.command.env.OpenScreenCommand;
	import tetragon.command.env.SetFramerateCommand;
	import tetragon.command.env.ShutdownApplicationCommand;
	import tetragon.command.env.ToggleFullscreenAIRCommand;
	import tetragon.command.env.ToggleFullscreenCommand;
	import tetragon.command.env.ToggleStatsMonitorCommand;
	import tetragon.command.env.ToggleStatsMonitorPosCommand;
	import tetragon.command.file.*;
	import tetragon.data.Config;
	import tetragon.data.Params;
	import tetragon.data.Settings;
	import tetragon.data.atlas.SpriteAtlas;
	import tetragon.data.atlas.TextureAtlas;
	import tetragon.debug.Log;
	import tetragon.entity.components.*;
	import tetragon.file.parsers.*;
	import tetragon.file.resource.processors.*;

	import com.hexagonstar.util.env.getSeparator;

	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	
	/**
	 * BaseSetup executes default setup steps for all build targets.
	 */
	public class BaseSetup extends Setup
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _paramsLocale:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function startupInitial():void
		{
			mapDefaultConfigProperties();
			mapDefaultSettingsProperties();
			mapDefaultKeyBindings();
			
			complete(INITIAL);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupPostConfig():void
		{
			/* Set verbose logging output on/off. If verbose logging was enabled via
			 * Flash vars we want it to keep active instead of being disabled again by
			 * the engine.ini config! */
			if (Main.params && Main.params.getParam(Params.LOGGING_VERBOSE) == true)
			{
				config.setProperty(Config.LOGGING_VERBOSE, true);
			}
			Log.verboseLoggingEnabled = config.getBoolean(Config.LOGGING_VERBOSE);
			
			/* Using basePath if useAbsoluteFilePath is true is not allowed so clear
			 * it in case both are being used. */
			var basePath:String = config.getString(Config.IO_BASE_PATH);
			if (config.getBoolean(Config.IO_USE_ABSOLUTE_FILEPATH) && basePath && basePath.length > 0)
			{
				Log.warn("Using a base path while useAbsoluteFilePath is true is not allowed."
					+ " The base path is being removed. Files and resources might not load if"
					+ " they are in the base path.", this);
				config.setProperty(Config.IO_BASE_PATH, "");
			}
			
			/* If the locale was overriden via Flash vars (Params) then set it as
			 * the default and current locale. */
			if (_paramsLocale != null)
			{
				config.setProperty(Config.LOCALE_DEFAULT, _paramsLocale);
				config.setProperty(Config.LOCALE_CURRENT, _paramsLocale);
			}
			/* Otherwise set default locale read from engine.ini as current locale. */
			else
			{
				config.setProperty(Config.LOCALE_CURRENT, config.getString(Config.LOCALE_DEFAULT).toLowerCase());
			}
			
			/* Set up debug utilities. */
			main.screenManager.createDebugFacilities(config.getBoolean(Config.CONSOLE_ENABLED),
				config.getBoolean(Config.STATSMONITOR_ENABLED));
			
			/* Now that app config is loaded, ready the Logger. */
			Log.ready(main);
			
			main.keyInputManager.activate();
			
			complete(POST_CONFIG);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupPostSettings():void
		{
			/* Set gameloop framerate according to value from settings. */
			main.gameLoop.frameRate = settings.getNumber(Settings.FRAME_RATE);
			
			/* Set the used theme. */
			main.themeManager.activateTheme(settings.getString(Settings.THEME_ID));
			
			/* Set screen scaling. */
			var screenScale:Number = settings.getNumber(Settings.SCREEN_SCALE);
			if (isNaN(screenScale)) screenScale = 1.0;
			main.screenManager.screenScale = screenScale;
			
			complete(POST_SETTINGS);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupFinal():void
		{
			/* Set fullScreenSourceRect for web builds only here! For other builds
			 * it is set in their responsible setup classes. */
			if (main.appInfo.buildType == BuildType.WEB)
			{
				var s:Stage = main.contextView.stage;
				s.fullScreenSourceRect = new Rectangle(0, 0, s.stageWidth, s.stageHeight);
			}
			
			complete(FINAL);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function shutdown():void
		{
			main.screenManager.dispose();
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
			return "base";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function mapDefaultConfigProperties():void
		{
			config.setProperty(Config.LOGGING_ENABLED, true);
			config.setProperty(Config.LOGFILE_ENABLED, false);
			config.setProperty(Config.LOGGING_FILTER_LEVEL, 0);
			
			/* Get flag for verbose logging from Flash vars if available. */
			if (Main.params)
			{
				config.setProperty(Config.LOGGING_VERBOSE,
					Main.params.getParam(Params.LOGGING_VERBOSE));
			}
			else
			{
				config.setProperty(Config.LOGGING_VERBOSE, false);
			}
			
			config.setProperty(Config.CONSOLE_ENABLED, true);
			config.setProperty(Config.CONSOLE_AUTO_OPEN_LEVEL, 4);
			config.setProperty(Config.CONSOLE_TWEEN, true);
			config.setProperty(Config.CONSOLE_MONOCHROME, false);
			config.setProperty(Config.CONSOLE_SIZE, 2);
			config.setProperty(Config.CONSOLE_TRANSPARENCY, 1.0);
			config.setProperty(Config.CONSOLE_FONT_SIZE, 11);
			config.setProperty(Config.CONSOLE_ENABLED, true);
			config.setProperty(Config.CONSOLE_MAX_BUFFERSIZE, 40000);
			config.setProperty(Config.CONSOLE_INPUT_BACKBUFFERSIZE, 100);
			config.setProperty(Config.CONSOLE_COLORS, ["111111", "00FFFF", "33BB55", "33FF99",
				"FFFFFF", "FFCC00", "FF6600", "BB0000", "FFFFAA"]);
			
			config.setProperty(Config.STATSMONITOR_ENABLED, true);
			config.setProperty(Config.STATSMONITOR_AUTO_OPEN, false);
			config.setProperty(Config.STATSMONITOR_POLL_INTERVAL, 0.5);
			config.setProperty(Config.STATSMONITOR_POSITION, "TR");
			config.setProperty(Config.STATSMONITOR_COLORS, ["0F0F0F", "FFFFFF", "FFCC00", "FF6600",
				"787878", "A2A268", "FFFFD4", "55D4FF", "016A97", "FF55AA"]);
			
			config.setProperty(Config.SCREENSHOTS_ENABLED, true);
			config.setProperty(Config.SCREENSHOTS_AS_JPG, false);
			config.setProperty(Config.SCREENSHOTS_JPG_QUALITY, 95);
			
			config.setProperty(Config.LOCALE_DEFAULT, "en");
			
			if (Main.params)
			{
				/* Set locale if it's set via Flash vars. */
				var locale:String = Main.params.getParam(Params.LOCALE);
				if (locale && locale.length > 0)
				{
					_paramsLocale = locale.toLowerCase();
					config.setProperty(Config.LOCALE_DEFAULT, _paramsLocale);
				}
				
				config.setProperty(Config.IO_USE_ABSOLUTE_FILEPATH,
					Main.params.getParam(Params.USE_ABSOLUTE_FILE_PATH));
				var basePath:String = Main.params.getParam(Params.BASE_PATH);
				if (basePath == null)
				{
					basePath = "";
				}
				else
				{
					var lastChar:String = basePath.substr(-1, 1);
					if (basePath.length > 0 && lastChar != "/" && lastChar != "\\")
					{
						basePath += getSeparator();
					}
				}
				config.setProperty(Config.IO_BASE_PATH, basePath);
				if (Main.params.getParam(Params.USE_ABSOLUTE_FILE_PATH) && basePath.length > 0)
				{
					Log.warn("Using a base path while useAbsoluteFilePath is true is not allowed."
						+ " The base path is being removed. Files and resources might not load if"
						+ " they are in the base path.", this);
					config.setProperty(Config.IO_BASE_PATH, "");
				}
			}
			else
			{
				config.setProperty(Config.IO_USE_ABSOLUTE_FILEPATH, false);
				config.setProperty(Config.IO_BASE_PATH, "");
			}
			
			config.setProperty(Config.IO_LOAD_CONNECTIONS, 1);
			config.setProperty(Config.IO_LOAD_RETRIES, 0);
			config.setProperty(Config.IO_PREVENT_FILE_CACHING, false);
			config.setProperty(Config.IO_ZIP_STREAM_BUFFERSIZE, 262144);
			
			config.setProperty(Config.RESOURCE_FOLDER, main.appInfo.resourcesFolder);
			config.setProperty(Config.ICONS_FOLDER, main.appInfo.iconsFolder);
			config.setProperty(Config.EXTRA_FOLDER, main.appInfo.extraFolder);
			
			config.setProperty(Config.FILENAME_ENGINECONFIG, main.appInfo.filenameEngineConfig);
			config.setProperty(Config.FILENAME_KEYBINDINGS, main.appInfo.filenameKeyBindings);
			config.setProperty(Config.FILENAME_RESOURCEINDEX, main.appInfo.filenameResourceIndex);
			
			config.setProperty(Config.USER_DATA_FOLDER, "%user_documents%/%publisher%/%app_name%");
			config.setProperty(Config.USER_SAVEGAMES_FOLDER, "savegames");
			config.setProperty(Config.USER_SCREENSHOTS_FOLDER, "screenshots");
			config.setProperty(Config.USER_CONFIG_FOLDER, "config");
			config.setProperty(Config.USER_LOGS_FOLDER, "logs");
			config.setProperty(Config.USER_MODS_FOLDER, "mods");
			
			config.setProperty(Config.UPDATE_ENABLED, true);
			config.setProperty(Config.UPDATE_URL, "");
			config.setProperty(Config.UPDATE_CHECK_AUTO, true);
			config.setProperty(Config.UPDATE_CHECK_INTERVAL, 1);
			config.setProperty(Config.UPDATE_CHECK_TIMEOUT, 10);
			
			config.setProperty(Config.HARDWARE_RENDERING_ENABLED, true);
			
			config.setProperty(Config.ENV_START_FULLSCREEN, false);
			config.setProperty(Config.ENV_BG_FRAMERATE, -1);
		}
		
		
		private function mapDefaultSettingsProperties():void
		{
			settings.setProperty(Settings.USER_CONFIG_FILE, registry.config.getProperty(Config.FILENAME_ENGINECONFIG));
			settings.setProperty(Settings.USER_KEYBINDINGS_FILE, registry.config.getProperty(Config.FILENAME_KEYBINDINGS));
		}
		
		
		private function mapDefaultKeyBindings():void
		{
			main.keyInputManager.init();
			main.keyInputManager.addKeyBinding("toggleConsole", "F8");
			main.keyInputManager.addKeyBinding("toggleStatsMonitor", "CTRL+F8");
			main.keyInputManager.addKeyBinding("toggleStatsMonitorPosition", "CTRL+SHIFT+F8");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerModules():void
		{
			//registrar.registerModule(Game2DModule.defaultID, Game2DModule);
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
			registrar.registerCommand("cli", "commands", "c", ListCLICommandsCommand, "Lists all available CLI commands.");
			registrar.registerCommand("cli", "log", null, LogCommand, "Sends the specified message to the logger.");
			registrar.registerCommand("cli", "help", "h", HelpCommand, "Shows help summary about the console or a specified command.");
			registrar.registerCommand("cli", "size", "s", ToggleConsoleSizeCommand, "Toggles between different console sizes.");
			registrar.registerCommand("cli", "listmeta", "lmt", ListMetaDataCommand, "Displays the full meta data of the application.");
			registrar.registerCommand("cli", "listcaps", "lcs", ListCapabilitiesCommand, "Lists the current runtime's capabilities.");
			registrar.registerCommand("cli", "listconfig", "lcf", ListConfigCommand, "Lists the current application configuration.");
			registrar.registerCommand("cli", "listlocalsettings", "lls", ListLocalSettingsCommand, "Lists all locally stored settings.");
			registrar.registerCommand("cli", "listsettings", "lst", ListSettingsCommand, "Lists all application settings.");
			registrar.registerCommand("cli", "listmodules", "lmd", ListModulesCommand, "Outputs a list of all used modules.");
			registrar.registerCommand("cli", "listtextformats", "ltf", ListTextFormatsCommand, "Outputs a list of all registered text formats.");
			registrar.registerCommand("cli", "listfonts", "lfn", ListFontsCommand, "Lists all available fonts.");
			registrar.registerCommand("cli", "clear", "cl", ClearConsoleCommand, "Clears the console buffer.");
			registrar.registerCommand("cli", "hide", "hd", HideConsoleCommand, "Hides the console.");
			registrar.registerCommand("cli", "setalpha", "sta", SetConsoleAlphaCommand, "Sets the console transparency to a value between 0.0 and 1.0.");
			registrar.registerCommand("cli", "setcolor", "stc", SetConsoleColorCommand, "Sets the console background color.");
			registrar.registerCommand("cli", "appinfo", "ai", OutputAppInfoCommand, "Displays application information string.");
			registrar.registerCommand("cli", "engineinfo", "ei", OutputEngineInfoCommand, "Displays version information about the engine.");
			registrar.registerCommand("cli", "runtime", "rt", OutputRuntimeInfoCommand, "Displays information about the runtime.");
			registrar.registerCommand("cli", "listscreens", "lsc", ListScreensCommand, "Lists all registered screens.");
			registrar.registerCommand("cli", "liststates", "lss", ListStatesCommand, "Lists all registered states.");
			registrar.registerCommand("cli", "listkeyassignments", "lka", ListKeyAssignmentsCommand, "Outputs a list of all current key assignments.");
			registrar.registerCommand("cli", "listparams", "lpa", ListParamsCommand, "Lists all application params.");
			registrar.registerCommand("cli", "listregistryobjects", "lro", ListRegistryObjectsCommand, "Lists all objects that are mapped in the data model registry.");
			
			registrar.registerCommand("env", "setfps", "stf", SetFramerateCommand, "Sets the stage framerate to the specified value.");
			registrar.registerCommand("env", "gc", null, ForceGCCommand, "Forces a garbage collection mark/sweep.");
			registrar.registerCommand("env", "exit", null, ShutdownApplicationCommand, "Exits the application.");
			registrar.registerCommand("env", "fps", null, ToggleStatsMonitorCommand, "Toggles the Stats Monitor on/off.");
			registrar.registerCommand("env", "fpspos", "fpp", ToggleStatsMonitorPosCommand, "Switches between different Stats Monitor positions.");
			registrar.registerCommand("env", "init", null, AppInitCommand, "Initializes the application.");
			registrar.registerCommand("env", "openscreen", "ops", OpenScreenCommand, "Opens the screen that is registered with the specified screen ID.");
			registrar.registerCommand("env", "enterstate", "est", EnterStateCommand, "Enters the state that is registered with the specified state ID.");
			registrar.registerCommand("env", "changelocale", "loc", ChangeLocaleCommand, "Changes to the specified locale.");
			
			/* For Web builds we include a different ToggleFullscreenCommand than for AIR builds
			 * because the inclusion of the WindowBoundsManager would cause an exception thrown
			 * on web builds when trying to toggle fullscreen. This seems to be a change in the
			 * Flash Player from v11.3 on. */
			if (main.appInfo.buildType == BuildType.WEB)
			{
				registrar.registerCommand("env", "fullscreen", "fs", ToggleFullscreenCommand, "Toggles fullscreen mode (if supported).");
			}
			else
			{
				registrar.registerCommand("env", "fullscreen", "fs", ToggleFullscreenAIRCommand, "Toggles fullscreen mode (if supported).");
			}
			
			registrar.registerCommand("file", "liststrings", "str", ListStringsCommand, "Outputs a list of all mapped strings.");
			registrar.registerCommand("file", "listresources", "res", ListResourcesCommand, "Outputs a list of all mapped resources.");
			registrar.registerCommand("file", "listdatafiles", "daf", ListDataFilesCommand, "Outputs a list of all mapped resources data files.");
			registrar.registerCommand("file", "loadresource", "ldr", LoadResourceCommand, "Loads a resource by it's resource ID.");
			registrar.registerCommand("file", "unloadresource", "ulr", UnloadResourceCommand, "Unloads a previously loaded resource.");
			registrar.registerCommand("file", "unloadallresources", "ula", UnloadAllResourcesCommand, "Forces unloading of all previously loaded resources.");
			registrar.registerCommand("file", "resourceinfo", "ri", ResourceInfoCommand, "Outputs info about the resource with the specified ID.");
			registrar.registerCommand("file", "dump", "d", DumpCommand, "Outputs a string dump of the resource with the specified ID.");
			
			registrar.registerCommand("ecs", "listentities", "len", ListEntitiesCommand, "Outputs a list of all currently existing entity objects.");
			registrar.registerCommand("ecs", "listentityfamilies", "lef", ListEntityFamiliesCommand, "Outputs a list of all currently mapped entity families and their entity count.");
			registrar.registerCommand("ecs", "listentitycomponents", "lec", ListEntityComponentsCommand, "Outputs a list of all current entity component mappings.");
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
			registrar.registerDataType(TextureAtlas.TEXTURE_ATLAS, TextureAtlasDataParser);
			registrar.registerDataType(SpriteAtlas.SPRITE_ATLAS, SpriteAtlasDataParser);
			//registrar.registerDataType(SWFAssetCatalog.SWF_ASSET_CATALOG, SWFAssetCatalogParser);
			//registrar.registerDataType(SpriteSheet.SPRITE_SHEET, SpriteSheetDataParser);
			//registrar.registerDataType(SpriteSet.SPRITE_SET, SpriteSetDataParser);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerResourceProcessors():void
		{
			registrar.registerResourceProcessor(TextureAtlas.TEXTURE_ATLAS, TextureAtlasProcessor);
			registrar.registerResourceProcessor(SpriteAtlas.SPRITE_ATLAS, SpriteAtlasProcessor);
			//registrar.registerResourceProcessor(SWFAssetCatalog.SWF_ASSET_CATALOG, SWFAssetCatalogProcessor);
			//registrar.registerResourceProcessor(SpriteSheet.SPRITE_SHEET, SpriteSheetProcessor);
			//registrar.registerResourceProcessor(SpriteSet.SPRITE_SET, SpriteSetProcessor);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerEntitySystems():void
		{
			//registrar.registerEntitySystem(BasicRenderSystem);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerEntityComponents():void
		{
			registrar.registerEntityComponent("refListComponent", RefListComponent);
			registrar.registerEntityComponent("graphicsComponent", GraphicsComponent);
			registrar.registerEntityComponent("spacial2DComponent", Spacial2DComponent);
			registrar.registerEntityComponent("spacial3DComponent", Spacial3DComponent);
			registrar.registerEntityComponent("actor2DRefComponent", Actor2DRefComponent);
			registrar.registerEntityComponent("cell2DComponent", Cell2DComponent);
			registrar.registerEntityComponent("cell2DInteriorDataComponent", Cell2DInteriorDataComponent);
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
