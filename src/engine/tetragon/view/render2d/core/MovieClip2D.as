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
	import flash.errors.IllegalOperationError;
	import flash.media.Sound;
	import tetragon.view.render2d.core.events.Event2D;

	
	
	/**
	 * A MovieClip2D is a simple way to display an animation depicted by a list of textures.
	 * 
	 * <p>
	 * Pass the frames of the movie in a vector of textures to the constructor. The movie
	 * clip will have the width and height of the first frame. If you group your frames
	 * with the help of a texture atlas (which is recommended), use the
	 * <code>getTextures</code>-method of the atlas to receive the textures in the correct
	 * (alphabetic) order.
	 * </p>
	 * 
	 * <p>
	 * You can specify the desired framerate via the constructor. You can, however,
	 * manually give each frame a custom duration. You can also play a sound whenever a
	 * certain frame appears.
	 * </p>
	 * 
	 * <p>
	 * The methods <code>play</code> and <code>pause</code> control playback of the movie.
	 * You will receive an event of type <code>Event.MovieCompleted</code> when the movie
	 * finished playback. If the movie is looping, the event is dispatched once per loop.
	 * </p>
	 * 
	 * <p>
	 * As any animated object, a movie clip has to be added to a juggler (or have its
	 * <code>advanceTime</code> method called regularly) to run. The movie will dispatch
	 * an event of type "Event.COMPLETE" whenever it has displayed its last frame.
	 * </p>
	 * 
	 * @see starling.textures.TextureAtlas2D
	 */
	public class MovieClip2D extends Image2D implements IAnimatable2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _textures:Vector.<Texture2D>;
		/** @private */
		private var _sounds:Vector.<Sound>;
		/** @private */
		private var _durations:Vector.<Number>;
		/** @private */
		private var _startTimes:Vector.<Number>;
		/** @private */
		private var _defaultFrameDuration:Number;
		/** @private */
		private var _totalTime:Number;
		/** @private */
		private var _currentTime:Number;
		/** @private */
		private var _currentFrame:int;
		/** @private */
		private var _loop:Boolean;
		/** @private */
		private var _playing:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a moviclip from the provided textures and with the specified default
		 * framerate. The movie will have the size of the first frame.
		 * 
		 * @param textures
		 * @param fps
		 */
		public function MovieClip2D(textures:Vector.<Texture2D>, fps:Number = 12)
		{
			if (textures && textures.length > 0)
			{
				super(textures[0]);
				_defaultFrameDuration = 1.0 / fps;
				_loop = true;
				_playing = true;
				_totalTime = 0.0;
				_currentTime = 0.0;
				_currentFrame = 0;
				_textures = new <Texture2D>[];
				_sounds = new <Sound>[];
				_durations = new <Number>[];
				_startTimes = new <Number>[];

				for each (var t:Texture2D in textures)
				{
					addFrame(t);
				}
			}
			else
			{
				throw new ArgumentError("Null or empty texture array.");
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds an additional frame, optionally with a sound and a custom duration. If the
		 * duration is omitted, the default framerate is used (as specified in the
		 * constructor).
		 * 
		 * @param texture
		 * @param sound
		 * @param duration
		 */
		public function addFrame(texture:Texture2D, sound:Sound = null, duration:Number = -1):void
		{
			addFrameAt(_textures.length, texture, sound, duration);
		}


		/**
		 * Adds a frame at a certain index, optionally with a sound and a custom duration.
		 * 
		 * @param frameID
		 * @param texture
		 * @param sound
		 * @param duration
		 */
		public function addFrameAt(frameID:int, texture:Texture2D, sound:Sound = null,
			duration:Number = -1):void
		{
			if (frameID < 0 || frameID > _textures.length) throwFrameIDException(frameID);
			if (duration < 0) duration = _defaultFrameDuration;
			if (frameID > 0 && frameID == _textures.length)
			{
				_startTimes[frameID] = _startTimes[frameID - 1] + _durations[frameID - 1];
			}
			else
			{
				updateStartTimes();
			}
			
			_textures.splice(frameID, 0, texture);
			_sounds.splice(frameID, 0, sound);
			_durations.splice(frameID, 0, duration);
			_totalTime += duration;
		}
		
		
		/**
		 * Removes the frame at a certain ID. The successors will move down.
		 * 
		 * @param frameID
		 */
		public function removeFrameAt(frameID:int):void
		{
			if (frameID < 0 || frameID >= _textures.length) throwFrameIDException(frameID);
			if (_textures.length == 1) throw new IllegalOperationError("MovieClip2D must not be empty.");
			_totalTime -= getFrameDuration(frameID);
			_textures.splice(frameID, 1);
			_sounds.splice(frameID, 1);
			_durations.splice(frameID, 1);
			updateStartTimes();
		}
		
		
		/**
		 * Returns the texture of a certain frame.
		 * 
		 * @param frameID
		 * @return Texture2D
		 */
		public function getFrameTexture(frameID:int):Texture2D
		{
			if (frameID < 0 || frameID >= _textures.length) throwFrameIDException(frameID);
			return _textures[frameID];
		}
		
		
		/**
		 * Sets the texture of a certain frame.
		 * 
		 * @param frameID
		 * @param texture
		 */
		public function setFrameTexture(frameID:int, texture:Texture2D):void
		{
			if (frameID < 0 || frameID >= _textures.length) throwFrameIDException(frameID);
			_textures[frameID] = texture;
		}
		
		
		/**
		 * Returns the sound of a certain frame.
		 * 
		 * @param frameID
		 * @return Sound
		 */
		public function getFrameSound(frameID:int):Sound
		{
			if (frameID < 0 || frameID >= _textures.length) throwFrameIDException(frameID);
			return _sounds[frameID];
		}


		/**
		 * Sets the sound of a certain frame. The sound will be played whenever the frame
		 * is displayed.
		 * 
		 * @param frameID
		 * @param sound
		 */
		public function setFrameSound(frameID:int, sound:Sound):void
		{
			if (frameID < 0 || frameID >= _textures.length) throwFrameIDException(frameID);
			_sounds[frameID] = sound;
		}
		
		
		/**
		 * Returns the duration of a certain frame (in seconds).
		 * 
		 * @param frameID
		 * @return Number
		 */
		public function getFrameDuration(frameID:int):Number
		{
			if (frameID < 0 || frameID >= _textures.length) throwFrameIDException(frameID);
			return _durations[frameID];
		}
		
		
		/**
		 * Sets the duration of a certain frame (in seconds).
		 * 
		 * @param frameID
		 * @param duration
		 */
		public function setFrameDuration(frameID:int, duration:Number):void
		{
			if (frameID < 0 || frameID >= _textures.length) throwFrameIDException(frameID);
			_totalTime -= getFrameDuration(frameID);
			_totalTime += duration;
			_durations[frameID] = duration;
			updateStartTimes();
		}
		
		
		/**
		 * Starts playback. Beware that the clip has to be added to a juggler, too!
		 */
		public function play():void
		{
			_playing = true;
		}
		
		
		/**
		 * Pauses playback.
		 */
		public function pause():void
		{
			_playing = false;
		}
		
		
		/**
		 * Stops playback, resetting "currentFrame" to zero.
		 */
		public function stop():void
		{
			_playing = false;
			currentFrame = 0;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function advanceTime(passedTime:Number):void
		{
			if (_loop && _currentTime == _totalTime) _currentTime = 0.0;
			if (!_playing || passedTime == 0.0 || _currentTime == _totalTime) return;
			
			_currentTime += passedTime;
			
			var numFrames:int = _textures.length;
			var previousFrame:int = _currentFrame;
			
			while (_currentTime >= _startTimes[_currentFrame] + _durations[_currentFrame])
			{
				if (++_currentFrame == numFrames)
				{
					if (hasEventListener(Event2D.COMPLETE))
					{
						dispatchEvent(new Event2D(Event2D.COMPLETE));
						
						/* User might have stopped movie in event handler. */
						if (!_playing)
						{
							_currentTime = _totalTime;
							_currentFrame = numFrames - 1;
							break;
						}
					}
					
					if (_loop)
					{
						_currentTime -= _totalTime;
						_currentFrame = 0;
					}
					else
					{
						_currentTime = _totalTime;
						_currentFrame = numFrames - 1;
						break;
					}
				}
			}
			
			if (_currentFrame != previousFrame)
			{
				texture = _textures[_currentFrame];
				if (_sounds[_currentFrame]) _sounds[_currentFrame].play();
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if a (non-looping) movie has come to its end.
		 */
		public function get isComplete():Boolean
		{
			return !_loop && _currentTime >= _totalTime;
		}
		
		
		/**
		 * The total duration of the clip in seconds.
		 */
		public function get totalTime():Number
		{
			return _totalTime;
		}
		
		
		/**
		 * The total number of frames.
		 */
		public function get numFrames():uint
		{
			return _textures.length;
		}
		
		
		/**
		 * Indicates if the clip should loop.
		 */
		public function get loop():Boolean
		{
			return _loop;
		}
		public function set loop(v:Boolean):void
		{
			_loop = v;
		}
		
		
		/**
		 * The index of the frame that is currently displayed.
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}
		public function set currentFrame(v:int):void
		{
			_currentFrame = v;
			_currentTime = 0.0;
			for (var i:int = 0; i < v; ++i)
			{
				_currentTime += getFrameDuration(i);
			}
			texture = _textures[_currentFrame];
			if (_sounds[_currentFrame]) _sounds[_currentFrame].play();
		}
		
		
		/**
		 * The default number of frames per second. Individual frames can have different
		 * durations. If you change the fps, the durations of all frames will be scaled
		 * relatively to the previous value.
		 */
		public function get fps():Number
		{
			return 1.0 / _defaultFrameDuration;
		}
		public function set fps(v:Number):void
		{
			var dur:Number = v == 0.0 ? Number.MAX_VALUE : 1.0 / v;
			var acc:Number = dur / _defaultFrameDuration;
			_currentTime *= acc;
			_defaultFrameDuration = dur;
			for (var i:uint = 0; i < _textures.length; ++i)
			{
				setFrameDuration(i, getFrameDuration(i) * acc);
			}
		}
		
		
		/**
		 * Indicates if the clip is still playing. Returns <code>false</code> when the end
		 * is reached.
		 */
		public function get isPlaying():Boolean
		{
			if (_playing) return _loop || _currentTime < _totalTime;
			else return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function updateStartTimes():void
		{
			var n:int = numFrames;
			_startTimes.length = 0;
			_startTimes[0] = 0;
			for (var i:int = 1; i < n; ++i)
			{
				_startTimes[i] = _startTimes[i - 1] + _durations[i - 1];
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param frameID
		 * @param total
		 */
		protected static function throwFrameIDException(frameID:int):void
		{
			throw new ArgumentError("Invalid frameID: " + frameID
				+ ". The frameID must be between 0 and numFrames.");
		}
	}
}
