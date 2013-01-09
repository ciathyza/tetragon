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
package tetragon.view.render2d.core
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import tetragon.debug.Log;
	import tetragon.view.render2d.core.events.Event2D;
	import tetragon.view.render2d.core.events.EventDispatcher2D;
	import tetragon.view.render2d.core.events.KeyboardEvent2D;
	import tetragon.view.render2d.core.events.ResizeEvent2D;
	import tetragon.view.render2d.core.events.TouchPhase2D;
	import tetragon.view.render2d.core.events.TouchProcessor2D;

	
	
	/**
	 * The Direct2D class represents the core of the Direct2D framework.
	 * 
	 * <p>
	 * The Direct2D framework makes it possible to create 2D applications and games that
	 * make use of the Stage3D architecture introduced in Flash Player 11. It implements a
	 * display tree system that is very similar to that of conventional Flash, while
	 * leveraging modern GPUs to speed up rendering.
	 * </p>
	 * 
	 * <p>
	 * The Direct2D class represents the link between the conventional Flash display tree
	 * and the Direct2D display tree. To create a Direct2D-powered application, you have
	 * to create an instance of the Direct2D class:
	 * </p>
	 * 
	 * <pre>
	 * var direct2D:Direct2D = new Direct2D(Game, stage);
	 * </pre>
	 * 
	 * <p>
	 * The first parameter has to be a Direct2D display object class, e.g. a subclass of
	 * <code>direct2D.display.Sprite</code>. In the sample above, the class "Game" is the
	 * application root. An instance of "Game" will be created as soon as Direct2D is
	 * initialized. The second parameter is the conventional (Flash) stage object. Per
	 * default, Direct2D will display its contents directly below the stage.
	 * </p>
	 * 
	 * <p>
	 * It is recommended to store the direct2D instance as a member variable, to make sure
	 * that the Garbage Collector does not destroy it. After creating the Direct2D object,
	 * you have to start it up like this:
	 * </p>
	 * 
	 * <pre>
	 * direct2D.start();
	 * </pre>
	 * 
	 * <p>
	 * It will now render the contents of the "Game" class in the frame rate that is set
	 * up for the application (as defined in the Flash stage).
	 * </p>
	 * 
	 * <strong>Accessing the Direct2D object</strong>
	 * 
	 * <p>
	 * From within your application, you can access the current Direct2D object anytime
	 * through the static method <code>Direct2D.current</code>. It will return the active
	 * Direct2D instance (most applications will only have one Direct2D object, anyway).
	 * </p>
	 * 
	 * <strong>Viewport</strong>
	 * 
	 * <p>
	 * The area the Direct2D content is rendered into is, per default, the complete size
	 * of the stage. You can, however, use the "viewPort" property to change it. This can
	 * be useful when you want to render only into a part of the screen, or if the player
	 * size changes. For the latter, you can listen to the RESIZE-event dispatched by the
	 * Direct2D stage.
	 * </p>
	 * 
	 * <strong>Native overlay</strong>
	 * 
	 * <p>
	 * Sometimes you will want to display native Flash content on top of Direct2D. That's
	 * what the <code>nativeOverlay</code> property is for. It returns a Flash Sprite
	 * lying directly on top of the Direct2D content. You can add conventional Flash
	 * objects to that overlay.
	 * </p>
	 * 
	 * <p>
	 * Beware, though, that conventional Flash content on top of 3D content can lead to
	 * performance penalties on some (mobile) platforms. For that reason, always remove
	 * all child objects from the overlay when you don't need them any longer. Direct2D
	 * will remove the overlay from the display list when it's empty.
	 * </p>
	 * 
	 * <strong>Multitouch</strong>
	 * 
	 * <p>
	 * Direct2D supports multitouch input on devices that provide it. During development,
	 * where most of us are working with a conventional mouse and keyboard, Direct2D can
	 * simulate multitouch events with the help of the "Shift" and "Ctrl" (Mac: "Cmd")
	 * keys. Activate this feature by enabling the <code>simulateMultitouch</code>
	 * property.
	 * </p>
	 * 
	 * <strong>Handling a lost render context</strong>
	 * 
	 * <p>
	 * On some operating systems and under certain conditions (e.g. returning from system
	 * sleep), Direct2D's stage3D render context may be lost. Direct2D can recover from a
	 * lost context if the class property "handleLostContext" is set to "true". Keep in
	 * mind, however, that this comes at the price of increased memory consumption;
	 * Direct2D will cache textures in RAM to be able to restore them when the context is
	 * lost.
	 * </p>
	 * 
	 * <p>
	 * In case you want to react to a context loss, Direct2D dispatches an event with the
	 * type "Event.CONTEXT3D_CREATE" when the context is restored. You can recreate any
	 * invalid resources in a corresponding event listener.
	 * </p>
	 */
	public final class Render2D extends EventDispatcher2D
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private var _stage3D:Stage3D;
		/** @private */
		private var _stage:Stage;
		/** @private */
		private var _stage2D:Stage2D; // direct2D.display.stage!
		/** @private */
		private var _root:Sprite2D;
		/** @private */
		private var _juggler:Juggler2D;
		/** @private */
		private var _support:Render2DRenderSupport;
		/** @private */
		private var _touchProcessor:TouchProcessor2D;
		/** @private */
		private var _viewPort:Rectangle;
		/** @private */
		private var _nativeOverlay:Sprite;
		/** @private */
		private var _context:Context3D;
		/** @private */
		private var _programs:Dictionary;
		
		/** @private */
		private var _antiAliasing:int;
		/** @private */
		private var _lastFrameTimestamp:Number;
		
		/** @private */
		private var _started:Boolean;
		/** @private */
		private var _simulateMultitouch:Boolean;
		/** @private */
		private var _enableErrorChecking:Boolean;
		/** @private */
		private var _leftMouseDown:Boolean;
		
		/** @private */
		private static var _current:Render2D;
		/** @private */
		private static var _handleLostContext:Boolean;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Direct2D instance.
		 * 
		 * @param stage The Flash (2D) stage.
		 * @param rootClass A subclass of a Direct2D display object. It will be created as
		 *            soon as initialization is finished and will become the first child
		 *            of the Direct2D stage.
		 * @param viewPort A rectangle describing the area into which the content will be
		 *            rendered. @default stage size
		 * @param stage3D The Stage3D object into which the content will be rendered.
		 * @param renderMode Use this parameter to force "software" rendering.
		 */
		public function Render2D(stage:Stage, root:Sprite2D = null, viewPort:Rectangle = null,
			stage3D:Stage3D = null, renderMode:String = "auto")
		{
			if (!stage) throw new ArgumentError("Stage must not be null");
			if (!root) root = new Sprite2D();
			if (!viewPort) viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			if (!stage3D) stage3D = stage.stage3Ds[0];
			
			makeCurrent();
			
			_root = root;
			_stage = stage;
			_viewPort = viewPort;
			_stage3D = stage3D;
			
			_stage2D = new Stage2D(viewPort.width, viewPort.height, stage.color);
			_touchProcessor = new TouchProcessor2D(_stage2D);
			_juggler = new Juggler2D();
			_programs = new Dictionary();
			_support = new Render2DRenderSupport();
			
			_simulateMultitouch = false;
			_enableErrorChecking = false;
			
			_antiAliasing = 0;
			_lastFrameTimestamp = getTimer() / 1000.0;
			
			// register touch/mouse event handlers
			for each (var t:String in touchEventTypes)
			{
				_stage.addEventListener(t, onTouch);
			}
			
			// register other event handlers
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
			_stage.addEventListener(Event.RESIZE, onResize);
			
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated, false, 1);
			_stage3D.addEventListener(ErrorEvent.ERROR, onStage3DError, false, 1);
			
			try
			{
				_stage3D.requestContext3D(renderMode);
			}
			catch (err:Error)
			{
				showOnScreenError("Context3D error: " + err.message);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes Shader programs and render context.
		 */
		public function dispose():void
		{
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame, false);
			_stage.removeEventListener(KeyboardEvent2D.KEY_DOWN, onKey, false);
			_stage.removeEventListener(KeyboardEvent2D.KEY_UP, onKey, false);
			_stage.removeEventListener(Event.RESIZE, onResize, false);
			_stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated, false);
			_stage3D.removeEventListener(ErrorEvent.ERROR, onStage3DError, false);
			
			for each (var t:String in touchEventTypes)
			{
				_stage.removeEventListener(t, onTouch, false);
			}
			for each (var p:Program3D in _programs)
			{
				p.dispose();
			}
			
			if (_context) _context.dispose();
			if (_touchProcessor) _touchProcessor.dispose();
			if (_support) _support.dispose();
			if (_current == this) _current = null;
		}
		
		
		/**
		 * Make this Direct2D instance the <code>current</code> one.
		 */
		public function makeCurrent():void
		{
			_current = this;
		}
		
		
		/**
		 * Starts rendering and dispatching of <code>ENTER_FRAME</code> events.
		 */
		public function start():void
		{
			_started = true;
		}
		
		
		/**
		 * Stops rendering.
		 */
		public function stop():void
		{
			_started = false;
		}
		
		
		/**
		 * Registers a vertex- and fragment-program under a certain name.
		 * 
		 * @param name
		 * @param vertexProgram
		 * @param fragmentProgram
		 */
		public function registerProgram(name:String, vertexProgram:ByteArray,
			fragmentProgram:ByteArray):void
		{
			if (name in _programs)
			{
				throw new Error("Another program with this name is already registered");
			}
			
			var program:Program3D = _context.createProgram();
			program.upload(vertexProgram, fragmentProgram);
			_programs[name] = program;
		}
		
		
		/**
		 * Deletes the vertex- and fragment-programs of a certain name.
		 * 
		 * @param name
		 */
		public function deleteProgram(name:String):void
		{
			var program:Program3D = getProgram(name);
			if (program)
			{
				program.dispose();
				delete _programs[name];
			}
		}
		
		
		/**
		 * Returns the vertex- and fragment-programs registered under a certain name.
		 * 
		 * @param name
		 * @return Program3D
		 */
		public function getProgram(name:String):Program3D
		{
			return _programs[name] as Program3D;
		}
		
		
		/**
		 * Indicates if a set of vertex- and fragment-programs is registered under a certain name.
		 * 
		 * @param name
		 * @return true or false.
		 */
		public function hasProgram(name:String):Boolean
		{
			return name in _programs;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "Render2D";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if this Direct2D instance is started.
		 */
		public function get isStarted():Boolean
		{
			return _started;
		}
		
		
		/**
		 * The default juggler of this instance. Will be advanced once per frame.
		 */
		public function get juggler():Juggler2D
		{
			return _juggler;
		}
		
		
		/**
		 * The root 2D displayobject container.
		 */
		public function get root():Sprite2D
		{
			return _root;
		}
		
		
		/**
		 * The render context of this instance.
		 */
		public function get context():Context3D
		{
			return _context;
		}
		
		
		/**
		 * Indicates if multitouch simulation with "Shift" and "Ctrl"/"Cmd"-keys is enabled. 
		 * 
		 * @default false
		 */
		public function get simulateMultitouch():Boolean
		{
			return _simulateMultitouch;
		}
		public function set simulateMultitouch(v:Boolean):void
		{
			_simulateMultitouch = v;
			if (_context) _touchProcessor.simulateMultitouch = v;
		}
		
		
		/**
		 * Indicates if Stage3D render methods will report errors. Activate only when
		 * needed, as this has a negative impact on performance.
		 * 
		 * @default false
		 */
		public function get enableErrorChecking():Boolean
		{
			return _enableErrorChecking;
		}
		public function set enableErrorChecking(v:Boolean):void
		{
			_enableErrorChecking = v;
			if (_context) _context.enableErrorChecking = v;
		}
		
		
		/**
		 * The antialiasing level. 0 - no antialasing, 16 - maximum antialiasing.
		 * 
		 * @default 0
		 */
		public function get antiAliasing():int
		{
			return _antiAliasing;
		}
		public function set antiAliasing(v:int):void
		{
			_antiAliasing = v < 0 ? 0 : v > 16 ? 16 : v;
			updateViewPort();
		}
		
		
		/**
		 * The viewport into which Direct2D contents will be rendered.
		 */
		public function get viewPort():Rectangle
		{
			return _viewPort.clone();
		}
		public function set viewPort(v:Rectangle):void
		{
			_viewPort = v.clone();
			updateViewPort();
		}
		
		
		/**
		 * Lazy getter for a Flash Sprite placed directly on top of the Direct2D content.
		 * Use it to display native Flash components.
		 */
		public function get nativeOverlay():Sprite
		{
			if (!_nativeOverlay)
			{
				_nativeOverlay = new Sprite();
				_stage.addChild(_nativeOverlay);
				updateNativeOverlay();
			}
			return _nativeOverlay;
		}
		
		
		/**
		 * The Direct2D stage object, which is the root of the display tree that is rendered.
		 */
		public function get stage2D():Stage2D
		{
			return _stage2D;
		}
		
		
		/**
		 * The Flash Stage3D object Direct2D renders into.
		 */
		public function get stage3D():Stage3D
		{
			return _stage3D;
		}
		
		
		/**
		 * The Flash (2D) stage object Direct2D renders beneath.
		 */
		public function get nativeStage():Stage
		{
			return _stage;
		}
		
		
		/**
		 * The currently active Direct2D instance.
		 */
		public static function get current():Render2D
		{
			return _current;
		}
		
		
		/**
		 * The render context of the currently active Direct2D instance.
		 */
		public static function get context():Context3D
		{
			return _current ? _current.context : null;
		}
		
		
		/**
		 * The default juggler of the currently active Direct2D instance.
		 */
		public static function get juggler():Juggler2D
		{
			return _current ? _current.juggler : null;
		}
		
		
		/**
		 * Indicates if multitouch input should be supported.
		 */
		public static function get multitouchEnabled():Boolean
		{
			return Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
		}
		public static function set multitouchEnabled(v:Boolean):void
		{
			Multitouch.inputMode = v ? MultitouchInputMode.TOUCH_POINT : MultitouchInputMode.NONE;
		}
		
		
		/**
		 * Indicates if Direct2D should automatically recover from a lost device context.
		 * On some systems, an upcoming screensaver or entering sleep mode may invalidate
		 * the render context. This setting indicates if Direct2D should recover from such
		 * incidents. Beware that this has a huge impact on memory consumption!
		 * 
		 * @default false
		 */
		public static function get handleLostContext():Boolean
		{
			return _handleLostContext;
		}
		public static function set handleLostContext(v:Boolean):void
		{
			if (_current)
			{
				throw new IllegalOperationError("Setting must be changed before Direct2D instance is created");
				return;
			}
			_handleLostContext = v;
		}
		
		
		/**
		 * @private
		 */
		private function get touchEventTypes():Array
		{
			return Mouse.supportsCursor || !multitouchEnabled
				? [MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_UP]
				: [TouchEvent.TOUCH_BEGIN, TouchEvent.TOUCH_MOVE, TouchEvent.TOUCH_END];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onStage3DError(e:ErrorEvent):void
		{
			showOnScreenError("This application is not correctly embedded (wrong wmode value).");
		}
		
		
		/**
		 * @private
		 */
		private function onContext3DCreated(e:Event):void
		{
			if (!Render2D.handleLostContext && _context)
			{
				showOnScreenError("Fatal error: The application lost the device context!");
				stop();
				return;
			}
			
			makeCurrent();
			initializeGraphicsAPI();
			dispatchEvent(new Event2D(Event2D.CONTEXT3D_CREATE));
			initializeRoot();
			_touchProcessor.simulateMultitouch = _simulateMultitouch;
		}
		
		
		/**
		 * @private
		 */
		private function onEnterFrame(e:Event):void
		{
			makeCurrent();
			if (_nativeOverlay) updateNativeOverlay();
			if (_started) render();
		}
		
		
		/**
		 * @private
		 */
		private function onKey(e:KeyboardEvent):void
		{
			makeCurrent();
			_stage2D.dispatchEvent(new KeyboardEvent2D(e.type, e.charCode, e.keyCode, e.keyLocation,
				e.ctrlKey, e.altKey, e.shiftKey));
		}
		
		
		/**
		 * @private
		 */
		private function onResize(e:Event):void
		{
			var stage:Stage = e.target as Stage;
			_stage2D.dispatchEvent(new ResizeEvent2D(Event.RESIZE, stage.stageWidth,
				stage.stageHeight));
		}
		
		
		/**
		 * @private
		 */
		private function onTouch(e:Event):void
		{
			var globalX:Number;
			var globalY:Number;
			var touchID:int;
			var phase:String;
			
			// figure out general touch properties
			if (e is MouseEvent)
			{
				var me:MouseEvent = e as MouseEvent;
				globalX = me.stageX;
				globalY = me.stageY;
				touchID = 0;
				
				// MouseEvent.buttonDown returns true for both left and right button (AIR supports
				// the right mouse button). We only want to react on the left button for now,
				// so we have to save the state for the left button manually.
				if (e.type == MouseEvent.MOUSE_DOWN) _leftMouseDown = true;
				else if (e.type == MouseEvent.MOUSE_UP) _leftMouseDown = false;
			}
			else
			{
				var touchEvent:TouchEvent = e as TouchEvent;
				globalX = touchEvent.stageX;
				globalY = touchEvent.stageY;
				touchID = touchEvent.touchPointID;
			}
			
			// figure out touch phase
			switch (e.type)
			{
				case TouchEvent.TOUCH_BEGIN:
					phase = TouchPhase2D.BEGAN;
					break;
				case TouchEvent.TOUCH_MOVE:
					phase = TouchPhase2D.MOVED;
					break;
				case TouchEvent.TOUCH_END:
					phase = TouchPhase2D.ENDED;
					break;
				case MouseEvent.MOUSE_DOWN:
					phase = TouchPhase2D.BEGAN;
					break;
				case MouseEvent.MOUSE_UP:
					phase = TouchPhase2D.ENDED;
					break;
				case MouseEvent.MOUSE_MOVE:
					phase = (_leftMouseDown ? TouchPhase2D.MOVED : TouchPhase2D.HOVER);
					break;
			}
			
			// move position into viewport bounds
			globalX = _stage2D.stageWidth * (globalX - _viewPort.x) / _viewPort.width;
			globalY = _stage2D.stageHeight * (globalY - _viewPort.y) / _viewPort.height;
			
			// enqueue touch in touch processor
			_touchProcessor.enqueue(touchID, phase, globalX, globalY);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function initializeGraphicsAPI():void
		{
			_context = _stage3D.context3D;
			_context.enableErrorChecking = _enableErrorChecking;
			_programs = new Dictionary();
			
			updateViewPort();
			
			Log.verbose("Initialization complete.", this);
			Log.verbose("Display Driver: " + _context.driverInfo, this);
		}
		
		
		/**
		 * @private
		 */
		private function initializeRoot():void
		{
			if (_stage2D.numChildren > 0) return;
			_stage2D.addChild(_root);
		}
		
		
		/**
		 * @private
		 */
		private function updateViewPort():void
		{
			if (_context)
			{
				_context.configureBackBuffer(_viewPort.width, _viewPort.height, _antiAliasing, false);
			}
			_stage3D.x = _viewPort.x;
			_stage3D.y = _viewPort.y;
		}
		
		
		/**
		 * @private
		 */
		private function render():void
		{
			if (_context == null || _context.driverInfo == "Disposed") return;
			
			var now:Number = getTimer() / 1000.0;
			var passedTime:Number = now - _lastFrameTimestamp;
			_lastFrameTimestamp = now;
			
			_stage2D.advanceTime(passedTime);
			_juggler.advanceTime(passedTime);
			_touchProcessor.advanceTime(passedTime);
			
			Render2DRenderSupport.clear(_stage2D.color, 1.0);
			_support.setOrthographicProjection(_stage2D.stageWidth, _stage2D.stageHeight);
			_stage2D.renderWithSupport(_support, 1.0);
			_support.finishQuadBatch();
			_support.nextFrame();
			_context.present();
		}
		
		
		/**
		 * @private
		 */
		private function updateNativeOverlay():void
		{
			_nativeOverlay.x = _viewPort.x;
			_nativeOverlay.y = _viewPort.y;
			_nativeOverlay.scaleX = _viewPort.width / _stage2D.stageWidth;
			_nativeOverlay.scaleY = _viewPort.height / _stage2D.stageHeight;
			
			// Having a native overlay on top of Stage3D content can cause a performance hit on
			// some environments. For that reason, we add it only to the stage while it's not empty.
			var numChildren:int = _nativeOverlay.numChildren;
			var parent:DisplayObject = _nativeOverlay.parent;

			if (numChildren != 0 && !parent) _stage.addChild(_nativeOverlay);
			else if (numChildren == 0 && parent) _stage.removeChild(_nativeOverlay);
		}
		
		
		/**
		 * @private
		 * 
		 * @param message
		 */
		private function showOnScreenError(message:String):void
		{
			var textField:TextField = new TextField();
			var textFormat:TextFormat = new TextFormat("Verdana", 12, 0xFFFFFF);
			textFormat.align = TextFormatAlign.CENTER;
			textField.defaultTextFormat = textFormat;
			textField.wordWrap = true;
			textField.width = _stage2D.stageWidth * 0.75;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = message;
			textField.x = (_stage2D.stageWidth - textField.width) / 2;
			textField.y = (_stage2D.stageHeight - textField.height) / 2;
			textField.background = true;
			textField.backgroundColor = 0x440000;
			nativeOverlay.addChild(textField);
		}
	}
}
