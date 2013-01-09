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
	
	
	public class Cell2DInteriorDataComponent extends EntityComponent implements IEntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _encounterZoneID:String;
		/** @private */
		private var _ownerActorID:String;
		/** @private */
		private var _ownerFactionID:String;
		/** @private */
		private var _ownerFactionRankID:String;
		/** @private */
		private var _isPublicArea:Boolean;
		/** @private */
		private var _isOffLimits:Boolean;


		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get encounterZoneID():String
		{
			return _encounterZoneID;
		}
		public function set encounterZoneID(v:String):void
		{
			_encounterZoneID = v;
		}
		
		
		public function get ownerActorID():String
		{
			return _ownerActorID;
		}
		public function set ownerActorID(v:String):void
		{
			_ownerActorID = v;
		}
		
		
		public function get ownerFactionID():String
		{
			return _ownerFactionID;
		}
		public function set ownerFactionID(v:String):void
		{
			_ownerFactionID = v;
		}
		
		
		public function get ownerFactionRankID():String
		{
			return _ownerFactionRankID;
		}
		public function set ownerFactionRankID(v:String):void
		{
			_ownerFactionRankID = v;
		}
		
		
		public function get isPublicArea():Boolean
		{
			return _isPublicArea;
		}
		public function set isPublicArea(v:Boolean):void
		{
			_isPublicArea = v;
		}
		
		
		public function get isOffLimits():Boolean
		{
			return _isOffLimits;
		}
		public function set isOffLimits(v:Boolean):void
		{
			_isOffLimits = v;
		}
	}
}
