package view.pseudo3d
{
	import view.racing.vo.PPoint;
	/**
	 * Util
	 * @author Hexagon
	 */
	public class Util
	{
		public static function timestamp():Number
		{
			return new Date().getTime();
		}
		
		
		public static function toInt(obj:*, def:*):int
		{
			if (obj != null)
			{
				var x:int = parseInt(obj, 10);
				if (!isNaN(x)) return x;
			}
			return toInt(def, 0);
		}
		
		
		public static function toFloat(obj:*, def:Number = NaN):Number
		{
			if (obj != null)
			{
				var x:Number = parseFloat(obj);
				if (!isNaN(x)) return x;
			}
			return toFloat(def, 0.0);
		}
		
		
		public static function limit(value:Number, min:Number, max:Number):Number
		{
			return Math.max(min, Math.min(value, max));
		}
		
		
		public static function randomInt(min:Number, max:Number):int
		{
			return Math.round(interpolate(min, max, Math.random()));
		}
		
		
		public static function randomChoice(options:Array):*
		{
			return options[randomInt(0, options.length - 1)];
		}


		public static function percentRemaining(n:Number, total:Number):Number
		{
			return (n % total) / total;
		}


		public static function accelerate(v:Number, accel:Number, dt:Number):Number
		{
			return v + (accel * dt);
		}


		public static function interpolate(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * percent;
		}


		public static function easeIn(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * Math.pow(percent, 2);
		}


		public static function easeOut(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * (1 - Math.pow(1 - percent, 2));
		}


		public static function easeInOut(a:Number, b:Number, percent:Number):Number
		{
			return a + (b - a) * ((-Math.cos(percent * Math.PI) / 2) + 0.5);
		}


		public static function exponentialFog(distance:Number, density:Number):Number
		{
			return 1 / (Math.pow(Math.E, (distance * distance * density)));
		}


		public static function increase(start:Number, increment:Number, max:Number):Number
		{
			var result:Number = start + increment;
			while (result >= max) result -= max;
			while (result < 0) result += max;
			return result;
		}
		
		
		public static function project(p:PPoint, cameraX:Number, cameraY:Number, cameraZ:Number,
			cameraDepth:Number, width:Number, height:Number, roadWidth:Number):void
		{
			p.camera.x = (p.world.x || 0) - cameraX;
			p.camera.y = (p.world.y || 0) - cameraY;
			p.camera.z = (p.world.z || 0) - cameraZ;
			p.screen.scale = cameraDepth / p.camera.z;
			p.screen.x = Math.round((width / 2) + (p.screen.scale * p.camera.x * width / 2));
			p.screen.y = Math.round((height / 2) - (p.screen.scale * p.camera.y * height / 2));
			p.screen.w = Math.round((p.screen.scale * roadWidth * width / 2));
		}
		
		
		public static function overlap(x1:Number, w1:Number, x2:Number, w2:Number, percent:Number = 1.0):Boolean
		{
			var half:Number = percent / 2;
			var min1:Number = x1 - (w1 * half);
			var max1:Number = x1 + (w1 * half);
			var min2:Number = x2 - (w2 * half);
			var max2:Number = x2 + (w2 * half);
			return !((max1 < min2) || (min1 > max2));
		}
	}
}
