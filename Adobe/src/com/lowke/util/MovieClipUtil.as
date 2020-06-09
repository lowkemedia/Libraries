package com.lowke.util
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.FrameLabel;
	import flash.display.MovieClip;

	public class MovieClipUtil
	{
		// returned by getFrameNumber(), indicates no frame found with that label
		public static const NO_FRAME:int = 0;

		/**
		 * Returns the frame number of a specifc label on a MovieClip.
		 *
		 * @param clip The MovieClip with labels.
		 * @param label The label being searched for.
		 * @return Returns the frame number of the label, -1 returned if no label found.
		 */
		public static function getFrameNumber(clip:MovieClip,
											  label:String):uint
		{
			if (! clip)
			{
				return NO_FRAME;
			}

			var frameLabels:Array = clip.currentLabels;
			for (var i:uint = 0; i < frameLabels.length; ++i)
			{
				var frameLabel:FrameLabel = frameLabels[i];
				if (frameLabel.name == label)
				{
					return frameLabel.frame;
				}
			}
			return NO_FRAME;
		}


		/**
		 * Returns the next FrameLabel on a MovieClip after the current frame.
		 * If there is no next label then the last label is given.
		 *
		 * @param clip The MovieClip with labels.
		 */
		public static function getNextLabel(clip:MovieClip):FrameLabel
		{
			var frameLabels:Array = clip.currentLabels;
			if (! frameLabels.length)
			{
				return null;    // no frame labels
			}

			for (var i:uint = 0; i < frameLabels.length; ++i)
			{
				var frameLabel:FrameLabel = frameLabels[i];
				if (frameLabel.frame > clip.currentFrame)
				{
					return frameLabel;
				}
			}

			// otherwise return the last label
			return frameLabels[frameLabels.length - 1];
		}


		/**
		 * Goto the next label in a MovieClip
		 *
		 * @param clip The MovieClip with labels
		 */
		public static function gotoNextLabel(clip:MovieClip):void
		{
			var frameLabel:FrameLabel = getNextLabel(clip);
			if (frameLabel)
			{
				clip.gotoAndStop(frameLabel.frame);
			}
		}


		/**
		 * Returns the previous FrameLabel on a MovieClip before the current frame.
		 * If there is no previous label then the first label is given.
		 *
		 * @param clip The MovieClip with labels.
		 */
		public static function getPreviousLabel(clip:MovieClip):FrameLabel
		{
			var frameLabels:Array = clip.currentLabels;
			if (! frameLabels.length)
			{
				return null;    // no frame labels
			}

			var index:int;
			for (var i:uint = 0; i < frameLabels.length; ++i)
			{
				var frameLabel:FrameLabel = frameLabels[i];
				if (frameLabel.frame > clip.currentFrame)
				{
					return frameLabels[(i < 2) ? 0 : i - 2];
				}
			}

			// must be at or beyond the last label so
			//  return the second last label
			return frameLabels[(frameLabels.length > 2) ? frameLabels.length - 2 : 0];
		}


		/**
		 * Goto the previous label in a MovieClip
		 *
		 * @param clip The MovieClip with labels
		 */
		public static function gotoPreviousLabel(clip:MovieClip):void
		{
			var frameLabel:FrameLabel = getPreviousLabel(clip);
			if (frameLabel)
			{
				clip.gotoAndStop(frameLabel.frame);
			}
		}

		/**
		 * Recursively stop any MovieClip children attached to a DisplayObjectContainer
		 *
		 * @param container DisplayObjectContainer being stopped
		 */
		public static function recursiveStop(container:DisplayObjectContainer):void
		{
			for (var i:uint = 0; i < container.numChildren; ++i)
			{
				var child:DisplayObject = container.getChildAt(i);
				if (child is MovieClip)
				{
					(child as MovieClip).stop();
				}

				if (child is DisplayObjectContainer)
				{
					recursiveStop(child as DisplayObjectContainer);
				}
			}
		}
	}
}