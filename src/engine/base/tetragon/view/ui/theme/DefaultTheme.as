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
package tetragon.view.ui.theme
{
	import tetragon.view.ui.controls.*;
	import tetragon.view.ui.core.UIComponent;

	import com.hexagonstar.ui.theme.ThemeAssets;
	
	
	/**
	 * DefaultTheme class
	 */
	public class DefaultTheme extends UITheme implements IUIComponentTheme
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "default";
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function setup():void
		{
			_name = "Default";
		}
		
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addFonts():void
		{
			super.addFonts();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addTextFormats():void
		{
			super.addTextFormats();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addUIStyles():void
		{
			addUIStyle(UIComponent, UIStyleNames.FOCUSRECT_SKIN,			"FocusRect");
			addUIStyle(UIComponent, UIStyleNames.FOCUSRECT_PADDING,			2);
			addUIStyle(UIComponent, UIStyleNames.TEXTFORMAT,				ThemeAssets.guiText);
			addUIStyle(UIComponent, UIStyleNames.TEXTFORMAT_DISABLED,		ThemeAssets.guiTextDisabled);
			addUIStyle(UIComponent, UIStyleNames.DEFAULT_TEXTFORMAT,		ThemeAssets.guiText);
			addUIStyle(UIComponent, UIStyleNames.DEFAULT_TEXTFORMAT_DISABLED,ThemeAssets.guiTextDisabled);
			
			addUIStyle(BaseButton, UIStyleNames.UP_SKIN,					"ButtonUp");
			addUIStyle(BaseButton, UIStyleNames.DOWN_SKIN,					"ButtonDown");
			addUIStyle(BaseButton, UIStyleNames.OVER_SKIN,					"ButtonOver");
			addUIStyle(BaseButton, UIStyleNames.DISABLED_SKIN,				"ButtonDisabled");
			addUIStyle(BaseButton, UIStyleNames.SELECTED_DISABLED_SKIN,		"ButtonToggledDisabled");
			addUIStyle(BaseButton, UIStyleNames.SELECTED_UP_SKIN,			"ButtonToggledDown");
			addUIStyle(BaseButton, UIStyleNames.SELECTED_DOWN_SKIN,			"ButtonToggledDown");
			addUIStyle(BaseButton, UIStyleNames.SELECTED_OVER_SKIN,			"ButtonToggledDown");
			addUIStyle(BaseButton, UIStyleNames.FOCUSRECT_SKIN,				null);
			addUIStyle(BaseButton, UIStyleNames.FOCUSRECT_PADDING,			null);
			addUIStyle(BaseButton, UIStyleNames.REPEAT_DELAY,				500);
			addUIStyle(BaseButton, UIStyleNames.REPEAT_INTERVAL,			35);
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
