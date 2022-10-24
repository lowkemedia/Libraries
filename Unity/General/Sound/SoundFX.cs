//
//  SoundFX - Chess Origins: Sound package
//  Russell Lowke, January 17th 2021
//
//  Copyright (c) 2020-2021 Lowke Media
//  All Rights Reserved
//

using UnityEngine;
using CallbackTypes;

public class SoundFX : MonoBehaviour
{
    public AudioSource start;
    public AudioSource chime;
    public AudioSource capture;
    public AudioSource promote;
    public AudioSource restart;
    public AudioSource undo;
    public AudioSource hint;
    public AudioSource check;
    public AudioSource checkmate;
    public AudioSource stalemate;
    public AudioSource cant;
    public AudioSource castle;
    public AudioSource enPassant;
    public AudioSource pin;
    public AudioSource stuck;
    public AudioSource leap;
    public AudioSource jump;
    public AudioSource exchange;
    public AudioSource pass;

    public static AudioSource Start { get { return Instance.start; } }
    public static AudioSource Chime { get { return Instance.chime; } }
    public static AudioSource Capture { get { return Instance.capture; } }
    public static AudioSource Promote { get { return Instance.promote; } }
    public static AudioSource Restart { get { return Instance.restart; } }
    public static AudioSource Undo { get { return Instance.undo; } }
    public static AudioSource Hint { get { return Instance.hint; } }
    public static AudioSource Check { get { return Instance.check; } }
    public static AudioSource Checkmate { get { return Instance.checkmate; } }
    public static AudioSource Stalemate { get { return Instance.stalemate; } }
    public static AudioSource Cant { get { return Instance.cant; } }
    public static AudioSource Castle { get { return Instance.castle; } }
    public static AudioSource EnPassant { get { return Instance.enPassant; } }
    public static AudioSource Pin { get { return Instance.pin; } }
    public static AudioSource Stuck { get { return Instance.stuck; } }
    public static AudioSource Leap { get { return Instance.leap; } }
    public static AudioSource Jump { get { return Instance.jump; } }
    public static AudioSource Exchange { get { return Instance.exchange; } }
    public static AudioSource Pass { get { return Instance.pass; } }

    public static void PlayStart(Callback callback = default) { SoundHelper.Play(Start, callback); }
    public static void PlayChime(Callback callback = default) { SoundHelper.Play(Chime, callback); }
    public static void PlayCapture(Callback callback = default) { SoundHelper.Play(Capture, callback); }
    public static void PlayPromote(Callback callback = default) { SoundHelper.Play(Promote, callback); }
    public static void PlayRestart(Callback callback = default) { SoundHelper.Play(Restart, callback); }
    public static void PlayUndo(Callback callback = default) { SoundHelper.Play(Undo, callback); }
    public static void PlayHint(Callback callback = default) { SoundHelper.Play(Hint, callback); }
    public static void PlayCheck(Callback callback = default) { SoundHelper.Play(Check, callback); }
    public static void PlayCheckmate(Callback callback = default) { SoundHelper.Play(Checkmate, callback); }
    public static void PlayStalemate(Callback callback = default) { SoundHelper.Play(Stalemate, callback); }
    public static void PlayCant(Callback callback = default) { SoundHelper.Play(Cant, callback); }
    public static void PlayCastle(Callback callback = default) { SoundHelper.Play(Castle, callback); }
    public static void PlayEnPassant(Callback callback = default) { SoundHelper.Play(EnPassant, callback); }
    public static void PlayPin(Callback callback = default) { SoundHelper.Play(Pin, callback); }
    public static void PlayStuck(Callback callback = default) { SoundHelper.Play(Stuck, callback); }
    public static void PlayLeap(Callback callback = default) { SoundHelper.Play(Leap, callback); }
    public static void PlayJump(Callback callback = default) { SoundHelper.Play(Jump, callback); }
    public static void PlayExchange(Callback callback = default) { SoundHelper.Play(Exchange, callback); }
    public static void PlayPass(Callback callback = default) { SoundHelper.Play(Pass, callback); }


    private static SoundFX _instance;
    private static SoundFX Instance {
        get {
            if (_instance is null) {
                Logger.Warning("SoundFX must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    public void Awake()
    {
        if (_instance != null) {
            Logger.Warning("SoundFX should only be attached once.");
            return;
        }
        _instance = this;
    }
}
