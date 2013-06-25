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
package tetragon.core.display.bitmap
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class BGScroller extends Bitmap
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _timer:Timer;
		protected var _shape:Shape;
		protected var _layers:Vector.<BGScrollLayer>;
		protected var _layerCount:uint;
		protected var _fillColor:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function BGScroller(width:int, height:int, transparent:Boolean = false,
			fillColor:uint = 0x000000, fps:Number = 30, layers:Array = null)
		{
			super(new BitmapData(width, height, transparent, _fillColor = fillColor));
			pixelSnapping = PixelSnapping.NEVER;
			smoothing = false;
			
			_shape = new Shape();
			_timer = new Timer(500, 0);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			this.layers = layers;
			this.fps = fps;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function start():void
		{
			if (!_layers) return;
			_timer.start();
		}
		
		
		public function stop():void
		{
			_timer.stop();
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "BGScroller";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get fps():Number
		{
			return 1000 / _timer.delay;
		}
		public function set fps(v:Number):void
		{
			var ms:Number = 1000 / v;
			if (ms < 16.6) ms = 16.6;
			_timer.delay = ms;
		}
		
		
		public function get layers():Array
		{
			if (!_layers) return null;
			var a:Array = [];
			for (var i:uint = 0; i < _layers.length; i++)
			{
				a.push(_layers[i]);
			}
			return a;
		}
		public function set layers(v:Array):void
		{
			if (!v)
			{
				_layers = null;
			}
			else
			{
				_layers = new Vector.<BGScrollLayer>(v.length, true);
				for (var i:uint = 0; i < _layers.length; i++)
				{
					_layers[i] = v[i];
				}
			}
			_layerCount = !_layers ? 0 : _layers.length;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		protected function onTimer(e:TimerEvent):void
		{
			_shape.graphics.clear();
			
			for (var i:uint = 0; i < _layerCount; i++)
			{
				var layer:BGScrollLayer = _layers[i];
				layer.tick();
				_shape.graphics.beginBitmapFill(layer.bitmapData, layer.matrix, true, false);
				if (!layer.repeatFill) _shape.graphics.drawRect(layer.x, layer.y, layer.bitmapData.width, layer.bitmapData.height);
				else _shape.graphics.drawRect(0, 0, width, height);
				_shape.graphics.endFill();
			}
			
			bitmapData.fillRect(bitmapData.rect, _fillColor);
			bitmapData.draw(_shape);
			
			e.updateAfterEvent();
		}
	}
}
