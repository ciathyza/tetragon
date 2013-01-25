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
package tetragon.view.render2d.touch
{
	import tetragon.view.render2d.display.Stage2D;
	import tetragon.view.render2d.events.KeyboardEvent2D;
	import tetragon.view.render2d.events.TouchEvent2D;

	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	
	/** @private
	 *  The TouchProcessor is used internally to convert mouse and touch events of the conventional
	 *  Flash stage to Render2D's TouchEvents. */
	public class TouchProcessor2D
	{
		private static const MULTITAP_TIME:Number = 0.3;
		private static const MULTITAP_DISTANCE:Number = 25;
		
		private var _stage2D:Stage2D;
		private var _elapsedTime:Number;
		private var _touchMarker:TouchMarker2D;
		private var _currentTouches:Vector.<Touch2D>;
		private var _queue:Vector.<Array>;
		private var _lastTaps:Vector.<Touch2D>;
		
		private var _shiftDown:Boolean;
		private var _ctrlDown:Boolean;
		
		/** Helper objects. */
		private static var _processedTouchIDs:Vector.<int> = new <int>[];
		private static var _hoveringTouchData:Vector.<TouchData2D> = new <TouchData2D>[];


		public function TouchProcessor2D(stage2D:Stage2D)
		{
			_stage2D = stage2D;
			_elapsedTime = 0.0;
			_currentTouches = new <Touch2D>[];
			_queue = new <Array>[];
			_lastTaps = new <Touch2D>[];

			_stage2D.addEventListener(KeyboardEvent2D.KEY_DOWN, onKey);
			_stage2D.addEventListener(KeyboardEvent2D.KEY_UP, onKey);
			monitorInterruptions(true);
		}


		public function dispose():void
		{
			monitorInterruptions(false);
			_stage2D.removeEventListener(KeyboardEvent2D.KEY_DOWN, onKey);
			_stage2D.removeEventListener(KeyboardEvent2D.KEY_UP, onKey);
			if (_touchMarker) _touchMarker.dispose();
		}


		public function advanceTime(passedTime:Number):void
		{
			var i:int;
			var touchID:int;
			var touch:Touch2D;

			_elapsedTime += passedTime;

			// remove old taps
			if (_lastTaps.length > 0)
			{
				for (i = _lastTaps.length - 1; i >= 0; --i)
					if (_elapsedTime - _lastTaps[i].timestamp > MULTITAP_TIME)
						_lastTaps.splice(i, 1);
			}

			while (_queue.length > 0)
			{
				_processedTouchIDs.length = _hoveringTouchData.length = 0;

				// set touches that were new or moving to phase 'stationary'
				for each (touch in _currentTouches)
					if (touch.phase == TouchPhase2D.BEGAN || touch.phase == TouchPhase2D.MOVED)
						touch.setPhase(TouchPhase2D.STATIONARY);

				// process new touches, but each ID only once
				while (_queue.length > 0 && _processedTouchIDs.indexOf(_queue[_queue.length - 1][0]) == -1)
				{
					var touchArgs:Array = _queue.pop();
					touchID = touchArgs[0] as int;
					touch = getCurrentTouch(touchID);

					// hovering touches need special handling (see below)
					if (touch && touch.phase == TouchPhase2D.HOVER && touch.target)
					{
						_hoveringTouchData.push(new TouchData2D(touch, touch.target, touch.bubbleChain));
					}

					processTouch.apply(this, touchArgs);
					_processedTouchIDs.push(touchID);
				}

				// the same touch event will be dispatched to all targets;
				// the 'dispatch' method will make sure each bubble target is visited only once.
				var touchEvent:TouchEvent2D = new TouchEvent2D(TouchEvent2D.TOUCH, _currentTouches, _shiftDown, _ctrlDown);

				// if the target of a hovering touch changed, we dispatch the event to the previous
				// target to notify it that it's no longer being hovered over.
				for each (var touchData:TouchData2D in _hoveringTouchData)
					if (touchData.touch.target != touchData.target)
						touchEvent.dispatch(touchData.bubbleChain);

				// dispatch events
				for each (touchID in _processedTouchIDs)
					getCurrentTouch(touchID).dispatchEvent(touchEvent);

				// remove ended touches
				for (i = _currentTouches.length - 1; i >= 0; --i)
					if (_currentTouches[i].phase == TouchPhase2D.ENDED)
						_currentTouches.splice(i, 1);
			}
		}


		public function enqueue(touchID:int, phase:String, globalX:Number, globalY:Number, pressure:Number = 1.0, width:Number = 1.0, height:Number = 1.0):void
		{
			_queue.unshift(arguments);

			// multitouch simulation (only with mouse)
			if (_ctrlDown && simulateMultitouch && touchID == 0)
			{
				_touchMarker.moveMarker(globalX, globalY, _shiftDown);
				_queue.unshift([1, phase, _touchMarker.mockX, _touchMarker.mockY]);
			}
		}


		public function enqueueMouseLeftStage():void
		{
			var mouse:Touch2D = getCurrentTouch(0);
			if (mouse == null || mouse.phase != TouchPhase2D.HOVER) return;

			// On OS X, we get mouse events from outside the stage; on Windows, we do not.
			// This method enqueues an artifial hover point that is just outside the stage.
			// That way, objects listening for HOVERs over them will get notified everywhere.

			var offset:int = 1;
			var exitX:Number = mouse.globalX;
			var exitY:Number = mouse.globalY;
			var distLeft:Number = mouse.globalX;
			var distRight:Number = _stage2D.stageWidth - distLeft;
			var distTop:Number = mouse.globalY;
			var distBottom:Number = _stage2D.stageHeight - distTop;
			var minDist:Number = Math.min(distLeft, distRight, distTop, distBottom);

			// the new hover point should be just outside the stage, near the point where
			// the mouse point was last to be seen.

			if (minDist == distLeft) exitX = -offset;
			else if (minDist == distRight) exitX = _stage2D.stageWidth + offset;
			else if (minDist == distTop) exitY = -offset;
			else exitY = _stage2D.stageHeight + offset;

			enqueue(0, TouchPhase2D.HOVER, exitX, exitY);
		}


		private function processTouch(touchID:int, phase:String, globalX:Number, globalY:Number, pressure:Number = 1.0, width:Number = 1.0, height:Number = 1.0):void
		{
			var position:Point = new Point(globalX, globalY);
			var touch:Touch2D = getCurrentTouch(touchID);

			if (touch == null)
			{
				touch = new Touch2D(touchID, globalX, globalY, phase, null);
				addCurrentTouch(touch);
			}

			touch.setPosition(globalX, globalY);
			touch.setPhase(phase);
			touch.setTimestamp(_elapsedTime);
			touch.setPressure(pressure);
			touch.setSize(width, height);

			if (phase == TouchPhase2D.HOVER || phase == TouchPhase2D.BEGAN)
				touch.setTarget(_stage2D.hitTest(position, true));

			if (phase == TouchPhase2D.BEGAN)
				processTap(touch);
		}


		private function onKey(event:KeyboardEvent2D):void
		{
			if (event.keyCode == 17 || event.keyCode == 15) // ctrl or cmd key
			{
				var wasCtrlDown:Boolean = _ctrlDown;
				_ctrlDown = event.type == KeyboardEvent2D.KEY_DOWN;

				if (simulateMultitouch && wasCtrlDown != _ctrlDown)
				{
					_touchMarker.visible = _ctrlDown;
					_touchMarker.moveCenter(_stage2D.stageWidth / 2, _stage2D.stageHeight / 2);

					var mouseTouch:Touch2D = getCurrentTouch(0);
					var mockedTouch:Touch2D = getCurrentTouch(1);

					if (mouseTouch)
						_touchMarker.moveMarker(mouseTouch.globalX, mouseTouch.globalY);

					// end active touch ...
					if (wasCtrlDown && mockedTouch && mockedTouch.phase != TouchPhase2D.ENDED)
						_queue.unshift([1, TouchPhase2D.ENDED, mockedTouch.globalX, mockedTouch.globalY]);
					// ... or start new one
					else if (_ctrlDown && mouseTouch)
					{
						if (mouseTouch.phase == TouchPhase2D.HOVER || mouseTouch.phase == TouchPhase2D.ENDED)
							_queue.unshift([1, TouchPhase2D.HOVER, _touchMarker.mockX, _touchMarker.mockY]);
						else
							_queue.unshift([1, TouchPhase2D.BEGAN, _touchMarker.mockX, _touchMarker.mockY]);
					}
				}
			}
			else if (event.keyCode == 16) // shift key
			{
				_shiftDown = event.type == KeyboardEvent2D.KEY_DOWN;
			}
		}


		private function processTap(touch:Touch2D):void
		{
			var nearbyTap:Touch2D = null;
			var minSqDist:Number = MULTITAP_DISTANCE * MULTITAP_DISTANCE;

			for each (var tap:Touch2D in _lastTaps)
			{
				var sqDist:Number = Math.pow(tap.globalX - touch.globalX, 2) + Math.pow(tap.globalY - touch.globalY, 2);
				if (sqDist <= minSqDist)
				{
					nearbyTap = tap;
					break;
				}
			}

			if (nearbyTap)
			{
				touch.setTapCount(nearbyTap.tapCount + 1);
				_lastTaps.splice(_lastTaps.indexOf(nearbyTap), 1);
			}
			else
			{
				touch.setTapCount(1);
			}

			_lastTaps.push(touch.clone());
		}


		private function addCurrentTouch(touch:Touch2D):void
		{
			for (var i:int = _currentTouches.length - 1; i >= 0; --i)
				if (_currentTouches[i].id == touch.id)
					_currentTouches.splice(i, 1);

			_currentTouches.push(touch);
		}


		private function getCurrentTouch(touchID:int):Touch2D
		{
			for each (var touch:Touch2D in _currentTouches)
				if (touch.id == touchID) return touch;
			return null;
		}


		public function get simulateMultitouch():Boolean
		{
			return _touchMarker != null;
		}


		public function set simulateMultitouch(value:Boolean):void
		{
			if (simulateMultitouch == value) return;
			// no change
			if (value)
			{
				_touchMarker = new TouchMarker2D();
				_touchMarker.visible = false;
				_stage2D.addChild(_touchMarker);
			}
			else
			{
				_touchMarker.removeFromParent(true);
				_touchMarker = null;
			}
		}


		// interruption handling
		private function monitorInterruptions(enable:Boolean):void
		{
			// if the application moves into the background or is interrupted (e.g. through
			// an incoming phone call), we need to abort all touches.

			try
			{
				var nativeAppClass:Object = getDefinitionByName("flash.desktop::NativeApplication");
				var nativeApp:EventDispatcher = nativeAppClass["nativeApplication"];

				if (enable)
					nativeApp.addEventListener("deactivate", onInterruption, false, 0, true);
				else
					nativeApp.removeEventListener("activate", onInterruption);
			}
			catch (e:Error)
			{
			}
			// we're not running in AIR
		}


		private function onInterruption(event:Object):void
		{
			var touch:Touch2D;

			// abort touches
			for each (touch in _currentTouches)
			{
				if (touch.phase == TouchPhase2D.BEGAN || touch.phase == TouchPhase2D.MOVED || touch.phase == TouchPhase2D.STATIONARY)
				{
					touch.setPhase(TouchPhase2D.ENDED);
				}
			}

			// dispatch events
			var touchEvent:TouchEvent2D = new TouchEvent2D(TouchEvent2D.TOUCH, _currentTouches, _shiftDown, _ctrlDown);

			for each (touch in _currentTouches)
				touch.dispatchEvent(touchEvent);

			// purge touches
			_currentTouches.length = 0;
		}
	}
}
