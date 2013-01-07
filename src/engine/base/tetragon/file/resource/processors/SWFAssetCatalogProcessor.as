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
package tetragon.file.resource.processors
{
	import tetragon.data.swf.SWFAsset;
	import tetragon.data.swf.SWFAssetCatalog;

	import com.hexagonstar.util.reflection.describeTypeProperties;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	
	/**
	 * A resource processor for Display assets that are defined on the timeline of
	 * a SWF resource file.
	 * 
	 * @deprecated
	 */
	public class SWFAssetCatalogProcessor extends ResourceProcessor
	{
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function processResources():Boolean
		{
			for (var i:uint = 0; i < resources.length; i++)
			{
				var assetsSWF:SWFAssetCatalog = resources[i].content;
				
				if (!assetsSWF)
				{
					return false;
				}
				if (assetsSWF.processed)
				{
					return true;
				}
				if (assetsSWF.swfFileID == null || assetsSWF.swfFileID == "")
				{
					error("Cannot process assetsSWF \"" + assetsSWF.id
						+ "\" because it has no swfFileID defined.");
					continue;
				}
				
				assetsSWF.swf = resourceIndex.getResourceContent(assetsSWF.swfFileID);
				if (!assetsSWF.swf)
				{
					error("Cannot process assetsSWF \"" + assetsSWF.id
						+ "\" because the required SWF file content \"" + assetsSWF.swfFileID
						+ "\" is null.");
					continue;
				}
				
				processAssetsSWF(assetsSWF);
			}
			return true;
		}
		
		
		/**
		 * @private
		 */
		private function processAssetsSWF(assetCatalog:SWFAssetCatalog):void
		{
			var swf:MovieClip = assetCatalog.swf;
			swf.stop();
			swf.gotoAndStop(1);
			
			/* Loop through all items found on the SWF display stage. */
			for each (var i:* in swf)
			{
				if (!(i is DisplayObject)) continue;
				
				var instance:DisplayObject = i;
				if (instance.name == null || instance.name == "") continue;
				
				var asset:SWFAsset = new SWFAsset(instance.name);
				asset.type = (instance as Object)['constructor'];
				asset.instance = instance;
				asset.properties = extractProperties(instance);
				
				if (instance is DisplayObjectContainer)
				{
					var len:int = (instance as DisplayObjectContainer).numChildren;
					if (len > 0)
					{
						asset.children = new Vector.<SWFAsset>(len, true);
						extractChildren(asset, 0);
					}
				}
				
				assetCatalog.mapAsset(asset);
			}
			
			assetCatalog.processed = true;
		}
		
		
		/**
		 * @private
		 */
		private function extractProperties(d:DisplayObject):Object
		{
			var obj:Object = describeTypeProperties(d, true);
			var properties:Object = {};
			for (var k:String in obj)
			{
				properties[k] = d[k];
			}
			return properties;
		}
		
		
		/**
		 * Recursive function to loop through all display objects and their children.
		 * @private
		 */
		private function extractChildren(asset:SWFAsset, depth:int):void
		{
			if (!(asset.instance is DisplayObjectContainer)) return;
			
			var instance:DisplayObjectContainer = asset.instance as DisplayObjectContainer;
			var numChildren:int = instance.numChildren;
			
			/* Loop through all children of currently iterated display object. */
			for (var i:uint = 0; i < numChildren; i++)
			{
				var child:DisplayObject = instance.getChildAt(i);
				var childAsset:SWFAsset = new SWFAsset(child.name);
				childAsset.type = (child as Object)['constructor'];
				childAsset.instance = child;
				childAsset.properties = extractProperties(child);
				
				if (asset.children) asset.children[i] = childAsset;
				
				if (child is DisplayObjectContainer)
				{
					var len:int = (child as DisplayObjectContainer).numChildren;
					if (len > 0)
					{
						childAsset.children = new Vector.<SWFAsset>(len, true);
						extractChildren(childAsset, ++depth);
					}
				}
			}
		}
	}
}
