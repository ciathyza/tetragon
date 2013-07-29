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
package tetragon.file.resource
{
	import tetragon.Main;
	import tetragon.data.Config;
	import tetragon.file.IFileAPIProxy;
	
	
	/**
	 * ResourceUtil class
	 *
	 * @author Hexagon
	 */
	public class ResourceUtil
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private static var _config:Config;
		private static var _fileAPIProxy:IFileAPIProxy;
		
		private static var _sep:String;
		private static var _userDataPath:String;
		private static var _resourceFolder:String;
		private static var _ioBasePath:String;
		
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param subPath
		 */
		public static function getResourceFilePath(subPath:String):String
		{
			init();
			
			var path:String;
			
			/* First, check if the requested file exists in the user data path. */
			if (_userDataPath != null)
			{
				path = _userDataPath + _sep + _resourceFolder + _sep + subPath;
				var file:* = _fileAPIProxy.resolvePath(path);
				if (_fileAPIProxy.exists(file)) return path;
			}
			
			/* If the file doesn't exist in user data path, use the file from app folder. */
			path = _resourceFolder;
			if (path.length > 0) path += _sep;
			path = _ioBasePath + path + subPath;
			
			return path;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function init():void
		{
			if (_config) return;
			
			_config = Main.instance.registry.config;
			_fileAPIProxy = Main.instance.fileAPIProxy;
			
			_userDataPath = _fileAPIProxy.getUserDataPath();
			_sep = _fileAPIProxy.getSeparator();
			
			_resourceFolder = _config.getString(Config.RESOURCE_FOLDER) || "";
			_ioBasePath = _config.getString(Config.IO_BASE_PATH);
		}
	}
}
