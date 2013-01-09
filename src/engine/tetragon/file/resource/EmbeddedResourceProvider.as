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
package tetragon.file.resource
{
	import tetragon.Main;
	import tetragon.data.Config;
	import tetragon.file.resource.loaders.XMLResourceLoader;

	import com.hexagonstar.file.types.IFile;

	
	/**
	 * Provider for resources that are embedded in the SWF file via [Embed] metatag.
	 */
	public final class EmbeddedResourceProvider extends ResourceProvider implements IResourceProvider
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "embeddedResourceProvider";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _resourceBundle:ResourceBundle;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EmbeddedResourceProvider(id:String = null)
		{
			super(id);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init(arg:* = null):Boolean
		{
			_resourceBundle = arg;
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function loadResourceBulk(bulk:ResourceBulk):void
		{
			if (!_resourceBundle) return;
			super.loadResourceBulk(bulk);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_resourceBundle = null;
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Not used for EmbeddedResourceProvider!
		 */
		override protected function onBulkFileLoaded(file:IFile):void
		{
		}
		
		
		/**
		 * Not used for EmbeddedResourceProvider!
		 */
		override protected function onBulkFileError(file:IFile):void
		{
		}
		
		
		override protected function onResourceInitSuccess(bf:ResourceBulkFile):void
		{
			if (bf.resourceLoader is XMLResourceLoader) parseXMLResource(bf);
			else parseMediaResource(bf);
			/* We need to call onLoaderComplete here for embedded resources. Otherwise
			 * we'd end up in a dead-end after loading an embedded resource. */
			onLoaderComplete(null);
		}
		
		
		override protected function onResourceInitFailed(bf:ResourceBulkFile, message:String):void
		{
			fail(bf, message);
			/* We need to call onLoaderComplete here for embedded resources. Otherwise
			 * we'd end up in a dead-end after loading an embedded resource. */
			onLoaderComplete(null);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function addBulkFile(bulkFile:ResourceBulkFile):void
		{
			super.addBulkFile(bulkFile);
			
			/* TODO For embedded resources only the first item from a bulkfile is
			 * supported for now! Need to check if this needs to be changed! */
			var item:ResourceBulkItem = bulkFile.items[0];
			var r:Resource = item.resource;
			var embeddedDataName:String;
			
			/* For text resources we need to get the embedded data that is mapped not only
			 * by the resource ID but also by the language key. */
			if (r.family == ResourceFamily.TEXT)
			{
				var lang:String = Main.instance.registry.config.getString(Config.LOCALE_CURRENT);
				embeddedDataName = _resourceBundle.getTextResourceDataName(r.id, lang);
			}
			else
			{
				embeddedDataName = _resourceBundle.getResourceDataName(r.id);
			}
			
			var embeddedData:* = _resourceBundle.getResourceData(embeddedDataName);
			
			bulkFile.resourceLoader.initSuccessSignal.addOnce(onResourceInitSuccess);
			bulkFile.resourceLoader.initFailedSignal.addOnce(onResourceInitFailed);
			bulkFile.resourceLoader.initialize(embeddedData);
		}
	}
}
