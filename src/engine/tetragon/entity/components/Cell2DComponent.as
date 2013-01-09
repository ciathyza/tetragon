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
package tetragon.entity.components
{
	import tetragon.entity.EntityComponent;
	import tetragon.entity.IEntityComponent;
	
	
	public class Cell2DComponent extends EntityComponent implements IEntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _nameID:String;
		/** @private */
		private var _descriptionID:String;
		/** @private */
		private var _type:String;
		/** @private */
		private var _worldSpaceID:String;
		/** @private */
		private var _acousticSpaceID:String;
		/** @private */
		private var _musicID:String;
		/** @private */
		private var _locationID:String;
		/** @private */
		private var _allowFastTravel:Boolean;
		/** @private */
		private var _allowWait:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get nameID():String
		{
			return _nameID;
		}
		public function set nameID(v:String):void
		{
			_nameID = v;
		}
		
		
		public function get descriptionID():String
		{
			return _descriptionID;
		}
		public function set descriptionID(v:String):void
		{
			_descriptionID = v;
		}
		
		
		public function get type():String
		{
			return _type;
		}
		public function set type(v:String):void
		{
			_type = v;
		}
		
		
		public function get worldSpaceID():String
		{
			return _worldSpaceID;
		}
		public function set worldSpaceID(v:String):void
		{
			_worldSpaceID = v;
		}
		
		
		public function get acousticSpaceID():String
		{
			return _acousticSpaceID;
		}
		public function set acousticSpaceID(v:String):void
		{
			_acousticSpaceID = v;
		}
		
		
		public function get musicID():String
		{
			return _musicID;
		}
		public function set musicID(v:String):void
		{
			_musicID = v;
		}
		
		
		public function get locationID():String
		{
			return _locationID;
		}
		public function set locationID(v:String):void
		{
			_locationID = v;
		}
		
		
		public function get allowFastTravel():Boolean
		{
			return _allowFastTravel;
		}
		public function set allowFastTravel(v:Boolean):void
		{
			_allowFastTravel = v;
		}
		
		
		public function get allowWait():Boolean
		{
			return _allowWait;
		}
		public function set allowWait(v:Boolean):void
		{
			_allowWait = v;
		}
	}
}
