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
package
{
	import tetragon.IAppInfo;
	
	
	/**
	 * Provides general meta information about the application.
	 * NOTE: Ant auto-generated application information class. Do not edit!
	 */
	public final class AppInfo implements IAppInfo
	{
		/** @inheritDoc */
		public function get id():String {return "@app_id@";}
		/** @inheritDoc */
		public function get name():String {return "@app_name@";}
		/** @inheritDoc */
		public function get description():String { return "@app_description@";}
		/** @inheritDoc */
		public function get version():String {return "@app_version@";}
		/** @inheritDoc */
		public function get build():String {return "@build_nr@";}
		/** @inheritDoc */
		public function get buildDate():String {return "@build_date@";}
		/** @inheritDoc */
		public function get milestone():String {return "@app_milestone@";}
		/** @inheritDoc */
		public function get buildType():String {return "@build_type@";}
		/** @inheritDoc */
		public function get releaseStage():String {return "@app_releasestage@";}
		/** @inheritDoc */
		public function get copyright():String {return "@app_copyright@";}
		/** @inheritDoc */
		public function get publisher():String {return "@meta_publisher@";}
		/** @inheritDoc */
		public function get creator():String {return "@meta_creator@";}
		/** @inheritDoc */
		public function get contributor():String {return "@meta_contributor@";}
		/** @inheritDoc */
		public function get year():String {return "@app_year@";}
		/** @inheritDoc */
		public function get website():String {return "@app_website@";}
		/** @inheritDoc */
		public function get language():String {return "@app_language@";}
		
		/** @inheritDoc */
		public function get filename():String {return "@file_name@";}
		/** @inheritDoc */
		public function get filenameEngineConfig():String {return "@filename_engineconfig@";}
		/** @inheritDoc */
		public function get filenameKeyBindings():String {return "@filename_keybindings@";}
		/** @inheritDoc */
		public function get filenameResourceIndex():String {return "@filename_resourceindex@";}
		
		/** @inheritDoc */
		public function get configFolder():String {return "@config_folder@";}
		/** @inheritDoc */
		public function get resourcesFolder():String {return "@resources_folder@";}
		/** @inheritDoc */
		public function get iconsFolder():String {return "@icons_folder@";}
		/** @inheritDoc */
		public function get extraFolder():String {return "@extra_folder@";}
		
		/** @inheritDoc */
		public function get defaultWidth():int {return @default_width@;}
		/** @inheritDoc */
		public function get defaultHeight():int {return @default_height@;}
		/** @inheritDoc */
		public function get referenceWidth():int {return @reference_width@;}
		/** @inheritDoc */
		public function get referenceHeight():int {return @reference_height@;}
		
		/** @inheritDoc */
		public function get swfVersion():int {return @swf_version@;}
		
		/** @inheritDoc */
		public function get isDebug():Boolean {return @is_debug@;}
		
		/** @inheritDoc */
		public function get usePackedResources():Boolean {return @use_packed_resources@;}
	}
}
