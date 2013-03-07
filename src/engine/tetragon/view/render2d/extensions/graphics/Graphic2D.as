package tetragon.view.render2d.extensions.graphics
{
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.display.BlendMode2D;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.extensions.graphics.materials.IMaterial2D;
	import tetragon.view.render2d.extensions.graphics.materials.StandardMaterial2D;
	import tetragon.view.render2d.extensions.graphics.shaders.fragment.VertexColorFragmentShader2D;
	import tetragon.view.render2d.extensions.graphics.shaders.vertex.StandardVertexShader2D;

	import com.hexagonstar.exception.AbstractMethodException;
	import com.hexagonstar.exception.MissingContext3DException;

	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	/**
	 * Abstract, do not instantiate directly
	 * Used as a base-class for all the drawing API sub-display objects (Like Fill and Stroke).
	 */
	public class Graphic2D extends DisplayObject2D
	{
		protected static const VERTEX_STRIDE:int = 9;
		protected static var sHelperMatrix:Matrix = new Matrix();
		protected static var defaultVertexShader:StandardVertexShader2D;
		protected static var defaultFragmentShader:VertexColorFragmentShader2D;
		protected var _material:IMaterial2D;
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		protected var vertices:Vector.<Number>;
		protected var indices:Vector.<uint>;
		protected var _uvMatrix:Matrix;
		protected var isInvalid:Boolean = false;
		protected var uvsInvalid:Boolean = false;
		
		// Filled-out with min/max vertex positions
		// during addVertex(). Used during getBounds().
		protected var minBounds:Point;
		protected var maxBounds:Point;


		public function Graphic2D()
		{
			indices = new Vector.<uint>();
			vertices = new Vector.<Number>();

			if ( defaultVertexShader == null )
			{
				defaultVertexShader = new StandardVertexShader2D();
				defaultFragmentShader = new VertexColorFragmentShader2D();
			}
			_material = new StandardMaterial2D(defaultVertexShader, defaultFragmentShader);
			minBounds = new Point();
			maxBounds = new Point();

			//Render2D.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			onContextCreated(null);
		}


		private function onContextCreated(event:Event):void
		{
			isInvalid = true;
			uvsInvalid = true;
			_material.dispose();
		}


		override public function dispose():void
		{
			super.dispose();

			if ( vertexBuffer )
			{
				vertexBuffer.dispose();
				vertexBuffer = null;
			}

			if ( indexBuffer )
			{
				indexBuffer.dispose();
				indexBuffer = null;
			}

			if ( material )
			{
				material.dispose();
				material = null;
			}
		}


		public function set material(value:IMaterial2D):void
		{
			_material = value;
		}


		public function get material():IMaterial2D
		{
			return _material;
		}


		public function get uvMatrix():Matrix
		{
			return _uvMatrix;
		}


		public function set uvMatrix(value:Matrix):void
		{
			_uvMatrix = value;
			uvsInvalid = true;
		}


		public function shapeHitTest(stageX:Number, stageY:Number):Boolean
		{
			var pt:Point = globalToLocal(new Point(stageX, stageY));
			return pt.x >= minBounds.x && pt.x <= maxBounds.x && pt.y >= minBounds.y && pt.y <= maxBounds.y;
		}


		override public function getBounds(targetSpace:DisplayObject2D, resultRect:Rectangle = null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();

			if (targetSpace == this) // optimization
			{
				resultRect.x = minBounds.x;
				resultRect.y = minBounds.y;
				resultRect.right = maxBounds.x;
				resultRect.bottom = maxBounds.y;
				return resultRect;
			}

			getTransformationMatrix(targetSpace, sHelperMatrix);
			var m:Matrix = sHelperMatrix;

			var tr:Point = new Point(minBounds.x + (maxBounds.x - minBounds.x), minBounds.y);
			var bl:Point = new Point(minBounds.x, minBounds.y + (maxBounds.y - minBounds.y));

			var TL:Point = sHelperMatrix.transformPoint(minBounds.clone());
			tr = sHelperMatrix.transformPoint(tr);
			var BR:Point = sHelperMatrix.transformPoint(maxBounds.clone());
			bl = sHelperMatrix.transformPoint(bl);

			resultRect.x = Math.min(TL.x, BR.x, tr.x, bl.x);
			resultRect.y = Math.min(TL.y, BR.y, tr.y, bl.y);
			resultRect.right = Math.max(TL.x, BR.x, tr.x, bl.x);
			resultRect.bottom = Math.max(TL.y, BR.y, tr.y, bl.y);

			return resultRect;
		}


		protected function buildGeometry():void
		{
			throw( new AbstractMethodException() );
		}


		protected function applyUVMatrix():void
		{
			if ( !vertices ) return;
			if ( !_uvMatrix ) return;

			var uv:Point = new Point();
			for ( var i:int = 0; i < vertices.length; i += VERTEX_STRIDE )
			{
				uv.x = vertices[i + 7];
				uv.y = vertices[i + 8];
				uv = _uvMatrix.transformPoint(uv);
				vertices[i + 7] = uv.x;
				vertices[i + 8] = uv.y;
			}
		}


		protected function validateNow():void
		{
			if ( vertexBuffer && (isInvalid || uvsInvalid) )
			{
				vertexBuffer.dispose();
				indexBuffer.dispose();
			}

			if ( isInvalid )
			{
				buildGeometry();
				applyUVMatrix();
			}
			else if ( uvsInvalid )
			{
				applyUVMatrix();
			}
		}


		override public function render(renderSupport:RenderSupport2D, parentAlpha:Number):void
		{
			validateNow();

			if ( indices.length < 3 ) return;

			if ( isInvalid || uvsInvalid )
			{
				// Upload vertex/index buffers.
				var numVertices:int = vertices.length / VERTEX_STRIDE;
				vertexBuffer = RenderSupport2D.context3D.createVertexBuffer(numVertices, VERTEX_STRIDE);
				vertexBuffer.uploadFromVector(vertices, 0, numVertices);
				indexBuffer = RenderSupport2D.context3D.createIndexBuffer(indices.length);
				indexBuffer.uploadFromVector(indices, 0, indices.length);

				isInvalid = uvsInvalid = false;
			}

			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			renderSupport.finishQuadBatch();

			var context:Context3D = RenderSupport2D.context3D;
			if (context == null) throw new MissingContext3DException();

			RenderSupport2D.setBlendFactors(false, this.blendMode == BlendMode2D.AUTO ? renderSupport.blendMode : this.blendMode);
			_material.drawTriangles(RenderSupport2D.context3D, renderSupport.mvpMatrix3D, vertexBuffer, indexBuffer, parentAlpha * this.alpha);

			context.setTextureAt(0, null);
			context.setTextureAt(1, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}
	}
}
