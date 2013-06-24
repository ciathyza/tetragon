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
package view.theme
{
	import assets.ui.*;

	import tetragon.view.theme.IUIComponentTheme;
	import tetragon.view.theme.UITheme;
	
	
	/**
	 * DefaultTheme class
	 */
	public class ApplicationTheme extends UITheme implements IUIComponentTheme
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "applicationTheme";
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function setup():void
		{
			_name = "ApplicationTheme";
		}
		
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addFonts():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addTextFormats():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function mapUIComponentAssets():void
		{
			mapUIAsset("FocusRect", UIFocusRectAsset);
			
			mapUIAsset("TextInputUp", UITextInputUpAsset);
			mapUIAsset("TextInputDisabled", UITextInputDisabledAsset);
			
			mapUIAsset("ButtonDisabled", UIButtonDisabledAsset);
			mapUIAsset("ButtonDown", UIButtonDownAsset);
			mapUIAsset("ButtonEmphasized", UIButtonEmphasizedAsset);
			mapUIAsset("ButtonOver", UIButtonOverAsset);
			mapUIAsset("ButtonUp", UIButtonUpAsset);
			mapUIAsset("ButtonToggledDisabled", UIButtonToggledDisabledAsset);
			mapUIAsset("ButtonToggledDown", UIButtonToggledDownAsset);
			
			mapUIAsset("ScrollArrowDownDisabled", UIScrollArrowDownDisabledAsset);
			mapUIAsset("ScrollArrowDownDown", UIScrollArrowDownDownAsset);
			mapUIAsset("ScrollArrowDownOver", UIScrollArrowDownOverAsset);
			mapUIAsset("ScrollArrowDownUp", UIScrollArrowDownUpAsset);
			mapUIAsset("ScrollArrowUpDisabled", UIScrollArrowUpDisabledAsset);
			mapUIAsset("ScrollArrowUpDown", UIScrollArrowUpDownAsset);
			mapUIAsset("ScrollArrowUpOver", UIScrollArrowUpOverAsset);
			mapUIAsset("ScrollArrowUpUp", UIScrollArrowUpUpAsset);
			mapUIAsset("ScrollBarThumbIcon", UIScrollBarThumbAsset);
			mapUIAsset("ScrollThumbDown", UIScrollThumbDownAsset);
			mapUIAsset("ScrollThumbOver", UIScrollThumbOverAsset);
			mapUIAsset("ScrollThumbUp", UIScrollThumbUpAsset);
			mapUIAsset("ScrollTrack", UIScrollTrackAsset);
			
			mapUIAsset("LiteScrollThumbDown", UILiteScrollThumbDownAsset);
			mapUIAsset("LiteScrollThumbOver", UILiteScrollThumbOverAsset);
			mapUIAsset("LiteScrollThumbUp", UILiteScrollThumbUpAsset);
			mapUIAsset("LiteScrollTrack", UILiteScrollTrackAsset);
			
			mapUIAsset("ScrollPaneUpSkin", UIScrollPaneUpAsset);
			mapUIAsset("ScrollPaneDisabledSkin", UIScrollPaneDisabledAsset);
			mapUIAsset("PaneNormal", UIPaneNormalAsset);
			
			mapUIAsset("RadioButtonDisabledIcon", UIRadioButtonDisabledAsset);
			mapUIAsset("RadioButtonDownIcon", UIRadioButtonDownAsset);
			mapUIAsset("RadioButtonOverIcon", UIRadioButtonOverAsset);
			mapUIAsset("RadioButtonSelectedDisabledIcon", UIRadioButtonSelectedDisabledAsset);
			mapUIAsset("RadioButtonSelectedDownIcon", UIRadioButtonSelectedDownAsset);
			mapUIAsset("RadioButtonSelectedOverIcon", UIRadioButtonSelectedOverAsset);
			mapUIAsset("RadioButtonSelectedUpIcon", UIRadioButtonSelectedUpAsset);
			mapUIAsset("RadioButtonUpIcon", UIRadioButtonUpAsset);
			
			mapUIAsset("CellRendererDisabledSkin", UICellRendererDisabledAsset);
			mapUIAsset("CellRendererDownSkin", UICellRendererDownAsset);
			mapUIAsset("CellRendererOverSkin", UICellRendererOverAsset);
			mapUIAsset("CellRendererSelectedDisabledSkin", UICellRendererSelectedDisabledAsset);
			mapUIAsset("CellRendererSelectedDownSkin", UICellRendererSelectedDownAsset);
			mapUIAsset("CellRendererSelectedOverSkin", UICellRendererSelectedOverAsset);
			mapUIAsset("CellRendererSelectedUpSkin", UICellRendererSelectedUpAsset);
			mapUIAsset("CellRendererUpSkin", UICellRendererUpAsset);
			
			mapUIAsset("ListSkin", UIListAsset);
			
			mapUIAsset("ProgressBarTrackSkin", UIProgressBarTrackAsset);
			mapUIAsset("ProgressBarIndeterminateSkin", UIProgressBarIndeterminateAsset);
			mapUIAsset("ProgressBarBarSkin", UIProgressBarAsset);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addUIStyles():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addColors():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addSounds():void
		{
			super.addSounds();
		}
	}
}
