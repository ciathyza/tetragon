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
    /** A KeyboardEvent is dispatched in response to user input through a keyboard.
     * 
     *  <p>This is Starling's version of the Flash KeyboardEvent class. It contains the same 
     *  properties as the Flash equivalent.</p> 
     * 
     *  <p>To be notified of keyboard events, add an event listener to the Starling stage. Children
     *  of the stage won't be notified of keybaord input. Starling has no concept of a "Focus"
     *  like native Flash.</p>
     *  
     *  @see starling.display.Stage
     */  
    public class KeyboardEvent2D extends Event2D
    {
        /** Event type for a key that was released. */
        public static const KEY_UP:String = "keyUp";
        
        /** Event type for a key that was pressed. */
        public static const KEY_DOWN:String = "keyDown";
        
        private var mCharCode:uint;
        private var mKeyCode:uint;
        private var mKeyLocation:uint;
        private var mAltKey:Boolean;
        private var mCtrlKey:Boolean;
        private var mShiftKey:Boolean;
        
        /** Creates a new KeyboardEvent. */
        public function KeyboardEvent2D(type:String, charCode:uint=0, keyCode:uint=0, 
                                      keyLocation:uint=0, ctrlKey:Boolean=false, 
                                      altKey:Boolean=false, shiftKey:Boolean=false)
        {
            super(type, false);
            mCharCode = charCode;
            mKeyCode = keyCode;
            mKeyLocation = keyLocation;
            mCtrlKey = ctrlKey;
            mAltKey = altKey;
            mShiftKey = shiftKey;
        }
        
        /** Contains the character code of the key. */
        public function get charCode():uint { return mCharCode; }
        
        /** The key code of the key. */
        public function get keyCode():uint { return mKeyCode; }
        
        /** Indicates the location of the key on the keyboard. This is useful for differentiating 
         *  keys that appear more than once on a keyboard. @see Keylocation */ 
        public function get keyLocation():uint { return mKeyLocation; }
        
        /** Indicates whether the Alt key is active on Windows or Linux; 
         *  indicates whether the Option key is active on Mac OS. */
        public function get altKey():Boolean { return mAltKey; }
        
        /** Indicates whether the Ctrl key is active on Windows or Linux; 
         *  indicates whether either the Ctrl or the Command key is active on Mac OS. */
        public function get ctrlKey():Boolean { return mCtrlKey; }
        
        /** Indicates whether the Shift key modifier is active (true) or inactive (false). */
        public function get shiftKey():Boolean { return mShiftKey; }
    }
}