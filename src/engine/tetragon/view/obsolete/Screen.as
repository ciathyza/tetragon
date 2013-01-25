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
package tetragon.view.obsolete
{
	import tetragon.file.resource.Resource;
	import tetragon.file.resource.ResourceCollection;
	import tetragon.view.loadprogress.DebugLoadProgressDisplay;
	import tetragon.view.loadprogress.LoadProgressDisplay;

	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.signals.NativeSignal;
	import com.hexagonstar.signals.Signal;

	import flash.events.Event;
	
	
	/**
	 * The abstract base class for screens.
	 * 
	 * <p>
	 * In the Tetragon display hierarchy, screens are view classes that are used as the
	 * top level display containers which can contain other view object children. They
	 * represent the whole visible area of the Flash display stage and use child view
	 * objects to provide the user interface of a game or application.
	 * </p>
	 * 
	 * <p>
	 * Screens are managed by the screen manager from where they are opened and closed
	 * when needed. At any one time there is always only one screen open. To open another
	 * screen the screen manager first closes the screen that is currently open.
	 * </p>
	 * 
	 * <p>
	 * To create new screen classes you can extend this class and then override any
	 * abstract methods that might be required in your screen class.
	 * </p>
	 * 
	 * @see tetragon.view.View
	 * @see tetragon.view.ScreenManager
	 */
	public class Screen extends View
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _id:String;
		
		/**
		 * Keeps a list of IDs for resources that need to be loaded for this state.
		 * @private
		 */
		private var _resourceIDs:Array;
		
		/** @private */
		private var _resourceCount:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _loadProgressSignal:Signal;
		/** @private */
		private var _loadErrorSignal:Signal;
		/** @private */
		private var _resourceLoadedSignal:Signal;
		/** @private */
		private var _screenLoadedSignal:Signal;
		/** @private */
		private var _screenCreatedSignal:Signal;
		/** @private */
		private var _screenUnloadedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			screenManager.stageResizeSignal.remove(onStageResize);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signal that is dispatched while resources for the screen are being loaded.
		 */
		public function get loadProgressSignal():Signal
		{
			if (!_loadProgressSignal) _loadProgressSignal = new Signal();
			return _loadProgressSignal;
		}
		
		
		/**
		 * Signal that is dispatched if resources for the screen failed to load.
		 */
		public function get loadErrorSignal():Signal
		{
			if (!_loadErrorSignal) _loadErrorSignal = new Signal();
			return _loadErrorSignal;
		}
		
		
		/**
		 * Signal that is dispatched whenever a resource for the screen has been loaded.
		 */
		public function get resourceLoadedSignal():Signal
		{
			if (!_resourceLoadedSignal) _resourceLoadedSignal = new Signal();
			return _resourceLoadedSignal;
		}
		
		
		/**
		 * Signal that is dispatched after the screen's resources have been loaded.
		 */
		public function get screenLoadedSignal():Signal
		{
			if (!_screenLoadedSignal) _screenLoadedSignal = new Signal();
			return _screenLoadedSignal;
		}
		
		
		/**
		 * A signal that is dispatched when the screen has been created and is ready for
		 * being opened.
		 */
		public function get screenCreatedSignal():Signal
		{
			if (!_screenCreatedSignal) _screenCreatedSignal = new Signal();
			return _screenCreatedSignal;
		}
		
		
		/**
		 * Signal that is dispatched after the screen has been unloaded.
		 */
		public function get screenUnloadedSignal():Signal
		{
			if (!_screenUnloadedSignal) _screenUnloadedSignal = new Signal();
			return _screenUnloadedSignal;
		}
		
		
		/**
		 * Creates and returns a new load progress display for use with the screen.
		 */
		public function get loadProgressDisplay():LoadProgressDisplay
		{
			return new DebugLoadProgressDisplay();
		}
		
		
		/**
		 * Determines whether the screen will unload all it's loaded resources once it is
		 * closed. You can override this getter and return false for screens where you don't
		 * want resources to be unloaded, .e.g. for a dedicated resource preload screen.
		 * 
		 * @default true
		 */
		protected function get unload():Boolean
		{
			return true;
		}
		
		
		/**
		 * The number of resources that the screen has registered for loading.
		 */
		public function get resourceCount():uint
		{
			return _resourceCount;
		}
		
		
		/**
		 * Determines whether the screen's resources have already been loaded.
		 */
		public function get resourcesAlreadyLoaded():Boolean
		{
			return resourceManager.checkAllResourcesLoaded(_resourceIDs);
		}
		
		
		/**
		 * A reference to the screen manager for quick access in sub-classes.
		 * 
		 * @see tetragon.view.ScreenManager
		 */
		protected function get screenManager():ScreenManager
		{
			return main.screenManager;
		}
		
		
		/**
		 * The ID of the screen, used by screen manager. Read only!
		 */
		public function get id():String
		{
			return _id;
		}
		public function set id(v:String):void
		{
			if (_id) return;
			_id = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Internal Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Loads all resources that are registered for the screen.
		 * @private
		 */
		internal function loadScreen():void
		{
			if (!_resourceIDs || _resourceIDs.length < 1)
			{
				onResourceLoadComplete();
				return;
			}
			resourceManager.load(_resourceIDs, onResourceLoadComplete, onResourceLoaded,
				onResourceLoadError, onResourceProgress, onAlreadyLoaded);
		}
		
		
		/**
		 * Creates the screen and it's children. You never call this method manually.
		 * Instead the screen manager calls it right before the screen is being faded in.
		 * @private
		 */
		internal function createScreen():void
		{
			createChildren();
			registerChildren();
			addChildren();
			addListeners();
			executeOnChildren(EXEC_CREATE);
			
			/* Watch stage resizing for screens. */
			screenManager.stageResizeSignal.add(onStageResize);
			
			executeOnChildren(EXEC_BEFORE_START);
			executeBeforeStart();
			
			/* Wait one frame before showing the screen, using AS3 signal one-liner, yay! */
			(new NativeSignal(this, Event.ENTER_FRAME, Event)).addOnce(onFramePassed);
		}
		
		
		/**
		 * Unloads the screen. You never have to call this method manually. Instead
		 * the screen manager calls it after the screen has been closed.
		 * @private
		 */
		internal function unloadScreen():void
		{
			stop();
			dispose();
			unloadResources();
			if (_screenUnloadedSignal)
			{
				_screenUnloadedSignal.dispatch(this);
				_screenUnloadedSignal.removeAll();
				_screenUnloadedSignal = null;
			}
		}
		
		
		/**
		 * Used by the screen manmager to set the initial enabled state of the view.
		 * This is used instead of the enabled accessor to take the autoEnable property
		 * of child views into account, but only when opened by the screen manager.
		 * @private
		 */
		internal function setInitialEnabledState(enabled:Boolean):void
		{
			_enabled = enabled;
			if (_children)
			{
				var len:uint = _children.length;
				for (var i:uint = 0; i < len; i++)
				{
					var c:View = _children[i];
					if (!enabled) c.enabled = enabled;
					else if (c.autoEnable) c.enabled = enabled;
				}
			}
			if (_enabled) enableChildren();
			else disableChildren();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after a resource has been loaded for this screen.
		 * 
		 * <p>When overriding make sure to call super.onResourceLoaded().</p>
		 */
		protected function onResourceLoaded(resource:Resource):void
		{
			if (_resourceLoadedSignal) _resourceLoadedSignal.dispatch(resource);
		}
		
		
		/**
		 * Invoked if a resource for this screen has failed to load.
		 * 
		 * <p>When overriding make sure to call super.onResourceLoadError().</p>
		 */
		protected function onResourceLoadError(resource:Resource):void
		{
			if (_loadErrorSignal) _loadErrorSignal.dispatch(resource);
		}
		
		
		/**
		 * Invoked while a resource for this screen is being loaded.
		 */
		protected function onResourceProgress(progress:BulkProgress):void
		{
			if (_loadProgressSignal) _loadProgressSignal.dispatch(progress);
		}
		
		
		/**
		 * Invoked if all resources have already been loaded (or failed) before and
		 * don't need to be loaded again.
		 */
		protected function onAlreadyLoaded():void
		{
			onResourceLoadComplete();
		}
		
		
		/**
		 * Invoked after all resource loading for this screen has been completed.
		 */
		protected function onResourceLoadComplete():void
		{
			if (_loadProgressSignal)
			{
				_loadProgressSignal.dispatch(null);
				_loadProgressSignal.removeAll();
				_loadProgressSignal = null;
			}
			if (_screenLoadedSignal)
			{
				_screenLoadedSignal.dispatch();
				_screenLoadedSignal.removeAll();
				_screenLoadedSignal = null;
			}
		}
		
		
		/**
		 * Used to wait exatcly one frame after the display has been created and before
		 * the loaded event is broadcasted. This is used to prevent abrupt blend-ins.
		 * 
		 * @private
		 */
		private function onFramePassed(e:Event):void
		{
			if (_screenCreatedSignal)
			{
				_screenCreatedSignal.dispatch();
				_screenCreatedSignal.removeAll();
				_screenCreatedSignal = null;
			}
		}
		
		
		/**
		 * Invoked whenever the display stage is resized. By default this method calls the
		 * layoutChildren() method of the screen class. You can override it to replace
		 * this handler with custom code or to disabled it.
		 */
		protected function onStageResize():void
		{
			update();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the screen. Called right after instantiation. If you override this
		 * method you must call <code>super.setup()</code> in your overriden init method.
		 */
		override protected function setup():void
		{
			_screen = this;
			registerResources();
		}
		
		
		/**
		 * Registers resources for loading that are required for the screen.
		 * 
		 * <p>This is an abstract method. Override this method in your screen sub-class and
		 * register as many resources as you need for the screen. The resources are being
		 * preloaded before the screen is opened by the screen manager.</p>
		 * 
		 * @see tetragon.view.Screen#registerResource()
		 * 
		 * @example
		 * <pre>
		 *     registerResource("resource1");
		 *     registerResource("resource2");
		 * </pre>
		 */
		protected function registerResources():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Does nothing and can't be overriden! Screens should not have the createView method
		 * be called which is inherited from the View class!
		 * 
		 * @private
		 */
		override protected final function createView():void
		{
		}
		
		
		/**
		 * Registers a resource that is going to be loaded for the screen. All resources
		 * that are registered with their ID are being loaded before the screen is being
		 * opened. Call this method inside the overriden <code>registerResources()</code>
		 * method.
		 * 
		 * @see tetragon.view.Screen#registerResources()
		 */
		protected function registerResource(resourceID:String):void
		{
			if (!_resourceIDs)
			{
				_resourceIDs = [];
				_resourceCount = 0;
			}
			var collection:ResourceCollection = resourceIndex.getResourceCollection(resourceID);
			if (collection) _resourceCount += collection.size;
			else ++_resourceCount;
			_resourceIDs.push(resourceID);
		}
		
		
		/**
		 * Used to unload any resources that have been loaded for the screen. Called
		 * automatically after a screen has been closed.
		 * 
		 * <p>If the screen's unload property is set to false, the screen's loaded resources will
		 * not be unloaded after the screen closes.</p>
		 */
		protected function unloadResources():void
		{
			if (!unload || !_resourceIDs || _resourceIDs.length < 1) return;
			resourceManager.unload(_resourceIDs);
		}
	}
}
