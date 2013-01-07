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
package tetragon.util.file
{
	import tetragon.IAppInfo;
	import tetragon.Main;
	import tetragon.data.Config;

	import flash.filesystem.File;
	
	
	public function getUserDataPath():String
	{
		var main:Main = Main.instance;
		var sep:String = File.separator;
		var appInfo:IAppInfo = main.appInfo;
		var path:String = main.registry.config.getString(Config.USER_DATA_FOLDER).toLowerCase();
		var parts:Array = path.split("\\").join("/").split("/");
		path = "";
		
		for (var i:uint = 0; i < parts.length; i++)
		{
			var part:String = parts[i];
			if (part.length < 1)
			{
				continue;
			}
			else if (part == "%user_documents%")
			{
				path += File.documentsDirectory.nativePath;
			}
			else if (part == "%publisher%")
			{
				if (appInfo.publisher && appInfo.publisher.length > 0)
					path += sep + appInfo.publisher;
				else if (appInfo.creator && appInfo.creator.length > 0)
					path += sep + appInfo.creator;
			}
			else if (part == "%app_name%")
			{
				path += sep + appInfo.name;
			}
			else
			{
				path += sep + part;
			}
		}
		
		return path;
	}
}
