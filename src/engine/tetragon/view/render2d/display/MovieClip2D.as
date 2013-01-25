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
package tetragon.view.render2d.display
{
	import tetragon.view.render2d.animation.IAnimatable2D;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.errors.IllegalOperationError;
	import flash.media.Sound;
	
	
	/** Dispatched whenever the movie has displayed its last frame. */
	[Event(name="complete", type="tetragon.view.render2d.events.Event2D")]
	
	
	/** A MovieClip is a simple way to display an animation depicted by a list of textures.
	 *  
	 *  <p>Pass the frames of the movie in a vector of textures to the constructor. The movie clip 
	 *  will have the width and height of the first frame. If you group your frames with the help 
	 *  of a texture atlas (which is recommended), use the <code>getTextures</code>-method of the 
	 *  atlas to receive the textures in the correct (alphabetic) order.</p> 
	 *  
	 *  <p>You can specify the desired framerate via the constructor. You can, however, manually 
	 *  give each frame a custom duration. You can also play a sound whenever a certain frame 
	 *  appears.</p>
	 *  
	 *  <p>The methods <code>play</code> and <code>pause</code> control playback of the movie. You
	 *  will receive an event of type <code>Event.MovieCompleted</code> when the movie finished
	 *  playback. If the movie is looping, the event is dispatched once per loop.</p>
	 *  
	 *  <p>As any animated object, a movie clip has to be added to a juggler (or have its 
	 *  <code>advanceTime</code> method called regularly) to run. The movie will dispatch 
	 *  an event of type "Event.COMPLETE" whenever it has displayed its last frame.</p>
	 *  
	 *  @see Render2D.textures.TextureAtlas
	 */
	public class MovieClip2D extends Image2D implements IAnimatable2D
	{
		private var _textures:Vector.<Texture2D>;
		private var _sounds:Vector.<Sound>;
		private var _durations:Vector.<Number>;
		private var _startTimes:Vector.<Number>;
		private var _defaultFrameDuration:Number;
		private var _totalTime:Number;
		private var _currentTime:Number;
		private var _currentFrame:int;
		private var _loop:Boolean;
		private var _playing:Boolean;


		/** Creates a movie clip from the provided textures and with the specified default framerate.
		 *  The movie will have the size of the first frame. */
		public function MovieClip2D(textures:Vector.<Texture2D>, fps:Number = 12)
		{
			if (textures.length > 0)
			{
				super(textures[0]);
				init(textures, fps);
			}
			else
			{
				throw new ArgumentError("Empty texture array");
			}
		}


		private function init(textures:Vector.<Texture2D>, fps:Number):void
		{
			if (fps <= 0) throw new ArgumentError("Invalid fps: " + fps);
			var numFrames:int = textures.length;

			_defaultFrameDuration = 1.0 / fps;
			_loop = true;
			_playing = true;
			_currentTime = 0.0;
			_currentFrame = 0;
			_totalTime = _defaultFrameDuration * numFrames;
			_textures = textures.concat();
			_sounds = new Vector.<Sound>(numFrames);
			_durations = new Vector.<Number>(numFrames);
			_startTimes = new Vector.<Number>(numFrames);

			for (var i:int = 0; i < numFrames; ++i)
			{
				_durations[i] = _defaultFrameDuration;
				_startTimes[i] = i * _defaultFrameDuration;
			}
		}


		// frame manipulation
		/** Adds an additional frame, optionally with a sound and a custom duration. If the 
		 *  duration is omitted, the default framerate is used (as specified in the constructor). */
		public function addFrame(texture:Texture2D, sound:Sound = null, duration:Number = -1):void
		{
			addFrameAt(numFrames, texture, sound, duration);
		}


		/** Adds a frame at a certain index, optionally with a sound and a custom duration. */
		public function addFrameAt(frameID:int, texture:Texture2D, sound:Sound = null, duration:Number = -1):void
		{
			if (frameID < 0 || frameID > numFrames) throw new ArgumentError("Invalid frame id");
			if (duration < 0) duration = _defaultFrameDuration;

			_textures.splice(frameID, 0, texture);
			_sounds.splice(frameID, 0, sound);
			_durations.splice(frameID, 0, duration);
			_totalTime += duration;

			if (frameID > 0 && frameID == numFrames)
				_startTimes[frameID] = _startTimes[frameID - 1] + _durations[frameID - 1];
			else
				updateStartTimes();
		}


		/** Removes the frame at a certain ID. The successors will move down. */
		public function removeFrameAt(frameID:int):void
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			if (numFrames == 1) throw new IllegalOperationError("Movie clip must not be empty");

			_totalTime -= getFrameDuration(frameID);
			_textures.splice(frameID, 1);
			_sounds.splice(frameID, 1);
			_durations.splice(frameID, 1);

			updateStartTimes();
		}


		/** Returns the texture of a certain frame. */
		public function getFrameTexture(frameID:int):Texture2D
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			return _textures[frameID];
		}


		/** Sets the texture of a certain frame. */
		public function setFrameTexture(frameID:int, texture:Texture2D):void
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			_textures[frameID] = texture;
		}


		/** Returns the sound of a certain frame. */
		public function getFrameSound(frameID:int):Sound
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			return _sounds[frameID];
		}


		/** Sets the sound of a certain frame. The sound will be played whenever the frame 
		 *  is displayed. */
		public function setFrameSound(frameID:int, sound:Sound):void
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			_sounds[frameID] = sound;
		}


		/** Returns the duration of a certain frame (in seconds). */
		public function getFrameDuration(frameID:int):Number
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			return _durations[frameID];
		}


		/** Sets the duration of a certain frame (in seconds). */
		public function setFrameDuration(frameID:int, duration:Number):void
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			_totalTime -= getFrameDuration(frameID);
			_totalTime += duration;
			_durations[frameID] = duration;
			updateStartTimes();
		}


		// playback methods
		/** Starts playback. Beware that the clip has to be added to a juggler, too! */
		public function play():void
		{
			_playing = true;
		}


		/** Pauses playback. */
		public function pause():void
		{
			_playing = false;
		}


		/** Stops playback, resetting "currentFrame" to zero. */
		public function stop():void
		{
			_playing = false;
			currentFrame = 0;
		}


		// helpers
		private function updateStartTimes():void
		{
			var numFrames:int = this.numFrames;

			_startTimes.length = 0;
			_startTimes[0] = 0;

			for (var i:int = 1; i < numFrames; ++i)
				_startTimes[i] = _startTimes[i - 1] + _durations[i - 1];
		}


		// IAnimatable
		/** @inheritDoc */
		public function advanceTime(passedTime:Number):void
		{
			var finalFrame:int;
			var previousFrame:int = _currentFrame;
			var restTime:Number = 0.0;
			var breakAfterFrame:Boolean = false;

			if (_loop && _currentTime == _totalTime)
			{
				_currentTime = 0.0;
				_currentFrame = 0;
			}

			if (_playing && passedTime > 0.0 && _currentTime < _totalTime)
			{
				_currentTime += passedTime;
				finalFrame = _textures.length - 1;

				while (_currentTime >= _startTimes[_currentFrame] + _durations[_currentFrame])
				{
					if (_currentFrame == finalFrame)
					{
						if (hasEventListener(Event2D.COMPLETE))
						{
							if (_currentFrame != previousFrame)
								texture = _textures[_currentFrame];

							restTime = _currentTime - _totalTime;
							_currentTime = _totalTime;
							dispatchEventWith(Event2D.COMPLETE);
							breakAfterFrame = true;
						}

						if (_loop)
						{
							_currentTime -= _totalTime;
							_currentFrame = 0;
						}
						else
						{
							_currentTime = _totalTime;
							breakAfterFrame = true;
						}
					}
					else
					{
						_currentFrame++;
					}

					var sound:Sound = _sounds[_currentFrame];
					if (sound) sound.play();
					if (breakAfterFrame) break;
				}
			}

			if (_currentFrame != previousFrame)
				texture = _textures[_currentFrame];

			if (restTime)
				advanceTime(restTime);
		}


		/** Indicates if a (non-looping) movie has come to its end. */
		public function get isComplete():Boolean
		{
			return !_loop && _currentTime >= _totalTime;
		}


		// properties
		/** The total duration of the clip in seconds. */
		public function get totalTime():Number
		{
			return _totalTime;
		}


		/** The total number of frames. */
		public function get numFrames():int
		{
			return _textures.length;
		}


		/** Indicates if the clip should loop. */
		public function get loop():Boolean
		{
			return _loop;
		}


		public function set loop(value:Boolean):void
		{
			_loop = value;
		}


		/** The index of the frame that is currently displayed. */
		public function get currentFrame():int
		{
			return _currentFrame;
		}


		public function set currentFrame(value:int):void
		{
			_currentFrame = value;
			_currentTime = 0.0;

			for (var i:int = 0; i < value; ++i)
				_currentTime += getFrameDuration(i);

			texture = _textures[_currentFrame];
			if (_sounds[_currentFrame]) _sounds[_currentFrame].play();
		}


		/** The default number of frames per second. Individual frames can have different 
		 *  durations. If you change the fps, the durations of all frames will be scaled 
		 *  relatively to the previous value. */
		public function get fps():Number
		{
			return 1.0 / _defaultFrameDuration;
		}


		public function set fps(value:Number):void
		{
			if (value <= 0) throw new ArgumentError("Invalid fps: " + value);

			var newFrameDuration:Number = 1.0 / value;
			var acceleration:Number = newFrameDuration / _defaultFrameDuration;
			_currentTime *= acceleration;
			_defaultFrameDuration = newFrameDuration;

			for (var i:int = 0; i < numFrames; ++i)
			{
				var duration:Number = _durations[i] * acceleration;
				_totalTime = _totalTime - _durations[i] + duration;
				_durations[i] = duration;
			}

			updateStartTimes();
		}


		/** Indicates if the clip is still playing. Returns <code>false</code> when the end 
		 *  is reached. */
		public function get isPlaying():Boolean
		{
			if (_playing)
				return _loop || _currentTime < _totalTime;
			else
				return false;
		}
	}
}