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
package tetragon.data.sprite
{
	/**
	 * Represents a single sprite object that can have sprite properties and one or
	 * more sprite sequences.
	 */
	public final class SpriteObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _id:String;
		private var _spriteSheetID:String;
		private var _properties:Object;
		private var _sequences:Object;
		private var _sequenceCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function SpriteObject(id:String, spriteSheetID:String, properties:Object,
			sequences:Object, sequenceCount:int)
		{
			_id = id;
			_spriteSheetID = spriteSheetID;
			_properties = properties;
			_sequences = sequences;
			_sequenceCount = sequenceCount;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Unique ID of the sprite object.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		/**
		 * The ID of the spriteSheet from which this sprite object takes it's frame.
		 * If this value is null the sprite object follows the tileset's spriteSheet ID.
		 */
		public function get spriteSheetID():String
		{
			return _spriteSheetID;
		}
		
		
		/**
		 * A map of SpriteProperty objects.
		 * The key name is originally taken from the SpriteSet's property definitions.
		 */
		public function get properties():Object
		{
			return _properties;
		}
		
		
		/**
		 * A map of SpriteSequence objects mapped by their ID.
		 */
		public function get sequences():Object
		{
			return _sequences;
		}
		
		
		/**
		 * The number of sequences in this sprite.
		 */
		public function get sequenceCount():int
		{
			return _sequenceCount;
		}
	}
}
