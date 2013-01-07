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
	import tetragon.data.DataList;
	import tetragon.entity.EntityDefinition;
	import tetragon.file.resource.Resource;

	import com.hexagonstar.util.debug.LogLevel;
	
	
	public class DumpCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _resourceID:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			var r:Resource = main.resourceManager.resourceIndex.getResource(_resourceID);
			if (r)
			{
				var content:* = r.content;
				var s:String;
				if (content)
				{
					if (content is EntityDefinition)
					{
						var et:EntityDefinition = EntityDefinition(content);
						s = et.dump();
					}
					else if (content is DataList)
					{
						var dl:DataList = DataList(content);
						s = dl.dump();
					}
					else
					{
						try
						{
							s = content["dump"]();
						}
						catch (err:Error)
						{
							main.console.log("Resource object with ID \"" + _resourceID + "\" has no dump() method!", LogLevel.ERROR);
						}
					}
				}
				else
				{
					main.console.log("The content of resource with ID \"" + _resourceID + "\" is null. Try loading the resource first.", LogLevel.ERROR);
				}
				
				if (s) main.console.log(s, LogLevel.INFO);
			}
			else
			{
				main.console.log("no resource with ID \"" + _resourceID + "\" found!", LogLevel.ERROR);
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
			return "dump";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get signature():Array
		{
			return ["resourceID:String"];
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get helpText():String
		{
			return "Outputs a string dump of the resource with the specified resource ID.";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get example():String
		{
			return "dump \"resourceID\"";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// CLI Command Signature Arguments
		//-----------------------------------------------------------------------------------------
		
		public function set resourceID(v:String):void
		{
			_resourceID = v;
		}
	}
}
