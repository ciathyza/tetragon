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
package tetragon.view.effect
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * VCREffect class
	 * 
	 * TODO This effect is only here on probation! Ultimately effects classes need to be
	 * more optimally integrated into the engine!
	 */
	public class VCREffect extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
        private const BMD_WIDTH:int = 240;
		/** @private */
        private const BMD_HEIGHT:int = 240;
		
		/** @private */
        private var _distortion:Number = 0.0003;
		/** @private */
        private var _noise:Number = 40;
		/** @private */
        private var _baseColor:uint = 0xFFFFFF;
		
		/** @private */
        private var _source:DisplayObject;
		/** @private */
        private var _bmp:Bitmap;
		/** @private */
        private var _baseBmd:BitmapData;
		/** @private */
        private var _editBmd:BitmapData;
		/** @private */
        private var _noiseBmd:BitmapData;
		/** @private */
        private var _sandstormBmd:BitmapData;
		/** @private */
        private var _baseMatrix:Matrix;
		
		/** @private */
        private var _pointArray:Vector.<Point>;
		/** @private */
        private var _randArray1:Vector.<Number>;
		/** @private */
        private var _randArray2:Vector.<Number>;
		
		/** @private */
		private var _point:Point;
		/** @private */
		private var _rect:Rectangle;
		
		/** @private */
        private var _randNum1:Number;
		/** @private */
        private var _bmdUpNum:Number;
		/** @private */
        private var _keyCnt:Number = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function VCREffect(source:DisplayObject = null)
		{
			setup();
			this.source = source;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get source():DisplayObject
		{
			return _source;
		}
		public function set source(v:DisplayObject):void
		{
			if (!v || v == _source) return;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_source = v;
			//_source.visible = false;
            _baseMatrix.identity();
            _baseMatrix.scale(BMD_WIDTH / _source.width, BMD_HEIGHT / _source.height);
            _bmp.scaleX = _source.width / BMD_WIDTH;
            _bmp.scaleY = _source.height / BMD_HEIGHT;
            _bmp.x = _bmp.y = 0;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		public function get distortion():Number
		{
			return _distortion;
		}
		public function set distortion(v:Number):void
		{
			_distortion = v;
		}
		
		
		public function get noise():Number
		{
			return _noise;
		}
		public function set noise(v:Number):void
		{
			_noise = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onEnterFrame(e:Event):void
		{
			var y:int = 0;
			var x:Number;
			var t:Number;
			
			var bd:BitmapData = _baseBmd.clone();
			bd.draw(_source, _baseMatrix);
			_editBmd = bd.clone();
			
			while (y < 3)
			{
				if (_randArray1[y] >= 1)
				{
					_randArray1[y] = _randArray1[y] - 1;
					_randArray2[y] = (Math.random() / 40) + _distortion;
				}
				
				_randArray1[y] = _randArray1[y] + _randArray2[y];
				_keyCnt = _keyCnt + ((48 - _keyCnt) / 4);
				_pointArray[y].x = Math.ceil(((Math.sin(((_randArray1[y] * Math.PI) * 2)) * _randArray2[y]) * _keyCnt) * 2);
				_pointArray[y].y = 0;
				y++;
			}
			
			t = (1 * ((Math.abs(_pointArray[0].x) + Math.abs(_pointArray[1].x)) + Math.abs(_pointArray[2].x)) + 8) / 4;
			y = BMD_HEIGHT;
			
			while (y--)
			{
				x = ((Math.sin((((((y / BMD_HEIGHT) * ((Math.random() / 8) + 1)) * _randNum1) * Math.PI) * 2)) * 0.8) * t) * t;
				_rect.x = x;
				_rect.y = _point.y = y;
				_rect.width = BMD_WIDTH - x;
				_editBmd.copyPixels(bd, _rect, _point);
			}
			
			_sandstormBmd.noise(int((Math.random() * 1000)), 0, 0xFF, 7, false);
			_point.y = 0;
			_editBmd.merge(_sandstormBmd, _editBmd.rect, _point, _noise, _noise, _noise, 0);
			_noiseBmd.copyChannel(_editBmd, _noiseBmd.rect, _pointArray[0], BitmapDataChannel.RED, BitmapDataChannel.RED);
			_noiseBmd.copyChannel(_editBmd, _noiseBmd.rect, _pointArray[1], BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			_noiseBmd.copyChannel(_editBmd, _noiseBmd.rect, _pointArray[2], BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function setup():void
		{
			_baseBmd = new BitmapData(BMD_WIDTH, BMD_HEIGHT, false, _baseColor);
			_editBmd = _baseBmd.clone();
			_noiseBmd = _baseBmd.clone();
			_sandstormBmd = _baseBmd.clone();
			
			_baseMatrix = new Matrix();
			_baseMatrix.scale(2, 2);
			_baseMatrix.tx = 10;
			_baseMatrix.ty = 100;
			
			_pointArray = new Vector.<Point>(3, true);
			_pointArray[0] = new Point(0, 0);
			_pointArray[1] = new Point(0, 0);
			_pointArray[2] = new Point(0, 0);
			
			_randArray1 = new Vector.<Number>(3, true);
			_randArray1[0] = Math.random() + 1;
			_randArray1[1] = Math.random() + 1;
			_randArray1[2] = Math.random() + 1;
			
			_randArray2 = new Vector.<Number>(3, true);
			_randArray2[0] = 0;
			_randArray2[1] = 0;
			_randArray2[2] = 0;
			
			_point = new Point(0, 0);
			_rect = new Rectangle(0, 0, 0, 1);
			
			_randNum1 = 0.5;
			_bmdUpNum = 0;
			
			_bmp = new Bitmap();
			_bmp.bitmapData = _noiseBmd;
			_bmp.smoothing = true;
			_bmp.visible = false;
			_bmp.visible = true;
			
			addChild(_bmp);
		}
	}
}
