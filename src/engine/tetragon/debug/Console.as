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
package tetragon.debug
{
	import tetragon.Main;
	import tetragon.core.display.shape.RectangleShape;
	import tetragon.core.signals.Signal;
	import tetragon.core.tween.Tween;
	import tetragon.core.tween.TweenVars;
	import tetragon.core.tween.easing.Cubic;
	import tetragon.data.Config;
	import tetragon.debug.cli.CLI;
	import tetragon.input.KeyInputManager;

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	
	/**
	 * A class that represents a Debugging and Command output console similar
	 * to that found in many later games. By default the console - once instantiated and
	 * added to the stage - is hidden and can be toggled visible with the toggle() method.
	 */
	public final class Console extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const LINED:String		= "\u2310";
		public static const UL:String			= "\u02CD";
		public static const INV_START:String	= "\u2320";
		public static const INV_END:String		= "\u2321";
		
		/** @private */
		private const FONT:String				= "Terminalscope";
		/** @private */
		private const FONT_INV:String			= "Terminalscope Inverse";
		/** @private */
		private const FONT_SIZE:int				= 16;
		/** @private */
		private const LEADING:int				= 0;
		/** @private */
		private const PADDING:int				= 4;
		
		/** @private */
		private const PROMPT:String				= "&gt; ";
		/** @private */
		private const LABEL_NOTICE:String		= "[NOTICE] ";
		/** @private */
		private const LABEL_WARN:String			= "[WARNING] ";
		/** @private */
		private const LABEL_ERROR:String		= "[ERROR] ";
		/** @private */
		private const LABEL_FATAL:String		= "[FATAL] ";
		/** @private */
		private const LABEL_SYSTEM:String		= "[SYSTEM] ";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _config:Config;
		/** @private */
		private var _container:DisplayObjectContainer;
		/** @private */
		private var _stage:Stage;
		/** @private */
		private var _keyInputManager:KeyInputManager;
		/** @private */
		private var _bg:RectangleShape;
		/** @private */
		private var _ta:ConsoleTextArea;
		/** @private */
		private var _ti:ConsoleTextInput;
		/** @private */
		private var _cli:CLI;
		/** @private */
		private var _backBuffer:BackBuffer;
		/** @private */
		private var _tweenVars:TweenVars;
		
		/** @private */
		private var _bgColor:uint;
		/** @private */
		private var _size:int = 2;
		/** @private */
		private var _heightDivider:int = 2;
		/** @private */
		private var _maxBufferSize:int = 40000;
		/** @private */
		private var _maxLevel:int = LogLevel.FATAL;
		
		private var _consoleAutoOpenLevel:int;
		
		/** @private */
		private var _useTween:Boolean = true;
		/** @private */
		private var _monochrome:Boolean;
		/** @private */
		private var _consoleEnabled:Boolean = true;
		/** @private */
		private var _allowInput:Boolean;
		/** @private */
		private var _visible:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _logSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Console(container:DisplayObjectContainer)
		{
			super();
			
			_main = Main.instance;
			_container = container;
			_config = _main.registry.config;
			_stage = _main.stage;
			_keyInputManager = _main.keyInputManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function init():void
		{
			_monochrome = _config.getBoolean(Config.CONSOLE_MONOCHROME);
			_useTween = _config.getBoolean(Config.CONSOLE_TWEEN);
			
			createChildren();
			addEventListeners();
			update();
			
			consoleEnabled = _config.getBoolean(Config.CONSOLE_ENABLED);
			size = _config.getNumber(Config.CONSOLE_SIZE);
			transparency = _config.getNumber(Config.CONSOLE_TRANSPARENCY);
			maxBufferSize = _config.getNumber(Config.CONSOLE_MAX_BUFFERSIZE);
			_consoleAutoOpenLevel = _config.getNumber(Config.CONSOLE_AUTO_OPEN_LEVEL);
			if (_consoleAutoOpenLevel < 0) _consoleAutoOpenLevel = 9999;
			
			_main.keyInputManager.assignEngineKey("toggleConsole", toggle);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function update():void
		{
			if (!_ta || !_ti) return;
			
			if (_heightDivider == 4)
			{
				_bg.setProperties(_stage.stageWidth, _ti.height, _bgColor);
				_bg.draw();
				_ta.visible = false;
			}
			else
			{
				_bg.setProperties(_stage.stageWidth, _stage.stageHeight / _heightDivider, _bgColor);
				_bg.draw();
				_ta.visible = true;
			}
			
			_ti.resize(_bg.width);
			_ti.x = 0;
			_ti.y = _bg.height - _ti.height;
			
			_ta.resize(_bg.width - (PADDING * 2), _bg.height - _ti.height - (PADDING * 3));
			_ta.x = PADDING;
			_ta.y = PADDING;
			
			y = _visible ? 0 : 0 - height;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return "[Console]";
		}
		
		
		/**
		 * Outputs the console welcome message.
		 */
		public function welcome():void
		{
			log("Welcome to the backdoor! Today is " + new Date().toString(), LogLevel.INFO);
			log("Type 'help' for a console help summary.", LogLevel.INFO, true);
			log("Type 'commands' for a list of all available commands.", LogLevel.INFO, true);
		}
		
		
		/**
		 * Adds a new log message to the console output area.
		 * 
		 * @param text the message to output.
		 * @param level the output level (0-6).
		 * @param inverse If true logged text color will be inverse.
		 */
		public function log(text:String, level:int = 2, inverse:Boolean = false):void
		{
			if (!_consoleEnabled) return;
			
			if (!_visible && (level >= _consoleAutoOpenLevel && level < 999))
			{
				toggle();
			}
			
			if (_ta.length >= _maxBufferSize) _ta.clear();
			if (_monochrome) level = 2;
			else if (level < 0) level = 0;
			else if (level > _maxLevel) level = _maxLevel;
			
			/* Add label to text. */
			switch (level)
			{
				case 3: text = LABEL_NOTICE + text; break;
				case 4: text = LABEL_WARN + text; break;
				case 5: text = LABEL_ERROR + text; break;
				case 6: text = LABEL_FATAL + text; break;
				case 999: text = LABEL_SYSTEM + text;
			}
			
			if (inverse) text = INV_START + text + INV_END;
			
			/* Convert HTML Tags. */
			text = text.replace(/&amp;/gi, "&amp;amp;")
				.replace(/&quot;/gi, "&amp;quot;")
				.replace(/&lt;/gi, "&amp;lt;")
				.replace(/&gt;/gi, "&amp;gt;")
				.replace(/</gi, "&lt;")
				.replace(/\u003E/gi, "&gt;");
			
			/* Check if text should be wrapped by delimiter lines. */
			if (text.substr(0, 1) == LINED && text.substr(-1, 1) == LINED)
			{
				var line:String = Console.makeLine(text.length - 2);
				text = line + "\n  " + text.substring(1, text.length - 1) + "\n  " + line;
			}
			
			/* Replace special tags. */
			text = text.replace(/\u2320([^\u2320^\u2321]+)\u2321/g, "<a>$1</a>").replace(/\u02CD([^\u02CD]+)\u02CD/g, "<u>$1</u>");
			
			/* Wrap text with color tags. */
			text = "<n" + level + ">" + PROMPT + text + "</n" + level + ">";
			
			_ta.text += text;
			_ta.updateScrolling();
			
			if (_logSignal) _logSignal.dispatch("> " + text);
		}
		
		
		/**
		 * Sends a system message to the console output.
		 */
		public function systemMessage(text:String):void
		{
			_maxLevel = LogLevel.SYSTEM;
			log(text, LogLevel.SYSTEM);
			_maxLevel = LogLevel.FATAL;
		}
		
		
		/**
		 * linefeed
		 */
		public function linefeed():void
		{
			log("", LogLevel.INFO);
		}
		
		
		/**
		 * Outputs a delimiter line.
		 */
		public function delimiter(length:int = 20, level:int = 2):void
		{
			log(Console.makeLine(length), level);
		}
		
		
		/**
		 * Clears the console.
		 */
		public function clear():void
		{
			clearInput();
			_ta.clear();
		}
		
		
		/**
		 * Clears the Text Input Line of the Console.
		 */
		public function clearInput():void
		{
			_ti.clear();
		}
		
		
		/**
		 * Toggles the console visibility.
		 */
		public function toggle():void
		{
			/* Only make visible if the console isn't disabled */
			if (_consoleEnabled && !_visible)
			{
				_container.visible = true;
				_container.addChild(this);
				
				/* If the FPSMonitor is also visible it should always be in the front! */
				if (_container.numChildren > 1) _container.swapChildrenAt(0, 1);
				
				if (_useTween)
				{
					_tweenVars.setProperty("y", 0);
					Tween.to(this, 0.2, _tweenVars);
				}
				else
				{
					y = 0;
					onTweenComplete();
				}
			}
			else
			{
				if (_useTween)
				{
					_tweenVars.setProperty("y", 0 - height);
					Tween.to(this, 0.2, _tweenVars);
				}
				else
				{
					onTweenComplete();
				}
			}
		}
		
		
		/**
		 * Toggles the console height.
		 */
		public function toggleSize():void
		{
			if (_heightDivider == 4) _heightDivider = 3;
			else if (_heightDivider == 3) _heightDivider = 2;
			else if (_heightDivider == 2) _heightDivider = 1;
			else _heightDivider = 4;
			
			update();
		}
		
		
		/**
		 * Generates a string line.
		 */
		public static function makeLine(length:int):String
		{
			length = (length < 1) ? 1 : (length > 1024) ? 1024 : length;
			var s:String = "";
			var i:int = 0;
			while (i++ < length) s += "-";
			return s;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the command line interpreter that is used by the console to
		 * execute commands.
		 */
		public function get cli():CLI
		{
			return _cli;
		}
		
		
		/**
		 * Allows for setting the console size (height) directly by specifying a number
		 * where 0 is smallest and 3 is largest.
		 */
		public function get size():int
		{
			return _size;
		}
		public function set size(v:int):void
		{
			_size = (v < 0) ? 0 : (v > 3) ? 3 : v;
			if (_size == 0) _heightDivider = 4;
			else if (v == 1) _heightDivider = 3;
			else if (v == 2) _heightDivider = 2;
			else if (v == 3) _heightDivider = 1;
			update();
		}
		
		
		/**
		 * Determines if the console is completely disabled or not. If this
		 * is set to false, console input and logging is disabled and the
		 * console cannot be made visible.
		 */
		public function get consoleEnabled():Boolean
		{
			return _consoleEnabled;
		}
		public function set consoleEnabled(v:Boolean):void
		{
			_consoleEnabled = v;
			if (!v) clear();
		}
		
		
		/**
		 * The max. text buffer size used for the console. If this value is
		 * exceeded the console will clear it's buffer to prevent lag.
		 */
		public function get maxBufferSize():int
		{
			return _maxBufferSize;
		}
		public function set maxBufferSize(v:int):void
		{
			_maxBufferSize = v;
		}
		
		
		/**
		 * Returns the console's currently occupied buffer size.
		 */
		public function get bufferSize():int
		{
			return _ta.length;
		}
		
		
		public function set transparency(v:Number):void
		{
			_bg.alpha = v;
		}
		
		
		public function set bgColor(v:uint):void
		{
			_bgColor = v;
			update();
		}
		
		
		/**
		 * Signal that is dispatched everytime a log message is added.
		 */
		public function get logSignal():Signal
		{
			if (!_logSignal) _logSignal = new Signal();
			return _logSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onTextInputChange(e:Event):void
		{
			if (!_allowInput) return;
		}
		
		
		/**
		 * @private
		 */
		private function onFocusIn(e:FocusEvent):void
		{
			_keyInputManager.consoleFocussed = true;
		}
		
		
		/**
		 * @private
		 */
		private function onFocusOut(e:FocusEvent):void
		{
			_keyInputManager.consoleFocussed = false;
		}
		
		
		/**
		 * @private
		 */
		private function onTextInputKeyDown(e:KeyboardEvent):void
		{
			if (!_allowInput) return;
			
			if (e.keyCode == Keyboard.TAB)
			{
				if (_stage.focus != _ti)
				{
					_ti.focus();
					e.stopImmediatePropagation();
					e.stopPropagation();
				}
				//doTab();
				return;
			}
			
			if (e.ctrlKey)
			{
				switch(e.keyCode)
				{
					case Keyboard.UP:
						_ta.scroll--;
						return;
					case Keyboard.DOWN:
						_ta.scroll++;
						return;
					case Keyboard.PAGE_UP:
						_ta.scrollPage(false);
						return;
					case Keyboard.PAGE_DOWN:
						_ta.scrollPage(true);
						return;
					case Keyboard.BACKSPACE:
						_ti.clear();
						return;
				}
				return;
			}
			
			if (e.keyCode == Keyboard.ENTER)
			{
				if (_ti.text.length < 1)
				{
					_ti.focus();
					return;
				}
				
				_backBuffer.push(_ti.text);
				_cli.parseInput(_ti.text);
				clearInput();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onTextInputKeyUp(e:KeyboardEvent):void
		{
			if (!_allowInput || e.ctrlKey) return;
			
			var s:String = "";
			if (e.keyCode == Keyboard.UP)
			{
				if (_backBuffer.hasPrevious) s = _backBuffer.previous;
			}
			else if (e.keyCode == Keyboard.DOWN) 
			{
				if (_backBuffer.hasNext) s = _backBuffer.next;
			}
			
			if (s.length > 0)
			{
				_ti.text = s;
				_ti.focus();
				var spaceIndex:int = _ti.text.indexOf(" ");
				if (spaceIndex > -1)
				{
					_ti.setSelection(_ti.text.indexOf(" ") + 1, _ti.text.length);
				}
				else
				{
					_ti.setSelection(0, _ti.text.length);
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function onStageResize(e:Event):void
		{
			update();
		}
		
		
		/**
		 * @private
		 */
		private function onTweenComplete():void 
		{
			if (y == 0)
			{
				_visible = true;
				_allowInput = true;
				if (_ti) _ti.focus();
			}
			else
			{
				y = 0 - height;
				_visible = false;
				_allowInput = false;
				_stage.focus = _stage;
				if (_container.contains(this)) _container.removeChild(this);
				
				/* Make console container invisible if it doesn't
				 * contain the console or fpsmonitor! */
				if (_container.numChildren == 0)
				{
					_container.visible = false;
				}
				onFocusOut(null);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function createChildren():void
		{
			_bg = new RectangleShape();
			addChild(_bg);
			
			_ta = new ConsoleTextArea();
			addChild(_ta);
			
			_ti = new ConsoleTextInput();
			addChild(_ti);
			
			_cli = new CLI(this);
			
			_backBuffer = new BackBuffer(_config.getNumber(Config.CONSOLE_INPUT_BACKBUFFERSIZE));
			
			if (_useTween)
			{
				_tweenVars = new TweenVars();
				_tweenVars.ease = Cubic.easeOut;
				_tweenVars.onComplete = onTweenComplete;
			}
			
			setupTextFormat();
		}
		
		
		/**
		 * @private
		 */
		public function setupTextFormat():void
		{
			var f:TextFormat = _main.themeManager.currentTheme.getDebugTextFormat();
			_ti.textFormat = f;
			
			var c:Array = _config.getArray(Config.CONSOLE_COLORS);
			if (!c) return;
			
			_bgColor = uint("0x" + c[0]);
			
			var s:StyleSheet = new StyleSheet();
			s.setStyle("a", {fontFamily: FONT_INV});
			/* Info */
			s.setStyle("n2", {fontFamily: FONT, fontSize: FONT_SIZE, color: ("#" + c[3]), leading: LEADING});
			
			if (!_monochrome)
			{
				/* Trace */
				s.setStyle("n0", {fontFamily: FONT, fontSize: FONT_SIZE, color: ("#" + c[1]), leading: LEADING});
				/* Debug */
				s.setStyle("n1", {fontFamily: FONT, fontSize: FONT_SIZE, color: ("#" + c[2]), leading: LEADING});
				/* Notice */
				s.setStyle("n3", {fontFamily: FONT, fontSize: FONT_SIZE, color: ("#" + c[4]), leading: LEADING});
				/* Warn */
				s.setStyle("n4", {fontFamily: FONT, fontSize: FONT_SIZE, color: ("#" + c[5]), leading: LEADING});
				/* Error */
				s.setStyle("n5", {fontFamily: FONT, fontSize: FONT_SIZE, color: ("#" + c[6]), leading: LEADING});
				/* Fatal */
				s.setStyle("n6", {fontFamily: FONT, fontSize: FONT_SIZE, color: ("#" + c[7]), leading: LEADING});
				/* System */
				s.setStyle("n999", {fontFamily: FONT, fontSize: FONT_SIZE, color: ("#" + c[8]), leading: LEADING});
			}
			
			_ta.styleSheet = s;
		}
		
		
		/**
		 * @private
		 */
		private function addEventListeners():void
		{
			_stage.addEventListener(Event.RESIZE, onStageResize);
			_ti.tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_ti.tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_ti.tf.addEventListener(KeyboardEvent.KEY_DOWN, onTextInputKeyDown);
			_ti.tf.addEventListener(Event.CHANGE, onTextInputChange);
			_ti.tf.addEventListener(KeyboardEvent.KEY_UP, onTextInputKeyUp);
			
			_ta.tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_ta.tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
		
		
		/**
		 * Converts all occurances of HTML special characters and braces.
		 * @private
		 * 
		 * @param s String to convert Tags in.
		 * @param stripCRs true if CR's should be stripped from String.
		 */
		//private function convertHTMLTags(s:String, stripCRs:Boolean = false):String
		//{
		//	if (stripCRs) s = s.replace(/\\r/g, "");
		//	return s.replace(/&amp;/gi, "&amp;amp;")
		//		.replace(/&quot;/gi, "&amp;quot;")
		//		.replace(/&lt;/gi, "&amp;lt;")
		//		.replace(/&gt;/gi, "&amp;gt;")
		//		.replace(/</gi, "&lt;")
		//		.replace(/\u003E/gi, "&gt;");
		//}
		
		
		/**
		 * @private
		 */
		//private function replaceSpecialTags(s:String, level:int):String
		//{
		//	/* Check if text should be wrapped by delimiter lines. */
		//	if (s.substr(0, 1) == LINED && s.substr(-1, 1) == LINED)
		//	{
		//		var line:String = Console.makeLine(s.length - 2);
		//		s = line + "\n  " + s.substring(1, s.length - 1) + "\n  " + line;
		//	}
		//	return s.replace(/\u2320([^\u2320^\u2321]+)\u2321/g, "<a>$1</a>").replace(/\u02CD([^\u02CD]+)\u02CD/g, "<u>$1</u>");
		//}
		
		
		/**
		 * @private
		 */
		//private function addLabel(s:String, level:int):String
		//{
		//	switch (level)
		//	{
		//		case 3: return LABEL_NOTICE + s;
		//		case 4: return LABEL_WARN + s;
		//		case 5: return LABEL_ERROR + s;
		//		case 6: return LABEL_FATAL + s;
		//		case 999: return LABEL_SYSTEM + s;
		//	}
		//	return s;
		//}
	}
}


import tetragon.core.display.shape.RectangleShape;

import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

/**
 * @private
 */
final class ConsoleTextArea extends Sprite
{
	private var _tf:TextField;
	
	public function ConsoleTextArea()
	{
		focusRect = false;
		
		_tf = new TextField();
		_tf.antiAliasType = AntiAliasType.NORMAL;
		_tf.gridFitType = GridFitType.PIXEL;
		_tf.multiline = true;
		_tf.wordWrap = true;
		_tf.embedFonts = true;
		_tf.focusRect = false;
		addChild(_tf);
	}
	
	public function clear():void 
	{
		_tf.text = "";
	}
	
	public function updateScrolling():void 
	{
		_tf.scrollV = _tf.maxScrollV;
	}
	
	public function resize(w:int, h:int):void
	{
		_tf.width = w;
		_tf.height = h;
	}
	
	public function scrollPage(down:Boolean = false):void
	{
		var visibleLines:int = _tf.numLines - _tf.maxScrollV;
		if (down) _tf.scrollV += visibleLines;
		else _tf.scrollV -= visibleLines;
	}
	
	public function get length():int
	{
		return _tf.text.length;
	}
	public function get text():String
	{
		return _tf.htmlText;
	}
	public function set text(v:String):void
	{
		_tf.htmlText = v;
	}
	public function set styleSheet(v:StyleSheet):void
	{
		_tf.styleSheet = v;
	}
	public function get scroll():int
	{
		return _tf.scrollV;
	}
	public function set scroll(v:int):void
	{
		_tf.scrollV = v;
	}
	public function get tf():TextField
	{
		return _tf;
	}
}


/**
 * @private
 */
final class ConsoleTextInput extends Sprite
{
	private var _tf:TextField;
	private var _bg:RectangleShape;
	
	
	public function ConsoleTextInput()
	{
		focusRect = false;
		
		_bg = new RectangleShape();
		_bg.alpha = 0.05;
		addChild(_bg);
		
		_tf = new TextField();
		_tf.type = TextFieldType.INPUT;
		_tf.antiAliasType = AntiAliasType.NORMAL;
		_tf.gridFitType = GridFitType.PIXEL;
		_tf.embedFonts = true;
		_tf.height = 20;
		_tf.focusRect = false;
		_tf.restrict = "^`";
		addChild(_tf);
	}
	
	public function clear():void
	{
		_tf.text = "";
	}
	
	public function focus():void 
	{
		var isEmpty:Boolean = (_tf.length == 0);
		if (isEmpty) _tf.text = " ";
		if (stage) stage.focus = _tf;
		_tf.setSelection(_tf.length, _tf.length);
		if (isEmpty) _tf.text = "";
	}
	
	public function resize(w:int):void
	{
		_bg.setProperties(w, 20, 0xFFFFFF);
		_bg.draw();
		_tf.width = w;
	}
	
	public function setSelection(i:int, length:int):void
	{
		_tf.setSelection(i, length);
	}
	
	public function get text():String
	{
		return _tf.text;
	}
	public function set text(v:String):void
	{
		_tf.text = v;
	}
	public function set textFormat(v:TextFormat):void
	{
		_tf.setTextFormat(v);
		_tf.defaultTextFormat = v;
	}
	public function get tf():TextField
	{
		return _tf;
	}
}


/**
 * @private
 */
final class BackBuffer
{
	private var _buffer:Vector.<String>;
	private var _bufferSize:int;
	private var _currentIndex:int;
	
	public function BackBuffer(bufferSize:int = 100)
	{
		if (bufferSize < 0) bufferSize = 0;
		_bufferSize = bufferSize;
		clear();
	}
	
	public function push(string:String):void
	{
		if (_bufferSize < 1) return;
		
		/* check if buffer is full */
		if (_buffer.length > 0 && _buffer.length == _bufferSize)
		{
			_buffer.shift();
		}
		
		/* add new one */
		_buffer.push(string);
		_currentIndex = _buffer.length;
	}
	
	public function clear():void
	{
		_buffer = new Vector.<String>();
		_currentIndex = 0;
	}
	
	public function get hasPrevious():Boolean
	{
		return _currentIndex > 0;
	}
	public function get previous():String
	{
		if (!hasPrevious) return null;
		_currentIndex--;
		return _buffer[_currentIndex];
	}
	public function get hasNext():Boolean
	{
		return _currentIndex < _buffer.length - 1;
	}
	public function get next():String
	{
		if (!hasNext) return null;
		_currentIndex++;
		return _buffer[_currentIndex];
	}
	public function get current():String
	{
		if (_buffer.length == 0) return null;
		var ci:int = (_currentIndex - 1 < 0) ? 0 : _currentIndex - 1;
		return _buffer[ci];
	}
}
