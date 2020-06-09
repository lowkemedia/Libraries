//
//  CacheAsBitmap v 1.6
//  Russell Lowke, July 25th 2009
// 
//  Copyright (c) 2009 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke/ for code repository
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
//  CacheAsBitmap class
//
//  CacheAsBitmap corrects an issue with the cacheAsBitmap flag of Flash
//  DisplayObject, where setting this flag fails to also set it for all its 
//  embedded children. CacheAsBitmap recursivly sets all flags for all embedded 
//  children while keeping those instance names of the DisplayObject's children 
//  intact for access by code.
//
//  CacheAsBitmap generally yields a much faster playback performance for 
//  static or semi-static DisplayObjects containing large complex vectors, 
//  often a threefold or greater improvement.
//
//  Complicated vector images, although slow to draw, sometimes have a 
//  smaller file size than as a bitmap, in such cases, CacheAsBitmap becomes 
//  useful as the image can be stored as the smaller vector, but displayed 
//  to screen as the faster bitmap.   
//
//  Usage:
//
//      import com.lowke.CacheAsBitmap;
//      CacheAsBitmap.doIt(displaySprite);
//
//  If you don't want any part of your display Sprite set to cacheAsBitmap, then 
//  set the instance name of a container (usually a MovieClip) containing that 
//  portion to any name containing "dontBMP".  Usually though, this is not 
//  necessary.
//
//  Note:   1) Avoid using any instance names that contain "instance"
//                  --they will confuse CacheAsBitmap.
//              Flash automatically names generated instances using the prefix 
//              "instance", such as "instance276". This fact is taken advantage 
//              of by CacheAsBitmap. If you name an instance with a name 
//              containing "instance" CacheAsBitmap will think that it was 
//              automatically generated, and will try to permit its conversion 
//              to a bitmap when it shouldn't.
//          2) displayObjects that have many animated key frames or animate in 
//              their scale, rotation, or skew, might well animate slower not 
//              faster after being processed with CacheAsBitmap. This is 
//              because the Flash Player must both recalculate the vectors and 
//              recreate the Bitmap instance every time the sprite is changed. 
//              CacheAsBitmap works best with complex, largely static vector 
//              artwork.
//          3) Bitmaps must snap to pixels. You can't render a bitmap on 
//              half a pixel. This can result in a very slight wobble on 
//              displayObjects processed with CacheAsBitmap and then animated 
//              at fractional pixel velocities.
//          4) The maximum width and maximum height of any BitmapData object is 
//              2880 pixels. Generally, any vector this large will be comprised 
//              of smaller displayObjects, so usually this is not a problem.
//

package com.lowke
{
    import com.lowke.logger.Logger;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    public class CacheAsBitmap 
    {
        public static function doIt(sprite:Sprite):void 
        {
            if (! sprite) 
            {
                Logger.warning("Can't perform CacheAsBitmap on a null sprite");
                return;
            }
            
            // iterate through all the children on the sprite container
            for(var i:uint = 0; i < sprite.numChildren; ++i) 
            {
                var dObj:DisplayObject = sprite.getChildAt(i);
                
                if (isSafe(dObj)) 
                {
                    // if safe to do so, set the cacheAsBitmap flag to true,
                    //  this tells Flash to display the Sprite in its rendering 
                    //  pipeline using a cached bitmap, rather than rendering as 
                    //  a vector.
                    dObj.cacheAsBitmap = true;
                    
                    // if dObj is not a sprite container, and it has a width or 
                    //  height of > 2880 then print a warning that it is too 
                    //  large to be converted to a bitmap. This should be very 
                    //  rare as, although a root container may be too large, its
                    //  end individual child containers are probably not.
                    if (!(dObj is Sprite) && (dObj.width > 2880 || dObj.height > 2880)) 
                    {
                        trace("WARNING: " + dObj.name + " could not be converted to a bitmap as it is larger than 2880 px high or wide.");
                    }
                }
                
                // if dObj is a sprite container
                if (dObj is Sprite) 
                {
                    // ensure its instance name does not contain "dontbmp"
                    if (dObj.name.toLowerCase().indexOf("dontbmp") == -1) 
                    {
                        // and recursively drill down child items
                        doIt(dObj as Sprite);
                    }
                }
            }
        }
        
        //
        // return true if it is safe to convert this DisplayObject to a bitmap
        private static function isSafe(dObj:DisplayObject):Boolean 
        {
            // ensure DisplayObject was generated by Flash, its instance
            //  name containing "instance"
            if (dObj.name.indexOf("instance") == -1) 
            {
                // "instance" not found in instance name
                return false;
            }
            
            // if a sprite container, then recursively check if
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
    }
}