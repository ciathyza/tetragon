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
	import tetragon.core.exception.IllegalStateException;
	import tetragon.core.file.types.SWFFile;
	import tetragon.file.resource.ResourceBulkFile;

	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;
	
	
	/**
	 * A resource loader for SWF files.
	 */
	public class SWFResourceLoader extends ResourceLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _movieClip:MovieClip;
		/** @private */
		protected var _appDomain:ApplicationDomain;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function setup(bulkFile:ResourceBulkFile):void
		{
			super.setup(bulkFile);
			_file = new SWFFile(bulkFile.path, bulkFile.id);
		}
		
		
		/**
		 * Gets a new instance of the specified exported class contained in the SWF.
		 * Returns a null reference if the exported name is not found in the loaded
		 * ApplicationDomain.
		 *
		 * @param name The fully qualified name of the exported class.
		 */
		public function getExportedAsset(name:String):Object
		{
			var assetClass:Class = getAssetClass(name);
			if (assetClass != null) return new assetClass();
			return null;
		}
		
		
		/**
		 * Gets a Class instance for the specified exported class name in the SWF.
		 * Returns a null reference if the exported name is not found in the loaded
		 * ApplicationDomain.
		 *
		 * @param name The fully qualified name of the exported class.
		 */
		public function getAssetClass(name:String):Class
		{
			if (_appDomain == null)
			{
				throw new IllegalStateException(toString()
					+ " Not initialized (applicationDomain is null)!");
				return null;
			}

			if (_appDomain.hasDefinition(name)) return Class(_appDomain.getDefinition(name));
			return null;
		}
		
		
		/**
		 * Recursively searches all child clips for the maximum frame count.
		 * 
		 * @param parent
		 * @param currentMax
		 */
		public function findMaxFrames(parent:MovieClip, currentMax:int):int
		{
			for (var i:int = 0; i < parent.numChildren; i++)
			{
				var mc:MovieClip = MovieClip(parent.getChildAt(i));
				if (!mc) continue;
				currentMax = Math.max(currentMax, mc.totalFrames);
				findMaxFrames(mc, currentMax);
			}
			return currentMax;
		}
		
		
		/**
		 * Recursively advances all child clips to the specified frame.
		 * If the child does not have a frame at the position, it is skipped.
		 * 
		 * @param parent
		 * @param frame
		 */
		public function advanceChildClips(parent:MovieClip, frame:int):void
		{
			for (var i:int = 0; i < parent.numChildren; i++)
			{
				var mc:MovieClip = MovieClip(parent.getChildAt(i));
				if (!mc) continue;
				if (mc.totalFrames >= frame) mc.gotoAndStop(frame);
				else mc.gotoAndStop(mc.totalFrames);
				advanceChildClips(mc, frame);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		
		/**
		 * Returns a MovieClip.
		 */
		override public function get content():*
		{
			return _movieClip;
		}
		
		
		public function get applicationDomain():ApplicationDomain 
		{
			return _appDomain; 
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function onContentReady(content:*):Boolean 
		{
			if (content) _movieClip = content;
			/* Get the app domain... */
			// TODO handle loader object for embedded data that comes without file!
			var l:Loader = SWFFile(_file).loader;
			if (l && l.contentLoaderInfo)
			{
				_appDomain = l.contentLoaderInfo.applicationDomain;
			}
			else if (content && content["loaderInfo"])
			{
				_appDomain = content["loaderInfo"]["applicationDomain"];
			}
			return _movieClip != null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromLoaded():void
		{
			if (SWFFile(_file).isAVM1)
			{
				_status = "The content of SWF resource \"" + _file.path
					+ "\" is AVM1 content which is not supported by the SWF resource loader."
					+ " Use AVM2 content instead (FP 9+).";
				onFailed(_status);
				return;
			}
			
			onContentReady(SWFFile(_file).contentAsMovieClip);
			onLoadComplete();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromEmbedded(embeddedData:*):void
		{
			if (embeddedData is MovieClip)
			{
				onContentReady(embeddedData);
				onLoadComplete();
				return;
			}
			/* Otherwise it must be a ByteArray, pass it over to the normal path. */
			super.initializeFromEmbedded(embeddedData);
		}
	}
}
