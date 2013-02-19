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
package tetragon.data.swf
{
	import tetragon.data.DataObject;

	import com.hexagonstar.util.string.TabularText;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	
	/**
	 * Defines an 'Assets SWF' data object.
	 */
	public class SWFAssetCatalog extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const SWF_ASSET_CATALOG:String = "SWFAssetCatalog";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _swfFileID:String;
		private var _swf:MovieClip;
		private var _assets:Object;
		private var _size:uint;
		private var _processed:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function SWFAssetCatalog(id:String)
		{
			_id = id;
			_assets = {};
			_size = 0;
			_processed = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Maps an SWF asset to the catalog.
		 */
		public function mapAsset(asset:SWFAsset):void
		{
			_assets[asset.id] = asset;
			++_size;
		}
		
		
		/**
		 * Returns the original instance of the asset.
		 */
		public function getAssetInstance(assetID:String):*
		{
			var asset:SWFAsset = _assets[assetID];
			if (!asset) return null;
			return asset.instance;
		}
		
		
		/**
		 * Creates a clone of an asset and returns it.
		 */
		public function cloneAsset(assetID:String):*
		{
			// TODO Cloning not working yet! Need to find another way!
			var asset:SWFAsset = _assets[assetID];
			if (!asset) return null;
			
			/* Create a clone of the instance. */
			var source:DisplayObject = asset.instance;
			var clazz:Class = (source as Object)['constructor'];
			var instance:DisplayObject = new clazz();
			
			/* Copy properties to new instance. */
			populateProperties(instance, asset);
			
			/* Populate children into instance. */
			populateChildren(instance, asset);
			
			return instance;
		}
		
		
		/**
		 * Returns a string dump of the asset catalog.
		 * 
		 * @return A string dump of the asset catalog.
		 */
		override public function dump():String
		{
			var t:TabularText = new TabularText(4, true, "  ", null, "  ", 0,
				["ID", "TYPE", "INSTANCE", "CHILDREN"]);
			
			for each (var e:SWFAsset in _assets)
			{
				var type:String = "" + e.type;
				var instance:String = e.instance.toString();
				var numChildren:int = e.children ? e.children.length : 0;
				t.add([e.id, type, instance, numChildren]);
			}
			return toString() + " (size: " + _size + ")\n" + t;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get swfFileID():String
		{
			return _swfFileID;
		}
		public function set swfFileID(v:String):void
		{
			_swfFileID = v;
		}
		
		
		/**
		 * The content of the SWF that this assets SWF represents.
		 */
		public function get swf():MovieClip
		{
			return _swf;
		}
		public function set swf(v:MovieClip):void
		{
			_swf = v;
		}
		
		
		public function get size():uint
		{
			return _size;
		}
		
		
		public function get processed():Boolean
		{
			return _processed;
		}
		public function set processed(v:Boolean):void
		{
			_processed = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function populateProperties(instance:DisplayObject, asset:SWFAsset):void
		{
			for (var k:String in asset.properties)
			{
				if (k == "scale9Grid") continue;
				instance[k] = asset.properties[k];
			}
			//if (asset.instance.scale9Grid)
			//{
			//	var rect:Rectangle = asset.instance.scale9Grid;
			//	instance.scale9Grid = rect;
			//}
		}
		
		
		/**
		 * Recursive function to loop through all display objects and their children.
		 * @private
		 */
		private function populateChildren(instance:DisplayObject, asset:SWFAsset):void
		{
			if (!asset.children) return;
			
			/* Loop through children of currently iterated instance, create an instance
			 * and populate it with the original properties. */
			var numChildren:uint = asset.children.length;
			for (var i:uint = 0; i < numChildren; i++)
			{
				var childAsset:SWFAsset = asset.children[i];
				var childSource:DisplayObject = asset.instance;
				var childClazz:Class = (childSource as Object)['constructor'];
				var childInstance:DisplayObject = new childClazz();
				populateProperties(childInstance, childAsset);
				(instance as DisplayObjectContainer).addChild(childInstance);
				
				/* If child has children, iterate through them. */
				if (childAsset.children)
				{
					for (var j:uint = 0; j < childAsset.children.length; j++)
					{
						populateChildren(childInstance, childAsset);
					}
				}
			}
		}
	}
}
