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
package tetragon.util.color
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	
	
	public final class ColorMatrix
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const LUMA_R:Number = 0.212671;
		private static const LUMA_G:Number = 0.71516;
		private static const LUMA_B:Number = 0.072169;
		private static const LUMA_R2:Number = 0.3086;
		private static const LUMA_G2:Number = 0.6094;
		private static const LUMA_B2:Number = 0.0820;
		private static const ONETHIRD:Number = 1 / 3;
		private static const RAD:Number = Math.PI / 180;
		
		private static const IDENTITY:Array = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _matrix:Array;
		private var _preHue:ColorMatrix;
		private var _postHue:ColorMatrix;
		private var _hueInitialized:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param matrix Optional init matrix, if omitted matrix gets initialized with an
		 *        identity matrix. Alternatively it can be initialized with another ColorMatrix
		 *        or an array (there is currently no check if the array is valid. A correct
		 *        array contains 20 elements.)
		 */
		public function ColorMatrix(matrix:Object = null)
		{
			if (matrix is ColorMatrix) _matrix = ColorMatrix(matrix)._matrix.concat();
			else if (matrix is Array) _matrix = (matrix as Array).concat();
			else reset();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Resets the matrix to the neutral identity matrix. Applying this matrix to an
		 * image will not make any changes to it.
		 */
		public function reset():void
		{
			_matrix = IDENTITY.concat();
		}
		
		
		/**
		 * Clones the ColorMatrix.
		 */
		public function clone():ColorMatrix
		{
			return new ColorMatrix(_matrix);
		}
		
		
		/**
		 * Inverts the ColorMatrix.
		 */
		public function invert():void
		{
			concat([-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * Changes the contrast. Typical values come in the range -1.0 ... 1.0 where -1.0
		 * means no contrast (grey), 0 means no change, 1.0 is high contrast.
		 * 
		 * @param r
		 * @param g
		 * @param b
		 */
		public function adjustContrast(r:Number, g:Number = NaN, b:Number = NaN):void
		{
			if (isNaN(g)) g = r;
			if (isNaN(b)) b = r;
			r += 1;
			g += 1;
			b += 1;
			concat([r, 0, 0, 0, (128 * (1 - r)), 0, g, 0, 0, (128 * (1 - g)), 0, 0, b, 0,
				(128 * (1 - b)), 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param r
		 * @param g
		 * @param b
		 */
		public function adjustBrightness(r:Number, g:Number = NaN, b:Number = NaN):void
		{
			if (isNaN(g)) g = r;
			if (isNaN(b)) b = r;
			concat([1, 0, 0, 0, r, 0, 1, 0, 0, g, 0, 0, 1, 0, b, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param s
		 */
		public function adjustSaturation(s:Number):void
		{
			var sInv:Number = (1 - s);
			var irlum:Number = (sInv * LUMA_R);
			var iglum:Number = (sInv * LUMA_G);
			var iblum:Number = (sInv * LUMA_B);
			concat([(irlum + s), iglum, iblum, 0, 0, irlum, (iglum + s), iblum, 0, 0,
				irlum, iglum, (iblum + s), 0, 0, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param r
		 * @param g
		 * @param b
		 */
		public function toGreyscale(r:Number, g:Number, b:Number):void
		{
			concat([r, g, b, 0, 0, r, g, b, 0, 0, r, g, b, 0, 0, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param degrees
		 */
		public function adjustHue(degrees:Number):void
		{
			degrees *= RAD;
			var cos:Number = Math.cos(degrees);
			var sin:Number = Math.sin(degrees);
			concat([((LUMA_R + (cos * (1 - LUMA_R))) + (sin * -(LUMA_R))),
				((LUMA_G + (cos * -(LUMA_G))) + (sin * -(LUMA_G))),
				((LUMA_B + (cos * -(LUMA_B))) + (sin * (1 - LUMA_B))),
				0, 0, ((LUMA_R + (cos * -(LUMA_R))) + (sin * 0.143)),
				((LUMA_G + (cos * (1 - LUMA_G))) + (sin * 0.14)),
				((LUMA_B + (cos * -(LUMA_B))) + (sin * -0.283)), 0, 0,
				((LUMA_R + (cos * -(LUMA_R))) + (sin * -((1 - LUMA_R)))),
				((LUMA_G + (cos * -(LUMA_G))) + (sin * LUMA_G)),
				((LUMA_B + (cos * (1 - LUMA_B))) + (sin * LUMA_B)), 0, 0, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param degrees
		 */
		public function rotateHue(degrees:Number):void
		{
			initHue();
			concat(_preHue._matrix);
			rotateBlue(degrees);
			concat(_postHue._matrix);
		}
		
		
		public function luminanceToAlpha():void
		{
			concat([0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, LUMA_R, LUMA_G, LUMA_B, 0, 0]);
		}
		
		
		/**
		 * @param amount
		 */
		public function adjustAlphaContrast(amount:Number):void
		{
			amount += 1;
			concat([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, amount, (128 * (1 - amount))]);
		}
		
		
		/**
		 * @param rgb
		 * @param amount
		 */
		public function colorize(rgb:uint, amount:Number = 1):void
		{
			var r:Number = (((rgb >> 16) & 0xFF) / 0xFF);
			var g:Number = (((rgb >> 8) & 0xFF) / 0xFF);
			var b:Number = ((rgb & 0xFF) / 0xFF);
			var invAmount:Number = (1 - amount);
			concat([(invAmount + ((amount * r) * LUMA_R)), ((amount * r) * LUMA_G),
				((amount * r) * LUMA_B), 0, 0, ((amount * g) * LUMA_R),
				(invAmount + ((amount * g) * LUMA_G)), ((amount * g) * LUMA_B),
				0, 0, ((amount * b) * LUMA_R), ((amount * b) * LUMA_G),
				(invAmount + ((amount * b) * LUMA_B)), 0, 0, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param r
		 * @param g
		 * @param b
		 * @param a
		 */
		public function setChannels(r:int = 1, g:int = 2, b:int = 4, a:int = 8):void
		{
			var rf:Number = (((r & 1) == 1) ? 1 : 0) + (((r & 2) == 2) ? 1 : 0) + (((r & 4) == 4) ? 1 : 0) + (((r & 8) == 8) ? 1 : 0);
			if (rf > 0) rf = (1 / rf);
			var gf:Number = (((g & 1) == 1) ? 1 : 0) + (((g & 2) == 2) ? 1 : 0) + (((g & 4) == 4) ? 1 : 0) + (((g & 8) == 8) ? 1 : 0);
			if (gf > 0) gf = (1 / gf);
			var bf:Number = (((b & 1) == 1) ? 1 : 0) + (((b & 2) == 2) ? 1 : 0) + (((b & 4) == 4) ? 1 : 0) + (((b & 8) == 8) ? 1 : 0);
			if (bf > 0) bf = (1 / bf);
			var af:Number = (((a & 1) == 1) ? 1 : 0) + (((a & 2) == 2) ? 1 : 0) + (((a & 4) == 4) ? 1 : 0) + (((a & 8) == 8) ? 1 : 0);
			if (af > 0) af = (1 / af);
			concat([(((r & 1) == 1)) ? rf : 0, (((r & 2) == 2)) ? rf : 0,
				(((r & 4) == 4)) ? rf : 0, (((r & 8) == 8)) ? rf : 0, 0,
				(((g & 1) == 1)) ? gf : 0, (((g & 2) == 2)) ? gf : 0,
				(((g & 4) == 4)) ? gf : 0, (((g & 8) == 8)) ? gf : 0, 0,
				(((b & 1) == 1)) ? bf : 0, (((b & 2) == 2)) ? bf : 0,
				(((b & 4) == 4)) ? bf : 0, (((b & 8) == 8)) ? bf : 0, 0,
				(((a & 1) == 1)) ? af : 0, (((a & 2) == 2)) ? af : 0,
				(((a & 4) == 4)) ? af : 0, (((a & 8) == 8)) ? af : 0, 0]);
		}
		
		
		/**
		 * @param r
		 * @param g
		 * @param b
		 * @param a
		 */
		public function clearChannels(r:Boolean = false, g:Boolean = false, b:Boolean = false, a:Boolean = false):void
		{
			if (r) _matrix[0] = _matrix[1] = _matrix[2] = _matrix[3] = _matrix[4] = 0;
			if (g) _matrix[5] = _matrix[6] = _matrix[7] = _matrix[8] = _matrix[9] = 0;
			if (b) _matrix[10] = _matrix[11] = _matrix[12] = _matrix[13] = _matrix[14] = 0;
			if (a) _matrix[15] = _matrix[16] = _matrix[17] = _matrix[18] = _matrix[19] = 0;
		}
		
		
		/**
		 * @param matrix
		 * @param amount
		 */
		public function blend(mat:ColorMatrix, amount:Number):void
		{
			var invAmount:Number = (1 - amount);
			var i:int = 0;
			while (i < 20)
			{
				_matrix[i] = ((invAmount * _matrix[i]) + (amount * mat._matrix[i]));
				i++;
			}
		}
		
		
		/**
		 * @param matrix
		 * @param factor
		 */
		public function extrapolate(matrix:ColorMatrix, factor:Number):void
		{
			var i:int = 0;
			while (i < 20)
			{
				_matrix[i] += ( matrix._matrix[i] - _matrix[i]) * factor;
				i++;
			}
		}
		
		
		/**
		 * @param r
		 * @param g
		 * @param b
		 */
		public function average(r:Number = ONETHIRD, g:Number = ONETHIRD, b:Number = ONETHIRD):void
		{
			concat([r, g, b, 0, 0, r, g, b, 0, 0, r, g, b, 0, 0, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param threshold
		 * @param factor
		 */
		public function threshold(threshold:Number, factor:Number = 256):void
		{
			concat([(LUMA_R * factor), (LUMA_G * factor), (LUMA_B * factor), 0,
				(-(factor - 1) * threshold), (LUMA_R * factor), (LUMA_G * factor),
				(LUMA_B * factor), 0, (-(factor - 1) * threshold), (LUMA_R * factor),
				(LUMA_G * factor), (LUMA_B * factor), 0, (-(factor - 1) * threshold),
				0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param threshold
		 * @param factor
		 */
		public function thresholdRGB(threshold:Number, factor:Number = 256):void
		{
			concat([factor, 0, 0, 0, (-(factor - 1) * threshold), 0, factor, 0, 0,
				(-(factor - 1) * threshold), 0, 0, factor, 0, (-(factor - 1) * threshold),
				0, 0, 0, 1, 0]);
		}
		
		
		public function desaturate():void
		{
			concat([LUMA_R, LUMA_G, LUMA_B, 0, 0, LUMA_R, LUMA_G, LUMA_B, 0, 0, LUMA_R, LUMA_G,
				LUMA_B, 0, 0, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param amount
		 */
		public function randomize(amount:Number = 1):void
		{
			var invAmount:Number = (1 - amount);
			var r1:Number = (invAmount + (amount * (Math.random() - Math.random())));
			var g1:Number = (amount * (Math.random() - Math.random()));
			var b1:Number = (amount * (Math.random() - Math.random()));
			var o1:Number = ((amount * 0xFF) * (Math.random() - Math.random()));
			var r2:Number = (amount * (Math.random() - Math.random()));
			var g2:Number = (invAmount + (amount * (Math.random() - Math.random())));
			var b2:Number = (amount * (Math.random() - Math.random()));
			var o2:Number = ((amount * 0xFF) * (Math.random() - Math.random()));
			var r3:Number = (amount * (Math.random() - Math.random()));
			var g3:Number = (amount * (Math.random() - Math.random()));
			var b3:Number = (invAmount + (amount * (Math.random() - Math.random())));
			var o3:Number = ((amount * 0xFF) * (Math.random() - Math.random()));
			concat([r1, g1, b1, 0, o1, r2, g2, b2, 0, o2, r3, g3, b3, 0, o3, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param r
		 * @param g
		 * @param b
		 * @param a
		 */
		public function setMultiplicators(r:Number = 1, g:Number = 1, b:Number = 1, a:Number = 1):void
		{
			concat([r, 0, 0, 0, 0, 0, g, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, a, 0]);
		}
		
		
		/**
		 * @param threshold
		 * @param factor
		 */
		public function thresholdAlpha(threshold:Number, factor:Number = 256):void
		{
			concat([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, factor,
				(-factor * threshold)]);
		}
		
		
		public function averageRGBToAlpha():void
		{
			concat([0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, ONETHIRD, ONETHIRD,
				ONETHIRD, 0, 0]);
		}
		
		
		public function invertAlpha():void
		{
			concat([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, 255]);
		}
		
		
		/**
		 * @param r
		 * @param g
		 * @param b
		 */
		public function rgbToAlpha(r:Number, g:Number, b:Number):void
		{
			concat([0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, r, g, b, 0, 0]);
		}
		
		
		/**
		 * @param alpha
		 */
		public function setAlpha(alpha:Number):void
		{
			concat([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, alpha, 0]);
		}
		
		
		/**
		 * @param bitmapData
		 */
		public function applyFilterTo(bitmapData:BitmapData):void
		{
			if (!bitmapData) return;
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), filter);
		}
		
		
		public function normalize():void
		{
			for (var i:int = 0; i < 4; i++)
			{
				var sum:Number = 0;
				for (var j:int = 0; j < 4; j++)
				{
					sum += _matrix[i * 5 + j] * _matrix[i * 5 + j];
				}
				sum = 1 / Math.sqrt(sum);
				if (sum != 1)
				{
					for (j = 0; j < 4; j++)
					{
						_matrix[i * 5 + j] *= sum;
					}
				}
			}
		}
		
		
		public function fitRange():void
		{
			for (var i:int = 0; i < 4; i++)
			{
				var minFactor:Number = 0;
				var maxFactor:Number = 0;
				for (var j:int = 0; j < 4; j++)
				{
					if (_matrix[i * 5 + j] < 0) minFactor += _matrix[i * 5 + j];
					else maxFactor += _matrix[i * 5 + j];
				}
				var range:Number = maxFactor * 255 - minFactor * 255;
				var rangeCorrection:Number = 255 / range;
				if (rangeCorrection != 1)
				{
					for (j = 0; j < 4; j++)
					{
						_matrix[i * 5 + j] *= rangeCorrection;
					}
				}
				minFactor = 0;
				maxFactor = 0;
				for (j = 0; j < 4; j++)
				{
					if (_matrix[i * 5 + j] < 0) minFactor += _matrix[i * 5 + j];
					else maxFactor += _matrix[i * 5 + j];
				}
				var worstMin:Number = minFactor * 255;
				var worstMax:Number = maxFactor * 255;
				_matrix[i * 5 + 4] = -(worstMin + (worstMax - worstMin) * 0.5 - 127.5);
			}
		}
		
		
		/**
		 * @param type
		 * @see ColorDeficiencyType
		 */
		public function applyColorDeficiency(type:String):void
		{
			switch (type.toLowerCase())
			{
				case "protanopia":
					concat([0.567, 0.433, 0, 0, 0, 0.558, 0.442, 0, 0, 0, 0, 0.242, 0.758, 0, 0, 0, 0, 0, 1, 0]);
					break;
				case "protanomaly":
					concat([0.817, 0.183, 0, 0, 0, 0.333, 0.667, 0, 0, 0, 0, 0.125, 0.875, 0, 0, 0, 0, 0, 1, 0]);
					break;
				case "deuteranopia":
					concat([0.625, 0.375, 0, 0, 0, 0.7, 0.3, 0, 0, 0, 0, 0.3, 0.7, 0, 0, 0, 0, 0, 1, 0]);
					break;
				case "deuteranomaly":
					concat([0.8, 0.2, 0, 0, 0, 0.258, 0.742, 0, 0, 0, 0, 0.142, 0.858, 0, 0, 0, 0, 0, 1, 0]);
					break;
				case "tritanopia":
					concat([0.95, 0.05, 0, 0, 0, 0, 0.433, 0.567, 0, 0, 0, 0.475, 0.525, 0, 0, 0, 0, 0, 1, 0]);
					break;
				case "tritanomaly":
					concat([0.967, 0.033, 0, 0, 0, 0, 0.733, 0.267, 0, 0, 0, 0.183, 0.817, 0, 0, 0, 0, 0, 1, 0]);
					break;
				case "achromatopsia":
					concat([0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0, 0, 0, 1, 0]);
					break;
				case "achromatomaly":
					concat([0.618, 0.320, 0.062, 0, 0, 0.163, 0.775, 0.062, 0, 0, 0.163, 0.320, 0.516, 0, 0, 0, 0, 0, 1, 0]);
			}
		}
		
		
		public function RGB2YUV():void
		{
			concat([0.29900, 0.58700, 0.11400, 0, 0, -0.16874, -0.33126, 0.50000, 0, 128,
				0.50000, -0.41869, -0.08131, 0, 128, 0, 0, 0, 1, 0]);
		}
		
		
		public function YUV2RGB():void
		{
			concat([1, -0.000007154783816076815, 1.4019975662231445, 0, -179.45477266423404,
				1, -0.3441331386566162, -0.7141380310058594, 0, 135.45870971679688,
				1, 1.7720025777816772, 0.00001542569043522235,
				0, -226.8183044444304, 0, 0, 0, 1, 0]);
		}
		
		
		public function RGB2YIQ():void
		{
			concat([0.2990, 0.5870, 0.1140, 0, 0, 0.595716, -0.274453, -0.321263, 0, 128,
				0.211456, -0.522591, -0.311135, 0, 128, 0, 0, 0, 1, 0]);
		}
		
		
		/**
		 * @param bitmapData
		 * @param stretchLevels
		 * @param outputToBlueOnly
		 * @param tolerance
		 */
		public function autoDesaturate(bitmapData:BitmapData, stretchLevels:Boolean = false,
			outputToBlueOnly:Boolean = false, tolerance:Number = 0.01):void
		{
			var histogram:Vector.<Vector.<Number>> = bitmapData.histogram(bitmapData.rect);
			var sumR:Number = 0;
			var sumG:Number = 0;
			var sumB:Number = 0;
			var min:Number;
			var max:Number;
			var minFound:Boolean = false;
			var histR:Vector.<Number> = histogram[0];
			var histG:Vector.<Number> = histogram[1];
			var histB:Vector.<Number> = histogram[2];

			for (var i:int = 0; i < 256; i++)
			{
				sumR += histR[i] * i;
				sumG += histG[i] * i;
				sumB += histB[i] * i;
			}
			var total:Number = sumR + sumG + sumB;
			if (total == 0)
			{
				total = 3;
				sumR = sumG = sumB = 3;
			}
			sumR /= total;
			sumG /= total;
			sumB /= total;
			var offset:Number = 0;
			if (stretchLevels)
			{
				var minPixels:Number = bitmapData.rect.width * bitmapData.rect.height * tolerance;
				var sr:Number = 0;
				var sg:Number = 0;
				var sb:Number = 0;
				for (i = 0; i < 256; i++)
				{
					sr += histR[i];
					sg += histG[i];
					sb += histB[i];
					if (sr > minPixels || sg > minPixels || sb > minPixels)
					{
						min = i;
						break;
					}
				}
				sr = 0;
				sg = 0;
				sb = 0;
				for (i = 256; --i > -1;)
				{
					sr += histR[i];
					sg += histG[i];
					sb += histB[i];
					if (sr > minPixels || sg > minPixels || sb > minPixels)
					{
						max = i;
						break;
					}
				}
				if (max - min < 255)
				{
					var f:Number = 256 / ((max - min) + 1);
					sumR *= f;
					sumG *= f;
					sumB *= f;
					offset = -min;
				}
			}
			f = 1 / Math.sqrt(sumR * sumR + sumG * sumG + sumB * sumB);
			sumR *= f;
			sumG *= f;
			sumB *= f;
			if (!outputToBlueOnly)
			{
				concat([sumR, sumG, sumB, 0, offset, sumR, sumG, sumB, 0, offset, sumR,
					sumG, sumB, 0, offset, 0, 0, 0, 1, 0]);
			}
			else
			{
				concat([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, sumR, sumG, sumB, 0, offset, 0, 0, 0, 1, 0]);
			}
		}
		
		
		/**
		 * @return true or false.
		 */
		public function invertMatrix():Boolean
		{
			var coeffs:Matrix3D = new Matrix3D(Vector.<Number>([_matrix[0], _matrix[1], _matrix[2],
				_matrix[3], _matrix[5], _matrix[6], _matrix[7], _matrix[8], _matrix[10], _matrix[11],
				_matrix[12], _matrix[13], _matrix[15], _matrix[16], _matrix[17], _matrix[18]]));
			var check:Boolean = coeffs.invert();
			if (!check) return false;
			
			_matrix[0] = coeffs.rawData[0];
			_matrix[1] = coeffs.rawData[1];
			_matrix[2] = coeffs.rawData[2];
			_matrix[3] = coeffs.rawData[3];
			var tmp1:Number = -(coeffs.rawData[0] * _matrix[4] + coeffs.rawData[1] * _matrix[9] + coeffs.rawData[2] * _matrix[14] + coeffs.rawData[3] * _matrix[15]);
			_matrix[5] = coeffs.rawData[4];
			_matrix[6] = coeffs.rawData[5];
			_matrix[7] = coeffs.rawData[6];
			_matrix[8] = coeffs.rawData[7];
			var tmp2:Number = -(coeffs.rawData[4] * _matrix[4] + coeffs.rawData[5] * _matrix[9] + coeffs.rawData[6] * _matrix[14] + coeffs.rawData[7] * _matrix[15]);
			_matrix[10] = coeffs.rawData[8];
			_matrix[11] = coeffs.rawData[9];
			_matrix[12] = coeffs.rawData[10];
			_matrix[13] = coeffs.rawData[11];
			var tmp3:Number = -(coeffs.rawData[8] * _matrix[4] + coeffs.rawData[9] * _matrix[9] + coeffs.rawData[10] * _matrix[14] + coeffs.rawData[11] * _matrix[15]);
			_matrix[15] = coeffs.rawData[12];
			_matrix[16] = coeffs.rawData[13];
			_matrix[17] = coeffs.rawData[14];
			_matrix[18] = coeffs.rawData[15];
			var tmp4:Number = -(coeffs.rawData[12] * _matrix[4] + coeffs.rawData[13] * _matrix[9] + coeffs.rawData[14] * _matrix[14] + coeffs.rawData[15] * _matrix[15]);
			_matrix[4] = tmp1;
			_matrix[9] = tmp2;
			_matrix[14] = tmp3;
			_matrix[19] = tmp4;
			return true;
		}
		
		
		/**
		 * @param rgba
		 */
		public function applyMatrix(rgba:uint):uint
		{
			var a:Number = (rgba >>> 24) & 0xff;
			var r:Number = (rgba >>> 16) & 0xff;
			var g:Number = (rgba >>> 8) & 0xff;
			var b:Number = rgba & 0xff;
			var r2:int = 0.5 + r * _matrix[0] + g * _matrix[1] + b * _matrix[2] + a * _matrix[3] + _matrix[4];
			var g2:int = 0.5 + r * _matrix[5] + g * _matrix[6] + b * _matrix[7] + a * _matrix[8] + _matrix[9];
			var b2:int = 0.5 + r * _matrix[10] + g * _matrix[11] + b * _matrix[12] + a * _matrix[13] + _matrix[14];
			var a2:int = 0.5 + r * _matrix[15] + g * _matrix[16] + b * _matrix[17] + a * _matrix[18] + _matrix[19];
			if (a2 < 0) a2 = 0;
			if (a2 > 255) a2 = 255;
			if (r2 < 0) r2 = 0;
			if (r2 > 255) r2 = 255;
			if (g2 < 0) g2 = 0;
			if (g2 > 255) g2 = 255;
			if (b2 < 0) b2 = 0;
			if (b2 > 255) b2 = 255;
			return a2 << 24 | r2 << 16 | g2 << 8 | b2;
		}
		
		
		/**
		 * @param degrees
		 */
		public function rotateRed(degrees:Number):void
		{
			rotateColor(degrees, 2, 1);
		}
		
		
		/**
		 * @param degrees
		 */
		public function rotateGreen(degrees:Number):void
		{
			rotateColor(degrees, 0, 2);
		}
		
		
		/**
		 * @param degrees
		 */
		public function rotateBlue(degrees:Number):void
		{
			rotateColor(degrees, 1, 0);
		}
		
		
		/**
		 * @param green
		 * @param blue
		 */
		public function shearRed(green:Number, blue:Number):void
		{
			shearColor(0, 1, green, 2, blue);
		}
		
		
		/**
		 * @param red
		 * @param blue
		 */
		public function shearGreen(red:Number, blue:Number):void
		{
			shearColor(1, 0, red, 2, blue);
		}
		
		
		/**
		 * @param red
		 * @param green
		 */
		public function shearBlue(red:Number, green:Number):void
		{
			shearColor(2, 0, red, 1, green);
		}
		
		
		/**
		 * @param values
		 */
		public function transformVector(values:Array):void
		{
			if ( values.length != 4) return;
			var r:Number = values[0] * _matrix[0] + values[1] * _matrix[1] + values[2] * _matrix[2] + values[3] * _matrix[3] + _matrix[4];
			var g:Number = values[0] * _matrix[5] + values[1] * _matrix[6] + values[2] * _matrix[7] + values[3] * _matrix[8] + _matrix[9];
			var b:Number = values[0] * _matrix[10] + values[1] * _matrix[11] + values[2] * _matrix[12] + values[3] * _matrix[13] + _matrix[14];
			var a:Number = values[0] * _matrix[15] + values[1] * _matrix[16] + values[2] * _matrix[17] + values[3] * _matrix[18] + _matrix[19];
			values[0] = r;
			values[1] = g;
			values[2] = b;
			values[3] = a;
		}
		
		
		public function toString():String
		{
			return _matrix.toString();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get filter():ColorMatrixFilter
		{
			return new ColorMatrixFilter(_matrix);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param m matrix
		 */
		private function concat(m:Array):void
		{
			var t:Array = [];
			var i:int = 0;
			var x:int = 0;
			var y:int = 0;
			for (y = 0; y < 4; y++)
			{
				for (x = 0; x < 5; x++)
				{
					t[int(i + x)] = m[i] * _matrix[x] + m[int(i + 1)] * _matrix[int(x + 5)]
						+ m[int(i + 2)] * _matrix[int(x + 10)] + m[int(i + 3)]
						* _matrix[int(x + 15)] + (x == 4 ? m[int(i + 4)] : 0);
				}
				i += 5;
			}
			_matrix = t;
		}
		
		
		/**
		 * @param degrees
		 * @param x
		 * @param y
		 */
		private function rotateColor(degrees:Number, x:int, y:int):void
		{
			degrees *= RAD;
			var m:Array = IDENTITY.concat();
			m[x + x * 5] = m[y + y * 5] = Math.cos(degrees);
			m[y + x * 5] = Math.sin(degrees);
			m[x + y * 5] = -Math.sin(degrees);
			concat(m);
		}
		
		
		/**
		 * @param x
		 * @param y1
		 * @param d1
		 * @param y2
		 * @param d2
		 */
		private function shearColor(x:int, y1:int, d1:Number, y2:int, d2:Number):void
		{
			var m:Array = IDENTITY.concat();
			m[y1 + x * 5] = d1;
			m[y2 + x * 5] = d2;
			concat(m);
		}
		
		
		private function initHue():void
		{
			var greenRotation:Number = 39.182655;
			if (!_hueInitialized)
			{
				_hueInitialized = true;
				_preHue = new ColorMatrix();
				_preHue.rotateRed(45);
				_preHue.rotateGreen(- greenRotation);
				var lum:Array = [LUMA_R2, LUMA_G2, LUMA_B2, 1.0];
				_preHue.transformVector(lum);
				var red:Number = lum[0] / lum[2];
				var green:Number = lum[1] / lum[2];
				_preHue.shearBlue(red, green);
				_postHue = new ColorMatrix();
				_postHue.shearBlue(-red, -green);
				_postHue.rotateGreen(greenRotation);
				_postHue.rotateRed(- 45.0);
			}
		}
	}
}
