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
	import com.hexagonstar.exception.AbstractClassException;
	import com.hexagonstar.exception.AbstractMethodException;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import tetragon.view.render2d.core.events.Event2D;
	import tetragon.view.render2d.core.events.EventDispatcher2D;
	import tetragon.view.render2d.core.events.TouchEvent2D;


	
	
	/**
	 * The DisplayObject class is the base class for all objects that are rendered on the
	 * screen.
	 * 
	 * <p>
	 * <strong>The Display Tree</strong>
	 * </p>
	 * 
	 * <p>
	 * In Starling, all displayable objects are organized in a display tree. Only objects
	 * that are part of the display tree will be displayed (rendered).
	 * </p>
	 * 
	 * <p>
	 * The display tree consists of leaf nodes (Image, Quad) that will be rendered
	 * directly to the screen, and of container nodes (subclasses of
	 * "DisplayObjectContainer", like "Sprite"). A container is simply a display object
	 * that has child nodes - which can, again, be either leaf nodes or other containers.
	 * </p>
	 * 
	 * <p>
	 * At the root of the display tree, there is the Stage, which is a container, too. To
	 * create a Starling application, you create a custom Sprite subclass, and Starling
	 * will add an instance of this class to the stage.
	 * </p>
	 * 
	 * <p>
	 * A display object has properties that define its position in relation to its parent
	 * (x, y), as well as its rotation and scaling factors (scaleX, scaleY). Use the
	 * <code>alpha</code> and <code>visible</code> properties to make an object
	 * translucent or invisible.
	 * </p>
	 * 
	 * <p>
	 * Every display object may be the target of touch events. If you don't want an object
	 * to be touchable, you can disable the "touchable" property. When it's disabled,
	 * neither the object nor its children will receive any more touch events.
	 * </p>
	 * 
	 * <strong>Transforming coordinates</strong>
	 * 
	 * <p>
	 * Within the display tree, each object has its own local coordinate system. If you
	 * rotate a container, you rotate that coordinate system - and thus all the children
	 * of the container.
	 * </p>
	 * 
	 * <p>
	 * Sometimes you need to know where a certain point lies relative to another
	 * coordinate system. That's the purpose of the method
	 * <code>getTransformationMatrix</code>. It will create a matrix that represents the
	 * transformation of a point in one coordinate system to another.
	 * </p>
	 * 
	 * <strong>Subclassing</strong>
	 * 
	 * <p>
	 * Since DisplayObject is an abstract class, you cannot instantiate it directly, but
	 * have to use one of its subclasses instead. There are already a lot of them
	 * available, and most of the time they will suffice.
	 * </p>
	 * 
	 * <p>
	 * However, you can create custom subclasses as well. That way, you can create an
	 * object with a custom render function. You will need to implement the following
	 * methods when you subclass DisplayObject:
	 * </p>
	 * 
	 * <ul>
	 * <li><code>function render(support:RenderSupport, alpha:Number):void</code></li>
	 * <li><code>function getBounds(targetSpace:DisplayObject, 
	 *                                 resultRect:Rectangle=null):Rectangle</code></li>
	 * </ul>
	 * 
	 * <p>
	 * Have a look at the Quad class for a sample implementation of the 'getBounds'
	 * method. For a sample on how to write a custom render function, you can have a look
	 * at the <a
	 * href="https://github.com/PrimaryFeather/Starling-Extension-Particle-System"
	 * >particle system extension</a>.
	 * </p>
	 * 
	 * <p>
	 * When you override the render method, it is important that you call the method
	 * 'finishQuadBatch' of the support object. This forces Starling to render all quads
	 * that were accumulated before by different render methods (for performance reasons).
	 * Otherwise, the z-ordering will be incorrect.
	 * </p>
	 * 
	 * @see DisplayObjectContainer
	 * @see Sprite
	 * @see Stage
	 */
	public class DisplayObject2D extends EventDispatcher2D
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private var _x:Number;
		/** @private */
		private var _y:Number;
		/** @private */
		private var _pivotX:Number;
		/** @private */
		private var _pivotY:Number;
		/** @private */
		private var _scaleX:Number;
		/** @private */
		private var _scaleY:Number;
		/** @private */
		private var _rotation:Number;
		/** @private */
		private var _alpha:Number;
		/** @private */
		private var _visible:Boolean;
		/** @private */
		private var _touchable:Boolean;
		/** @private */
		private var _name:String;
		/** @private */
		private var _lastTouchTimestamp:Number;
		/** @private */
		private var _parent:DisplayObjectContainer2D;
		
		/* Helper objects. */
		
		/** @private */
		private static var _ancestors:Vector.<DisplayObject2D> = new <DisplayObject2D>[];
		/** @private */
		private static var _helperRect:Rectangle = new Rectangle();
		/** @private */
		private static var _helperMatrix:Matrix = new Matrix();
		/** @private */
		private static var _targetMatrix:Matrix = new Matrix();
		/** @private */
		protected static var _rectCount:int = 0;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function DisplayObject2D()
		{
			if (getQualifiedClassName(this) == "starling.display::DisplayObject")
			{
				throw new AbstractClassException(this);
			}
			
			_x = _y = _pivotX = _pivotY = _rotation = 0.0;
			_scaleX = _scaleY = _alpha = 1.0;
			_visible = _touchable = true;
			_lastTouchTimestamp = -1;
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Disposes all resources of the display object. GPU buffers are released, event
		 * listeners are removed.
		 */
		public function dispose():void
		{
			removeEventListeners();
		}
		
		
		/**
		 * Removes the object from its parent, if it has one.
		 * 
		 * @param dispose
		 */
		public function removeFromParent(dispose:Boolean = false):void
		{
			if (_parent) _parent.removeChild(this);
			if (dispose) this.dispose();
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
			if (resultMatrix) resultMatrix.identity();
			else resultMatrix = new Matrix();
			
			if (targetSpace == this)
			{
				return resultMatrix;
			}
			else if (targetSpace == _parent || (targetSpace == null && _parent == null))
			{
				if (_pivotX != 0.0 || _pivotY != 0.0) resultMatrix.translate(-_pivotX, -_pivotY);
				if (_scaleX != 1.0 || _scaleY != 1.0) resultMatrix.scale(_scaleX, _scaleY);
				if (_rotation != 0.0) resultMatrix.rotate(_rotation);
				if (_x != 0.0 || _y != 0.0) resultMatrix.translate(_x, _y);
				return resultMatrix;
			}
			else if (targetSpace == null)
			{
				// targetCoordinateSpace 'null' represents the target space of the root object.
				// -> move up from this to root
				currentObject = this;
				while (currentObject)
				{
					currentObject.getTransformationMatrix(currentObject._parent, _helperMatrix);
					resultMatrix.concat(_helperMatrix);
					currentObject = currentObject.parent;
				}
				return resultMatrix;
			}
			else if (targetSpace._parent == this) // optimization
			{
				targetSpace.getTransformationMatrix(this, resultMatrix);
				resultMatrix.invert();
				return resultMatrix;
			}
			
			// 1. find a common parent of this and the target space
			_ancestors.length = 0;
			var commonParent:DisplayObject2D = null;
			var currentObject:DisplayObject2D = this;
			while (currentObject)
			{
				_ancestors.push(currentObject);
				currentObject = currentObject.parent;
			}
			
			currentObject = targetSpace;
			while (currentObject && _ancestors.indexOf(currentObject) == -1)
			{
				currentObject = currentObject.parent;
			}
			
			if (currentObject == null)
			{
				throw new ArgumentError("Object not connected to target");
			}
			else
			{
				commonParent = currentObject;
			}
			
			// 2. move up from this to common parent
			currentObject = this;
			while (currentObject != commonParent)
			{
				currentObject.getTransformationMatrix(currentObject._parent, _helperMatrix);
				resultMatrix.concat(_helperMatrix);
				currentObject = currentObject.parent;
			}
			
			// 3. now move up from target until we reach the common parent
			_targetMatrix.identity();
			currentObject = targetSpace;
			while (currentObject != commonParent)
			{
				currentObject.getTransformationMatrix(currentObject._parent, _helperMatrix);
				_targetMatrix.concat(_helperMatrix);
				currentObject = currentObject.parent;
			}
			
			// 4. now combine the two matrices
			_targetMatrix.invert();
			resultMatrix.concat(_targetMatrix);

			return resultMatrix;
		}
		
		
		/**
		 * Returns a rectangle that completely encloses the object as it appears in
		 * another coordinate system. If you pass a 'resultRectangle', the result will be
		 * stored in this rectangle instead of creating a new object.
		 * 
		 * @param targetSpace
		 * @param resultRect
		 * @return Rectangle
		 */
		public function getBounds(targetSpace:DisplayObject2D, resultRect:Rectangle = null):Rectangle
		{
			/* Abstract method! */
			throw new AbstractMethodException("Method is abstract!");
			return null;
		}
		
		
		/**
		 * Returns the object that is found topmost beneath a point in local coordinates,
		 * or nil if the test fails. If "forTouch" is true, untouchable and invisible
		 * objects will cause the test to fail.
		 * 
		 * @param localPoint
		 * @param forTouch
		 * @return DisplayObject
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
		 * coordinates.
		 * 
		 * @param localPoint
		 * @return Point
		 */
		public function localToGlobal(localPoint:Point):Point
		{
			// move up  until parent is null
			_targetMatrix.identity();
			var currentObject:DisplayObject2D = this;
			while (currentObject)
			{
				currentObject.getTransformationMatrix(currentObject._parent, _helperMatrix);
				_targetMatrix.concat(_helperMatrix);
				currentObject = currentObject.parent;
			}
			return _targetMatrix.transformPoint(localPoint);
		}
		
		
		/**
		 * Transforms a point from global (stage) coordinates to the local coordinate
		 * system.
		 * 
		 * @param globalPoint
		 * @return Point
		 */
		public function globalToLocal(globalPoint:Point):Point
		{
			// move up until parent is null, then invert matrix
			_targetMatrix.identity();
			var currentObject:DisplayObject2D = this;
			while (currentObject)
			{
				currentObject.getTransformationMatrix(currentObject._parent, _helperMatrix);
				_targetMatrix.concat(_helperMatrix);
				currentObject = currentObject.parent;
			}
			_targetMatrix.invert();
			return _targetMatrix.transformPoint(globalPoint);
		}
		
		
		/**
		 * Renders the display object with the help of a support object. Never call this
		 * method directly, except from within another render method.
		 * 
		 * @param support Provides utility functions for rendering.
		 * @param alpha The accumulated alpha value from the object's parent up to the
		 *            stage.
		 */
		public function renderWithSupport(support:Render2DRenderSupport, alpha:Number):void
		{
			/* Abstract method! */
			throw new AbstractMethodException("Method is abstract!");
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function dispatchEvent(e:Event2D):void
		{
			// on one given moment, there is only one set of touches -- thus,
			// we process only one touch event with a certain timestamp per frame
			if (e is TouchEvent2D)
			{
				var touchEvent:TouchEvent2D = e as TouchEvent2D;
				if (touchEvent.timestamp == _lastTouchTimestamp) return;
				else _lastTouchTimestamp = touchEvent.timestamp;
			}
			
			super.dispatchEvent(e);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The transformation matrix of the object relative to its parent.
		 */
		public function get transformationMatrix():Matrix
		{
			return getTransformationMatrix(_parent);
		}
		
		
		/**
		 * The bounds of the object relative to the local coordinates of the parent.
		 */
		public function get bounds():Rectangle
		{
			return getBounds(_parent);
		}
		
		
		/**
		 * The width of the object, in pixels.
		 */
		public function get width():Number
		{
			return getBounds(_parent, _helperRect).width;
		}
		public function set width(v:Number):void
		{
			// this method calls 'this.scaleX' instead of changing mScaleX directly.
			// that way, subclasses reacting on size changes need to override only the scaleX method.
			_scaleX = 1.0;
			var actualWidth:Number = width;
			if (actualWidth != 0.0) scaleX = v / actualWidth;
			else scaleX = 1.0;
		}
		
		
		/**
		 * The height of the object, in pixels.
		 */
		public function get height():Number
		{
			return getBounds(_parent, _helperRect).height;
		}
		public function set height(v:Number):void
		{
			_scaleY = 1.0;
			var actualHeight:Number = height;
			if (actualHeight != 0.0) scaleY = v / actualHeight;
			else scaleY = 1.0;
		}
		
		
		/**
		 * The topmost object in the display tree the object is part of.
		 */
		public function get root():DisplayObject2D
		{
			var d:DisplayObject2D = this;
			while (d.parent) d = d.parent;
			return d;
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
			_x = v;
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
			_y = v;
		}
		
		
		/**
		 * The x coordinate of the object's origin in its own coordinate space (default: 0).
		 */
		public function get pivotX():Number
		{
			return _pivotX;
		}
		public function set pivotX(v:Number):void
		{
			_pivotX = v;
		}
		
		
		/**
		 * The y coordinate of the object's origin in its own coordinate space (default: 0).
		 */
		public function get pivotY():Number
		{
			return _pivotY;
		}
		public function set pivotY(v:Number):void
		{
			_pivotY = v;
		}
		
		
		/**
		 * The horizontal scale factor. '1' means no scale, negative values flip the object.
		 */
		public function get scaleX():Number
		{
			return _scaleX;
		}
		public function set scaleX(v:Number):void
		{
			_scaleX = v;
		}
		
		
		/**
		 * The vertical scale factor. '1' means no scale, negative values flip the object.
		 */
		public function get scaleY():Number
		{
			return _scaleY;
		}
		public function set scaleY(v:Number):void
		{
			_scaleY = v;
		}
		
		
		/**
		 * The rotation of the object in radians. (all angles are measured in radians).
		 */
		public function get rotation():Number
		{
			return _rotation;
		}
		public function set rotation(v:Number):void
		{
			// move into range [-180 deg, +180 deg]
			while (v < -Math.PI) v += Math.PI * 2.0;
			while (v > Math.PI) v -= Math.PI * 2.0;
			_rotation = v;
		}
		
		
		/**
		 * The opacity of the object. 0 = transparent, 1 = opaque.
		 */
		public function get alpha():Number
		{
			return _alpha;
		}
		public function set alpha(v:Number):void
		{
			_alpha = v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);
		}
		
		
		/**
		 * The visibility of the object. An invisible object will be untouchable.
		 */
		public function get visible():Boolean
		{
			return _visible;
		}
		public function set visible(v:Boolean):void
		{
			_visible = v;
		}
		
		
		/**
		 * Indicates if this object (and its children) will receive touch events.
		 */
		public function get touchable():Boolean
		{
			return _touchable;
		}
		public function set touchable(v:Boolean):void
		{
			_touchable = v;
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
		 * The display object container that contains this display object.
		 */
		public function get parent():DisplayObjectContainer2D
		{
			return _parent;
		}
		
		
		/**
		 * The stage the display object is connected to, or null if it is not connected to
		 * a stage.
		 */
		public function get stage():Stage2D
		{
			return this.root as Stage2D;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		internal function setParent(v:DisplayObjectContainer2D):void
		{
			// check for a recursion
			var ancestor:DisplayObject2D = v;
			while (ancestor != this && ancestor != null)
			{
				ancestor = ancestor._parent;
			}
			
			if (ancestor == this)
			{
				throw new ArgumentError("An object cannot be added as a child to itself or one "
					+ "of its children (or children's children, etc.)");
			}
			else
			{
				_parent = v;
			}
		}
		
		
		/**
		 * @private
		 */
		internal function dispatchEventOnChildren(e:Event2D):void
		{
			dispatchEvent(e);
		}
	}
}
