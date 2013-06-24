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
package tetragon.env.update
{
	import tetragon.Main;
	import tetragon.data.Config;
	import tetragon.debug.Log;
	import tetragon.env.update.au.AUApplicationUpdater;
	import tetragon.env.update.au.events.AUStatusUpdateErrorEvent;
	import tetragon.env.update.au.events.AUStatusUpdateEvent;
	import tetragon.env.update.au.events.AUUpdateEvent;

	import com.hexagonstar.signals.Signal;

	import flash.events.Event;
	
	
	/**
	 * Manages updating for AIR desktop builds.
	 */
	public class UpdateManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _updater:AUApplicationUpdater;
		/** @private */
		private var _isInstallPostponed:Boolean;
		/** @private */
		private var _checkAfterInitialize:Boolean = true;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _finishedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constructer for UpdateManager Class
		 */
		public function UpdateManager()
		{
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function checkNow():void
		{
			_isInstallPostponed = false;
			_updater.checkNow();
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			_finishedSignal.removeAll();
			disposeUpdater();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "UpdateManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get finishedSignal():Signal
		{
			return _finishedSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onUpdaterInitialized(e:AUUpdateEvent):void
		{
			_updater.applicationName = Main.instance.appInfo.name;
			Log.debug("Initialized (current version: " + _updater.currentVersion + ").", this);
			if (_checkAfterInitialize) _updater.checkNow();
			else finish();
		}
		
		
		/**
		 * @private
		 */
		private function onStatusUpdate(e:AUStatusUpdateEvent):void
		{
			e.preventDefault();
			if (e.available)
			{
				/* Extract update description notes. */
				if (e.details && e.details.length == 1) _updater.description = e.details[0][1];
				else _updater.description = "";
				
				_updater.updateVersion = e.version;
				Log.debug("Update available: v" + e.version, this);
				_updater.showUpdateUI();
			}
			else
			{
				finish();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onStatusUpdateError(e:AUStatusUpdateErrorEvent):void
		{
			/* Could not reach the update file on the server. Don't bother! */
			e.preventDefault();
			Log.debug("Could not get update status (" + e.text + ").", this);
			finish();
		}
		
		
		/**
		 * @private
		 */
		private function onUpdaterFinished(e:Event):void
		{
			finish();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------		
		
		/**
		 * @private
		 */
		private function setup():void
		{
			if (!_finishedSignal) _finishedSignal = new Signal();
			if (!_updater)
			{
				_updater = new AUApplicationUpdater();
				_updater.addEventListener(AUUpdateEvent.INITIALIZED, onUpdaterInitialized);
				_updater.addEventListener(AUStatusUpdateEvent.UPDATE_STATUS, onStatusUpdate);
				_updater.addEventListener(AUStatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
				_updater.addEventListener(Event.COMPLETE, onUpdaterFinished);
				_updater.updateUIClass = UpdateDialog;
				_updater.updateURL = Main.instance.registry.config.getString(Config.UPDATE_URL);
				_updater.delay = Main.instance.registry.config.getNumber(Config.UPDATE_CHECK_INTERVAL);
				_updater.initialize();
			}
		}
		
		
		/**
		 * @private
		 */
		private function disposeUpdater():void
		{
			if (_updater)
			{
				_updater.removeEventListener(AUUpdateEvent.INITIALIZED, onUpdaterInitialized);
				_updater.removeEventListener(AUStatusUpdateEvent.UPDATE_STATUS, onStatusUpdate);
				_updater.removeEventListener(AUStatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
				_updater.removeEventListener(Event.COMPLETE, onUpdaterFinished);
				_updater.dispose();
				_updater = null;
			}
		}
		
		
		/**
		 * @private
		 */
		private function finish():void
		{
			_finishedSignal.dispatch();
		}
	}
}
