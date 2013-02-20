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
	import tetragon.data.DataObject;
	import tetragon.file.resource.Resource;

	import com.hexagonstar.types.Byte;
	import com.hexagonstar.util.debug.LogLevel;

	import flash.display.BitmapData;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	
	public class ResourceInfoCommand extends CLICommand
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
				var objType:String = "unknown";
				var size:String = "unknown";
				
				if (content)
				{
					if (content is DataObject)
					{
						objType = "DataObject";
					}
					else if (content is ByteArray)
					{
						objType = "ByteArray";
						size = new Byte(ByteArray(content).length).toString();
					}
					else if (content is BitmapData)
					{
						objType = "BitmapData";
						size = new Byte(BitmapData(content).width * BitmapData(content).height).toString();
					}
					else if (content is String)
					{
						objType = "String";
						size = new Byte(String(content).length).toString();
					}
					else if (content is Array)
					{
						objType = "Array";
						size = "" + (content as Array).length;
					}
					else if (content is XML)
					{
						objType = "XML";
						size = new Byte(XML(content).toXMLString().length).toString();
					}
					else if (content is XMLList)
					{
						objType = "XMLList";
						size = "" + XMLList(content).length();
					}
					else if (content is Sound)
					{
						objType = "Sound";
						size = new Byte(Sound(content).bytesTotal).toString();
					}
					else
					{
						try
						{
							var b:ByteArray = new ByteArray();
							b.writeObject(content);
							size = b.length.toString();
						}
						catch (err:Error)
						{
							size = "unknown";
						}
					}
				}
				
				var s:String = "\n\tid:             " + r.id
					+ "\n\tobjType         " + objType
					+ "\n\ttype:           " + r.type
					+ "\n\tpackageID:      " + r.packageID
					+ "\n\tpath:           " + r.path
					+ "\n\tdataFileID:     " + r.dataFileID
					+ "\n\tembedded:       " + r.embedded
					+ "\n\treferenceCount: " + r.referenceCount
					+ "\n\tstatus:         " + r.status
					+ "\n\tsize:           " + size
					+ "\n\tloaderClass:    " + r.loaderClass
					+ "\n\tcontent:        " + content
					+ "";
				main.console.log(s, LogLevel.INFO);
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
			return "resourceinfo";
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
			return "Outputs info about the resource with the specified resource ID.";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get example():String
		{
			return "resourceinfo \"resourceID\"";
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
