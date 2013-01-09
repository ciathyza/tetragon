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
package tetragon.view.shader
{
	import flash.display.Shader;
	import flash.utils.ByteArray;
	
	
	/**
	 * Wrapper for the Pixel Bender CRT Shader that provides typed accessors to
	 * the shader's properties.
	 */
	public class CRTShader extends Shader
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function CRTShader(code:ByteArray = null)
		{
			super(code);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get blur():int
		{
			return data["blur"]["value"][0];
		}
		public function set blur(v:int):void
		{
			v = v < 0 ? 0 : v > 4 ? 4 : v;
			data["blur"]["value"] = [v];
		}
		
		
		public function get saturation():Number
		{
			return data["saturation"]["value"][0];
		}
		public function set saturation(v:Number):void
		{
			v = v < 0.0 ? 0.0 : v > 2.0 ? 2.0 : v;
			data["saturation"]["value"] = [v];
		}
		
		
		public function get contrast():Number
		{
			return data["contrast"]["value"][0];
		}
		public function set contrast(v:Number):void
		{
			v = v < 0.0 ? 0.0 : v > 5.0 ? 5.0 : v;
			data["contrast"]["value"] = [v];
		}
		
		
		public function get brightness():Number
		{
			return data["brightness"]["value"][0];
		}
		public function set brightness(v:Number):void
		{
			v = v < 0.0 ? 0.0 : v > 5.0 ? 5.0 : v;
			data["brightness"]["value"] = [v];
		}
		
		
		public function get scanlineOpacity():Number
		{
			return data["scanlineOpacity"]["value"][0];
		}
		public function set scanlineOpacity(v:Number):void
		{
			v = v < 0.0 ? 0.0 : v > 1.0 ? 1.0 : v;
			data["scanlineOpacity"]["value"] = [v];
		}
		
		
		public function get scanlineDirection():int
		{
			return data["scanlineDirection"]["value"][0];
		}
		public function set scanlineDirection(v:int):void
		{
			v = v < 0 ? 0 : v > 1 ? 1 : v;
			data["scanlineDirection"]["value"] = [v];
		}
		
		
		public function get verticalScanlines():Boolean
		{
			return data["scanlineDirection"]["value"][0] == 1;
		}
		public function set verticalScanlines(v:Boolean):void
		{
			if (v) data["scanlineDirection"]["value"] = [1];
			else data["scanlineDirection"]["value"] = [0];
		}
		
		
		public function get scanlineSize():int
		{
			return data["scanlineSize"]["value"][0];
		}
		public function set scanlineSize(v:int):void
		{
			v = v < 1 ? 1 : v > 2 ? 2 : v;
			data["scanlineSize"]["value"] = [v];
		}
	}
}
