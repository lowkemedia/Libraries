//
//  BitmapMovieClip v 1.2 - bitmapMovieClip package
//  Russell Lowke, June 1st 2011
//
//  Copyright (c) 2011 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke-animator/ for code repository
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

package com.lowke.bitmapMovieClip
{
    import com.lowke.logger.Logger;
    import com.lowke.playFrames.PlayFrames;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class BitmapMovieClip extends Sprite
    {
        // constants used for the align parameter of the constructor
        public static const ALIGN_CENTER:String   = "center";
        public static const ALIGN_TOP_LEFT:String = "top_left";
        
        // constants used for the type parameter of gotoAndPlay
        public static const TYPE_END:uint = PlayFrames.TYPE_END;                        // close() called when endFrame reached
        public static const TYPE_DESTROY:uint = PlayFrames.TYPE_DESTROY;                // close() called and view removed when endFrame reached
        public static const TYPE_CYCLE:uint = PlayFrames.TYPE_CYCLE;                    // cycles to the beginning when endFrame reached
        public static const TYPE_REVERSE:uint = PlayFrames.TYPE_REVERSE;                // reverses animation when endFrame reached
        
        // default frame rate used if stage can't be found
        public static const DEFAULT_FRAME_RATE:Number = 24; 
        
        protected var _image:Bitmap;
        protected var _images:Vector.<Bitmap>;
        protected var _offsets:Vector.<Point>;
        protected var _frame:uint;                        // current frame being displayed
        protected var _align:String = ALIGN_TOP_LEFT;
        
        public function BitmapMovieClip(images:Vector.<Bitmap>,
                                        align:String = ALIGN_TOP_LEFT,
                                        pixelSnapping:String = "auto", 
                                        smoothing:Boolean = false)
        {   
            super();
            
            _frame = 0;
            _images = images;
            _align = align;
            _image = new Bitmap(null, pixelSnapping, smoothing);
            addChild(_image);
            calcOffsets();
            setFrame(0);
        }
        
        public function calcOffsets():void {
            _offsets = new Vector.<Point>;
            for (var frame:uint = 0; frame < this.totalFrames; ++frame) 
            {
                var image:Bitmap = _images[frame];
                var pt:Point = new Point(0, 0);
                if (image && _align == ALIGN_CENTER) 
                {
                    pt.x = -image.width/2;
                    pt.y = -image.height/2;
                }
                _offsets.push(pt);
            }
        }
        
        // setting the frame works in C style notation, where
        //  0 is the first frame and length - 1 the last.
        public function setFrame(frame:uint):void {
            
            if (! totalFrames) 
            {
                return;     // there are no images in this clip
            } 
            else if (frame > _images.length - 1) 
            {
                frame = _images.length - 1;
            }
            
            _frame = frame;
            var bmp:Bitmap = _images[_frame];
            
            if (bmp) 
            {
                _image.bitmapData = bmp.bitmapData;
            } 
            else 
            {
                _image.bitmapData = null;
            }
            
            var offset:Point = _offsets[_frame];
            _image.x = offset.x;
            _image.y = offset.y;
        }
        
        // make a deep copy of this clip
        public function clone():BitmapMovieClip 
        {
            var imagesList:Vector.<Bitmap> = new Vector.<Bitmap>;
            for each (var bmp:Bitmap in _images) 
            {
                imagesList.push(new Bitmap(bmp.bitmapData.clone()));
            }
            return new BitmapMovieClip(imagesList, _align, _image.pixelSnapping, _image.smoothing);
        }
        
        //
        // make a shallow copy of this clip 
        //  if uniqueImageList parameter is false then copy uses the same _images list of frames
        public function shallowCopy(uniqueImageList:Boolean = false):BitmapMovieClip 
        {
            var imagesList:Vector.<Bitmap>;
            if (uniqueImageList) 
            {
                imagesList = new Vector.<Bitmap>;
                for each (var bmp:Bitmap in _images) 
                {
                    imagesList.push(new Bitmap(bmp.bitmapData));    // Note: bitmapData isn't cloned
                }
            } 
            else 
            {
                imagesList = _images;
            }
            
            return new BitmapMovieClip(imagesList, _align, _image.pixelSnapping, _image.smoothing);
        }
        
        
        //
        // The following methods are intentionally kept (somewhat) consistent 
        //  with the Flash MovieClip API.
        //
        
        public function play():void
        {
            gotoAndPlay(currentFrame);
        }
        
        // gotoAndPlay() is consistent with Flash MovieClip gotoAndPlay()
        //  in that the 1st frame is = 1 (not 0).
        // Possible values for the type parameter are  END, DESTROY, CYCLE, or REVERSE
        public function gotoAndPlay(frame:int, 
                                    frameRate:Number = NaN, 
                                    playEveryFrame:Boolean = false,
                                    type:uint = 1 /* CYCLE */):void {
            
            // first, goto the frame
            gotoAndStop(frame);
            
            if (isNaN(frameRate)) 
            {
                if (stage) 
                {
                    frameRate = stage.frameRate;
                } 
                else 
                {
                    frameRate = DEFAULT_FRAME_RATE;
                }
            }
            
            // then use PlayFrames to play
            PlayFrames.fps(this, frameRate, false, playEveryFrame, false, type);
        }
        
        public function stop():void
        {
            PlayFrames.removePlayFrames(this);
        }
        
        // gotoAndStop() is consistent with Flash MovieClip gotoAndStop()
        //  where the 1st frame is = 1 (not 0).
        public function gotoAndStop(frame:int):void {
            
            // frame = 1 is considered the 1st frame of the clip
            //  this is to keep consistency with MovieClip
            if (frame < 1) 
            {
                frame = 1;
            }
            
            // decrement frame as _frame starts at 0 not 1.
            --frame;
            
            setFrame(frame);
        }
        
        // get currentFrame is consistent with Flash MovieClip API
        //  where, most notably, currentFrame starts at 1 not 0
        public function get currentFrame():uint
        {
            return _frame + 1;
        }
        
        public function get totalFrames():uint
        { 
            return _images ? _images.length : 0; 
        }
        
        
        
        //
        // Static helper classes
        //
        
        //
        // takes a number of BitmapMovieClips and merges them into one
        public static function mergeClips(clips:Vector.<BitmapMovieClip>):BitmapMovieClip
        {
            var i:uint;
            var clip:BitmapMovieClip;
            var rect:Rectangle = new Rectangle();
            var pt:Point = new Point();
            var images:Vector.<Bitmap> = new Vector.<Bitmap>;
            
            // purge any empty clips
            for (i = 0; i < clips.length;) 
            {
                if (! clips[i]) 
                {
                    clips.splice(i, 1);
                } 
                else 
                {
                    ++i;
                }
            }
            
            if (! clips.length) 
            {
                // no clips to merge
                return new BitmapMovieClip(images);
            }
            
            // find the smallest totalFrames
            var totalFrames:uint = clips[0].totalFrames;
            for each(clip in clips) 
            {
                if (clip.totalFrames < totalFrames) 
                {
                    totalFrames = clip.totalFrames;
                    Logger.warning("Clip " + clip + " has too few frames when merging.");
                } 
                else if (clip.totalFrames > totalFrames) 
                {
                    Logger.warning("Clip " + clip + " has too many frames when merging.");
                }
            }
            
            // merge onto new images object
            for (i = 0; i < totalFrames; ++i) 
            {
                // find image size on this frame
                var height:Number = 1;  // minimum width and height for a Bitmap is 1
                var width:Number = 1;
                for each(clip in clips) 
                {
                    if (clip.images[i].height > height) 
                    {
                        height = clip.images[i].height;
                    }
                    
                    if (clip.images[i].width > width) 
                    {
                        width = clip.images[i].width;
                    }
                }
                
                // merge images
                var data:BitmapData = new BitmapData(width, height, true, 0);
                for each(clip in clips) 
                {
                    var bmp:Bitmap = clip.images[i];
                    rect.width = bmp.width;
                    rect.height = bmp.height;
                    
                    pt.x = (width - bmp.width)/2;
                    pt.y = (height - bmp.height)/2;
                    if (bmp.bitmapData) 
                    {
                        data.copyPixels(bmp.bitmapData, rect, pt, null, null, true);
                    }
                }
                var image:Bitmap = new Bitmap(data, clip.images[i].pixelSnapping, clip.images[i].smoothing);
                images.push(image);
            }
            
            clip = new BitmapMovieClip(images, clips[0].align);
            return clip;
        }
        
        //
        // assessors and mutators
        //
        public function get image():Bitmap                          { return _image; }
        public function get images():Vector.<Bitmap>                { return _images; }
        public function get align():String                          { return _align; }
        public function get frame():uint                            { return _frame; }
        public function get offsets():Vector.<Point>                { return _offsets; }
        
        public function set frame(val:uint):void                    { setFrame(val); }      // REMOVE?
        public function set offsets(val:Vector.<Point>):void        { _offsets = val; }
        public function set images(val:Vector.<Bitmap>):void 
        { 
            if (val != _images) 
            {
                _images = val;
                calcOffsets();
            }
        }
        public function set align(val:String):void 
        {
            if (val != _align) 
            {
                _align = val;
                calcOffsets();
            }
        }
    }
}