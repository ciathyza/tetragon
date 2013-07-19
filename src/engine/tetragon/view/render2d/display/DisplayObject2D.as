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
	import tetragon.core.exception.AbstractMethodException;
	import tetragon.util.geom.MatrixUtil;
	import tetragon.view.render2d.core.Render2D;
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.events.EventDispatcher2D;
	import tetragon.view.render2d.events.TouchEvent2D;
	import tetragon.view.render2d.filters.FragmentFilter2D;

	import flash.display3D.Context3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	
	/** Dispatched when an object is added to a parent. */
	[Event(name="added", type="tetragon.view.render2d.events.Event2D")]
	/** Dispatched when an object is connected to the stage (directly or indirectly). */
	[Event(name="addedToStage", type="tetragon.view.render2d.events.Event2D")]
	/** Dispatched when an object is removed from its parent. */
	[Event(name="removed", type="tetragon.view.render2d.events.Event2D")]
	/** Dispatched when an object is removed from the stage and won't be rendered any longer. */
	[Event(name="removedFromStage", type="tetragon.view.render2d.events.Event2D")]
	/** Dispatched once every frame on every object that is connected to the stage. */
	[Event(name="enterFrame", type="tetragon.view.render2d.events.EnterFrameEvent2D")]
	/** Dispatched when an object is touched. Bubbles. */
	[Event(name="touch", type="tetragon.view.render2d.events.TouchEvent2D")]
	
	
	/**
	 * The DisplayObject class is the base class for all objects that are rendered on the
	 * screen.
	 * <p>
	 * <strong>The Display Tree</strong>
	 * </p>
	 * <p>
	 * In Render2D, all displayable objects are organized in a display tree. Only objects
	 * that are part of the display tree will be displayed (rendered).
	 * </p>
	 * <p>
	 * The display tree consists of leaf nodes (Image, Quad) that will be rendered
	 * directly to the screen, and of container nodes (subclasses of
	 * "DisplayObjectContainer", like "Sprite"). A container is simply a display object
	 * that has child nodes - which can, again, be either leaf nodes or other containers.
	 * </p>
	 * <p>
	 * At the base of the display tree, there is the Stage, which is a container, too. To
	 * create a Render2D application, you create a custom Sprite subclass, and Render2D
	 * will add an instance of this class to the stage.
	 * </p>
	 * <p>
	 * A display object has properties that define its position in relation to its parent
	 * (x, y), as well as its rotation and scaling factors (scaleX, scaleY). Use the
	 * <code>alpha</code> and <code>visible</code> properties to make an object
	 * translucent or invisible.
	 * </p>
	 * <p>
	 * Every display object may be the target of touch events. If you don't want an object
	 * to be touchable, you can disable the "touchable" property. When it's disabled,
	 * neither the object nor its children will receive any more touch events.
	 * </p>
	 * <strong>Transforming coordinates</strong>
	 * <p>
	 * Within the display tree, each object has its own local coordinate system. If you
	 * rotate a container, you rotate that coordinate system - and thus all the children
	 * of the container.
	 * </p>
	 * <p>
	 * Sometimes you need to know where a certain point lies relative to another
	 * coordinate system. That's the purpose of the method
	 * <code>getTransformationMatrix</code>. It will create a matrix that represents the
	 * transformation of a point in one coordinate system to another.
	 * </p>
	 * <strong>Subclassing</strong>
	 * <p>
	 * Since DisplayObject is an abstract class, you cannot instantiate it directly, but
	 * have to use one of its subclasses instead. There are already a lot of them
	 * available, and most of the time they will suffice.
	 * </p>
	 * <p>
	 * However, you can create custom subclasses as well. That way, you can create an
	 * object with a custom render function. You will need to implement the following
	 * methods when you subclass DisplayObject:
	 * </p>
	 * <ul>
	 * <li><code>function render(support:RenderSupport, parentAlpha:Number):void</code></li>
	 * <li><code>function getBounds(targetSpace:DisplayObject, 
	 *                                 resultRect:Rectangle=null):Rectangle</code></li>
	 * </ul>
	 * <p>
	 * Have a look at the Quad class for a sample implementation of the 'getBounds'
	 * method. For a sample on how to write a custom render function, you can have a look
	 * at this <a
	 * href="http://wiki.Render2D-framework.org/manual/custom_display_objects">article</a>
	 * in the Render2D Wiki.
	 * </p>
	 * <p>
	 * When you override the render method, it is important that you call the method
	 * 'finishQuadBatch' of the support object. This forces Render2D to render all quads
	 * that were accumulated before by different render methods (for performance reasons).
	 * Otherwise, the z-ordering will be incorrect.
	 * </p>
	 * 
	 * @see DisplayObjectContainer2D
	 * @see Sprite2D
	 * @see Stage2D
	 */
	public class DisplayObject2D extends EventDispatcher2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public static var render2D:Render2D;
		public static var context3D:Context3D;
		
		private var _parent:DisplayObjectContainer2D;
		private var _transMatrix:Matrix;
		private var _filter:FragmentFilter2D;
		
		private var _x:Number;
		private var _y:Number;
		private var _pivotX:Number;
		private var _pivotY:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _skewX:Number;
		private var _skewY:Number;
		private var _rotation:Number;
		private var _alpha:Number;
		
		private var _orientationChanged:Boolean;
		private var _visible:Boolean;
		private var _touchable:Boolean;
		private var _useHandCursor:Boolean;
		
		private var _blendMode:String;
		private var _name:String;
		
		/** Helper objects. */
		private static var _ancestors:Vector.<DisplayObject2D> = new <DisplayObject2D>[];
		private static var _helperRect:Rectangle = new Rectangle();
		private static var _helperMatrix:Matrix = new Matrix();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Abstract class!
		 */
		public function DisplayObject2D()
		{
			_x = _y = _pivotX = _pivotY = _rotation = _skewX = _skewY = 0.0;
			_scaleX = _scaleY = _alpha = 1.0;
			_visible = _touchable = true;
			_orientationChanged = _useHandCursor = false;
			_blendMode = BlendMode2D.AUTO;
			_transMatrix = new Matrix();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes all resources of the display object. GPU buffers are released, event
		 * listeners are removed, filters are disposed.
		 */
		public function dispose():void
		{
			if (_filter) _filter.dispose();
			removeEventListeners();
		}


		/**
		 * Removes the object from its parent, if it has one.
		 */
		public function removeFromParent(dispose:Boolean = false):void
		{
			if (_parent) _parent.removeChild(this, dispose);
		}
		
		
		/**
		 * 
		 */
		public function bringToFront():void
		{
			if (!_parent) return;
			_parent.setChildIndex(this, _parent.numChildren);
		}
		
		
		/**
		 * Creates a matrix that represents the transformation from the local coordinate
		 * system to another. If you pass a 'resultMatrix', the result will be stored in
		 * this matrix instead of creating a new object.
		 * 
		 * @param targetSpace
		 * @param resultMatrix
		 */
		public function getTransformationMatrix(targetSpace:DisplayObject2D,
			resultMatrix:Matrix = null):Matrix
		{
			var commonParent:DisplayObject2D;
			var currentObject:DisplayObject2D;
			
			if (resultMatrix) resultMatrix.identity();
			else resultMatrix = new Matrix();
			
			if (targetSpace == this)
			{
				return resultMatrix;
			}
			else if (targetSpace == _parent || (!targetSpace && !_parent))
			{
				resultMatrix.copyFrom(transformationMatrix);
				return resultMatrix;
			}
			else if (!targetSpace || targetSpace == base)
			{
				// targetCoordinateSpace 'null' represents the target space of the base object.
				// -> move up from this to base.
				currentObject = this;
				while (currentObject != targetSpace)
				{
					resultMatrix.concat(currentObject.transformationMatrix);
					currentObject = currentObject._parent;
				}
				return resultMatrix;
			}
			else if (targetSpace._parent == this) // optimization
			{
				targetSpace.getTransformationMatrix(this, resultMatrix);
				resultMatrix.invert();
				return resultMatrix;
			}

			// 1. find a common parent of this and the target space.
			commonParent = null;
			currentObject = this;
			
			while (currentObject)
			{
				_ancestors.push(currentObject);
				currentObject = currentObject._parent;
			}
			
			currentObject = targetSpace;
			while (currentObject && _ancestors.indexOf(currentObject) == -1)
			{
				currentObject = currentObject._parent;
			}
			
			_ancestors.length = 0;
			
			if (currentObject) commonParent = currentObject;
			else throw new ArgumentError("Object not connected to target.");
			
			// 2. move up from this to common parent
			currentObject = this;
			while (currentObject != commonParent)
			{
				resultMatrix.concat(currentObject.transformationMatrix);
				currentObject = currentObject._parent;
			}
			
			if (commonParent == targetSpace) return resultMatrix;
			
			// 3. now move up from target until we reach the common parent.
			_helperMatrix.identity();
			currentObject = targetSpace;
			while (currentObject != commonParent)
			{
				_helperMatrix.concat(currentObject.transformationMatrix);
				currentObject = currentObject._parent;
			}
			
			// 4. now combine the two matrices.
			_helperMatrix.invert();
			resultMatrix.concat(_helperMatrix);
			
			return resultMatrix;
		}
		
		
		/**
		 * Returns a rectangle that completely encloses the object as it appears in
		 * another coordinate system. If you pass a 'resultRectangle', the result will be
		 * stored in this rectangle instead of creating a new object.
		 * 
		 * @param targetSpace
		 * @param resultRect
		 */
		public function getBounds(targetSpace:DisplayObject2D, resultRect:Rectangle = null):Rectangle
		{
			throw new AbstractMethodException();
			return null;
		}


		/**
		 * Returns the object that is found topmost beneath a point in local coordinates,
		 * or nil if the test fails. If "forTouch" is true, untouchable and invisible
		 * objects will cause the test to fail.
		 * 
		 * @param localPoint
		 * @param forTouch
		 */
		public function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject2D
		{
			// on a touch test, invisible or untouchable objects cause the test to fail
			if (forTouch && (!_visible || !_touchable)) return null;
			// otherwise, check bounding box
			if (getBounds(this, _helperRect).containsPoint(localPoint)) return this;
			else return null;
		}


		/**
		 * Transforms a point from the local coordinate system to global (stage)
		 * coordinates. If you pass a 'resultPoint', the result will be stored in this
		 * point instead of creating a new object.
		 * 
		 * @param localPoint
		 * @param resultPoint
		 */
		public function localToGlobal(localPoint:Point, resultPoint:Point = null):Point
		{
			getTransformationMatrix(base, _helperMatrix);
			return MatrixUtil.transformCoords(_helperMatrix, localPoint.x, localPoint.y,
				resultPoint);
		}
		
		
		/**
		 * Transforms a point from global (stage) coordinates to the local coordinate
		 * system. If you pass a 'resultPoint', the result will be stored in this point
		 * instead of creating a new object.
		 * 
		 * @param globalPoint
		 * @param resultPoint
		 */
		public function globalToLocal(globalPoint:Point, resultPoint:Point = null):Point
		{
			getTransformationMatrix(base, _helperMatrix);
			_helperMatrix.invert();
			return MatrixUtil.transformCoords(_helperMatrix, globalPoint.x, globalPoint.y,
				resultPoint);
		}
		
		
		/**
		 * Renders the display object with the help of a support object. Never call this
		 * method directly, except from within another render method.
		 * 
		 * @param support Provides utility functions for rendering.
		 * @param parentAlpha The accumulated alpha value from the object's parent up to
		 *            the stage.
		 */
		public function render(support:RenderSupport2D, parentAlpha:Number):void
		{
			throw new AbstractMethodException();
		}
		
		
		/**
		 * Allows to set scale X and scale y with one call.
		 */
		public function scale(value:Number):void
		{
			scaleX = scaleY = value;
		}
		
		
		/**
		 * 
		 */
		public function setTo(x:Number, y:Number, width:Number, height:Number):void
		{
			_x = x;
			_y = y;
			_orientationChanged = true;
			this.width = width;
			this.height = height;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if an object occupies any visible area. (Which is the case when its
		 * 'alpha', 'scaleX' and 'scaleY' values are not zero, and its 'visible' property
		 * is enabled.)
		 */
		public function get hasVisibleArea():Boolean
		{
			return _alpha != 0.0 && _visible && _scaleX != 0.0 && _scaleY != 0.0;
		}
		
		
		/**
		 * The transformation matrix of the object relative to its parent.
		 * <p>
		 * If you assign a custom transformation matrix, Render2D will try to figure out
		 * suitable values for <code>x, y, scaleX, scaleY,</code> and
		 * <code>rotation</code>. However, if the matrix was created in a different way,
		 * this might not be possible. In that case, Render2D will apply the matrix, but
		 * not update the corresponding properties.
		 * </p>
		 * 
		 * @return CAUTION: not a copy, but the actual object!
		 */
		public function get transformationMatrix():Matrix
		{
			if (_orientationChanged)
			{
				_orientationChanged = false;
				if (_skewX == 0.0 && _skewY == 0.0)
				{
					// optimization: no skewing / rotation simplifies the matrix math:
					if (_rotation == 0.0)
					{
						_transMatrix.setTo(_scaleX, 0.0, 0.0, _scaleY, _x - _pivotX * _scaleX,
							_y - _pivotY * _scaleY);
					}
					else
					{
						var cos:Number = Math.cos(_rotation);
						var sin:Number = Math.sin(_rotation);
						var a:Number = _scaleX * cos;
						var b:Number = _scaleX * sin;
						var c:Number = _scaleY * -sin;
						var d:Number = _scaleY * cos;
						var tx:Number = _x - _pivotX * a - _pivotY * c;
						var ty:Number = _y - _pivotX * b - _pivotY * d;
						_transMatrix.setTo(a, b, c, d, tx, ty);
					}
				}
				else
				{
					_transMatrix.identity();
					_transMatrix.scale(_scaleX, _scaleY);
					MatrixUtil.skew(_transMatrix, _skewX, _skewY);
					_transMatrix.rotate(_rotation);
					_transMatrix.translate(_x, _y);
					if (_pivotX != 0.0 || _pivotY != 0.0)
					{
						// prepend pivot transformation
						_transMatrix.tx = _x - _transMatrix.a * _pivotX - _transMatrix.c * _pivotY;
						_transMatrix.ty = _y - _transMatrix.b * _pivotX - _transMatrix.d * _pivotY;
					}
				}
			}
			return _transMatrix;
		}
		public function set transformationMatrix(v:Matrix):void
		{
			_orientationChanged = false;
			_transMatrix.copyFrom(v);

			_x = v.tx;
			_y = v.ty;

			_scaleX = Math.sqrt(v.a * v.a + v.b * v.b);
			_skewY = Math.acos(v.a / _scaleX);

			if (!isEquivalent(v.b, _scaleX * Math.sin(_skewY)))
			{
				_scaleX *= -1;
				_skewY = Math.acos(v.a / _scaleX);
			}

			_scaleY = Math.sqrt(v.c * v.c + v.d * v.d);
			_skewX = Math.acos(v.d / _scaleY);

			if (!isEquivalent(v.c, -_scaleY * Math.sin(_skewX)))
			{
				_scaleY *= -1;
				_skewX = Math.acos(v.d / _scaleY);
			}

			if (isEquivalent(_skewX, _skewY))
			{
				_rotation = _skewX;
				_skewX = _skewY = 0;
			}
			else
			{
				_rotation = 0;
			}
		}


		/**
		 * Indicates if the mouse cursor should transform into a hand while it's over the
		 * sprite.
		 * 
		 * @default false
		 */
		public function get useHandCursor():Boolean
		{
			return _useHandCursor;
		}
		public function set useHandCursor(v:Boolean):void
		{
			if (v == _useHandCursor) return;
			_useHandCursor = v;
			if (_useHandCursor) addEventListener(TouchEvent2D.TOUCH, onTouch);
			else removeEventListener(TouchEvent2D.TOUCH, onTouch);
		}
		
		
		/**
		 * The bounds of the object relative to the local coordinates of the parent.
		 */
		public function get bounds():Rectangle
		{
			return getBounds(_parent);
		}


		/**
		 * The width of the object in pixels.
		 */
		public function get width():Number
		{
			return getBounds(_parent, _helperRect).width;
		}
		public function set width(v:Number):void
		{
			// this method calls 'this.scaleX' instead of changing mScaleX directly.
			// that way, subclasses reacting on size changes need to override only the scaleX method.
			scaleX = 1.0;
			var actualWidth:Number = width;
			if (actualWidth != 0.0) scaleX = v / actualWidth;
		}


		/**
		 * The height of the object in pixels.
		 */
		public function get height():Number
		{
			return getBounds(_parent, _helperRect).height;
		}
		public function set height(v:Number):void
		{
			scaleY = 1.0;
			var actualHeight:Number = height;
			if (actualHeight != 0.0) scaleY = v / actualHeight;
		}


		/**
		 * The x coordinate of the object relative to the local coordinates of the parent.
		 */
		public function get x():Number
		{
			return _x;
		}
		public function set x(v:Number):void
		{
			if (_x != v)
			{
				_x = v;
				_orientationChanged = true;
			}
		}


		/**
		 * The y coordinate of the object relative to the local coordinates of the parent.
		 */
		public function get y():Number
		{
			return _y;
		}
		public function set y(v:Number):void
		{
			if (_y != v)
			{
				_y = v;
				_orientationChanged = true;
			}
		}


		/** The x coordinate of the object's origin in its own coordinate space (default: 0). */
		public function get pivotX():Number
		{
			return _pivotX;
		}


		public function set pivotX(v:Number):void
		{
			if (_pivotX != v)
			{
				_pivotX = v;
				_orientationChanged = true;
			}
		}


		/** The y coordinate of the object's origin in its own coordinate space (default: 0). */
		public function get pivotY():Number
		{
			return _pivotY;
		}


		public function set pivotY(v:Number):void
		{
			if (_pivotY != v)
			{
				_pivotY = v;
				_orientationChanged = true;
			}
		}


		/** The horizontal scale factor. '1' means no scale, negative values flip the object. */
		public function get scaleX():Number
		{
			return _scaleX;
		}
		public function set scaleX(v:Number):void
		{
			if (_scaleX != v)
			{
				_scaleX = v;
				_orientationChanged = true;
			}
		}


		/** The vertical scale factor. '1' means no scale, negative values flip the object. */
		public function get scaleY():Number
		{
			return _scaleY;
		}
		public function set scaleY(v:Number):void
		{
			if (_scaleY != v)
			{
				_scaleY = v;
				_orientationChanged = true;
			}
		}
		
		
		/** The horizontal skew angle in radians. */
		public function get skewX():Number
		{
			return _skewX;
		}
		public function set skewX(v:Number):void
		{
			v = normalizeAngle(v);

			if (_skewX != v)
			{
				_skewX = v;
				_orientationChanged = true;
			}
		}


		/** The vertical skew angle in radians. */
		public function get skewY():Number
		{
			return _skewY;
		}
		public function set skewY(v:Number):void
		{
			v = normalizeAngle(v);

			if (_skewY != v)
			{
				_skewY = v;
				_orientationChanged = true;
			}
		}


		/**
		 * The rotation of the object in radians. (In Render2D, all angles are measured in
		 * radians.)
		 */
		public function get rotation():Number
		{
			return _rotation;
		}
		public function set rotation(v:Number):void
		{
			v = normalizeAngle(v);

			if (_rotation != v)
			{
				_rotation = v;
				_orientationChanged = true;
			}
		}


		/** The opacity of the object. 0 = transparent, 1 = opaque. */
		public function get alpha():Number
		{
			return _alpha;
		}
		public function set alpha(v:Number):void
		{
			_alpha = v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);
		}


		/** The visibility of the object. An invisible object will be untouchable. */
		public function get visible():Boolean
		{
			return _visible;
		}
		public function set visible(v:Boolean):void
		{
			_visible = v;
		}


		/** Indicates if this object (and its children) will receive touch events. */
		public function get touchable():Boolean
		{
			return _touchable;
		}
		public function set touchable(v:Boolean):void
		{
			_touchable = v;
		}


		/**
		 * The blend mode determines how the object is blended with the objects
		 * underneath.
		 * 
		 * @default auto
		 * @see Render2D.display.BlendMode2D
		 */
		public function get blendMode():String
		{
			return _blendMode;
		}
		public function set blendMode(v:String):void
		{
			_blendMode = v;
		}


		/**
		 * The name of the display object (default: null). Used by 'getChildByName()' of
		 * display object containers.
		 */
		public function get name():String
		{
			return _name;
		}
		public function set name(v:String):void
		{
			_name = v;
		}


		/**
		 * The filter or filter group that is attached to the display object. The
		 * Render2D.filters package contains several classes that define specific filters
		 * you can use. Beware that you should NOT use the same filter on more than one
		 * object (for performance reasons).
		 */
		public function get filter():FragmentFilter2D
		{
			return _filter;
		}
		public function set filter(v:FragmentFilter2D):void
		{
			_filter = v;
		}


		/** The display object container that contains this display object. */
		public function get parent():DisplayObjectContainer2D
		{
			return _parent;
		}


		/** The topmost object in the display tree the object is part of. */
		public function get base():DisplayObject2D
		{
			var currentObject:DisplayObject2D = this;
			while (currentObject._parent)
			{
				currentObject = currentObject._parent;
			}
			return currentObject;
		}


		/**
		 * The root object the display object is connected to (i.e. an instance of the
		 * class that was passed to the Render2D constructor), or null if the object is
		 * not connected to the stage.
		 */
		public function get root():DisplayObject2D
		{
			var currentObject:DisplayObject2D = this;
			while (currentObject._parent)
			{
				if (currentObject._parent is Stage2D) return currentObject;
				else currentObject = currentObject.parent;
			}

			return null;
		}


		/**
		 * The stage the display object is connected to, or null if it is not connected to
		 * the stage.
		 */
		public function get stage():Stage2D
		{
			return base as Stage2D;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onTouch(e:TouchEvent2D):void
		{
			Mouse.cursor = e.interactsWith(this) ? MouseCursor.BUTTON : MouseCursor.AUTO;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Internal
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		internal function setParent(value:DisplayObjectContainer2D):void
		{
			// check for a recursion
			var ancestor:DisplayObject2D = value;
			while (ancestor != this && ancestor != null)
			{
				ancestor = ancestor._parent;
			}

			if (ancestor == this)
			{
				throw new ArgumentError("An object cannot be added as a child to itself or one"
					+ " of its children (or children's children, etc.)");
			}
			else
			{
				_parent = value;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------

		/**
		 * @private
		 */
		private final function isEquivalent(a:Number, b:Number, epsilon:Number = 0.0001):Boolean
		{
			return (a - epsilon < b) && (a + epsilon > b);
		}


		/**
		 * @private
		 */
		private final function normalizeAngle(angle:Number):Number
		{
			// move into range [-180 deg, +180 deg]
			while (angle < -Math.PI) angle += Math.PI * 2.0;
			while (angle > Math.PI) angle -= Math.PI * 2.0;
			return angle;
		}
	}
}
