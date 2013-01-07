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
package modules.app
{
	import tetragon.BuildType;
	import tetragon.data.Config;
	import tetragon.debug.Log;
	import tetragon.file.resource.Resource;
	import tetragon.modules.IModule;
	import tetragon.modules.Module;

	import flash.events.ContextMenuEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Timer;
	
	
	/**
	 * Application-specific persistent assist class for all builds.
	 * 
	 * <p>This mobule class can be used to hold any implementation that is used
	 * for all build types, i.e. web, AIR desktop, AIR android and AIR iOS.</p>
	 * 
	 * <p>In contrary to the Setup classes which are instatiated only temporarily
	 * and which contain instructions that should be executed during application startup,
	 * the AppModule class can contain instructions that should persist during
	 * the application's lifetime, typically implementation that is bound to callback
	 * handlers.</p>
	 */
	public final class AppModule extends Module implements IModule
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			/* Prepare special features that are only available in web builds. */
			if (main.appInfo.buildType == BuildType.WEB)
			{
				prepareHTMLCommunicationLayer();
				createCustomContextMenu();
			}
			
			assignGlobalKeys();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public static function get defaultID():String
		{
			return "appModule";
		}
		
		
		private function get isJavaScriptReady():Boolean
		{
			return ExternalInterface.call("isJSReady");
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onTimerComplete(e:TimerEvent):void
		{
			(e.target as Timer).stop();
			(e.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			
			if (isJavaScriptReady)
			{
				onJavaScriptReady();
			}
			else
			{
				Log.notice("JavaScript not ready, couldn't make external calls.", this);
			}
		}
		
		
		/**
		 * @private
		 */
		private function onJavaScriptReady():void
		{
			Log.verbose("JavaScript is ready.", this);
			ExternalInterface.call("onSWFVersionNumber", main.appInfo.version);
			ExternalInterface.call("onSWFBuildNumber", main.appInfo.build);
			ExternalInterface.call("onSWFBuildDate", main.appInfo.buildDate);
			ExternalInterface.call("onSWFIsDebugBuild", "" + main.appInfo.isDebug);
			ExternalInterface.call("onSWFConsoleKey", main.keyInputManager.getKeyBinding("toggleConsole"));
			ExternalInterface.call("onSWFStatsKey", main.keyInputManager.getKeyBinding("toggleStatsMonitor"));
		}
		
		
		/**
		 * Changes the locale of the application
		 *
		 * @param locale  the new language of the application
		 */
		private function onLocaleChangeFromHTML(locale:String = null):void
		{
			if (locale == null) return;
			locale = locale.toLowerCase();
			if (locale == main.registry.config.getString(Config.LOCALE_CURRENT)) return;
			
			Log.verbose("Requested locale change from HTML to: " + locale, this);
			
			main.resourceManager.localeSwitchCompleteSignal.addOnce(onLocaleSwitched);
			main.resourceManager.localeSwitchFailedSignal.addOnce(onLocaleSwitchFailed);
			main.resourceManager.switchToLocale(locale);
		}
		
		
		/**
		 * @private
		 */
		private function onLocaleSwitched(locale:String):void
		{
			Log.verbose("Locale switched to: " + locale, this);
		}
		
		
		/**
		 * @private
		 */
		private function onLocaleSwitchFailed(locale:String, r:Resource):void
		{
			var resID:String = r ? r.id : "null";
			Log.error("Failed switching to locale \"" + locale + "\", resource: " + resID, this);
		}
		
		
		/**
		 * @private
		 */
		private function onSoundToggleFromHTML(): void
		{
			Log.verbose("Toggled sound from HTML.", this);
		}
		
		
		/**
		 * @private
		 */
		private function onHTMLPageUnload():void
		{
			Log.verbose("Invoked page unloading from HTML.", this);
		}
		
		
		/**
		 * @private
		 */
		private function onContextMenuSelect(e:ContextMenuEvent):void
		{
			navigateToURL(new URLRequest(main.appInfo.website), "_blank");
		}
		
		
		/**
		 * @private
		 */
		private function onContextMenuToggleConsole(e:ContextMenuEvent):void
		{
			if (main.console) main.console.toggle();
		}
		
		
		/**
		 * @private
		 */
		private function onContextMenuToggleStatsMonitor(e:ContextMenuEvent):void
		{
			if (main.statsMonitor) main.statsMonitor.toggle();
		}
		
		
		/**
		 * @private
		 */
		private function onContextMenuToggleStatsMonitorPosition(e:ContextMenuEvent):void
		{
			if (main.statsMonitor) main.statsMonitor.togglePosition();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function prepareHTMLCommunicationLayer():void
		{
			if (ExternalInterface.available)
			{
				try
				{
					/* Required for communication with HTML side. */
					Security.allowDomain("*");
					
					Log.verbose("Adding HTML callbacks ...", this);
					ExternalInterface.addCallback("changeLocale", onLocaleChangeFromHTML);
					ExternalInterface.addCallback("toggleSound", onSoundToggleFromHTML);
					ExternalInterface.addCallback("unload", onHTMLPageUnload);
					
					if (isJavaScriptReady)
					{
						onJavaScriptReady();
					}
					else
					{
						Log.verbose("JavaScript is not yet ready, trying external calls later.", this);
						var t:Timer = new Timer(1000, 0);
						t.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
						t.start();
					}
				}
				catch (err1:SecurityError)
				{
					Log.warn("prepareHTMLCommunicationLayer: A security error occurred: "
						+ err1.message, this);
				}
				catch (err2:Error)
				{
					Log.warn("prepareHTMLCommunicationLayer: An error occurred: "
						+ err2.message, this);
				}
			}
			else
			{
				Log.notice("ExternalInterface is not available.", this);
			}
		}
		
		
		private function createCustomContextMenu():void
		{
			if (main.appInfo.buildType == BuildType.WEB)
			{
				var cm:ContextMenu = new ContextMenu();
				
				/* Create developer link CM item. */
				var title:String = main.appInfo.name + " v" + main.appInfo.version + "." + main.appInfo.build;
				var item1:ContextMenuItem = new ContextMenuItem(title);
				var item2:ContextMenuItem = new ContextMenuItem("Made by " + main.appInfo.creator);
				item1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelect);
				item2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelect);
				cm.customItems.push(item1, item2);
				
				/* Create debug context menu items only if this is a debug build! */
				if (main.appInfo.isDebug)
				{
					var item3:ContextMenuItem = new ContextMenuItem("Toggle Console", true);
					var item4:ContextMenuItem = new ContextMenuItem("Toggle Stats Monitor");
					var item5:ContextMenuItem = new ContextMenuItem("Toggle Stats Monitor Position");
					item3.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuToggleConsole);
					item4.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuToggleStatsMonitor);
					item5.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuToggleStatsMonitorPosition);
					cm.customItems.push(item3, item4, item5);
				}
				else
				{
					cm.hideBuiltInItems();
				}
				
				main.contextView.contextMenu = cm;
			}
		}
		
		
		private function assignGlobalKeys():void
		{
		}
	}
}
