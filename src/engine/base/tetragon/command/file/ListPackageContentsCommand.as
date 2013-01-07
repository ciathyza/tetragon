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
package tetragon.command.file
{
	import tetragon.command.CLICommand;
	import tetragon.file.resource.IResourceProvider;
	import tetragon.file.resource.PackedResourceProvider;

	import com.hexagonstar.util.debug.LogLevel;
	
	
	/**
	 * CLI command to list the contents of a resource package file.
	 */
	public class ListPackageContentsCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _packageID:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			var rp:IResourceProvider = main.resourceManager.getResourceProvider(_packageID);
			if (rp == null)
			{
				main.console.log("no resource package with ID \"" + _packageID
					+ "\" found! Use the command 'listpackages' to see a list of all used"
					+ " resource packages and their IDs.", LogLevel.ERROR);
				complete();
				return;
			}
			
			if (rp is PackedResourceProvider)
			{
				main.console.log("\n" + PackedResourceProvider(rp).dump(), LogLevel.INFO);
			}
			else
			{
				main.console.log("You specified the ID of a non-PackedResourceProvider."
					+ " These cannot be output with this command.", LogLevel.ERROR);
			}
			
			complete();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String 
		{
			return "listPackageContents";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get signature():Array
		{
			return ["packageID:String"];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// CLI Command Signature Arguments
		//-----------------------------------------------------------------------------------------
		
		public function set packageID(v:String):void
		{
			_packageID = v;
		}
	}
}
