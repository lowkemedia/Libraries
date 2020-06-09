//
//  Rasterize v 1.7
//  Russell Lowke, February 6th 2009
//
//  Copyright (c) 2009 Lowke Media
//  see http://www.lowkemedia.com for more information
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER  
//  DEALINGS IN THE SOFTWARE. 
//
//

//      
//  Rasterize class
//
//  Converts a Sprite (or MovieClip) full of vector graphics to a bitmap, while 
//   keeping all instance names intact. This generally yields much better playback performance.
//
//  Usage:
//
//      import com.lowke.Rasterize;
//      Rasterize.makeBMP(displaySprite);
//
//   Set the showTrace flag to true if you want detailed output of what
//    has been converted to a BMP and what has not
//
//      Rasterize.makeBMP(displaySprite, true);
//
//    If you don't want any part of your displaySprite converted to a BMP, then set  
//      the instance name of a container (usually a MovieClip) containing that portion
//      to any name containing "dontBMP".  Usually though, this is not necessary.
//
//  Note:   -) Avoid using any instance names that contain "instance"
//                  --they will confuse Rasterize.
//          -) Bitmap data has to snap to pixels. You can’t render a bitmap on half a pixel.
//              This can result in a very slight wobble on displaySprites processed with 
//              Rasterize and then animated at fractional pixel velocities.
//          -) The maximum width and maximum height of any BitmapData object is 2880 pixels.
//              Generally, any vector this large will be comprised of smaller displayObjects,
//              so usually this is not a problem, but it can be an issue if a single 
//              displayObject has a height or width of > 2880 pixels.

