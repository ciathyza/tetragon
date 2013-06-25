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
package tetragon.view.render2d.display
{
	import tetragon.core.exception.AbstractClassException;

	import flash.display3D.Context3DBlendFactor;

	/** A class that provides constant values for visual blend mode effects. 
	 *   
	 *  <p>A blend mode is always defined by two 'Context3DBlendFactor' values. A blend factor 
	 *  represents a particular four-value vector that is multiplied with the source or destination
	 *  color in the blending formula. The blending formula is:</p>
	 * 
	 *  <pre>result = source × sourceFactor + destination × destinationFactor</pre>
	 * 
	 *  <p>In the formula, the source color is the output color of the pixel shader program. The 
	 *  destination color is the color that currently exists in the color buffer, as set by 
	 *  previous clear and draw operations.</p>
	 *  
	 *  <p>Beware that blending factors produce different output depending on the texture type.
	 *  Textures may contain 'premultiplied alpha' (pma), which means that their RGB values were 
	 *  multiplied with their color value (to save processing time). Textures based on 'BitmapData'
	 *  objects have premultiplied alpha values, while ATF textures haven't. For this reason, 
	 *  a blending mode may have different factors depending on the pma value.</p>
	 *  
	 *  @see flash.display3D.Context3DBlendFactor
	 */
	public class BlendMode2D
	{
		private static var sBlendFactors:Array = [// no premultiplied alpha
		{"none":[Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO], "normal":[Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA], "add":[Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA], "multiply":[Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA], "screen":[Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE], "erase":[Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA]},
		// premultiplied alpha 
		{"none":[Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO], "normal":[Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA], "add":[Context3DBlendFactor.ONE, Context3DBlendFactor.ONE], "multiply":[Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA], "screen":[Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR], "erase":[Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA]}];


		// predifined modes
		/** @private */
		public function BlendMode2D()
		{
			throw new AbstractClassException(this);
		}


		/** Inherits the blend mode from this display object's parent. */
		public static const AUTO:String = "auto";
		/** Deactivates blending, i.e. disabling any transparency. */
		public static const NONE:String = "none";
		/** The display object appears in front of the background. */
		public static const NORMAL:String = "normal";
		/** Adds the values of the colors of the display object to the colors of its background. */
		public static const ADD:String = "add";
		/** Multiplies the values of the display object colors with the the background color. */
		public static const MULTIPLY:String = "multiply";
		/** Multiplies the complement (inverse) of the display object color with the complement of 
		 * the background color, resulting in a bleaching effect. */
		public static const SCREEN:String = "screen";
		/** Erases the background when drawn on a RenderTexture. */
		public static const ERASE:String = "erase";


		// accessing modes
		/** Returns the blend factors that correspond with a certain mode and premultiplied alpha
		 *  value. Throws an ArgumentError if the mode does not exist. */
		public static function getBlendFactors(mode:String, premultipliedAlpha:Boolean = true):Array
		{
			var modes:Object = sBlendFactors[int(premultipliedAlpha)];
			if (mode in modes) return modes[mode];
			else throw new ArgumentError("Invalid blend mode");
		}


		/** Registeres a blending mode under a certain name and for a certain premultiplied alpha
		 *  (pma) value. If the mode for the other pma value was not yet registered, the factors are
		 *  used for both pma settings. */
		public static function register(name:String, sourceFactor:String, destFactor:String, premultipliedAlpha:Boolean = true):void
		{
			var modes:Object = sBlendFactors[int(premultipliedAlpha)];
			modes[name] = [sourceFactor, destFactor];

			var otherModes:Object = sBlendFactors[int(!premultipliedAlpha)];
			if (!(name in otherModes)) otherModes[name] = [sourceFactor, destFactor];
		}
	}
}