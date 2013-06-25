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
package tetragon.core.display.text
{
	import tetragon.core.types.Gradient;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	
	/**
	 * GradientTextArea class
	 */
	public class GradientTextArea extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _gradient:Gradient;
		/** @private */
		protected var _gradientAffordance:int = -1;
		/** @private */
		protected var _shape:Shape;
		/** @private */
		protected var _textfields:Vector.<TextField>;
		/** @private */
		protected var _textfieldsWrapper:Sprite;
		/** @private */
		protected var _text:String;
		/** @private */
		protected var _lines:Array;
		/** @private */
		protected var _numLines:uint;
		/** @private */
		protected var _defaultTextFormat:TextFormat;
		/** @private */
		protected var _flatten:Boolean;
		/** @private */
		protected var _scroll:Boolean;
		/** @private */
		protected var _debug:Boolean;
		
		/** @private */
		protected var _scrollFPS:int = 30;
		/** @private */
		protected var _scrollRect:Rectangle;
		/** @private */
		protected var _scrollHeight:int;
		/** @private */
		protected var _timer:Timer;
		
		/** @private */
		protected static var _defaultGradient:Gradient;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param textFormat
		 * @param text
		 * @param gradient
		 * @param gradientAffordance
		 */
		public function GradientTextArea(textFormat:TextFormat = null, text:String = null,
			gradient:Gradient = null, gradientAffordance:int = -1)
		{
			setup();
			
			this.gradient = gradient;
			this.gradientAffordance = gradientAffordance;
			this.defaultTextFormat = textFormat;
			this.text = text;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			if (!_timer) return;
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
		}
		
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get text():String
		{
			return _text;
		}
		public function set text(v:String):void
		{
			if (v == _text) return;
			_text = v || "";
			_lines = _text.split("\n");
			_numLines = _lines.length;
			createLines();
			draw();
		}
		
		
		public function get defaultTextFormat():TextFormat
		{
			return _defaultTextFormat;
		}
		public function set defaultTextFormat(v:TextFormat):void
		{
			if (!v || v == _defaultTextFormat) return;
			_defaultTextFormat = v;
			draw();
		}
		
		
		public function get length():int
		{
			if (!_text) return 0;
			return _text.length;
		}
		
		
		public function get flatten():Boolean
		{
			return _flatten;
		}
		public function set flatten(v:Boolean):void
		{
			if (v == _flatten) return;
			_flatten = v;
			_shape.cacheAsBitmap = _flatten;
			_textfieldsWrapper.cacheAsBitmap = _flatten;
		}
		
		
		public function get scroll():Boolean
		{
			return _scroll;
		}
		public function set scroll(v:Boolean):void
		{
			if (v == _scroll) return;
			_scroll = v;
			draw();
		}
		
		
		public function get scrollFPS():int
		{
			return _scrollFPS;
		}
		public function set scrollFPS(v:int):void
		{
			_scrollFPS = v < 5 ? 5 : v > 60 ? 60 : v;
			if (_timer) _timer.delay = 1000 / _scrollFPS;
		}
		
		
		override public function set width(v:Number):void
		{
			/* Not allowed to set width! */
		}
		
		
		override public function set height(v:Number):void
		{
			/* Not allowed to set height! */
		}
		
		
		public function get debug():Boolean
		{
			return _debug;
		}
		public function set debug(v:Boolean):void
		{
			if (v == _debug) return;
			_debug = v;
			draw();
		}
		
		
		public function get gradient():Gradient
		{
			return _gradient;
		}
		public function set gradient(v:Gradient):void
		{
			if (!v)
			{
				if (!_defaultGradient)
				{
					_defaultGradient = new Gradient([0x0066FD,0xFFFFFF, 0x996600, 0xFFCC00, 0xFFFFFF]);
				}
				v = _defaultGradient;
			}
			if (v == _gradient) return;
			_gradient = v;
			draw(true);
		}
		
		
		/**
		 * @default -1
		 */
		public function get gradientAffordance():int
		{
			return _gradientAffordance;
		}
		public function set gradientAffordance(v:int):void
		{
			if (v == _gradientAffordance) return;
			_gradientAffordance = v;
			draw(true);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onTimer(e:TimerEvent):void
		{
			if (_scrollRect.y == _scrollHeight)
			{
				_scrollRect.y = 0;
			}
			
			_shape.scrollRect = _scrollRect;
			_scrollRect.y += 1;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function setup():void
		{
			_textfieldsWrapper = new Sprite();
			_shape = new Shape();
			
			addChild(_shape);
			addChild(_textfieldsWrapper);
		}
		
		
		/**
		 * @private
		 */
		protected function createLines():void
		{
			_textfields = new Vector.<TextField>(_numLines, false);
			
			for (var i:uint = 0; i < _numLines; i++)
			{
				var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.embedFonts = true;
				tf.mouseEnabled = false;
				tf.multiline = false;
				tf.selectable = false;
				tf.antiAliasType = AntiAliasType.ADVANCED;
				tf.gridFitType = GridFitType.PIXEL;
				tf.type = TextFieldType.DYNAMIC;
				tf.borderColor = 0xFF00FF;
				tf.textColor = 0xFF00FF;
				tf.border = false;
				_textfields[i] = tf;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function draw(force:Boolean = false):void
		{
			if (!_textfields || !_defaultTextFormat) return;
			
			if (_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTimer);
				_timer = null;
				_scrollRect = null;
				_shape.scrollRect = null;
				_scrollHeight = 0;
			}
			
			/* remove old text fields. */
			if (_textfieldsWrapper.numChildren > 0)
			{
				while (_textfieldsWrapper.numChildren > 0) _textfieldsWrapper.removeChildAt(0);
			}
			
			var tf:TextField;
			var leading:int = int(_defaultTextFormat.leading);
			var align:String = _defaultTextFormat.align;
			var yp:int = 0;
			
			/* Draw text fields. */
			for (var i:uint = 0; i < _numLines; i++)
			{
				tf = _textfields[i];
				tf.defaultTextFormat = _defaultTextFormat;
				tf.text = _lines[i];
				tf.x = 0;
				tf.y = yp;
				_textfieldsWrapper.addChild(tf);
				yp += tf.height + leading;
			}
			
			if (align == TextFormatAlign.CENTER)
			{
				for each (tf in _textfields)
				{
					tf.x = int((_textfieldsWrapper.width - tf.width) * 0.5);
				}
			}
			else if (align == TextFormatAlign.RIGHT)
			{
				for each (tf in _textfields)
				{
					tf.x = int(_textfieldsWrapper.width - tf.width);
				}
			}
			
			var lineHeight:Number = tf.height + leading;
			var numLines:int = _scroll ? _numLines * 2 : _numLines;
			
			/* Draw gradient shape. */
			drawMultiGradient(_shape, _textfieldsWrapper.width, _gradient, numLines, leading, tf.height, lineHeight);
			_shape.height = Math.ceil(_shape.height);
			
			/* Draw debug graphics. */
			if (_debug)
			{
				_textfieldsWrapper.graphics.clear();
				for each (tf in _textfields)
				{
					_textfieldsWrapper.graphics.lineStyle(1, 0xFF0000, 1.0, true);
					_textfieldsWrapper.graphics.drawRect(tf.x, tf.y - leading, tf.width, lineHeight);
				}
				_shape.mask = null;
			}
			else
			{
				_shape.mask = _textfieldsWrapper;
			}
			
			/* Handle scrolling. */
			if (_scroll && !_timer)
			{
				if (!_flatten) flatten = true;
				_scrollHeight = Math.ceil(_shape.height * 0.5);
				_scrollRect = new Rectangle(0, 0, _shape.width, Math.ceil(_textfieldsWrapper.height));
				_timer = new Timer(1000 / _scrollFPS);
				_timer.addEventListener(TimerEvent.TIMER, onTimer);
				_timer.start();
			}
		}
		
		
		/**
		 * @private
		 */
		protected static function drawMultiGradient(s:Shape, w:int, g:Gradient, numLines:int,
			leading:int, tfHeight:Number, lineHeight:Number):void
		{
			s.graphics.clear();
			s.graphics.lineStyle();
			
			var y:int = 0;
			for (var i:uint = 0; i < numLines; i++)
			{
				var m:Matrix = new Matrix();
				m.createGradientBox(w, lineHeight, (g.rotation * Math.PI / 180), 0, y - leading);
				s.graphics.beginGradientFill(g.type, g.colors, g.alphas, g.ratios, m,
					g.spreadMethod, g.interpolationMethod, g.focalPointRatio);
				s.graphics.drawRect(0, y - leading, w, lineHeight);
				s.graphics.endFill();
				y += tfHeight + leading;
			}
		}
	}
}
