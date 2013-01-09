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
package tetragon.view.render2d.core.events
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import tetragon.view.render2d.core.Image2D;
	import tetragon.view.render2d.core.Sprite2D;
	import tetragon.view.render2d.core.Texture2D;



    
    /** The TouchMarker is used internally to mark touches created through "simulateMultitouch". */
    internal class TouchMarker2D extends Sprite2D
    {
        private static var TouchMarkerBmp:Class;
        
        private var mCenter:Point;
        private var mTexture:Texture2D;
        
        public function TouchMarker2D()
        {
            mCenter = new Point();
            mTexture = Texture2D.fromBitmap(new Bitmap(new BitmapData(20, 20, true, 0x55FF00FF)));
            
            for (var i:int=0; i<2; ++i)
            {
                var marker:Image2D = new Image2D(mTexture);
                marker.pivotX = mTexture.width / 2;
                marker.pivotY = mTexture.height / 2;
                marker.touchable = false;
                addChild(marker);
            }
        }
        
        public override function dispose():void
        {
            mTexture.dispose();
            super.dispose();
        }
        
        public function moveMarker(x:Number, y:Number, withCenter:Boolean=false):void
        {
            if (withCenter)
            {
                mCenter.x += x - realMarker.x;
                mCenter.y += y - realMarker.y;
            }
            
            realMarker.x = x;
            realMarker.y = y;
            mockMarker.x = 2*mCenter.x - x;
            mockMarker.y = 2*mCenter.y - y;
        }
        
        public function moveCenter(x:Number, y:Number):void
        {
            mCenter.x = x;
            mCenter.y = y;
            moveMarker(realX, realY); // reset mock position
        }
        
        private function get realMarker():Image2D { return getChildAt(0) as Image2D; }
        private function get mockMarker():Image2D { return getChildAt(1) as Image2D; }
        
        public function get realX():Number { return realMarker.x; }
        public function get realY():Number { return realMarker.y; }
        
        public function get mockX():Number { return mockMarker.x; }
        public function get mockY():Number { return mockMarker.y; }
    }        
}