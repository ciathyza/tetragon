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
package view.splash
{
	import tetragon.data.Settings;
	import tetragon.util.display.centerChild;
	import tetragon.view.Screen;
	import tetragon.view.display.shape.RectangleGradientShape;
	import tetragon.view.loadprogress.LoadProgressDisplay;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	
	/**
	 * A screen that shows the engine's logo.
	 */
	public class SplashScreen extends Screen
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "splashScreen";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _bgColors:Array;
		private var _background:RectangleGradientShape;
		private var _view:SplashView;
		
		private var _timer:Timer;
		private var _tetragonLogoSoundChannel:SoundChannel;
		private var _allowSplashAbort:Boolean;
		private var _splashScreenWaitTime:int;
		private var _initialScreenID:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function start():void
		{
			super.start();
			_timer.start();
			
			var sound:Sound = getResource("audioLogoTetragon");
			if (sound) _tetragonLogoSoundChannel = sound.play();
			
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			if (_allowSplashAbort)
			{
				main.screenManager.mouseSignal.addOnce(onUserInput);
				main.keyInputManager.keySignal.addOnce(onUserInput);
			}
		}
		
		
		override public function stop():void
		{
			super.stop();
			if (_timer) _timer.stop();
			if (_tetragonLogoSoundChannel) _tetragonLogoSoundChannel.stop();
		}
		
		
		override public function dispose():void
		{
			super.dispose();
			_timer = null;
			_tetragonLogoSoundChannel = null;
		}
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		override public function get loadProgressDisplay():LoadProgressDisplay
		{
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onUserInput(type:String, e:Event):void
		{
			if (_timer) _timer.stop();
			Mouse.show();
			screenManager.openScreen(_initialScreenID, true, true);
		}
		
		
		private function onTimerComplete(e:TimerEvent):void
		{
			/* Once the screen fades out, the user should not be able to interrupt, otherwise
			 * we might hang up somewhere so remove input listeners right here. */
			Mouse.show();
			screenManager.openScreen(_initialScreenID);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function setup():void
		{
			super.setup();
			
			/* Hide mouse during splash state if fullscreen. */
			if (main.isFullscreen) Mouse.hide();
			
			_initialScreenID = settings.getString(Settings.INITIAL_SCREEN_ID);
			_allowSplashAbort = settings.getBoolean(Settings.ALLOW_SPLASH_SABORT);
			_splashScreenWaitTime = settings.getNumber(Settings.SPLASH_SCREEN_WAIT_TIME);
			if (_splashScreenWaitTime < 1) _splashScreenWaitTime = 6;
		}
		
		
		override protected function registerResources():void
		{
			registerResource("audioLogoTetragon");
		}
		
		
		override protected function createChildren():void
		{
			var bgc:Array = settings.getArray(Settings.SPLASH_BACKGROUND_COLORS);
			_bgColors = bgc ? bgc : [0x002C3F, 0x0181B8];
			_background = new RectangleGradientShape();
			_view = new SplashView();
			_timer = new Timer(_splashScreenWaitTime * 1000, 1);
		}
		
		
		override protected function registerChildren():void
		{
			registerChild(_view);
		}
		
		
		override protected function addChildren():void 
		{
			addChild(_background);
			addChild(_view);
		}
		
		
		override protected function removeListeners():void
		{
			if (_timer) _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		
		override protected function layoutChildren():void
		{
			_background.setProperties(main.stage.stageWidth, main.stage.stageHeight, -90, _bgColors);
			_background.draw();
			centerChild(_background);
			centerChild(_view);
		}
	}
}