package com.lowke
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    public class Rasterize 
    {
        public static var counter:uint;
        
        public static function doIt(dObj:Sprite, 
                                    showTrace:Boolean = false, 
                                    str:String = null):void 
        {
            if (! str) 
            {
                counter = 0;
                str = dObj.name + " >>";
            }
            
            var childObj:DisplayObject;
            for(var i:uint = 0; i < dObj.numChildren; ++i) 
            {
                childObj = dObj.getChildAt(i);
                if (childObj is MovieClip && ((childObj as MovieClip).totalFrames > 1)) 
                {
                    // skip the animated MovieClip layer but continue on to any children.
                    if (showTrace) 
                    {
                        trace(str + " " + i + "." + childObj.name + " SKIPPED MC");
                    }
                    
                    var mcChild:DisplayObject;
                    for(var j:uint = 0; j < (childObj as Sprite).numChildren; ++j) 
                    {
                        mcChild = (childObj as Sprite).getChildAt(j);
                        
                        if (mcChild is Sprite) 
                        {
                            doIt(mcChild as Sprite, showTrace, str + " " + i + "." + childObj.name + " >> " + j + "." + mcChild.name + " >>");
                        } 
                        else 
                        {
                            mcChild.cacheAsBitmap = true;
                            if (showTrace) 
                            {
                                trace(str + " " + i + "." + childObj.name + " >> " + j + "." + mcChild.name + " CONVERTED, rect " + childObj.getBounds(childObj));
                            }
                        }
                    }
                }  
                else if (isStatic(childObj)) 
                { 
                    if (childObj is Sprite) 
                    {
                        insertBMP(childObj as Sprite, showTrace, str + " " + i + ".");
                    } 
                    else 
                    {
                        replaceWithBMP(childObj, showTrace, str + " " + i + ".");
                    }
                } 
                else 
                {
                    doIt(childObj as Sprite, showTrace, str + " " + i + "." + childObj.name + " >>");
                }
            }
        }
        
        
        
        //
        // returns true if the DisplayObject and all its children are static (non-animating)
        //
        public static function isStatic(dObj:DisplayObject):Boolean 
        {
            if (dObj is MovieClip && ((dObj as MovieClip).totalFrames > 1)) 
            {
                // is a multi-frame MovieClip
                return false;
            } 
            else if (dObj is Sprite) 
            {
                // is a single frame MovieClip or Sprite, so step through children
                var sprite:Sprite = dObj as Sprite;
                for (var i:uint = 0; i < sprite.numChildren; ++i) 
                {
                    if (! isStatic(sprite.getChildAt(i))) 
                    {
                        return false;
                    }
                }
                return true;
            } 
            else 
            {
                // is a simple DisplayObject
                return true;
            }
        }
        
        
        //
        // General functions for converting vector graphics to BMPs
        
        
        //
        // returns a BMP version of the supplied DisplayObject
        //
        public static function returnBMP(dObj:DisplayObject, 
                                         showTrace:Boolean = false, 
                                         str:String = null):DisplayObject 
        {
            if (! dObj) 
            {
                return null;
            }
            
            // save the bounds and scale information 
            var rect:Rectangle = dObj.getBounds(dObj);
            var scaleX:Number = (! dObj.scaleX) ? 1 : dObj.scaleX;
            var scaleY:Number = (! dObj.scaleY) ? 1 : dObj.scaleY;
            var width:Number = Math.abs(rect.width*scaleX);
            var height:Number = Math.abs(rect.height*scaleY);
            
            // The maximum width and maximum height of a BitmapData object is 2880 pixels.
            if (width > 2880 || height > 2880) 
            {
                trace(str + dObj.name + " could not be converted to a BMP as it is larger than 2880 px high or wide.");
                return null;
            }
            
            // Can't have a BMP with with or height < 1
            if (width < 1 || height < 1) 
            {
                trace(str + dObj.name + " could not be converted to a BMP as it has a width < 1 px or height < 1 px.");
                return null;
            }
            
            // create a BitmapData canvas to draw onto
            var bit:BitmapData = new BitmapData(width, height, true, 0x00000000);
            
            // create transformation Matrix taking into account location and scale
            var matrix:Matrix = new Matrix();
            matrix.scale(scaleX, scaleY);
            matrix.translate(-rect.x*dObj.scaleX, -rect.y*dObj.scaleY);
            
            // unscale and draw the object
            dObj.scaleX = 1;
            dObj.scaleY = 1;
            bit.draw(dObj, matrix);
            
            // create bitmap at correct location and scale
            var bmpDObj:DisplayObject = new Bitmap(bit);
            bmpDObj.x = rect.x*scaleX;
            bmpDObj.y = rect.y*scaleY;
            bmpDObj.cacheAsBitmap = true;
            
            if (showTrace) 
            {
                trace(str + dObj.name + " converted to a BMP [#" + ++counter + "] with rect " + rect);
            }
            return bmpDObj;
        }
        
        //
        // Creates a BMP of the Sprite, clears the sprite of content, 
        //  and inserts the BMP into the Sprite
        public static function insertBMP(dObj:Sprite, 
                                         showTrace:Boolean = false, 
                                         str:String = null):Boolean 
        {
            // get bitmap version
            var bmpDObj:DisplayObject = returnBMP(dObj, showTrace, str);
            
            if (bmpDObj) 
            {
                // remove all existing children
                while(dObj.numChildren > 0) 
                {
                    dObj.removeChildAt(0);
                }
                
                // insert bitmap
                dObj.addChild(bmpDObj);
                return true;
            }
            return false;
        }
        
        //
        // Removes the DisplayObject from its parent and replaces it with a BMP
        //
        public static function replaceWithBMP(dObj:DisplayObject, 
                                              showTrace:Boolean = false, 
                                              str:String = null):DisplayObject 
        {
            // scale dObj if there is scaling information
            //  in its transformation matrix.
            var scaleX:Number = dObj.transform.matrix.a;
            var scaleY:Number = dObj.transform.matrix.d;
            dObj.scaleX = scaleX;
            dObj.scaleY = scaleY;
            
            // get bitmap version
            var bmpDObj:DisplayObject = returnBMP(dObj, showTrace, str);
            
            if (bmpDObj) 
            {
                bmpDObj.x = bmpDObj.x + dObj.x;
                bmpDObj.y = bmpDObj.y + dObj.y;
                
                var theParent:DisplayObjectContainer = dObj.parent;
                var index:uint = theParent.getChildIndex(dObj);
                theParent.removeChild(dObj);
                theParent.addChildAt(bmpDObj, index);
                return bmpDObj;
            }
            return null;
        }
        
        
        
        // cacheAsBitmap
        //____________________________________________________________
        //  -) DisplayObjects that are pragmatically animated in their scale, rotation, 
        //      or skew, will likely animate slower not faster after being processed with 
        //      Rasterize. This is because the Flash Player must both recalculate the vectors 
        //      and recreate the Bitmap instance every time the sprite is distorted.
        //      Essentially Rasterize only works on DisplayObjects that are being moved ONLY.
        //  -) Unfortunately Flash Player will also recalculate vectors on every key frame, 
        //      so, Rasterize is really only effective on largely static DisplayObjects or MovieClips 
        //      with few key frames in the animation.
        //  -) Setting cacheAsBitmap has been known to damage the concatenatedMatrix property
        //      which represents the combined transformation matrixes of the display object.
        //      for more information on this see,
        //      http://www.sephiroth.it/weblog/archives/2008/03/cacheasbitmap_hell.php
        
        public static function cacheAsBitmap(sprite:Sprite, 
                                             showTrace:Boolean = false, 
                                             str:String = null):void 
        {
            if (! str) { str = "\"" + sprite.name + "\" >>"; }
            
            // iterate through all the children on the sprite container
            for (var i:uint = 0; i < sprite.numChildren; ++i) 
            {
                var dObj:DisplayObject = sprite.getChildAt(i);
                var prefix:String = str + " #" + i + " \"" + dObj.name + "\"";
                var suffix:String = " [ x=" + dObj.x + ", y=" + dObj.y + ", w=" + dObj.width + ", h=" + dObj.height + " ]";
                
                if (isSafe(dObj)) 
                {
                    dObj.cacheAsBitmap = true;
                    if (showTrace) 
                    {
                        trace(prefix + " CONVERTED TO BITMAP." + suffix);
                    }
                    
                    // if dObj is not a sprite container, and it has a width or height of > 2880
                    //  then show a warning that it is too large to be converted to a bitmap.
                    //  This should be very rare as, although a container may be too large, its
                    //  end individual child components are probably not.
                    if (!(dObj is Sprite) && (dObj.width > 2880 || dObj.height > 2880)) 
                    {
                        trace("WARNING: " + dObj.name + " could not be converted to a bitmap as it is larger than 2880 px high or wide.");
                    }
                } 
                else if (showTrace) 
                {
                    trace(prefix + " SKIPPED." + suffix);
                }
                
                // if dObj is a container...
                if (dObj is Sprite) 
                {
                    // ...ensure its instance name does not contain "dontbmp"...
                    if (dObj.name.toLowerCase().indexOf("dontbmp") == -1) 
                    {
                        // ...and recursively drill down child items
                        cacheAsBitmap(dObj as Sprite, showTrace, prefix + " >>");
                    }
                }
            }
        }
        
        //
        // return true if it is safe to convert this DisplayObject to a bitmap
        private static function isSafe(dObj:DisplayObject):Boolean 
        {
            // ensure that all instance names contain "instance"
            if (dObj.name.indexOf("instance") == -1) 
            {
                return false;
            }
            
            // if a sprite container then recursively check if
            // all its children are safe
            var sprite:Sprite = dObj as Sprite;
            if (sprite) 
            {
                for (var i:uint = 0; i < sprite.numChildren; ++i) 
                {
                    if (! isSafe(sprite.getChildAt(i))) 
                    {
                        return false;
                    }
                }
            }
            return true;
        }
        //____________________________________________________________
    }
}