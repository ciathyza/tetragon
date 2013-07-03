/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package tetragon.view.display.button
{
	import tetragon.Main;
	import tetragon.audio.AudioManager;
	import tetragon.core.signals.Signal;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	
	/**
	 * Base class for generic in-game button classes. Use this class by providing a
	 * MovieClip instance to the constructor. The MovieClip needs to have a property
	 * named 'buttonArea' or 'mouseArea' which must be a Sprite or MovieClip.
	 * 
	 * The buttonSymbol can contain a textfield named 'labelTF' or 'tf' or a wrapped
	 * textfield named 'tf' in a movieclip named 'label'.
	 *
	 * @author Hexagon
	 * @version 1.2
	 */
	public class BasicButton extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected static var _audioManager:AudioManager;
		
		protected var _symbol:MovieClip;
		protected var _label:TextField;
		protected var _buttonArea:Sprite;
		protected var _clickSound:Sound;
		
		protected var _isMouseOver:Boolean;
		
		protected var _enabled:Boolean;
		protected var _multiClick:Boolean;
		protected var _toggle:Boolean;
		protected var _selected:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		protected var _downSignal:Signal;
		protected var _upSignal:Signal;
		protected var _clickSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param buttonSymbol
		 * @param clickSound
		 * @param multiClick
		 */
		public function BasicButton(buttonSymbol:MovieClip, clickSound:Sound = null,
			multiClick:Boolean = false)
		{
			_symbol = buttonSymbol;
			_clickSound = clickSound;
			_multiClick = multiClick;
			_enabled = true;
			
			createChildren();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function setPosition(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			if (_buttonArea)
			{
				_buttonArea.removeEventListener(MouseEvent.CLICK, onClick);
				_buttonArea.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				_buttonArea.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				_buttonArea.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				_buttonArea.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(v:Boolean):void
		{
			_enabled = v;
		}
		
		
		override public function set useHandCursor(v:Boolean):void
		{
			super.useHandCursor = v;
			if (_buttonArea) _buttonArea.useHandCursor = v;
		}
		
		
		public function get toggle():Boolean
		{
			return _toggle;
		}
		public function set toggle(v:Boolean):void
		{
			_toggle = v;
		}
		
		
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set selected(v:Boolean):void
		{
			_selected = v;
		}
		
		
		public function get label():String
		{
			if (!_label) return null;
			return _label.text;
		}
		public function set label(v:String):void
		{
			if (_label)	_label.text = v;
		}
		
		
		public function get downSignal():Signal
		{
			if (!_downSignal) _downSignal = new Signal();
			return _downSignal;
		}


		public function get upSignal():Signal
		{
			if (!_upSignal) _upSignal = new Signal();
			return _upSignal;
		}
		
		
		public function get clickSignal():Signal
		{
			if (!_clickSignal) _clickSignal = new Signal();
			return _clickSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onMouseOver(e:MouseEvent):void
		{
			if (!_enabled || !_symbol) return;
			if (_toggle)
			{
				if (!_selected)
				{
					_symbol.gotoAndStop(2);
				}
			}
			else
			{
				_symbol.gotoAndStop(2);
			}
			
			_isMouseOver = true;
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseOut(e:MouseEvent):void
		{
			if (!_symbol) return;
			if (_toggle)
			{
				if (!_selected)
				{
					_symbol.gotoAndStop(1);
				}
			}
			else
			{
				_symbol.gotoAndStop(1);
			}
			
			_isMouseOver = false;
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseDown(e:MouseEvent):void
		{
			if (!_enabled || !_symbol) return;
			if (_audioManager && _clickSound) _audioManager.playSound(_clickSound);
			
			if (_toggle)
			{
				if (!_selected)
				{
					_selected = true;
					_symbol.gotoAndStop(3);
				}
				else
				{
					_selected = false;
					_symbol.gotoAndStop(1);
				}
			}
			else
			{
				_symbol.gotoAndStop(3);
			}
			
			if (_downSignal) _downSignal.dispatch();
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseUp(e:MouseEvent):void
		{
			if (!_enabled || !_symbol) return;
			if (!_toggle)
			{
				_symbol.gotoAndStop(1);
			}
			if (_isMouseOver)
			{
				if (!_multiClick)
				{
					dispose();
					if (_buttonArea) _buttonArea.useHandCursor = false;
				}
			}
			if (_upSignal) _upSignal.dispatch();
		}
		
		
		/**
		 * @private
		 */
		private function onClick(e:MouseEvent):void
		{
			if (!_enabled) return;
			if (_clickSignal) _clickSignal.dispatch();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		protected function createChildren():void
		{
			if (!_audioManager)
			{
				_audioManager = Main.instance.audioManager;
			}
			
			if (_symbol)
			{
				_symbol.stop();
				_symbol.focusRect = null;
				
				if (_symbol['label'] && _symbol['label']['tf'] && (_symbol['label']['tf'] is TextField))
				{
					_label = _symbol['label']['tf'];
				}
				else if (_symbol['labelTF'] && (_symbol['labelTF'] is TextField))
				{
					_label = _symbol['labelTF'];
				}
				else if (_symbol['tf'] && (_symbol['tf'] is TextField))
				{
					_label = _symbol['tf'];
				}
				
				if (_label)
				{
					_label.type = TextFieldType.DYNAMIC;
					_label.selectable = false;
				}
				
				_buttonArea = _symbol['buttonArea'];
				if (!_buttonArea) _buttonArea = _symbol["mouseArea"];
				
				if (_buttonArea)
				{
					_buttonArea.focusRect = false;
					_buttonArea.mouseChildren = false;
					_buttonArea.buttonMode = true;
					_buttonArea.useHandCursor = true;
					_buttonArea.addEventListener(MouseEvent.CLICK, onClick);
					_buttonArea.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
					_buttonArea.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
					_buttonArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					_buttonArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				}
			
				addChild(_symbol);
			}
		}
	}
}
