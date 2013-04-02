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
	import tetragon.Main;
	import tetragon.debug.IDrawCallsPollingSource;
	import tetragon.debug.Log;
	import tetragon.view.render2d.animation.Juggler2D;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.display.Stage2D;
	import tetragon.view.render2d.display.View2D;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.events.EventDispatcher2D;
	import tetragon.view.render2d.events.KeyboardEvent2D;
	import tetragon.view.render2d.events.ResizeEvent2D;
	import tetragon.view.render2d.filters.FragmentFilter2D;
	import tetragon.view.render2d.textures.Texture2D;
	import tetragon.view.render2d.touch.TouchPhase2D;
	import tetragon.view.render2d.touch.TouchProcessor2D;
	import tetragon.view.stage3d.Stage3DProxy;

	import com.hexagonstar.exception.FatalException;
	import com.hexagonstar.exception.SingletonException;

	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	
	
	/** Dispatched when a new render context is created. */
	[Event(name="context3DCreate", type="tetragon.view.render2d.events.Event2D")]
	/** Dispatched when the root class has been created. */
	[Event(name="rootCreated", type="tetragon.view.render2d.events.Event2D")]
	
	
	/**
	 * The Render2D class represents the core of the Render2D framework.
	 * <p>
	 * The Render2D framework makes it possible to create 2D applications and games that
	 * make use of the Stage3D architecture introduced in Flash Player 11. It implements a
	 * display tree system that is very similar to that of conventional Flash, while
	 * leveraging modern GPUs to speed up rendering.
	 * </p>
	 * <p>
	 * The Render2D class represents the link between the conventional Flash display tree
	 * and the Render2D display tree. To create a Render2D-powered application, you have
	 * to create an instance of the Render2D class:
	 * </p>
	 * 
	 * <pre>var Render2D:Render2D = new Render2D(Game, stage);</pre>
	 * <p>
	 * The first parameter has to be a Render2D display object class, e.g. a subclass of
	 * <code>Render2D.display.Sprite</code>. In the sample above, the class "Game" is the
	 * application root. An instance of "Game" will be created as soon as Render2D is
	 * initialized. The second parameter is the conventional (Flash) stage object. Per
	 * default, Render2D will display its contents directly below the stage.
	 * </p>
	 * <p>
	 * It is recommended to store the Render2D instance as a member variable, to make sure
	 * that the Garbage Collector does not destroy it. After creating the Render2D object,
	 * you have to start it up like this:
	 * </p>
	 * 
	 * <pre>Render2D.start();</pre>
	 * <p>
	 * It will now render the contents of the "Game" class in the frame rate that is set
	 * up for the application (as defined in the Flash stage).
	 * </p>
	 * <strong>Accessing the Render2D object</strong>
	 * <p>
	 * From within your application, you can access the current Render2D object anytime
	 * through the static method <code>Render2D.current</code>. It will return the active
	 * Render2D instance (most applications will only have one Render2D object, anyway).
	 * </p>
	 * <strong>Viewport</strong>
	 * <p>
	 * The area the Render2D content is rendered into is, per default, the complete size
	 * of the stage. You can, however, use the "viewPort" property to change it. This can
	 * be useful when you want to render only into a part of the screen, or if the player
	 * size changes. For the latter, you can listen to the RESIZE-event dispatched by the
	 * Render2D stage.
	 * </p>
	 * <strong>Native overlay</strong>
	 * <p>
	 * Sometimes you will want to display native Flash content on top of Render2D. That's
	 * what the <code>nativeOverlay</code> property is for. It returns a Flash Sprite
	 * lying directly on top of the Render2D content. You can add conventional Flash
	 * objects to that overlay.
	 * </p>
	 * <p>
	 * Beware, though, that conventional Flash content on top of 3D content can lead to
	 * performance penalties on some (mobile) platforms. For that reason, always remove
	 * all child objects from the overlay when you don't need them any longer. Render2D
	 * will remove the overlay from the display list when it's empty.
	 * </p>
	 * <strong>Multitouch</strong>
	 * <p>
	 * Render2D supports multitouch input on devices that provide it. During development,
	 * where most of us are working with a conventional mouse and keyboard, Render2D can
	 * simulate multitouch events with the help of the "Shift" and "Ctrl" (Mac: "Cmd")
	 * keys. Activate this feature by enabling the <code>simulateMultitouch</code>
	 * property.
	 * </p>
	 * <strong>Handling a lost render context</strong>
	 * <p>
	 * On some operating systems and under certain conditions (e.g. returning from system
	 * sleep), Render2D's stage3D render context may be lost. Render2D can recover from a
	 * lost context if the class property "handleLostContext" is set to "true". Keep in
	 * mind, however, that this comes at the price of increased memory consumption;
	 * Render2D will cache textures in RAM to be able to restore them when the context is
	 * lost.
	 * </p>
	 * <p>
	 * In case you want to react to a context loss, Render2D dispatches an event with the
	 * type "Event.CONTEXT3D_CREATE" when the context is restored. You can recreate any
	 * invalid resources in a corresponding event listener.
	 * </p>
	 * <strong>Sharing a 3D Context</strong>
	 * <p>
	 * Per default, Render2D handles the Stage3D context independently. If you want to
	 * combine Render2D with another Stage3D engine, however, this may not be what you
	 * want. In this case, you can make use of the <code>shareContext</code> property:
	 * </p>
	 * <ol>
	 * <li>Manually create and configure a context3D object that both frameworks can work
	 * with (through <code>stage3D.requestContext3D</code> and
	 * <code>context.configureBackBuffer</code>).</li>
	 * <li>Initialize Render2D with the stage3D instance that contains that configured
	 * context. This will automatically enable <code>shareContext</code>.</li>
	 * <li>Call <code>start()</code> on your Render2D instance (as usual). This will make
	 * Render2D queue input events (keyboard/mouse/touch).</li>
	 * <li>Create a game loop (e.g. using the native <code>ENTER_FRAME</code> event) and
	 * let it call Render2D's <code>nextFrame</code> as well as the equivalent method of
	 * the other Stage3D engine. Surround those calls with <code>context.clear()</code>
	 * and <code>context.present()</code>.</li>
	 * </ol>
	 */
	public class Render2D extends EventDispatcher2D implements IDrawCallsPollingSource
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** The version of the Render2D framework. */
		public static const VERSION:String = "1.3";
		
		/** The key for the shader programs stored in 'contextData' */
		private static const PROGRAM_DATA_NAME:String = "render2d.programs";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _instance:Render2D;
		/** @private */
		private static var _singletonLock:Boolean;
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _nativeStage:Stage;
		/** @private */
		private var _stage3DProxy:Stage3DProxy;
		/** @private */
		private var _stage3D:Stage3D;
		/** @private */
		private var _stage2D:Stage2D;
		/** @private */
		private static var _context:Context3D;
		
		/** @private */
		private var _rootView:View2D;
		
		/** @private */
		private var _juggler:Juggler2D;
		/** @private */
		private var _renderSupport:RenderSupport2D;
		/** @private */
		private var _touchProcessor:TouchProcessor2D;
		
		/** @private */
		private var _viewPort:Rectangle;
		/** @private */
		private var _previousViewPort:Rectangle;
		/** @private */
		private var _clippedViewPort:Rectangle;
		
		/** @private */
		private var _profile:String;
		/** @private */
		private var _antiAliasing:int;
		/** @private */
		private var _lastFrameTimestamp:Number;
		
		/** @private */
		internal var _drawCount:uint;
		/** @private */
		private var _started:Boolean;
		/** @private */
		private var _simulateMultitouch:Boolean;
		/** @private */
		private var _leftMouseDown:Boolean;
		/** @private */
		private var _shareContext:Boolean;
		
		/** @private */
		private static var _contextData:Dictionary;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Render2D instance.
		 */
		public function Render2D()
		{
			if (!_singletonLock) throw new SingletonException(this);
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes all children of the stage and the render context; removes all registered
		 * event listeners.
		 */
		public function dispose():void
		{
			stop();
			
			_nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			_nativeStage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
			_nativeStage.removeEventListener(Event.RESIZE, onResize);
			_nativeStage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			
			for each (var touchEventType:String in touchEventTypes)
			{
				_nativeStage.removeEventListener(touchEventType, onTouch);
			}
			
			if (_stage2D) _stage2D.dispose();
			if (_renderSupport) _renderSupport.dispose();
			if (_touchProcessor) _touchProcessor.dispose();
			if (_context && !_shareContext) _context.dispose();
		}
		
		
		/**
		 * Disposes and removes all children of the Render2D stage but not the stage itself,
		 * so that the Render2D instance can be re-used afterwards.
		 * 
		 * This also clears the Stage3D backbuffer.
		 */
		public function purge():void
		{
			if (_stage2D) _stage2D.removeChildren(0, -1, true);
			if (_stage3DProxy)
			{
				_stage3DProxy.clear();
				_stage3DProxy.present();
			}
			_drawCount = 0;
		}
		
		
		/**
		 * Calls <code>advanceTime()</code> (with the time that has passed since the last
		 * frame) and <code>render()</code>.
		 */
		public function nextFrame():void
		{
			var now:Number = getTimer() / 1000.0;
			var passedTime:Number = now - _lastFrameTimestamp;
			_lastFrameTimestamp = now;
			
			advanceTime(passedTime);
			nextRender();
		}
		
		
		/**
		 * Dispatches ENTER_FRAME events on the display list, advances the Juggler and
		 * processes touches.
		 */
		public function advanceTime(passedTime:Number):void
		{
			_touchProcessor.advanceTime(passedTime);
			_stage2D.advanceTime(passedTime);
			_juggler.advanceTime(passedTime);
		}
		
		
		/**
		 * Renders the complete display list. Before rendering, the context is cleared;
		 * afterwards, it is presented. This can be avoided by enabling
		 * <code>shareContext</code>.
		 */
		public function nextRender():void
		{
			if (!contextValid) return;
			
			updateViewPort();
			_renderSupport.nextFrame();
			
			if (!_shareContext) RenderSupport2D.clear(_stage2D.color, 1.0);
			
			var scaleX:Number = _viewPort.width / _stage2D.stageWidth;
			var scaleY:Number = _viewPort.height / _stage2D.stageHeight;
			
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_context.setCulling(Context3DTriangleFace.NONE);
			
			_renderSupport.renderTarget = null;
			_renderSupport.setOrthographicProjection(
				_viewPort.x < 0 ? -_viewPort.x / scaleX : 0.0,
				_viewPort.y < 0 ? -_viewPort.y / scaleY : 0.0,
				_clippedViewPort.width / scaleX,
				_clippedViewPort.height / scaleY);
			
			_stage2D.render(_renderSupport, 1.0);
			_renderSupport.finishQuadBatch();
			
			if (!_shareContext) _context.present();
		}
		
		
		/**
		 * As soon as Render2D is started, it will queue input events (keyboard/mouse/touch);
		 * furthermore, the method <code>nextFrame</code> will be called once per Flash Player
		 * frame. (Except when <code>shareContext</code> is enabled: in that case, you have to
		 * call that method manually.)
		 */
		public function start():void
		{
			_started = true;
			_lastFrameTimestamp = getTimer() / 1000.0;
		}
		
		
		/**
		 * Stops all logic processing and freezes the rendering in its current state. The content
		 * is still being rendered once per frame, though, because otherwise the conventional
		 * display list would no longer be updated.
		 */
		public function stop():void
		{
			_started = false;
		}
		
		
		/**
		 * 
		 */
		public function render():void
		{
			/* On mobile, the native display list is only updated on stage3D draw calls.
			 * Thus, we render even when Render2D is paused. */
			if (_started) nextFrame();
			else nextRender();
		}
		
		
		/**
		 * Registers a vertex- and fragment-program under a certain name. If the name was
		 * already used, the previous program is overwritten.
		 * 
		 * @param name
		 * @param vertexProgram
		 * @param fragmentProgram
		 */
		public function registerProgram(name:String, vertexProgram:ByteArray,
			fragmentProgram:ByteArray):void
		{
			deleteProgram(name);
			
			var program:Program3D = _context.createProgram();
			program.upload(vertexProgram, fragmentProgram);
			programs[name] = program;
		}
		
		
		/**
		 * Deletes the vertex- and fragment-programs of a certain name.
		 * 
		 * @param name
		 */
		public function deleteProgram(name:String):void
		{
			var program:Program3D = getProgram(name);
			if (!program) return;
			program.dispose();
			delete programs[name];
		}
		
		
		/**
		 * Returns the vertex- and fragment-programs registered under a certain name.
		 * 
		 * @param name
		 */
		public function getProgram(name:String):Program3D
		{
			return programs[name];
		}
		
		
		/**
		 * Indicates if a set of vertex- and fragment-programs is registered under a
		 * certain name.
		 * 
		 * @param name
		 */
		public function hasProgram(name:String):Boolean
		{
			return name in programs;
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
		 * Returns the singleton instance of the class.
		 */
		public static function get instance():Render2D
		{
			if (_instance == null)
			{
				_singletonLock = true;
				_instance = new Render2D();
				_singletonLock = false;
			}
			return _instance;
		}
		
		
		/**
		 * Indicates if a context is available and non-disposed.
		 */
		private function get contextValid():Boolean
		{
			return (_context && _context.driverInfo != "Disposed");
		}


		/**
		 * Indicates if this Render2D instance is started.
		 */
		public function get started():Boolean
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
		 * A dictionary that can be used to save custom data related to the current context.
		 * If you need to share data that is bound to a specific stage3D instance (e.g.
		 * textures), use this dictionary instead of creating a static class variable. The
		 * Dictionary is actually bound to the stage3D instance, thus it survives a context
		 * loss.
		 */
		public function get contextData():Dictionary
		{
			return _contextData[_stage3D];
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
			if (v == _antiAliasing) return;
			_antiAliasing = v;
			if (contextValid) updateViewPort(true);
		}
		
		
		/**
		 * The viewport into which Render2D contents will be rendered.
		 */
		public function get viewPort():Rectangle
		{
			return _viewPort;
		}
		public function set viewPort(v:Rectangle):void
		{
			_viewPort = v.clone();
		}
		
		
		/**
		 * The ratio between viewPort width and stage width. Useful for choosing a different
		 * set of textures depending on the display resolution.
		 */
		public function get contentScaleFactor():Number
		{
			return _viewPort.width / _stage2D.stageWidth;
		}
		
		
		/**
		 * The Render2D stage object, which is the root of the display tree that
		 * is rendered.
		 */
		public function get stage2D():Stage2D
		{
			return _stage2D;
		}
		
		
		/**
		 * The Flash Stage3D object Render2D renders into.
		 */
		public function get stage3D():Stage3D
		{
			return _stage3D;
		}


		/**
		 * The Flash native stage object that Render2D renders beneath.
		 */
		public function get nativeStage():Stage
		{
			return _nativeStage;
		}
		
		
		/**
		 * Allows to get and set the root view after Render2D has been instantiated.
		 * Note that the rootview can only be set once!
		 */
		public function get rootView():View2D
		{
			return _rootView;
		}
		public function set rootView(v:View2D):void
		{
			if (_rootView)
			{
				_stage2D.removeChild(_rootView);
				_rootView = null;
			}
			if (v)
			{
				_rootView = v;
				_stage2D.addChildAt(_rootView, 0);
				dispatchEventWith(Event2D.ROOT_CREATED, false, _rootView);
			}
		}
		
		
		/**
		 * Indicates if the Context3D render calls are managed externally to Render2D, to
		 * allow other frameworks to share the Stage3D instance.
		 * 
		 * @default false
		 */
		public function get shareContext():Boolean
		{
			return _shareContext;
		}
		public function set shareContext(v:Boolean):void
		{
			_shareContext = v;
		}
		
		
		/**
		 * The Context3D profile as requested in the constructor. Beware that if you are using
		 * a shared context, this might not be accurate. Possible values are:
		 * 
		 * baseline
		 * baselineConstrained
		 * 
		 * @default baselineConstrained
		 */
		public function get profile():String
		{
			return _profile;
		}
		public function set profile(v:String):void
		{
			if (v == _profile) return;
			_profile = v;
			if (contextValid) updateViewPort(true);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get drawCount():uint
		{
			return _drawCount;
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
			Multitouch.inputMode = v
				? MultitouchInputMode.TOUCH_POINT
				: MultitouchInputMode.NONE;
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
		
		
		/**
		 * @private
		 */
		private function get programs():Dictionary
		{
			return contextData[PROGRAM_DATA_NAME];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onKey(e:KeyboardEvent):void
		{
			if (!_started) return;
			_stage2D.dispatchEvent(new KeyboardEvent2D(e.type, e.charCode, e.keyCode,
				e.keyLocation, e.ctrlKey, e.altKey, e.shiftKey));
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
		private function onMouseLeave(e:Event):void
		{
			_touchProcessor.enqueueMouseLeftStage();
		}


		/**
		 * @private
		 */
		private function onTouch(e:Event):void
		{
			if (!_started) return;
			
			var globalX:Number;
			var globalY:Number;
			var touchID:int;
			var phase:String;
			var pressure:Number = 1.0;
			var width:Number = 1.0;
			var height:Number = 1.0;
			
			/* Figure out general touch properties. */
			if (e is MouseEvent)
			{
				var mouseEvent:MouseEvent = e as MouseEvent;
				globalX = mouseEvent.stageX;
				globalY = mouseEvent.stageY;
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
				pressure = touchEvent.pressure;
				width = touchEvent.sizeX;
				height = touchEvent.sizeY;
			}
			
			/* Figure out touch phase. */
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
			
			/* Move position into viewport bounds. */
			globalX = _stage2D.stageWidth * (globalX - _viewPort.x) / _viewPort.width;
			globalY = _stage2D.stageHeight * (globalY - _viewPort.y) / _viewPort.height;
			
			/* Enqueue touch in touch processor. */
			_touchProcessor.enqueue(touchID, phase, globalX, globalY, pressure, width, height);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			_main = Main.instance;
			_nativeStage = _main.stage;
			_stage3DProxy = _main.screenManager.stage3DProxy;
			
			if (!_stage3DProxy)
			{
				throw new FatalException("Stage3DProxy is not available! Is hardware"
					+ " rendering enabled?");
			}
			
			/* Set shortcut to render2D instance in often used classes for faster access. */
			DisplayObject2D.render2D =
			FragmentFilter2D.render2D =
			Texture2D.render2D = this;
			
			/* Register renderer for draw calls polling on Tetragon's stats monitor. */
			if (_main.statsMonitor) _main.statsMonitor.registerDrawCallsPolling(this);
			
			_stage3D = _stage3DProxy.stage3D;
			_viewPort = new Rectangle(0, 0, _stage3DProxy.width, _stage3DProxy.height);
			_previousViewPort = new Rectangle();
			_stage2D = new Stage2D(_stage3DProxy.width, _stage3DProxy.height, _stage3DProxy.color);
			_touchProcessor = new TouchProcessor2D(_stage2D);
			_juggler = new Juggler2D();
			_renderSupport = new RenderSupport2D(this);
			
			_drawCount = 0;
			_antiAliasing = 0;
			_simulateMultitouch = false;
			_profile = "baselineConstrained";
			_lastFrameTimestamp = getTimer() / 1000.0;
			
			/* For context data, we actually reference by stage3D, since it survives
			 * a context loss. */
			if (!_contextData) _contextData = new Dictionary(true);
			_contextData[stage3D] = new Dictionary();
			_contextData[stage3D][PROGRAM_DATA_NAME] = new Dictionary();
			
			/* Register touch/mouse event handlers. */
			for each (var touchEventType:String in touchEventTypes)
			{
				_nativeStage.addEventListener(touchEventType, onTouch);
			}
			
			/* Register other event handlers. */
			_nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			_nativeStage.addEventListener(KeyboardEvent.KEY_UP, onKey);
			_nativeStage.addEventListener(Event.RESIZE, onResize);
			_nativeStage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			
			/* If we already got a context3D and it's not disposed. */
			if (RenderSupport2D.context3D && RenderSupport2D.context3D.driverInfo != "Disposed")
			{
				_context = RenderSupport2D.context3D;
				contextData[PROGRAM_DATA_NAME] = new Dictionary();
				updateViewPort(true);
				Log.verbose("Render2D System v" + VERSION + " initialized.", this);
				dispatchEventWith(Event2D.CONTEXT3D_CREATE, false, _context);
				
				_touchProcessor.simulateMultitouch = _simulateMultitouch;
			}
			else
			{
				Log.fatal("Stage3DProxy has no context!", this);
			}
		}
		
		
		/**
		 * @private
		 */
		private function updateViewPort(updateAliasing:Boolean = false):void
		{
			/* The last set viewport is stored in a variable; that way, people can modify the
			 * viewPort directly (without a copy) and we still know if it has changed. */
			if (updateAliasing
				|| _previousViewPort.width != _viewPort.width
				|| _previousViewPort.height != _viewPort.height
				|| _previousViewPort.x != _viewPort.x
				|| _previousViewPort.y != _viewPort.y)
			{
				_previousViewPort.setTo(_viewPort.x, _viewPort.y, _viewPort.width, _viewPort.height);

				// Constrained mode requires that the viewport is within the native stage bounds;
				// thus, we use a clipped viewport when configuring the back buffer. (In baseline
				// mode, that's not necessary, but it does not hurt either.)
				_clippedViewPort = _viewPort.intersection(new Rectangle(0, 0, _nativeStage.stageWidth,
					_nativeStage.stageHeight));
				
				if (!_shareContext)
				{
					// setting x and y might move the context to invalid bounds (since changing
					// the size happens in a separate operation) -- so we have no choice but to
					// set the backbuffer to a very small size first, to be on the safe side.
					if (_profile == "baselineConstrained")
					{
						_renderSupport.configureBackBuffer(32, 32, _antiAliasing, false);
					}
					
					_stage3D.x = _clippedViewPort.x;
					_stage3D.y = _clippedViewPort.y;
					
					_renderSupport.configureBackBuffer(_clippedViewPort.width,
						_clippedViewPort.height, _antiAliasing, false);
				}
				else
				{
					_renderSupport.backBufferWidth = _clippedViewPort.width;
					_renderSupport.backBufferHeight = _clippedViewPort.height;
				}
			}
		}
	}
}
