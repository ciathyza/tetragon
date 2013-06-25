/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.file.types
{
	import tetragon.core.constants.Status;
	import tetragon.core.exception.InvalidDataException;

	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	
	/**
	 * A file type used to load MP3 files. Requires Flash Player 11 or AIR 3 as a minimum.
	 * For sounds that need to be loaded with Flash Player version below 11, use the
	 * SoundFile class instead.
	 * 
	 * <p>NOTE: The loaded MP3 file must contain ID3v2 data to be able to be loaded with
	 * the MP3File! This is a due to a limitation of the AS3 Sound API.</p>
	 * 
	 * @see com.hexagonstar.file.types.IFile
	 * @see com.hexagonstar.file.types.SoundFile
	 */
	public class MP3File extends BinaryFile implements IFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _sound:Sound;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the file class.
		 * 
		 * @param path The path of the file that this file object is used for.
		 * @param id An optional ID for the file.
		 * @param priority An optional load priority for the file. Used for loading with the
		 *            BulkLoader class.
		 * @param weight An optional weight for the file. Used for weighted loading with the
		 *            BulkLoader class.
		 * @param callback An optional callback method that can be associated with the file.
		 * @param params An optional array of parameters that can be associated with the file.
		 */
		public function MP3File(path:String = null, id:String = null, priority:Number = NaN,
			weight:int = 1, callback:Function = null, params:Array = null)
		{
			super(path, id, priority, weight, callback, params);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get fileTypeID():int
		{
			return FileTypeIndex.MP3_FILE_ID;
		}

		
		/**
		 * @inheritDoc
		 */
		override public function get content():*
		{
			return contentAsSound;
		}
		override public function set content(v:*):void
		{
			if (v is ByteArray)
			{
				var bytes:ByteArray = v as ByteArray;
				bytes.position = 0;
				
				if (bytes.length < 3 || bytes.readUTFBytes(3) != "ID3")
				{
					_valid = false;
					_status = "MP3File data does not contain ID3v2 data.";
					complete();
					return;
				}
				
				bytes.position = 0;
				_sound = new Sound();
				_sound.addEventListener(Event.ID3, onComplete);
				
				try
				{
					_sound.loadCompressedDataFromByteArray(bytes, bytes.length);
				}
				catch (err:Error)
				{
					_valid = false;
					_status = err.message;
					throw new InvalidDataException(toString() + " " + _status);
					complete();
				}
				return;
			}
			else
			{
				_valid = false;
				_status = "MP3File only accepts a ByteArray object as content.";
				throw new InvalidDataException(toString() + " " + _status);
			}
			complete();
		}
		
		
		/**
		 * The SoundFile content, as a Sound object.
		 */
		public function get contentAsSound():Sound
		{
			return _sound;
		}
		
		
		/**
		 * The sound file's content data, as a ByteArray. This simply writes the sound
		 * object into a ByteArray and returns it.
		 */
		override public function get contentAsBytes():ByteArray
		{
			if (!_sound) return null;
			var b:ByteArray = new ByteArray();
			/* TODO Sound.extract needs testing! Might hang if extracted all data at once! */
			try
			{
				_sound.extract(b, _sound.length * 44.1);
			}
			catch (err:Error)
			{
				throw new InvalidDataException(toString() + " Cound not extract sound data. (Error was: " + err.message + ").");
			}
			return b;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set contentAsBytes(v:ByteArray):void
		{
			content = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onComplete(e:Event):void 
		{
			_sound.removeEventListener(Event.ID3, onComplete);
			_valid = true;
			_status = Status.OK;
			complete();
		}
	}
}
