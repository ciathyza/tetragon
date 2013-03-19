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
package tetragon.input
{
	import tetragon.Main;
	import tetragon.debug.Log;
	import tetragon.view.ScreenManager;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	
	
	/**
	 * The KeyInputManager class can be used to assign key combinations to trigger a callback
	 * method.
	 */
	public final class KeyInputManager
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A string that is used in key combinations to divide between single keys
		 * in the combination.
		 */
		public static const KEY_COMBINATION_DELIMITER:String = "+";
		
		public static const TYPE_KEYSTRING:int = 0;
		public static const TYPE_KEYCODE:int = 1;
		public static const TYPE_KEYSEQ:int = 2;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _stage:Stage;
		/** @private */
		private var _screenManager:ScreenManager;
		/** @private */
		private var _keyBindings:Object;
		/** @private */
		private var _assignments:Object;
		/** @private */
		private var _keysDown:Object;
		/** @private */
		private var _combinationsDown:Object;
		/** @private */
		private var _keysTyped:Vector.<uint>;
		/** @private */
		private var _longestCombination:int;
		
		/** @private */
		private var _active:Boolean;
		/** @private */
		private var _consoleFocussed:Boolean;
		
		/** @private */
		private var _lastShiftKeyLocation:uint;
		/** @private */
		private var _lastCtrlKeyLocation:uint;
		/** @private */
		private var _lastAltKeyLocation:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _keySignal:KeySignal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function KeyInputManager()
		{
			_stage = Main.instance.stage;
			_screenManager = Main.instance.screenManager;
			_keySignal = new KeySignal();
			_active = false;
			_consoleFocussed = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the key manager. This clears all key assignments if there are any and
		 * then assigns some default key combinations that are used for the engine.
		 */
		public function init():void
		{
			clearBindings();
			clearAssignments();
		}
		
		
		/**
		 * Activates the key manager.
		 */
		public function activate():void
		{
			if (_active) return;
			_active = true;
			
			_screenManager.nativeViewContainer.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_screenManager.nativeViewContainer.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		}
		
		
		/**
		 * Deactivates the key manager.
		 */
		public function deactivate():void
		{
			if (!_active) return;
			_screenManager.nativeViewContainer.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_screenManager.nativeViewContainer.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
			_active = false;
		}
		
		
		/**
		 * Adds a new key binding.
		 * 
		 * @param identifier Key Binding identifier, e.g. toggleConsole
		 * @param keyString Key Binding combination string, e.g. SHIFT+F8
		 */
		public function addKeyBinding(identifier:String, keyString:String):void
		{
			var binding:String = _keyBindings[identifier];
			if (binding)
			{
				Log.warn("Failed to map key binding <" + keyString + "> to identifier \""
					+ identifier + "\" because another binding is already mapped to it ("
					+ binding + ").", this);
				return;
			}
			
			/* Remove any occuring whitespace from the combination string. */
			keyString = keyString.split(" ").join("");
			
			/* Make sure that the combination string contains valid keys. */
			var a:Array = keyString.split(KEY_COMBINATION_DELIMITER);
			for each (var s:String in a)
			{
				if (KeyCodes.getKeyCode(s) == -1)
				{
					Log.warn("Failed to map key binding <" + keyString + "> to identifier \""
						+ identifier + "\" because it contains an invalid key definition ("
						+ s + ").", this);
					return;
				}
			}
			
			Log.verbose("Mapped key binding with identifier \"" + identifier + "\" to <"
				+ keyString + ">.", this);
			_keyBindings[identifier] = keyString;
		}
		
		
		/**
		 * Removes a key binding.
		 * 
		 * @param identifier
		 * @return true or false.
		 */
		public function removeKeyBinding(identifier:String):Boolean
		{
			if (!_keyBindings[identifier]) return false;
			delete _keyBindings[identifier];
			return true;
		}
		
		
		/**
		 * Returns the key string that is mapped with the specified identifier or
		 * <code>null</code> if there is nothing mapped with it.
		 * 
		 * @param identifier The key binding identifier.
		 * @return A String of the mapped key combination or <code>null</code>.
		 */
		public function getKeyBinding(identifier:String):String
		{
			return _keyBindings[identifier];
		}
		
		
		/**
		 * Returns the key binding identifier that is used to map the specified keyString
		 * or <code>null</code> if the keyString isn't mapped.
		 * 
		 * @param keyString The key string.
		 * @return A String of the key identifier or <code>null</code>.
		 */
		public function getBindingIdentifier(keyString:String):String
		{
			for (var s:String in _keyBindings)
			{
				if (_keyBindings[s] == keyString) return s;
			}
			return null;
		}
		
		
		/**
		 * Assigns a key combination that is used to trigger any of the engine-inherent
		 * functionalities like the debug console, stats monitor, etc.
		 * 
		 * <p>Normally any key combination assign with assign() is not allowed to trigger
		 * if the debug console is focussed. Key combinations that are assigned with 
		 * assignEngineKey() on the other hand are alloed to trigger while the console
		 * is open and focussed.</p>
		 * 
		 * @param keyIdentifier
		 * @param callback
		 * @param keyMode
		 * @param params
		 */
		public function assignEngineKey(keyIdentifier:String, callback:Function,
			keyMode:int = KeyMode.DOWN, ...params):void
		{
			var kc:KeyCombination = assign2(keyIdentifier, keyMode, callback, params);
			if (kc) kc.consoleAllow = true;
		}
		
		
		/**
		 * Assigns a keyboard key or key combination to a callback function. The specified
		 * <code>keyValue</code> can be either a <code>String</code>, a <code>uint</code>,
		 * a <code>KeyCombination</code> object or an <code>Array</code>.
		 * 
		 * <p>By specifying a <code>String</code> you can assign a key combination which
		 * determines that the exact keys in this combination need to be pressed to
		 * trigger the callback. The String can contain one or more key identifiers which
		 * are divided by the <code>KEY_COMBINATION_DELIMITER</code> constant (a plus sign
		 * '+'), for example <code>F1</code>, <code>CTRL+A</code> or
		 * <code>SHIFT+CTRL+1</code>.</p>
		 * 
		 * <p>A <code>String</code> keyValue can also be a key binding identifier which is
		 * used to associate a specific key or key combination with the binding
		 * identifier. This feature is used in particular in connection with the
		 * keybindings.ini file. A key binding first needs to have been added to the key
		 * manager with the <code>addKeyBinding()</code> method. If the specified keyValue
		 * reflects any mapped key binding identifier the key combination string that is
		 * mapped with the identifier is used in place for it.</p>
		 * 
		 * <p>If the specified mode is <code>KeyMode.SEQ</code> the key string is
		 * interpreted as being a sequence of characters that need to be entered to
		 * trigger the callback.</p>
		 * 
		 * <p>By specifying a <code>uint</code> you can assign one key by it's key code
		 * directly. With this you can also use the numeric contants from ActionScript's
		 * native Keyboard class.</p>
		 * 
		 * <p>By specifying a <code>KeyCombination</code> object the key manager assigns
		 * the KeyCombination object with the key codes that are already listed in the
		 * KeyCombination.</p>
		 * 
		 * <p>By specifying an Array you can assign multiple key combinations to the same
		 * callback. The Array can contain a combination of String key identifiers, uints
		 * and/or KeyCombination objects.</p>
		 * 
		 * @see base.io.key.KeyCodes
		 * @see base.io.key.KeyMode
		 * 
		 * @param keyValue The key value to assign. This can be one of the following
		 *            object types: String, uint, KeyCombination or Array.
		 * @param mode The mode of the key assignment that determines when the callback is
		 *            triggered, either when the key is pressed or released or whether it
		 *            is repeatedly triggered or a sequence of keys that need to be
		 *            entered to trigger the callback. You can use the KeyMode class with
		 *            it's constants.
		 * @param callback The method that is called when the key or key combination is
		 *            triggered.
		 * @param params A list of optional parameters that are provided as arguments to
		 *            the callback function.
		 * @return A <code>KeyCombination</code> object or <code>null</code>. If the
		 *         assignment succeeded the resulting <code>KeyCombination</code> object
		 *         is returned, if the assignment failed <code>null</code> is returned. If
		 *         the specified <code>keyValue</code> is an <code>Array</code> only the
		 *         last successful assignment from the arrays' containing key values is
		 *         returned. if all assignments from the array failed, <code>null</code>
		 *         is returned.
		 */
		public function assign(keyValue:*, mode:int, callback:Function, ...params):KeyCombination
		{
			return assign2(keyValue, mode, callback, params);
		}
		
		
		/**
		 * Allows to remove a specific key assignment from the key manager.
		 * 
		 * @param keyValue The key value to remove. This can be either a String, a uint
		 *        a KeyCombination object or an Array containing any of these.
		 * @param mode The key mode of the to-be-removed key assignment.
		 * @return The KeyCombination object that was removed or null if no key mapping was
		 *       found with the specified keyValue and mode.
		 */
		public function remove(keyValue:*, mode:int = KeyMode.DOWN):KeyCombination
		{
			var vo:KeyCodesVO;
			var kc:KeyCombination;
			
			if (keyValue is String)
			{
				var binding:String = getKeyBinding(keyValue);
				if (binding) keyValue = binding;
				vo = createKeyCodes(keyValue, (mode == KeyMode.SEQ ? TYPE_KEYSEQ : TYPE_KEYSTRING));
			}
			else if (keyValue is uint)
			{
				vo = createKeyCodes(keyValue, TYPE_KEYCODE);
			}
			else if (keyValue is KeyCombination)
			{
				vo = new KeyCodesVO();
				vo.codes = KeyCombination(keyValue).codes;
			}
			else if (keyValue is Array)
			{
				var a:Array = keyValue;
				if (a.length > 0)
				{
					for (var i:uint = 0; i < a.length; i++)
					{
						var result:KeyCombination = remove(a[i], mode);
						if (result) kc = result;
					}
					return kc;
				}
			}
			
			if (!vo) return null;
			var id:String = generateKeyCombinationID(vo.codes, mode);
			if (_assignments[id])
			{
				kc = _assignments[id];
				delete _assignments[id];
				Log.verbose("Removed key assignment for ID \"" + id + "\".", this);
				return kc;
			}
			return null;
		}
		
		
		/**
		 * Clears all mapped key bindings.
		 */
		public function clearBindings():void
		{
			_keyBindings = {};
		}
		
		
		/**
		 * Clears all key assignments from the key manager.
		 */
		public function clearAssignments():void
		{
			var wasActive:Boolean = _active;
			deactivate();
			_assignments = {};
			_keysDown = {};
			_combinationsDown = {};
			_keysTyped = new Vector.<uint>();
			_longestCombination = 0;
			if (wasActive) activate();
		}
		
		
		/**
		 * Creates a key-combination object from a string that defines either one or
		 * multiple keys identifier strings, a key code or a key sequence.
		 * 
		 * @see KeyCodes
		 * @param keyString A string that defines a key identifier or multiple key
		 *            identifiers, separated by the
		 *            <code>KeyManager.KEY_COMBINATION_DELIMITER</code> (+), e.g. CTRL+C.
		 * @param type The type of the specified string, can be either TYPE_KEYSTRING,
		 *            TYPE_KEYCODE or TYPE_KEYSEQ.
		 * @return A KeyCombination object or <code>null</code>.
		 */
		public static function createKeyCombination(keyString:String, type:int):KeyCombination
		{
			if (keyString == null || keyString.length < 1) return null;
			var vo:KeyCodesVO = createKeyCodes(keyString, type);
			if (!vo) return null;
			var kc:KeyCombination = new KeyCombination();
			kc.codes = vo.codes;
			kc.shiftKeyLocation = vo.shiftKeyLoc;
			kc.ctrlKeyLocation = vo.ctrlKeyLoc;
			kc.altKeyLocation = vo.altKeyLoc;
			kc.hasShiftKey = vo.codes.indexOf(Keyboard.SHIFT) != -1;
			kc.hasCtrlKey = vo.codes.indexOf(Keyboard.CONTROL) != -1;
			kc.hasAltKey = vo.codes.indexOf(Keyboard.ALTERNATE) != -1;
			return kc;
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		public function toString():String
		{
			return "KeyInputManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The signal that can be used to listen for keyboard events. In rare
		 * occassions you don't want to use the functionality of the KeyManager to
		 * listen for keyboard events. In that case add your signal listener to this
		 * dispatcher.
		 */
		public function get keySignal():KeySignal
		{
			return _keySignal;
		}
		
		
		/**
		 * Determines whether the console currently has focus or not. This is set
		 * automatically by the console whenever it gains or looses key focus.
		 */
		public function get consoleFocussed():Boolean
		{
			return _consoleFocussed;
		}
		public function set consoleFocussed(v:Boolean):void
		{
			_consoleFocussed = v;
		}
		
		
		/**
		 * A map that contains all assigned KeyCombination objects mapped by their ID.
		 */
		public function get assignments():Object
		{
			return _assignments;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			_keySignal.dispatch(KeySignal.KEY_DOWN, e);
			var isAlreadyDown:Boolean = _keysDown[e.keyCode] as Boolean;
			var i:int;
			
			/* Store all keys that are currently pressed. */
			_keysDown[e.keyCode] = true;
			
			/* Store typed keys for sequence checking. */
			_keysTyped.push(e.charCode);
			if (_keysTyped.length > _longestCombination)
			{
				_keysTyped.splice(0, 1);
			}
			
			if (isAlreadyDown) return;
			
			/* Store last used modifier keys if any of them are pressed. We can't use
			 * e.shiftKey etc. here and have to fallback checking key codes. */
			if (e.keyCode == 16 && _lastShiftKeyLocation == 0) _lastShiftKeyLocation = e.keyLocation;
			else if (e.keyCode == 17 && _lastCtrlKeyLocation == 0) _lastCtrlKeyLocation = e.keyLocation;
			else if (e.keyCode == 18 && _lastAltKeyLocation == 0) _lastAltKeyLocation = e.keyLocation;
			
			/* loop through all key combinations and check if any of them are pressed. */
			for each (var kc:KeyCombination in _assignments)
			{
				/* Check for key sequences. */
				if (kc.mode == KeyMode.SEQ)
				{
					var c1:Vector.<uint> = kc.codes;
					i = c1.length;
					var c2:Vector.<uint> = _keysTyped.slice(-i);
					if (i != c2.length) continue;
					var isEqual:Boolean = true;
					while (i--)
					{
						if (c1[i] != c2[i])
						{
							isEqual = false;
							break;
						}
					}
					if (isEqual)
					{
						if (kc.params) kc.callback.apply(null, kc.params);
						else kc.callback();
					}
					continue;
				}
				
				/* If modifier keys are pressed we have to filter out any other keys
				 * that might have a single key code assignment but also have an
				 * assignment together with the mod key or we might end up triggering
				 * only the single code one if it's found before the multi-code one. */
				if (e.shiftKey && !kc.hasShiftKey) continue;
				if (e.ctrlKey && !kc.hasCtrlKey) continue;
				if (e.altKey && !kc.hasAltKey) continue;
				
				/* Filter any key combinations if their modifier key location matters and
				 * we don't have that key location pressed. */
				if (kc.shiftKeyLocation > 0 && kc.shiftKeyLocation != _lastShiftKeyLocation) continue;
				if (kc.ctrlKeyLocation > 0 && kc.ctrlKeyLocation != _lastCtrlKeyLocation) continue;
				if (kc.altKeyLocation > 0 && kc.altKeyLocation != _lastAltKeyLocation) continue;
				
				/* Remove duplicate characters from entered key sequences. */
				var uniqueCodes:Vector.<uint> = kc.codes.filter(
					function (e:uint, i:int, v:Vector.<uint>):Boolean
					{return (i == 0) ? true : v.lastIndexOf(e, i - 1) == -1;});
				
				i = uniqueCodes.length;
				var isUnique:Boolean = true;
				while (i--)
				{
					if (!_keysDown[uniqueCodes[i]])
					{
						isUnique = false;
						break;
					}
				}
				if (!isUnique) continue;
				
				/* While console is focussed, only allow console-related keys! */
				if (_consoleFocussed && !kc.consoleAllow) continue;
				
				/* Store combination in currently pressed combinations list. */
				_combinationsDown[kc.id] = kc;
				
				/* Loop through all currently pressed combinations and check if any of them
				 * still has a callback to trigger. */
				for each (var cd:KeyCombination in _combinationsDown)
				{
					if (!cd.isTriggered && cd.mode < 2)
					{
						if (cd.mode == 0) cd.isTriggered = true;
						else if (cd.mode == 1) delete _keysDown[e.keyCode];
						if (cd.params) cd.callback.apply(null, cd.params);
						else cd.callback();
					}
				}
			}
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			_keySignal.dispatch(KeySignal.KEY_UP, e);
			
			/* Clear last used modifier keys if any of them is released. */
			if (e.keyCode == 16) _lastShiftKeyLocation = 0;
			else if (e.keyCode == 17) _lastCtrlKeyLocation = 0;
			else if (e.keyCode == 18) _lastAltKeyLocation = 0;
			
			for each (var kc:KeyCombination in _combinationsDown)
			{
				if (kc.codes.indexOf(e.keyCode) != -1)
				{
					if (kc.mode == 2)
					{
						if (kc.params) kc.callback.apply(null, kc.params);
						else kc.callback();
					}
					kc.isTriggered = false;
					delete _combinationsDown[kc.id];
				}
			}
			delete _keysDown[e.keyCode];
		}
		
		
		private function onDeactivate(e:Event):void
		{
			_combinationsDown = {};
			_keysDown = {};
			_lastShiftKeyLocation = _lastCtrlKeyLocation = _lastAltKeyLocation = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Internal assign method used by the public assign API. This method exists so that
		 * any params arrays are 'unwrapped' and don't result in arrays wrapped into arrays
		 * if we do assignments that happen by iteration due to an Array keyValue.
		 * 
		 * However by using a second method that takes the params explicitly as an Array
		 * object we can iterate the method without causing nested params arrays. On the
		 * other hand we can still use the ...rest operator on the public assign method.
		 */
		private function assign2(keyValue:*, mode:int, callback:Function, params:Array):KeyCombination
		{
			var combination:KeyCombination;
			if (keyValue is String)
			{
				var binding:String = getKeyBinding(keyValue);
				if (binding) keyValue = binding;
				combination = createKeyCombination(keyValue, (mode == KeyMode.SEQ ? TYPE_KEYSEQ : TYPE_KEYSTRING));
			}
			else if (keyValue is uint)
			{
				combination = createKeyCombination(String(keyValue), TYPE_KEYCODE);
			}
			else if (keyValue is KeyCombination)
			{
				combination = keyValue;
			}
			else if (keyValue is Array)
			{
				var a:Array = keyValue;
				if (a.length > 0)
				{
					var kc:KeyCombination;
					for (var i:uint = 0; i < a.length; i++)
					{
						var result:KeyCombination = assign2(a[i], mode, callback, params);
						if (result) kc = result;
					}
					return kc;
				}
			}
			
			if (!combination)
			{
				fail("Could not create key combination for key value: \"" + keyValue + "\".");
				return null;
			}
			if (callback == null)
			{
				fail("Failed to assign key combination for key value: \"" + keyValue
					+ "\". Callback may not be null!");
				return null;
			}
			
			combination.mode = mode < 0 ? 0 : mode > 3 ? 3 : mode;
			combination.callback = callback;
			if (params && params.length > 0) combination.params = params;
			
			var id:String = generateKeyCombinationID(combination.codes, combination.mode);
			if (_assignments[id])
			{
				Log.warn("A key combination with the ID \"" + id + "\" has already been assigned."
					+ " New assignment for key value <" + keyValue + "> was ignored.", this);
				return null;
			}
			
			combination.id = id;
			_assignments[id] = combination;
			_longestCombination = Math.max(_longestCombination, combination.codes.length);
			Log.verbose("Assigned key codes <" + keyValue + "> (mode: " + mode + ").", this);
			return combination;
		}
		
		
		/**
		 * Sends an error message to the logger.
		 */
		private function fail(message:String):void
		{
			Log.error(message, this);
		}
		
		
		/**
		 * Creates a KeyCode value object that contains a list of key codes.
		 */
		private static function createKeyCodes(keyString:String, type:int):KeyCodesVO
		{
			var vo:KeyCodesVO = new KeyCodesVO();
			var i:uint;
			switch (type)
			{
				case TYPE_KEYCODE:
					vo.codes = new Vector.<uint>(1, true);
					vo.codes[0] = uint(keyString);
					return vo;
				case TYPE_KEYSEQ:
					vo.codes = new Vector.<uint>(keyString.length, true);
					for (i = 0; i < keyString.length; i++)
					{
						vo.codes[i] = keyString.charCodeAt(i);
					}
					return vo;
				case TYPE_KEYSTRING:
					var a:Array = keyString.split(KEY_COMBINATION_DELIMITER);
					vo.codes = new Vector.<uint>(a.length, true);
					for (i = 0; i < vo.codes.length; i++)
					{
						var ks:String = String(a[i]).toLowerCase();
						var code:int = KeyCodes.getKeyCode(ks);
						if (code == -1) return null;
						if (ks == "lshift") vo.shiftKeyLoc = KeyLocation.LEFT;
						else if (ks == "rshift") vo.shiftKeyLoc = KeyLocation.RIGHT;
						else if (ks == "lctrl" || ks == "lcontrol") vo.ctrlKeyLoc = KeyLocation.LEFT;
						else if (ks == "rctrl" || ks == "rcontrol") vo.ctrlKeyLoc = KeyLocation.RIGHT;
						else if (ks == "lalt") vo.altKeyLoc = KeyLocation.LEFT;
						else if (ks == "ralt") vo.altKeyLoc = KeyLocation.RIGHT;
						vo.codes[i] = code;
					}
					return vo;
				default:
					return null;
			}
		}
		
		
		/**
		 * Generates an ID for the specified KeyCombination object.
		 */
		private static function generateKeyCombinationID(codes:Vector.<uint>, mode:int):String
		{
			var id:String = "";
			for (var i:uint = 0; i < codes.length; i++)
			{
				id += codes[i] + "-";
			}
			return id + mode;
		}
	}
}


final class KeyCodesVO
{
	public var codes:Vector.<uint>;
	public var shiftKeyLoc:uint = 0;
	public var ctrlKeyLoc:uint = 0;
	public var altKeyLoc:uint = 0;
}
