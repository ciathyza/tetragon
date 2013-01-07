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
package tetragon.file.resource.loaders
{
	import tetragon.Main;
	import tetragon.debug.Log;
	import tetragon.file.resource.ResourceBulkFile;

	import com.hexagonstar.file.types.MP3File;
	import com.hexagonstar.file.types.SoundFile;
	import com.hexagonstar.util.env.getRuntimeVersion;

	import flash.media.Sound;
	
	
	/**
	 * A resource loader for sound data (MP3).
	 */
	public class MP3ResourceLoader extends ResourceLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _sound:Sound;
		/** @private */
		protected static var _rtVersion:int = 0;
		/** @private */
		protected static var _swfVersion:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function setup(bulkFile:ResourceBulkFile):void
		{
			super.setup(bulkFile);
			
			/* Use legacy SoundFile type for content running in Flash Player version lower
			 * than 11, use MP3File otherwise. */
			if (_rtVersion == 0)
			{
				_rtVersion = getRuntimeVersion().major;
				_swfVersion = Main.instance.appInfo.swfVersion;
			}
			
			if (_rtVersion < 11)
			{
				_file = new SoundFile(bulkFile.path, bulkFile.id);
			}
			else
			{
				if (_swfVersion < 13)
				{
					Log.notice("SWF version is lower than 13. Using legacy sound loading!", this);
					_file = new SoundFile(bulkFile.path, bulkFile.id);
				}
				else
				{
					_file = new MP3File(bulkFile.path, bulkFile.id);
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns a Sound object.
		 */
		override public function get content():*
		{
			return _sound;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function onContentReady(content:*):Boolean 
		{
			return _sound != null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromLoaded():void
		{
			if (_rtVersion < 11 || _swfVersion < 13)
			{
				initializeFromEmbedded((_file as SoundFile).contentAsSound);
			}
			else
			{
				initializeFromEmbedded((_file as MP3File).contentAsSound);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromEmbedded(embeddedData:*):void
		{
			if (!(embeddedData is Sound))
			{
				throwInvalidDataException("Sound");
			}
			else
			{
				_sound = embeddedData;
				onLoadComplete();
			}
		}
	}
}
