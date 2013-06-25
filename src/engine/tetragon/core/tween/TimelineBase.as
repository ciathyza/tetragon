/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.tween
{
	
	
	/**
	 * TimelineBase is the base class for the TimelineLite and TimelineMax classes. It
	 * provides the most basic timeline functionality and is used for the root timelines
	 * in TweenLite. It is meant to be very fast and lightweight.
	 */
	public class TimelineBase extends TweenBase
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected var _firstChild:TweenBase;
		
		/** @private **/
		protected var _lastChild:TweenBase;
		
		/**
		 * If a timeline's autoRemoveChildren is true, its children will be removed and
		 * made eligible for garbage collection as soon as they complete. This is the
		 * default behavior for the main/root timeline.
		 */
		public var autoRemoveChildren:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param vars
		 */
		public function TimelineBase(tweenVars:TweenVars = null)
		{
			super(0, tweenVars);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Inserts a TweenLite, TweenMax, TimelineLite, or TimelineMax instance into the
		 * timeline at a specific time.
		 * 
		 * @param tween TweenLite, TweenMax, TimelineLite, or TimelineMax instance to
		 *            insert
		 * @param time The time in seconds (or frames for frames-based timelines) at which
		 *            the tween/timeline should be inserted. For example,
		 *            myTimeline.insert(myTween, 3) would insert myTween 3-seconds into
		 *            the timeline.
		 * @return TweenLite, TweenMax, TimelineLite, or TimelineMax instance that was
		 *         inserted
		 */
		public function insert(tween:TweenBase, time:* = 0):TweenBase
		{
			var prevTimeline:TimelineBase = tween.timeline;
			if (!tween.cachedOrphan && prevTimeline)
			{
				// removes from existing timeline so that it can be properly added to this one.
				prevTimeline.remove(tween, true);
			}
			tween.timeline = this;
			tween.cachedStartTime = Number(time) + tween.delay;
			if (tween.gc)
			{
				tween.setEnabled(true, true);
			}
			if (tween.cachedPaused && prevTimeline != this)
			{
				// we only adjust the cachedPauseTime if it wasn't in this timeline
				// already. Remember, sometimes a tween will be inserted again into
				// the same timeline when its startTime is changed so that the tweens
				// in the TimelineLite/Max are re-ordered properly in the linked list
				// (so everything renders in the proper order).
				tween.cachedPauseTime = tween.cachedStartTime
					+ ((rawTime - tween.cachedStartTime) / tween.cachedTimeScale);
			}
			
			if (_lastChild) _lastChild.nextNode = tween;
			else _firstChild = tween;
			
			tween.prevNode = _lastChild;
			_lastChild = tween;
			tween.nextNode = null;
			tween.cachedOrphan = false;
			return tween;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Reports the totalTime of the timeline without capping the number at the
		 * totalDuration (max) and zero (minimum) which can be useful when unpausing
		 * tweens/timelines. Imagine a case where a paused tween is in a timeline that has
		 * already reached the end, but then the tween gets unpaused - it needs a way to
		 * place itself accurately in time AFTER what was previously the timeline's end
		 * time. In a TimelineBase, rawTime is always the same as cachedTotalTime, but
		 * in TimelineLite and TimelineMax, it can be different.
		 * 
		 * @private
		 * 
		 * @return The totalTime of the timeline without capping the number at the
		 *         totalDuration (max) and zero (minimum)
		 */
		public function get rawTime():Number
		{
			return cachedTotalTime;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * @param tween
		 * @param skipDisable
		 */
		public function remove(tween:TweenBase, skipDisable:Boolean = false):void
		{
			if (tween.cachedOrphan)
			{
				// already removed!
				return;
			}
			else if (!skipDisable)
			{
				tween.setEnabled(false, true);
			}
			if (tween.nextNode)
			{
				tween.nextNode.prevNode = tween.prevNode;
			}
			else if (_lastChild == tween)
			{
				_lastChild = tween.prevNode;
			}
			if (tween.prevNode)
			{
				tween.prevNode.nextNode = tween.nextNode;
			}
			else if (_firstChild == tween)
			{
				_firstChild = tween.nextNode;
			}
			// don't null nextNode and prevNode, otherwise the chain
			// could break in rendering loops.
			tween.cachedOrphan = true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function renderTime(time:Number, suppressEvents:Boolean = false,
			force:Boolean = false):void
		{
			var tween:TweenBase = _firstChild, dur:Number, next:TweenBase;
			cachedTotalTime = time;
			cachedTime = time;
			
			while (tween)
			{
				next = tween.nextNode;
				// record it here because the value could change after rendering...
				if (tween.active || (time >= tween.cachedStartTime && !tween.cachedPaused && !tween.gc))
				{
					if (!tween.cachedReversed)
					{
						tween.renderTime((time - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
					}
					else
					{
						dur = (tween.cacheIsDirty) ? tween.totalDuration : tween.cachedTotalDuration;
						tween.renderTime(dur - ((time - tween.cachedStartTime) * tween.cachedTimeScale), suppressEvents, false);
					}
				}
				tween = next;
			}
		}
	}
}
