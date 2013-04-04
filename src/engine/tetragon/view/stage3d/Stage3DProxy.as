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
package tetragon.view.stage3d
{
	import tetragon.debug.Log;

	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	[Event(name="enterFrame", type="flash.events.Event")]
	[Event(name="exitFrame", type="flash.events.Event")]
	
	
	/**
	 * Stage3DProxy provides a proxy class to manage a single Stage3D instance as well as
	 * handling the creation and attachment of the Context3D (and in turn the back buffer)
	 * it uses. Stage3DProxy should never be created directly, but requested through
	 * Stage3DManager.
	 */
	public class Stage3DProxy
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		//private static var _frameEventDriver:Shape;
		private static var _enableErrorChecking:Boolean;
		
		private var _stage3D:Stage3D;
		private var _context3D:Context3D;
		private var _activeProgram3D:Program3D;
		private var _stage3DManager:Stage3DManager;
		private var _renderTarget:TextureBase;
		
		private var _activeVertexBuffers:Vector.<VertexBuffer3D>;
		private var _activeTextures:Vector.<TextureBase>;
		
		private var _viewPort:Rectangle;
		private var _scissorRect:Rectangle;
		
		private var _stage3DIndex:int = -1;
		private var _backBufferWidth:int;
		private var _backBufferHeight:int;
		private var _antiAlias:int;
		private var _renderSurfaceSelector:int;
		private var _color:uint;
		
		private var _enterFrame:Event;
		private var _exitFrame:Event;
		
		private var _forceSoftware:Boolean;
		private var _usesSoftwareRendering:Boolean;
		private var _enableDepthAndStencil:Boolean;
		private var _contextRequested:Boolean;
		private var _backBufferDirty:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		private var _stage3DSignal:Stage3DSignal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a Stage3DProxy object. This method should not be called directly. Creation
		 * of Stage3DProxy objects should be handled by Stage3DManager.
		 * 
		 * @param stage3DIndex The index of the Stage3D to be proxied.
		 * @param stage3D The Stage3D to be proxied.
		 * @param stage3DManager
		 * @param forceSoftware Whether to force software mode even if hardware acceleration
		 *            is available.
		 */
		public function Stage3DProxy(stage3DIndex:int, stage3D:Stage3D,
			stage3DManager:Stage3DManager, forceSoftware:Boolean = false)
		{
			//if (!_frameEventDriver) _frameEventDriver = new Shape();
			
			_stage3DIndex = stage3DIndex;
			_stage3D = stage3D;
			_stage3DManager = stage3DManager;
			_forceSoftware = forceSoftware;
			
			_stage3D.x = 0;
			_stage3D.y = 0;
			_stage3D.visible = true;
			_viewPort = new Rectangle();
			_enableDepthAndStencil = false;
			
			_activeVertexBuffers = new Vector.<VertexBuffer3D>(8, true);
			_activeTextures = new Vector.<TextureBase>(8, true);
			
			_enterFrame = new Event(Event.ENTER_FRAME);
			_exitFrame = new Event(Event.EXIT_FRAME);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Requests a Context3D object to attach to the managed Stage3D.
		 */
		public function requestContext3D():void
		{
			if (_contextRequested) return;
			_contextRequested = true;
			
			/* Whatever happens, be sure this has highest priority. */
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DUpdate, false, 1000);
			
			// If forcing software, we can be certain that the
			// returned Context3D will be running software mode.
			// If not, we can't be sure and should stick to the
			// old value (will likely be same if re-requesting.)
			_usesSoftwareRendering ||= _forceSoftware;
			
			try
			{
				_stage3D.requestContext3D(_forceSoftware
					? Context3DRenderMode.SOFTWARE
					: Context3DRenderMode.AUTO);
			}
			catch (err:Error)
			{
				_contextRequested = false;
				Log.fatal("Error requesting Context3D: " + err.message, this);
			}
		}
		
		
		/**
		 * Assign the vertex buffer in the Context3D ready for use in the shader.
		 * 
		 * @param index The index for the vertex buffer setting
		 * @param buffer The Vertex Buffer 
		 * @param format The format of the buffer. See Context3DVertexBufferFormat
		 * @param offset An offset from the start of the data
		 */
		public function setSimpleVertexBuffer(index:int, buffer:VertexBuffer3D, format:String,
			offset:int = 0):void
		{
			// force setting null
			if (buffer && _activeVertexBuffers[index] == buffer) return;
			_context3D.setVertexBufferAt(index, buffer, offset, format);
			_activeVertexBuffers[index] = buffer;
		}
		
		
		/**
		 * Assign the texture in the Context3D ready for use in the shader.
		 * 
		 * @param index The index where the texture is set
		 * @param texture The texture to set
		 */
		public function setTextureAt(index:int, texture:TextureBase):void
		{
			if (texture && _activeTextures[index] == texture) return;
			_context3D.setTextureAt(index, texture);
			_activeTextures[index] = texture;
		}
		
		
		/**
		 * Set the shader program for the subsequent rendering calls.
		 * 
		 * @param program3D The program to be used in the shader
		 */
		public function setProgram(program3D:Program3D):void
		{
			if (_activeProgram3D == program3D) return;
			_context3D.setProgram(program3D);
			_activeProgram3D = program3D;
		}
		
		
		/**
		 * Disposes the Stage3DProxy object, freeing the Context3D attached to the Stage3D.
		 */
		public function dispose():void
		{
			_stage3DManager.removeStage3DProxy(this);
			_stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContext3DUpdate);
			freeContext3D();
			_stage3D = null;
			_stage3DManager = null;
			_stage3DIndex = -1;
		}
		
		
		/**
		 * Configures the back buffer associated with the Stage3D object.
		 * 
		 * @param backBufferWidth The width of the backbuffer.
		 * @param backBufferHeight The height of the backbuffer.
		 * @param antiAlias The amount of anti-aliasing to use.
		 * @param enableDepthAndStencil Indicates whether the back buffer contains
		 *        a depth and stencil buffer.
		 */
		public function configureBackBuffer(backBufferWidth:int, backBufferHeight:int,
			antiAlias:int, enableDepthAndStencil:Boolean):void
		{
			_backBufferWidth = backBufferWidth;
			_backBufferHeight = backBufferHeight;
			_antiAlias = antiAlias;
			_enableDepthAndStencil = enableDepthAndStencil;

			if (!_context3D) return;
			
			_context3D.configureBackBuffer(backBufferWidth, backBufferHeight, antiAlias,
				enableDepthAndStencil);
		}
		
		
		/**
		 * Clear and reset the back buffer when using a shared context.
		 */
		public function clear():void
		{
			if (!_context3D) return;
			if (_backBufferDirty)
			{
				configureBackBuffer(_backBufferWidth, _backBufferHeight, _antiAlias,
					_enableDepthAndStencil);
				_backBufferDirty = false;
			}
			
			_context3D.clear((
			(_color >> 16) & 0xFF) / 255.0,
			((_color >> 8) & 0xFF) / 255.0,
			(_color & 0xFF) / 255.0,
			((_color >> 24) & 0xFF) / 255.0);
		}
		
		
		/**
		 * Display the back rendering buffer.
		 */
		public function present():void
		{
			if (!_context3D) return;
			_context3D.present();
			_activeProgram3D = null;
		}
		
		
		/**
		 * Registers an event listener object with an EventDispatcher object so that the
		 * listener receives notification of an event. Special case for enterframe and
		 * exitframe events - will switch Stage3DProxy into automatic render mode. You can
		 * register event listeners on all nodes in the display list for a specific type
		 * of event, phase, and priority.
		 * 
		 * @param type The type of event.
		 * @param listener The listener function that processes the event.
		 * @param useCapture Determines whether the listener works in the capture phase or
		 *            the target and bubbling phases. If useCapture is set to true, the
		 *            listener processes the event only during the capture phase and not
		 *            in the target or bubbling phase. If useCapture is false, the
		 *            listener processes the event only during the target or bubbling
		 *            phase. To listen for the event in all three phases, call
		 *            addEventListener twice, once with useCapture set to true, then again
		 *            with useCapture set to false.
		 * @param priority The priority level of the event listener. The priority is
		 *            designated by a signed 32-bit integer. The higher the number, the
		 *            higher the priority. All listeners with priority n are processed
		 *            before listeners of priority n-1. If two or more listeners share the
		 *            same priority, they are processed in the order in which they were
		 *            added. The default priority is 0.
		 * @param useWeakReference Determines whether the reference to the listener is
		 *            strong or weak. A strong reference (the default) prevents your
		 *            listener from being garbage-collected. A weak reference does not.
		 */
		//public override function addEventListener(type:String, listener:Function,
		//	useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		//{
		//	super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		//	if ((type == Event.ENTER_FRAME || type == Event.EXIT_FRAME)
		//		&& !_frameEventDriver.hasEventListener(Event.ENTER_FRAME))
		//	{
		//		_frameEventDriver.addEventListener(Event.ENTER_FRAME, onEnterFrame, useCapture,
		//			priority, useWeakReference);
		//	}
		//}
		
		
		/**
		 * Removes a listener from the EventDispatcher object. Special case for enterframe
		 * and exitframe events - will switch Stage3DProxy out of automatic render mode.
		 * If there is no matching listener registered with the EventDispatcher object, a
		 * call to this method has no effect.
		 * 
		 * @param type The type of event.
		 * @param listener The listener object to remove.
		 * @param useCapture Specifies whether the listener was registered for the capture
		 *            phase or the target and bubbling phases. If the listener was
		 *            registered for both the capture phase and the target and bubbling
		 *            phases, two calls to removeEventListener() are required to remove
		 *            both, one call with useCapture() set to true, and another call with
		 *            useCapture() set to false.
		 */
		//public override function removeEventListener(type:String, listener:Function,
		//	useCapture:Boolean = false):void
		//{
		//	super.removeEventListener(type, listener, useCapture);
		//	// Remove the main rendering listener if no EnterFrame listeners remain
		//	if (!hasEventListener(Event.ENTER_FRAME) && !hasEventListener(Event.EXIT_FRAME)
		//		&& _frameEventDriver.hasEventListener(Event.ENTER_FRAME))
		//	{
		//		_frameEventDriver.removeEventListener(Event.ENTER_FRAME, onEnterFrame, useCapture);
		//	}
		//}
		
		
		public function resize(width:int, height:int):void
		{
			this.width = width;
			this.height = height;
			if (_stage3DSignal) _stage3DSignal.dispatch(Stage3DSignal.RESIZE);
		}
		
		
		/**
		 * setRenderTarget
		 * 
		 * @param target
		 * @param enableDepthAndStencil
		 * @param surfaceSelector
		 */
		public function setRenderTarget(target:TextureBase, enableDepthAndStencil:Boolean = false,
			surfaceSelector:int = 0):void
		{
			if (_renderTarget == target && surfaceSelector == _renderSurfaceSelector
				&& _enableDepthAndStencil == enableDepthAndStencil)
			{
				return;
			}
			
			_renderTarget = target;
			_renderSurfaceSelector = surfaceSelector;
			_enableDepthAndStencil = enableDepthAndStencil;
			
			if (target)
			{
				_context3D.setRenderToTexture(target, enableDepthAndStencil, _antiAlias,
					surfaceSelector);
			}
			else
			{
				_context3D.setRenderToBackBuffer();
			}
		}
		
		
		/**
		 * recoverFromDisposal
		 */
		public function recoverFromDisposal():Boolean
		{
			if (!_context3D) return false;
			if (_context3D.driverInfo == "Disposed")
			{
				_context3D = null;
				if (_stage3DSignal) _stage3DSignal.dispatch(Stage3DSignal.CONTEXT3D_DISPOSED);
				return false;
			}
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates whether the depth and stencil buffer is used
		 */
		public function get enableDepthAndStencil():Boolean
		{
			return _enableDepthAndStencil;
		}
		public function set enableDepthAndStencil(v:Boolean):void
		{
			_enableDepthAndStencil = v;
			_backBufferDirty = true;
		}
		
		
		public function get renderTarget():TextureBase
		{
			return _renderTarget;
		}
		
		
		public function get renderSurfaceSelector():int
		{
			return _renderSurfaceSelector;
		}
		
		
		public function get scissorRect():Rectangle
		{
			return _scissorRect;
		}
		public function set scissorRect(v:Rectangle):void
		{
			_scissorRect = v;
			_context3D.setScissorRectangle(_scissorRect);
		}
		
		
		/**
		 * The index of the Stage3D which is managed by this instance of Stage3DProxy.
		 */
		public function get stage3DIndex():int
		{
			return _stage3DIndex;
		}
		
		
		/**
		 * The base Stage3D object associated with this proxy.
		 */
		public function get stage3D():Stage3D
		{
			return _stage3D;
		}
		
		
		/**
		 * The Context3D object associated with the given Stage3D object.
		 */
		public function get context3D():Context3D
		{
			return _context3D;
		}
		
		
		/**
		 * The driver information as reported by the Context3D object (if any)
		 */
		public function get driverInfo():String
		{
			return _context3D ? _context3D.driverInfo : null;
		}
		
		
		/**
		 * Indicates whether the Stage3D managed by this proxy is running in software mode.
		 * Remember to wait for the CONTEXT3D_CREATED event before checking this property,
		 * as only then will it be guaranteed to be accurate.
		 */
		public function get usesSoftwareRendering():Boolean
		{
			return _usesSoftwareRendering;
		}
		
		
		/**
		 * The x position of the Stage3D.
		 */
		public function get x():Number
		{
			return _stage3D.x;
		}
		public function set x(v:Number):void
		{
			_stage3D.x = _viewPort.x = v;
		}
		
		
		/**
		 * The y position of the Stage3D.
		 */
		public function get y():Number
		{
			return _stage3D.y;
		}
		public function set y(v:Number):void
		{
			_stage3D.y = _viewPort.y = v;
		}
		
		
		/**
		 * The width of the Stage3D.
		 */
		public function get width():int
		{
			return _backBufferWidth;
		}
		public function set width(v:int):void
		{
			_backBufferWidth = _viewPort.width = v;
			_backBufferDirty = true;
		}
		
		
		/**
		 * The height of the Stage3D.
		 */
		public function get height():int
		{
			return _backBufferHeight;
		}
		public function set height(v:int):void
		{
			_backBufferHeight = _viewPort.height = v;
			_backBufferDirty = true;
		}
		
		
		/**
		 * The antiAliasing of the Stage3D.
		 */
		public function get antiAlias():int
		{
			return _antiAlias;
		}
		public function set antiAlias(v:int):void
		{
			_antiAlias = v;
			_backBufferDirty = true;
		}
		
		
		/**
		 * A viewPort rectangle equivalent of the Stage3D size and position.
		 */
		public function get viewPort():Rectangle
		{
			return _viewPort;
		}
		
		
		/**
		 * The background color of the Stage3D.
		 */
		public function get color():uint
		{
			return _color;
		}
		public function set color(v:uint):void
		{
			_color = v;
		
		
		}
		/**
		 * The visibility of the Stage3D.
		 */
		public function get visible():Boolean
		{
			return _stage3D.visible;
		}
		public function set visible(v:Boolean):void
		{
			_stage3D.visible = v;
		}
		
		
		/**
		 * Determines global Context3D Error Checking.
		 * 
		 * @default false
		 */
		public static function get enableErrorChecking():Boolean
		{
			return _enableErrorChecking;
		}
		public static function set enableErrorChecking(v:Boolean):void
		{
			_enableErrorChecking = v;
		}
		
		
		public function get stage3DSignal():Stage3DSignal
		{
			if (!_stage3DSignal) _stage3DSignal = new Stage3DSignal();
			return _stage3DSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Called whenever the Context3D is retrieved or lost.
		 * @param event The event dispatched.
		 * 
		 * @private
		 */
		private function onContext3DUpdate(e:Event):void
		{
			if (_stage3D.context3D)
			{
				var hadContext:Boolean = (_context3D != null);
				_context3D = _stage3D.context3D;
				_context3D.enableErrorChecking = _enableErrorChecking;
				_usesSoftwareRendering = (_context3D.driverInfo.indexOf('Software') == 0);
				
				// Only configure back buffer if width and height have been set,
				// which they may not have been if View3D.render() has yet to be
				// invoked for the first time.
				if (_backBufferWidth && _backBufferHeight)
				{
					_context3D.configureBackBuffer(_backBufferWidth, _backBufferHeight,
						_antiAlias, _enableDepthAndStencil);
				}
				
				// Dispatch the appropriate event depending on whether context was
				// created for the first time or recreated after a device loss.
				if (_stage3DSignal)
				{
					_stage3DSignal.dispatch(hadContext
						? Stage3DSignal.CONTEXT3D_RECREATED
						: Stage3DSignal.CONTEXT3D_CREATED);
				}
			}
			else
			{
				throw new Error("Stage3D rendering context lost!");
			}
		}
		
		
		/**
		 * The Enter_Frame handler for processing the proxy.ENTER_FRAME and
		 * proxy.EXIT_FRAME event handlers. Typically the proxy.ENTER_FRAME listener would
		 * render the layers for this Stage3D instance.
		 * 
		 * @private
		 */
		//private function onEnterFrame(event:Event):void
		//{
		//	if (!_context3D) return;
		//	clear();
		//	notifyEnterFrame();
		//	present();
		//	notifyExitFrame();
		//}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		//private function notifyEnterFrame():void
		//{
		//	if (!hasEventListener(Event.ENTER_FRAME)) return;
		//	dispatchEvent(_enterFrame);
		//}
		
		
		/**
		 * @private
		 */
		//private function notifyExitFrame():void
		//{
		//	if (!hasEventListener(Event.EXIT_FRAME)) return;
		//	dispatchEvent(_exitFrame);
		//}
		
		
		/**
		 * Frees the Context3D associated with this Stage3DProxy.
		 * @private
		 */
		private function freeContext3D():void
		{
			if (!_context3D) return;
			_context3D.dispose();
			if (_stage3DSignal) _stage3DSignal.dispatch(Stage3DSignal.CONTEXT3D_DISPOSED);
			_context3D = null;
			_contextRequested = false;
		}
	}
}
