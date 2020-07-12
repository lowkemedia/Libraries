//
//  VideoController - Video package
//  Russell Lowke, June 16th 2020
//
//  Copyright (c) 2020 Lowke Media
//  see https://github.com/lowkemedia/Libraries for more information
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

using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;

public class VideoController : MonoBehaviour
{
    public delegate void Callback();

    public VideoPlayer videoPlayer;
    public RenderTexture renderTexture;

    public Slider videoSeekSlider;
    public ClickButton pauseButton;
    public ClickButton playButton;
	public ClickButton muteButton;
	public ClickButton soundButton;

	private bool _videoPrepared;					// true if the video is prepared and ready to play
	private long _pauseFrame;                       // frame the video was last paused on

	//
	// easy to use callbacks
	public Callback VideoPreparedCallback { get; set; }         // TODO: use UnityEvent? e.g. see ClickButton
	public Callback VideoFinishedCallback { get; set; }

	public bool IsPaused { get; private set; }

	//
	// video frame as a percentage
	private float VideoValue {
		get { return (float)videoPlayer.frame/videoPlayer.frameCount; }
	}

	//
	// slider percentage as a frame
	private long SliderFrame {
		get { return (long)(videoSeekSlider.value * videoPlayer.frameCount); }
	}

	private void Start()
    {
        if (videoPlayer == null) {
            // if no video player declared, then find one
            //  videoPlayer = GetComponent<VideoPlayer>();
            //  gameObject.GetComponent(typeof(VideoPlayer)) as VideoPlayer;

            // if no video player found, then make one
            //  videoPlayer = gameObject.AddComponent<UnityEngine.Video.VideoPlayer>();

            throw new Exception("Video Player not assigned.");
        }

        // add listeners
        pauseButton.onClick.AddListener(OnClickPause);
        playButton.onClick.AddListener(OnClickPlay);
        muteButton.onClick.AddListener(OnClickToggleSound);
        soundButton.onClick.AddListener(OnClickToggleSound);
        videoSeekSlider.onValueChanged.AddListener(OnSliderChanged);
        // Note: BeginDrag and EndDrag listeners added via EventTrigger in Unity Editor

        pauseButton.gameObject.SetActive(true);
        playButton.gameObject.SetActive(false);

        // setup mute/sound toggle buttons
        if (!videoPlayer.canSetDirectAudioVolume) {
			muteButton.gameObject.SetActive(false);
		} else {
			muteButton.gameObject.SetActive(true);
		}
		soundButton.gameObject.SetActive(false);
	}

	private void Update()
	{
		if (videoPlayer.isPlaying &&
			videoPlayer.frame != _pauseFrame) {         // fix for videoPlayer.frame latency lingers on old _pauseFrame
			videoSeekSlider.value = VideoValue;         // update position of slider
		}
	}

	public void Play(VideoClip clip)
    {
        if (videoPlayer.clip != clip) {
            _videoPrepared = false;
            videoPlayer.clip = clip;
        }

        Play();
    }

    public void Play(string url)
    {
        if (videoPlayer.url != url) {
            _videoPrepared = false;
            videoPlayer.url = url;
        }

        Play();
    }

    public void Play()
    {
		VideoPlayerPlay();
		SetIsPaused(false);
	}

	private void VideoPlayerPlay()
	{
		if (!_videoPrepared) {
			VideoPlayerPrepare();
			return;
		}

		if (SliderFrame == (long)videoPlayer.frameCount) {
			// fix for issue where video played at end loops to start
			return;
		}
	
		videoPlayer.Play();
	}

    private void VideoPlayerPrepare()
    {
        videoPlayer.prepareCompleted += OnVideoPrepared;
		videoPlayer.loopPointReached += OnVideoFinished;
		videoPlayer.Prepare();
    }

    private void OnVideoPrepared(VideoPlayer value)
    {
        Logger.Print("Video ready (URL):" + videoPlayer.url);
        // Logger.Print("Height:" + videoPlayer.height + " Width:" + videoPlayer.width);

        //  VideoPlayer set to AspectRatio = "Stretch", no need for sized render texture

        // Logger.Print(">> Render Texture:" + renderTexture.height + " Width:" + renderTexture.width);
        /* create new render texture for specific sizing
        renderTexture.height = (int) videoPlayer.height;
        renderTexture.width = (int) videoPlayer.width;
        videoPlayer.targetTexture = renderTexture
        */

        _videoPrepared = true;
		VideoPreparedCallback?.Invoke();
		VideoPreparedCallback = null;

		VideoPlayerPlay();
    }

	private void OnVideoFinished(VideoPlayer value)
	{
		VideoFinishedCallback?.Invoke();
		VideoFinishedCallback = null;
	}

	public void Pause()
    {
		VideoPlayerPause();
		SetIsPaused(true);
	}

	private void SetIsPaused(bool isPaused)
	{
		IsPaused = isPaused;
		pauseButton.gameObject.SetActive(!isPaused);
		playButton.gameObject.SetActive(isPaused);
	}

	private void VideoPlayerPause()
	{
		videoPlayer.Pause();
		_pauseFrame = videoPlayer.frame;
	}

    public void Stop()
    {
		// stop causes videoPlayer.frame to revert to the begining
		videoPlayer.Stop();
    }

	public void Mute(bool mute)
	{
		if (videoPlayer.canSetDirectAudioVolume) {
			videoPlayer.SetDirectAudioMute(0, mute);
			muteButton.gameObject.SetActive(!mute);
			soundButton.gameObject.SetActive(mute);
		}
	}

    public void OnSliderChanged(float value)
    {
        if (!videoPlayer.isPlaying) {
            videoPlayer.frame = SliderFrame;        // scrub video
        }
    }

    // Note: Added via EventTrigger in Unity Editor
    public void OnSliderBeginDrag()
	{
		VideoPlayerPause();
	}

    // Note: Added via EventTrigger in Unity Editor
    public void OnSliderEndDrag()
	{
		if (IsPaused) {
			VideoPlayerPause();
			return;
		}

		VideoPlayerPlay();
	}

    public void OnClickPlay(ClickButton button)
    {
        Play();
    }

    public void OnClickPause(ClickButton button)
    {
        Pause();
    }

    public void OnClickToggleSound(ClickButton button)
    {
        Mute(muteButton.gameObject.activeSelf);
    }
}


/* detecting for buffering video
 *
 * see also https://docs.unity3d.com/Manual/profiler-video-profiler-module.html

private void Update()
{
	//when the video is playing, check each time that the video image get update based in the video's frame rate
	if (videoPlayer.isPlaying && (Time.frameCount % (int)(videoPlayer.frameRate + 1)) == 0) {
		//if the video time is the same as the previous check, that means it's buffering cuz the video is Playing.
		if (lastTimePlayed == videoPlayer.time)//buffering
		{
			Debug.Log("buffering");
		} else//not buffering
		  {
			Debug.Log("Not buffering");
		}
		lastTimePlayed = videoPlayer.time;
	}
}

*/
