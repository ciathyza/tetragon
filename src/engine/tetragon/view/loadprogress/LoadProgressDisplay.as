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
package tetragon.view.loadprogress
{
	import tetragon.Main;
	import tetragon.view.Screen2;
	import tetragon.view.ScreenManager2;

	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.signals.Signal;

	import flash.display.Sprite;
	
	
	/**
	 * Abstract base class for load progress display classes.
	 * 
	 * <p>
	 * Load progress displays are used to display the load progress of resources that are
	 * being loaded for a screen. If a screen registers resources for loading and provides
	 * a load progress display, the screen manager will show the display while the
	 * screen's resources are being loaded.
	 * </p>
	 * 
	 * <p>
	 * To create a custom load progress display extend this class and provide your own
	 * implementation for it by overriding the <code>setup()</code>,
	 * <code>onReset()</code>, <code>onUpdate()</code> and <code>onComplete()</code>
	 * methods. By extending and customizing the display, it can display any information
	 * that should be shown while a screen's resources are being preloaded for example
	 * images, text messages and a progress bar.
	 * </p>
	 * 
	 * @see tetragon.view.loadprogress.BasicLoadProgressDisplay
	 * @see tetragon.view.loadprogress.DebugLoadProgressDisplay
	 * @see tetragon.view.Screen
	 * @see tetragon.view.Screen#loadProgressDisplay
	 * @see tetragon.view.ScreenManager
	 */
	public class LoadProgressDisplay extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _screenManager:ScreenManager2;
		/** @private */
		private var _screen:Screen2;
		/** @private */
		private var _userInputSignal:Signal;
		/** @private */
		private var _progress:BulkProgress;
		/** @private */
		private var _totalCount:uint;
		/** @private */
		private var _loadedCount:uint;
		/** @private */
		private var _failedCount:uint;
		/** @private */
		private var _allLoaded:Boolean;
		/** @private */
		private var _allFailed:Boolean;
		/** @private */
		private var _allComplete:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function LoadProgressDisplay()
		{
			super();
			
			_screenManager = Main.instance.screenManager;
			_screenManager.stageResizeSignal.add(onStageResize);
			_screen = _screenManager.currentScreen;
			
			if (waitForUserInput)
			{
				_userInputSignal = new Signal();
			}
			
			setup();
			reset();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Updates the load progress display. Called automatically by screen manager when the
		 * load progress updates. Do not override, override onUpdate() instead!
		 * 
		 * @param progress The BulkProgress object that provides statistics about the
		 *            current load progress.
		 */
		public function update(progress:BulkProgress = null):void
		{
			_progress = progress;
			onUpdate();
		}
		
		
		/**
		 * Disposes the load progress display. When overriding, make sure to call
		 * <code>super.dispose()</code>.
		 */
		public function dispose():void
		{
			if (_userInputSignal) _userInputSignal.removeAll();
			_screenManager.stageResizeSignal.remove(onStageResize);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates whether all resources failed loading. This property is false unless
		 * all resources that were to be loaded failed.
		 */
		public function get allFailed():Boolean
		{
			return _allFailed;
		}
		
		
		/**
		 * Indicates whether all resources completed loading. This property is false unless
		 * all resources have successfully been loaded.
		 */
		public function get allLoaded():Boolean
		{
			return _allLoaded;
		}
		
		
		/**
		 * Indicates whether the load progress display is complete. This property can be
		 * checked for in the overriden onUpdate() handler to prevent any further updates
		 * to the load progress display after all loading has completed.
		 */
		public function get allComplete():Boolean
		{
			return _allComplete;
		}
		
		
		/**
		 * Determines if the load progress display should request to close any screen that
		 * might be open. By default this property returns <code>false</code> which means
		 * that the load progress display appears overlaid over any open screen. You can
		 * override this getter in your sub-class and let it return <code>true</code> to
		 * have any open screen closed before the load progress display is shown.
		 * 
		 * @private
		 * @default <code>false</code>
		 */
		// NOTE: Currently unsupported!
		//public function get closeScreenBeforeLoad():Boolean
		//{
		//	return false;
		//}
		
		
		/**
		 * Determines whether the load progress display should wait for user input before
		 * continuing after the loading completed. You can override this accessor to return
		 * <code>true</code> in your subclass if you want your progress display to wait
		 * for user input after loading has finished.
		 * 
		 * @default <code>false</code>
		 * @see tetragon.view.loadprogress.LoadProgressDisplay#userInputSignal
		 */
		public function get waitForUserInput():Boolean
		{
			return false;
		}
		
		
		/**
		 * A signal that is dispatched after user input has been detected. This only applies
		 * if <code>waitForUserInput</code> is set to true.
		 * 
		 * @see tetragon.view.loadprogress.LoadProgressDisplay#waitForUserInput
		 */
		public function get userInputSignal():Signal
		{
			return _userInputSignal;
		}
		
		
		/**
		 * The BulkProgress object used to provide statistics about the load progress.
		 * If a load operation fails this property is <code>null</code>.
		 */
		protected function get progress():BulkProgress
		{
			return _progress;
		}
		
		
		/**
		 * A reference to the screen manager for quick access in subclasses.
		 */
		protected function get screenManager():ScreenManager2
		{
			return _screenManager;
		}
		
		
		/**
		 * A reference to the screen that the load progress display is used for.
		 */
		protected function get screen():Screen2
		{
			return _screen;
		}
		
		
		/**
		 * Used by screen manager to set total amount of resources to be loaded.
		 * Read only!
		 */
		public function get totalCount():uint
		{
			return _totalCount;
		}
		public function set totalCount(v:uint):void
		{
			if (v == _totalCount) return;
			_totalCount = v;
		}
		
		
		/**
		 * Used by screen manager to set amount of resources that have been loaded.
		 * Read only!
		 */
		public function get loadedCount():uint
		{
			return _loadedCount;
		}
		public function set loadedCount(v:uint):void
		{
			if (v == _loadedCount) return;
			_loadedCount = v;
			onLoadProgressChanged();
		}
		
		
		/**
		 * Used by screen manager to set amount of resources that have failed.
		 * Read only!
		 */
		public function get failedCount():uint
		{
			return _failedCount;
		}
		public function set failedCount(v:uint):void
		{
			if (v == _failedCount) return;
			_failedCount = v;
			onLoadProgressChanged();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked whenever a resources has loaded or failed.
		 * @private
		 */
		private function onLoadProgressChanged():void
		{
			_allLoaded = _loadedCount == _totalCount;
			_allFailed = _failedCount == _totalCount;
		}
		
		
		/**
		 * Invoked when the load progress display is reset. You can override this
		 * method and reset any custom children and properties here.
		 */
		protected function onReset():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Invoked whenever the load progress display is updated. You can override this
		 * method and update the load progress display to reflect the current load progress.
		 */
		protected function onUpdate():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Completes the load progress display. You can override this method and place any
		 * implementation to be executed after all loading has completed, for example
		 * telling the user to press a key or the mouse to continue if
		 * <code>waitForUserInput</code> is <code>true</code>.
		 */
		protected function onComplete():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Invoked if the stage size changes, for example when the application window
		 * is resized or toggled to/from fullscreen.
		 * 
		 * <p>This is an abstract method. Override it if your load progress display
		 * requires to lay out display objects in case the stage size changes.</p>
		 */
		protected function onStageResize():void
		{
			/* Abstract method! */
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to set up the load progress display.
		 * 
		 * <p>This is an abstract method. Override it in your load progress display
		 * subclass and use it to create child objects and set initial property
		 * values, etc. here.</p> 
		 */
		protected function setup():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Resets the load progress display. Do not override, override onReset() instead!
		 */
		private function reset():void
		{
			_totalCount = _loadedCount = _failedCount = 0;
			_allLoaded = _allFailed = _allComplete = false;
			onReset();
		}
		
		
		/**
		 * Completes the load progress display. Call this method in your overriden onUpdate()
		 * method after all loading has completed, for example after the load percentage
		 * reaches 100%.
		 */
		protected function complete():void
		{
			_allComplete = true;
			onComplete();
		}
	}
}
