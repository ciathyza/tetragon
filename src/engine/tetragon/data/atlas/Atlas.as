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
package tetragon.data.atlas
{
	import tetragon.core.types.PointInt;
	import tetragon.data.DataObject;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	/**
	 * Abstract base class for atlas classes.
	 *
	 * @author Hexagon
	 */
	public class Atlas extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _imageID:String;
		/** @private */
		protected var _alphaImageID:String;
		/** @private */
		protected var _subTextureBounds:Vector.<SubTextureBounds>;
		/** @private */
		protected var _source:*;
		/** @private */
		protected var _regions:Object;
		/** @private */
		protected var _frames:Object;
		/** @private */
		protected var _alphaMasks:Object;
		/** @private */
		protected var _polygonalDatas:Object;
		/** @private */
		protected var _processed:Boolean;
		
		/** @private */
		protected static var _point:Point;
		/** @private */
		protected static var _matrix:Matrix;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param id
		 * @param imageID
		 * @param subTextureBounds
		 * @param alphaImageID
		 */
		public function Atlas(id:String, imageID:String, subTextureBounds:Vector.<SubTextureBounds>,
			alphaImageID:String = null)
		{
			_id = id;
			_imageID = imageID;
			_subTextureBounds = subTextureBounds;
			_alphaImageID = alphaImageID;
			_regions = {};
			_frames = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the atlas.
		 */
		override public function dispose():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Retrieves a sub-image by name. Returns <code>null</code> if it is not found.
		 * 
		 * @param id
		 * @param scale scaling factor for image pre-scaling.
		 * @return The sub-image.
		 */
		public function getImage(id:String, scale:Number = 1.0):*
		{
			/* Abstract method! */
			return null;
		}
		
		
		/**
		 * Returns all sub-images that start with a certain string, sorted alphabetically
		 * (especially useful for "MovieClip").
		 * 
		 * If a result array is specified, the images will be added to that array.
		 * 
		 * @param prefix
		 * @param scale scaling factor for image pre-scaling.
		 * @param result An Array that is used as the result.
		 * @return Array
		 */
		public function getImages(prefix:String = "", scale:Number = 1.0, result:Array = null):Array
		{
			var names:Vector.<String> = getNames(prefix);
			var images:Array;
			
			if (result) images = result;
			else images = [];
			
			for each (var name:String in names)
			{
				images.push(getImage(name, scale));
			}
			
			return images;
		}
		
		
		/**
		 * Returns all sub-images of the atlas mapped by their name into a dictionary.
		 * 
		 * @param prefix
		 * @param scale
		 * @param result
		 */
		public function getImageMap(prefix:String = "", scale:Number = 1.0,
			result:Dictionary = null):Dictionary
		{
			var map:Dictionary = result || new Dictionary();
			var names:Vector.<String> = getNames(prefix);
			for each (var name:String in names)
			{
				map[name] = getImage(name, scale);
			}
			return map;
		}
		
		
		/**
		 * Returns all sub-image names that start with a certain string, sorted alphabetically.
		 * 
		 * @param prefix
		 * @param result
		 */
		public function getNames(prefix:String = "", result:Vector.<String> = null):Vector.<String>
		{
			if (!result) result = new <String>[];
			for (var name:String in _regions)
			{
				if (name.indexOf(prefix) == 0) result.push(name);
			}
			result.sort(Array.CASEINSENSITIVE);
			return result;
		}
		
		
		/**
		 * Creates a region for a subtexture and gives it a name.
		 * 
		 * @param id
		 * @param region
		 * @param frame
		 * @param alphaMask
		 * @param polygonalData
		 */
		public function addRegion(id:String, region:Rectangle, frame:Rectangle = null,
			alphaMask:BitmapData = null, polygonalData:Vector.<PointInt> = null):void
		{
			_regions[id] = region;
			if (frame) _frames[id] = frame;
			if (alphaMask)
			{
				if (!_alphaMasks) _alphaMasks = {};
				_alphaMasks[id] = alphaMask;
			}
			if (polygonalData)
			{
				if (!_polygonalDatas) _polygonalDatas = {};
				_polygonalDatas[id] = polygonalData;
			}
		}
		
		
		/**
		 * Returns the alpha mask for a specific subtexture, if available, otherwise
		 * it returns null.
		 * 
		 * @param id ID of the subtexture.
		 * @return A black and white BitmapData or null.
		 */
		public function getAlphaMask(id:String):BitmapData
		{
			if (!_alphaMasks) return null;
			return _alphaMasks[id];
		}
		
		
		/**
		 * Returns the polygonal data for a specific subtexture, if available, otherwise
		 * it returns null.
		 * 
		 * @param id ID of the subtexture.
		 * @return A Vector.<PointInt> or null.
		 */
		public function getPolygonalData(id:String):Vector.<PointInt>
		{
			if (!_polygonalDatas) return null;
			return _polygonalDatas[id];
		}
		
		
		/**
		 * Returns the region rectangle for a specific sprite.
		 * 
		 * @param id
		 */
		public function getRegion(id:String):Rectangle
		{
			return _regions[id];
		}
		
		
		/**
		 * Removes a region with a certain name.
		 * 
		 * @param id
		 */
		public function removeRegion(id:String):void
		{
			delete _regions[id];
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dump():String
		{
			var s:String = toString();
			for (var i:uint = 0; i < _subTextureBounds.length; i++)
			{
				var stb:SubTextureBounds = _subTextureBounds[i];
				s += "\n\t" + stb.id;
			}
			return s;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get subTextureBounds():Vector.<SubTextureBounds>
		{
			return _subTextureBounds;
		}
		
		
		public function get subTextureCount():uint
		{
			if (!_subTextureBounds) return 0;
			return _subTextureBounds.length;
		}
		
		
		public function get imageID():String
		{
			return _imageID;
		}
		
		
		public function get alphaImageID():String
		{
			return _alphaImageID;
		}
		
		
		public function get source():*
		{
			return _source;
		}
		public function set source(v:*):void
		{
			_source = v;
		}
		
		
		public function get regions():Object
		{
			return _regions;
		}
		
		
		public function get frames():Object
		{
			return _frames;
		}
		
		
		public function get alphaMasks():Object
		{
			return _alphaMasks;
		}
		
		
		public function get processed():Boolean
		{
			return _processed;
		}
		public function set processed(v:Boolean):void
		{
			_processed = v;
		}
	}
}
