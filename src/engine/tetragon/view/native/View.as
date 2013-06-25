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
package tetragon.view.native
{
	import tetragon.Main;
	import tetragon.data.Registry;
	import tetragon.data.Settings;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.file.resource.ResourceManager;
	import tetragon.file.resource.StringIndex;
	import tetragon.util.reflection.getClassName;
	import tetragon.view.IView;
	import tetragon.view.Screen;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	
	/**
	 * <code>View</code> is the abstract base class for any view classes. You can use
	 * views to organize the display hierarchy in a Tetragon-based game or application.
	 * 
	 * <p>
	 * A view is a display object container that can hold any number of other AS3 display
	 * objects (sprites, movieclips, shapes, bitmaps, etc.) and/or other <code>View</code>
	 * objects as it's display children. The top level views in the Tetragon display
	 * hirarchy must always be <code>View</code> subclasses that are children in a
	 * <code>Screen</code> subclass. These <code>View</code> subclasses in turn can
	 * contain other <code>View</code> subclasses and AS3 native display objects.
	 * </p>
	 * 
	 * <p>
	 * View children that are subclassing the <code>View</code> class can be registered in
	 * their parent view class inside the <code>registerChildren()</code> method. When the
	 * parent view is started, updated, reset, stopped, disposed, enabled/disabled or
	 * paused/unpaused, all it's registered view children follow along and have their
	 * respective methods automatically called in the order they were registered.
	 * </p>
	 * 
	 * <p>
	 * Native AS3 display objects that are added to a view as children or
	 * <code>View</code> subclasses that are not registered in their parent view need to
	 * be manually started, updated, stopped, disposed, etc. in case they require any of
	 * these functionalities. For this any of the respective methods in the parent view
	 * class can be overriden, their super method called and any additional instructions
	 * added.
	 * </p>
	 * 
	 * <p>
	 * View classes always follow a stricty defined order of execution. <b>The constructor of
	 * a <code>View</code> subclass is never overriden.</b> They are instantiated
	 * automatically by their parent view class (or by their parent screen class if they
	 * are top level views). When a view class is created, several of it's methods are
	 * called automatically in the following order:
	 * </p>
	 * 
	 * <ol>
	 * <li>The view is instantiated and it's constructor is executed.</li>
	 * <li>The <code>setup()</code> method is called.<br/>
	 * Then after the view's parent view or screen is ready, the following method are
	 * called:</li>
	 * <li>The <code>createChildren()</code> method is called.</li>
	 * <li>The <code>registerChildren()</code> method is called.</li>
	 * <li>The <code>addChildren()</code> method is called.</li>
	 * <li>The <code>addListeners()</code> method is called.</li>
	 * <li>The <code>executeBeforeStart()</code> method is called.</li>
	 * <li>The view executes step 3, 4, 5 and 6 on all it's registered child views.</li>
	 * </ol>
	 * 
	 * <p>For views that should not be registered as a child view in their parent view or
	 * screen and that can be instantiated at a later time, extend the
	 * <code>DeferredView</code> class instead.</p>
	 * 
	 * @see Screen
	 * @see DeferredView
	 */
	public class View extends Sprite implements IView
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected static const EXEC_CREATE:String		= "create";
		/** @private */
		protected static const EXEC_BEFORE_START:String	= "beforeStart";
		/** @private */
		protected static const EXEC_START:String		= "start";
		/** @private */
		protected static const EXEC_UPDATE:String		= "update";
		/** @private */
		protected static const EXEC_RESET:String		= "reset";
		/** @private */
		protected static const EXEC_STOP:String			= "stop";
		/** @private */
		protected static const EXEC_DISPOSE:String		= "dispose";
		/** @private */
		protected static const EXEC_ENABLED:String		= "enabled";
		/** @private */
		protected static const EXEC_PAUSED:String		= "paused";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _main:Main;
		/** @private */
		protected var _screen:Screen;
		/** @private */
		protected var _enabled:Boolean = true;
		/** @private */
		protected var _started:Boolean;
		/** @private */
		protected var _paused:Boolean;
		/** @private */
		protected var _flattened:Boolean;
		/** @private */
		protected var _layoutOnce:Boolean;
		/** @private */
		protected var _isLaidout:Boolean;
		/** @private */
		protected var _children:Vector.<View>;
		/** @private */
		private static var _resourceIndex:ResourceIndex;
		/** @private */
		private static var _stringIndex:StringIndex;
		/** @private */
		private static var _settings:Settings;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new View instance. <b>View subclasses are always instantiated
		 * automatically by their parent view or screen and the constructor should not be
		 * overriden.</b>
		 */
		public function View()
		{
			_main = Main.instance;
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Starts the view. You normally don't call this method manually. Instead the
		 * parent owner calls it automatically when it is being requested to start.
		 * 
		 * <p>
		 * You don't need to override this method unless you have any custom objects in
		 * your view that need starting. All registered child views of this view are
		 * started automatically when the view is started.
		 * </p>
		 * 
		 * <p>
		 * If you override this method make sure to call <code>super.start()</code> <b>at
		 * the beginning of your overriden method</b>, otherwise registered child views
		 * will not be started automatically.
		 * </p>
		 */
		public function start():void
		{
			if (_started) return;
			_started = true;
			executeOnChildren(EXEC_START);
		}
		
		
		/**
		 * Updates the view. This method is called automatically by the parent owner
		 * before the view is being started. A call to this method updates all registered
		 * child views and then updates the view's display text (if available) and lay's
		 * out it's display children.
		 * 
		 * <p>
		 * If you override this method make sure to call <code>super.update()</code> in
		 * your overriden method, otherwise registered views will not be updated
		 * automatically.
		 * </p>
		 * 
		 * @see tetragon.view.View#updateDisplayText()
		 * @see tetragon.view.View#layoutChildren()
		 */
		public function update():void
		{
			executeOnChildren(EXEC_UPDATE);
			updateDisplayText();
			
			if (!_layoutOnce || !_isLaidout)
			{
				_isLaidout = true;
				layoutChildren();
			}
		}
		
		
		/**
		 * Resets the view and all of it's registered child views. This method can be used
		 * to reset the view or any of it's children to their initial state, position,
		 * size etc.
		 * 
		 * <p>
		 * If you override this method make sure to call <code>super.reset()</code> in
		 * your overriden method, otherwise registered child views will not be reset
		 * automatically.
		 * </p>
		 */
		public function reset():void
		{
			executeOnChildren(EXEC_RESET);
		}
		
		
		/**
		 * Stops the view if it has been started before. You normally don't call this method
		 * manually. Instead it is called automatically before the view is being closed by
		 * it's parent owner. For example a screen is stopped by the screen manager before
		 * it is closed and all view children of the screen are therefore stopped as well.
		 * 
		 * <p>If you override this method make sure to call <code>super.stop()</code> <b>at
		 * the beginning of your overriden method</b>, otherwise registered child views will
		 * not be stopped.</p>
		 */
		public function stop():void
		{
			if (!_started) return;
			executeOnChildren(EXEC_STOP);
			_started = false;
		}
		
		
		/**
		 * Flattens the view. This will change all of the view's contents to be flattened
		 * and rendered to a single bitmap (baked). If the view is resized after it was
		 * flattened, it will be re-flattened with the new size.
		 */
		public function flatten():void
		{
			_flattened = true;
			// TODO
		}
		
		
		/**
		 * Unflattens the view.
		 */
		public function unflatten():void
		{
			_flattened = false;
			// TODO
		}
		
		
		/**
		 * Can be used to set the x,y position of the view with one call instead of
		 * accessors.
		 */
		public function setPosition(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		
		
		/**
		 * Disposes the view and all it's registered child views to clean up objects that
		 * are no longer needed. A call to this method removes any event/signal listeners.
		 * 
		 * <p>
		 * You normally don't call this method manually. Instead it is called
		 * automatically when the parent owner is being disposed.
		 * </p>
		 * 
		 * <p>
		 * If you want to override this method, for example to dispose non-registered
		 * objects, make sure to call <code>super.dispose()</code> in your overriden
		 * dispose method.
		 * </p>
		 */
		public function dispose():void
		{
			executeOnChildren(EXEC_DISPOSE);
			stop();
			removeListeners();
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		override public function toString():String
		{
			return getClassName(this);
		}
		
		
		/**
		 * @private
		 */
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (!child) return null;
			return super.addChild(child);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the view is enabled or disabled. On a disabled view any
		 * display children are disabled so that no user interaction may occur until the
		 * view is enabled again. Set this property to either <code>true</code> (enabled)
		 * or <code>false</code> (disabled).
		 * 
		 * <p>
		 * Any registered child views of this view are automatically enabled or disabled
		 * if this view is enabled or disabled.
		 * </p>
		 * 
		 * @default <code>true</code>
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(v:Boolean):void
		{
			if (v == _enabled) return;
			_enabled = v;
			executeOnChildren(EXEC_ENABLED, _enabled);
			if (_enabled) enableChildren();
			else disableChildren();
		}
		
		
		/**
		 * Determines whether the view is automatically enabled after it has been opened
		 * (i.e. after its parent view/screen has been opened by the screen manager.
		 * Normally the screen manager enables the currently opened screen (and therefore
		 * all the screen's child views) after the screen has been opened but ocassionally
		 * there might be views that should stay disabled until they are manually enabled
		 * somewhere else. In this case override this accessor and set it to return false.
		 * Then the view will not be automatically enabled after opening.
		 * 
		 * @default true
		 */
		public function get autoEnable():Boolean
		{
			return true;
		}
		
		
		/**
		 * Determines whether the view is in paused state or not. If paused, any child
		 * objects of the view are being paused too, if possible. This property should
		 * be used if the view needs to be pausable, for example if it contains any
		 * animation that should not play while the application is in a paused state.
		 * 
		 * <p>
		 * Any registered child views of this view are automatically paused or unpaused
		 * if this view is paused or unpaused.
		 * </p>
		 * 
		 * @default <code>false</code>
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			if (v == _paused) return;
			_paused = v;
			executeOnChildren(EXEC_PAUSED, _paused);
			if (_paused) pauseChildren();
			else unpauseChildren();
		}
		
		
		/**
		 * Determines whether the view has been started or not. After calling the view's
		 * <code>start()</code> method this property is <code>true</code> while after
		 * calling <code>stop()</code> it is set to <code>false</code>.
		 */
		public function get started():Boolean
		{
			return _started;
		}
		
		
		/**
		 * Determines whether the view is flattened or not.
		 */
		public function get flattened():Boolean
		{
			return _flattened;
		}
		
		
		/**
		 * Determines whether the view is auto-started (i.e. it's <code>start()</code>
		 * method called) by the parent view or screen. This accessor can be overriden in
		 * <code>View</code> subclasses and <code>false</code> can be returned instead if
		 * the <code>View</code> subclass is being registered but should not be started
		 * automatically once it's parent view or screen ios started.
		 * 
		 * @default true
		 */
		public function get autoStart():Boolean
		{
			return true;
		}
		
		
		/**
		 * A reference to the view chain's parent screen, for quick access in subclasses.
		 * 
		 * @see Screen
		 */
		public function get screen():Screen
		{
			return _screen;
		}
		
		
		/**
		 * If true, layout() will only be called once and ignored on further update calls.
		 * 
		 * @default false
		 */
		protected function get layoutOnce():Boolean
		{
			return _layoutOnce;
		}
		protected function set layoutOnce(v:Boolean):void
		{
			_layoutOnce = v;
		}
		
		
		/**
		 * A reference to Main for quick access in subclasses.
		 * 
		 * @see tetragon.Main
		 */
		protected function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * A reference to the registry for quick access in subclasses.
		 * 
		 * @see tetragon.data.Registry
		 */
		protected function get registry():Registry
		{
			return _main.registry;
		}
		
		
		/**
		 * A reference to the resource manager for quick access in subclasses.
		 * 
		 * @see tetragon.file.resource.ResourceManager
		 */
		protected function get resourceManager():ResourceManager
		{
			return _main.resourceManager;
		}
		
		
		/**
		 * A reference to the resource index for quick access in subclasses.
		 * 
		 * @see tetragon.file.resource.ResourceIndex
		 */
		public static function get resourceIndex():ResourceIndex
		{
			if (!_resourceIndex) _resourceIndex = Main.instance.resourceManager.resourceIndex;
			return _resourceIndex;
		}
		
		
		/**
		 * A reference to the settings for quick access in subclasses.
		 * 
		 * @see tetragon.data.Settings
		 */
		static public function get settings():Settings
		{
			if (!_settings) _settings = Main.instance.registry.settings;
			return _settings;
		}
		
		
		/**
		 * A vector containing all child views of the view. This only includes children
		 * that extend the View class and that have been registered in this view's
		 * registerChildren() method.
		 * 
		 * @private
		 */
		public function get children():Vector.<View>
		{
			return _children;
		}
		
		
		/**
		 * Returns the number of child views that are used in this view. This only includes
		 * children that extend the View class and that have been registered in this view's
		 * registerChildren() method.
		 * 
		 * @private
		 */
		public function get numChildViews():uint
		{
			if (!_children) return 0;
			return _children.length;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Can be used for early initialization of properties. You can override this method
		 * in your <code>View</code> subclass and assign initial values to properties or
		 * instantiate class members that are required to exist right after the view has
		 * been created. To create display children or other objects that are not required
		 * right after instantiation use the <code>createChildren()</code> method instead.
		 * This method is only called once, automatically right after the view has been
		 * instatiated.
		 * 
		 * <p>
		 * This is an abstract method. Override it in your sub-view class and assign any
		 * initial values to properties here that are part of the view.
		 * </p>
		 */
		protected function setup():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used internally to create the view. You never call this method manually.
		 * Instead the parent owner calls it automatically before it is being opened.
		 * 
		 * @private
		 */
		protected function createView():void
		{
			createChildren();
			registerChildren();
			addChildren();
			addListeners();
			executeOnChildren(EXEC_CREATE);
			executeOnChildren(EXEC_BEFORE_START);
		}
		
		
		/**
		 * Used to create any display children (and other objects) that the view might
		 * require. Child display objects should not be added to the display list here.
		 * Instead they are added in the <code>addChildren()</code> method.
		 * 
		 * <p>
		 * This is an abstract method. Override it in your sub-view class and create any
		 * objects or view/display children here that are part of the view.
		 * </p>
		 * 
		 * @see tetragon.view.View#addChildren()
		 */
		protected function createChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Registers child views for use in the view.
		 * 
		 * <p>
		 * This is an abstract method. Override this method in your sub-view class and
		 * register the views by using the <code>registerView()</code> method. Child views
		 * that are registered with this view have most of their methods called
		 * automatically when these methods are called in their parent view. These methods
		 * are: <code>init()</code>, <code>start()</code>, <code>stop()</code>,
		 * <code>reset()</code>, <code>update()</code>, <code>dispose()</code>,
		 * <code>enabled</code> and <code>paused</code>.
		 * </p>
		 * 
		 * <p>
		 * Only child objects that extend the View class may be registered. Native AS3
		 * display classes like Sprite, MovieClip, Bitmap, etc. cannot be registered and
		 * must have any of their respective methods called manually instead.
		 * </p>
		 * 
		 * @example
		 * <pre>
		 * registerView(&quot;view1&quot;);
		 * registerView(&quot;view1&quot;);
		 * </pre>
		 * 
		 * @see tetragon.view.View#registerChild()
		 */
		protected function registerChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used inside an overriden <code>registerChildren()</code> method to register
		 * child views.
		 * 
		 * This doesn't add a view to the display list but registers it for use in this
		 * view. Views that are registered as children in their parent view have several
		 * methods and setters automatically be called if these methods are called in
		 * their view.
		 * 
		 * @see tetragon.view.View#registerChildren()
		 * 
		 * @param child The View instance to register.
		 */
		protected final function registerChild(child:View):void
		{
			if (!child) return;
			if (!_children) _children = new Vector.<View>();
			child.setViewParams(_screen);
			_children.push(child);
		}
		
		
		/**
		 * Can be used to unregister a previously registered child of the view. Note
		 * that this method does not dispose the child view. The unregistered child view
		 * can still be used afterwards but it wont receive any automatic method calls
		 * from it's parent view anymore.
		 * 
		 * @param child The View instance to unregister.
		 * @return true if the child view was unregistered successfully, false if not.
		 */
		protected final function unregisterChild(child:View):Boolean
		{
			if (!child || !_children) return false;
			var i:int = _children.indexOf(child);
			if (i > -1)
			{
				_children.splice(i, 1);
				return true;
			}
			return false;
		}
		
		
		/**
		 * Used to set params provided by the parent owner of the view.
		 * @private
		 * 
		 * @param screen The parent screen of this view.
		 */
		private function setViewParams(screen:Screen):void
		{
			_screen = screen;
		}
		
		
		/**
		 * Used to add child display objects to the display list that were created in the
		 * <code>createChildren()</code> method.
		 * 
		 * <p>This is an abstract method. Override it in your sub-view class and add
		 * any display children to the display list here</p>
		 * 
		 * @see tetragon.view.View#createChildren()
		 */
		protected function addChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Can be used to dispose a child view if it's not needed anymore. This
		 * unregisters the view, then removes it from the display list and then disposes
		 * it. The view cannot be used anymore after it was disposed unless it is
		 * instantiated again.
		 * 
		 * @param child The child view to dispose.
		 */
		protected function disposeChildView(child:View):void
		{
			if (!child) return;
			unregisterChild(child);
			if (contains(child)) removeChild(child);
			child.dispose();
			child = null;
		}
		
		
		/**
		 * Calls a method on all registered child views of the view. Used by many default
		 * methods of the view to delegate execution to child views. Execution is always
		 * delegated to child views in the same order in that they were registered in
		 * <code>registerChildren()</code>.
		 * 
		 * @private
		 * 
		 * @param func The function that should be called on the view.
		 * @param value An optional value used when calling setters.
		 */
		protected final function executeOnChildren(func:String, value:* = null):void
		{
			if (!_children) return;
			var len:uint = _children.length;
			for (var i:uint = 0; i < len; i++)
			{
				var c:View = _children[i];
				switch (func)
				{
					case EXEC_CREATE:
						c.createView();
						break;
					case EXEC_BEFORE_START:
						c.executeBeforeStart();
						break;
					case EXEC_START:
						if (c.autoStart) c.start();
						break;
					case EXEC_UPDATE:
						c.update();
						break;
					case EXEC_RESET:
						c.reset();
						break;
					case EXEC_STOP:
						c.stop();
						break;
					case EXEC_DISPOSE:
						c.dispose();
						break;
					case EXEC_ENABLED:
						c.enabled = value as Boolean;
						break;
					case EXEC_PAUSED:
						c.paused = value as Boolean;
						break;
				}
			}
		}
		
		
		/**
		 * Used to add any event- or signal listeners to child objects of the view.
		 * 
		 * <p>This is an abstract method. Override this method and add any listeners to
		 * objects that require event/signal listening.</p>
		 * 
		 * @see tetragon.view.View#removeListeners()
		 */
		protected function addListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to remove any event- or signal listeners from child objects that were added
		 * inside the <code>addListeners()</code> method. Called automatically when the
		 * view is being disposed.
		 * 
		 * <p>This is an abstract method. Override this method and remove any event/signal
		 * listeners here that were added in <code>addListeners()</code>.</p>
		 * 
		 * @see tetragon.view.View#addListeners()
		 */
		protected function removeListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to update any display text that the view might contain. Typically any
		 * textfield text should be set here with strings from the application's currently
		 * used text resources. This method is called automatically whenever the view's
		 * <code>update()</code> method is called.
		 * 
		 * <p>
		 * This is an abstract method. Override it in your sub-view class and set strings
		 * from text resources to any text-containing display objects if they require it.
		 * </p>
		 * 
		 * @see tetragon.view.View#update()
		 */
		protected function updateDisplayText():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to lay out the display children of the view. This method is called
		 * initially to set the position and size of any child objects and should be
		 * called whenever the children need to update their position or size because the
		 * layout has changed, for example after the application window has been resized.
		 * 
		 * <p>
		 * In screen classes this method is called by default automatically whenever the
		 * display stage is resized. Override the <code>onStageResize()</code> signal
		 * handler in your screen class to change this behavior.
		 * </p>
		 * 
		 * <p>
		 * This is an abstract method. Override it in your sub-view class and set the
		 * position and size of all child display objects here.
		 * </p>
		 * 
		 * @see tetragon.view.View#update()
		 */
		protected function layoutChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to enable any child display objects. Called whenever the
		 * <code>enabled</code> property of the view is set to <code>true</code>.
		 * 
		 * <p>This is an abstract method. Override it in your sub-view class and enable
		 * any child display objects here that should be enabled when the view is being
		 * enabled.</p>
		 * 
		 * @see tetragon.view.View#enabled
		 * @see tetragon.view.View#disableChildren()
		 */
		protected function enableChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to disable any child display objects. Called whenever the
		 * <code>enabled</code> property of the view is set to <code>false</code>.
		 * 
		 * <p>This is an abstract method. Override it in your sub-view class and disable
		 * any child display objects here that should be disabled when the view is being
		 * disabled.</p>
		 * 
		 * @see tetragon.view.View#enabled
		 * @see tetragon.view.View#enableChildren()
		 */
		protected function disableChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to pause any child display objects. Called whenever the
		 * <code>paused</code> property of the view is set to <code>true</code>.
		 * 
		 * <p>This is an abstract method. Override it in your sub-view class and pause
		 * any child display objects here that should be paused when the view is being
		 * put into paused mode.</p>
		 * 
		 * @see tetragon.view.View#paused
		 * @see tetragon.view.View#unpauseChildren()
		 */
		protected function pauseChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to unpause any child display objects that were paused. Called whenever the
		 * <code>paused</code> property of the view is set to <code>false</code>.
		 * 
		 * <p>This is an abstract method. Override it in your sub-view class and unpause
		 * any child display objects here that should be unpaused when the view is being
		 * put into unpaused mode.</p>
		 * 
		 * @see tetragon.view.View#paused
		 * @see tetragon.view.View#pauseChildren()
		 */
		protected function unpauseChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Can be used to execute tasks right before the view is opened and started. You can
		 * override and use this method to prepare the view with any instructions that
		 * need to be done after the view has been created but before the view is opened
		 * and started. This method is only called once after the view has been created
		 * and before it is being displayed.
		 * 
		 * <p>This is an abstract method. You can override it in your subclass and
		 * place any preparing setup steps into it.</p>
		 */
		protected function executeBeforeStart():void
		{
			/* Abstract method! */
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Helper Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Helper method to get a resource's content from the resource index. The type
		 * depends on the content type of the resource.
		 * 
		 * @param resourceID The ID of the resource.
		 * @return The resource content or <code>null</code>.
		 */
		protected static function getResource(resourceID:String):*
		{
			return resourceIndex.getResourceContent(resourceID);
		}
		
		
		/**
		 * Helper method to get a string from the string index.
		 * 
		 * @param stringID The ID of the string.
		 * @return The requested string.
		 */
		protected static function getString(stringID:String):String
		{
			if (!_stringIndex) _stringIndex = Main.instance.resourceManager.stringIndex;
			return _stringIndex.getString(stringID);
		}
		
		
		/**
		 * Helper method to get a settings value from the Settings map.
		 * 
		 * @param settingsID The ID of the settings property.
		 * @return The settings' value.
		 */
		protected static function getSettings(settingsID:String):*
		{
			return settings.getProperty(settingsID);
		}
	}
}
