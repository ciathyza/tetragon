/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package tetragon.view
{
	import tetragon.Main;
	import tetragon.data.Registry;
	import tetragon.data.Settings;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.file.resource.ResourceManager;
	import tetragon.file.resource.StringIndex;

	import com.hexagonstar.util.reflection.getClassName;
	
	
	/**
	 * Screen2 class
	 *
	 * @author Hexagon
	 */
	public class Screen2
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _main:Main;
		protected var _id:String;
		
		/**
		 * Keeps a list of IDs for resources that need to be loaded for this state.
		 * @private
		 */
		private var _resourceIDs:Array;
		
		/** @private */
		private var _resourceCount:uint;
		
		private static var _resourceIndex:ResourceIndex;
		private static var _stringIndex:StringIndex;
		private static var _settings:Settings;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Screen2()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Updates the screen.
		 */
		public function update():void
		{
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the screen will unload all it's loaded resources once it is
		 * closed. You can override this getter and return false for screens where you don't
		 * want resources to be unloaded, .e.g. for a dedicated resource preload screen.
		 * 
		 * @default true
		 */
		protected function get unload():Boolean
		{
			return true;
		}
		
		
		/**
		 * The number of resources that the screen has registered for loading.
		 */
		public function get resourceCount():uint
		{
			return _resourceCount;
		}
		
		
		/**
		 * Determines whether the screen's resources have already been loaded.
		 */
		public function get resourcesAlreadyLoaded():Boolean
		{
			return resourceManager.checkAllResourcesLoaded(_resourceIDs);
		}
		
		
		/**
		 * A reference to the screen manager for quick access in sub-classes.
		 * 
		 * @see tetragon.view.ScreenManager
		 */
		protected function get screenManager():ScreenManager2
		{
			return main.screenManager;
		}
		
		
		/**
		 * The ID of the screen, used by screen manager. Read only!
		 */
		public function get id():String
		{
			return _id;
		}
		public function set id(v:String):void
		{
			if (_id) return;
			_id = v;
		}
		
		
		/**
		 * A reference to Main for quick access in subclasses.
		 * 
		 * @see tetragon.Main
		 */
		protected function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * A reference to the registry for quick access in subclasses.
		 * 
		 * @see tetragon.data.Registry
		 */
		protected function get registry():Registry
		{
			return _main.registry;
		}
		
		
		/**
		 * A reference to the resource manager for quick access in subclasses.
		 * 
		 * @see tetragon.file.resource.ResourceManager
		 */
		protected function get resourceManager():ResourceManager
		{
			return _main.resourceManager;
		}
		
		
		/**
		 * A reference to the resource index for quick access in subclasses.
		 * 
		 * @see tetragon.file.resource.ResourceIndex
		 */
		public static function get resourceIndex():ResourceIndex
		{
			if (!_resourceIndex) _resourceIndex = Main.instance.resourceManager.resourceIndex;
			return _resourceIndex;
		}
		
		
		/**
		 * A reference to the settings for quick access in subclasses.
		 * 
		 * @see tetragon.data.Settings
		 */
		static public function get settings():Settings
		{
			if (!_settings) _settings = Main.instance.registry.settings;
			return _settings;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
