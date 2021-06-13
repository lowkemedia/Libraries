//
//  DialogManager - DialogManager package
//  Russell Lowke, June 13th 2021
//
//  Copyright (c) 2021 Lowke Media
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

using UnityEngine;
using ClickBlockerTypes;

public class DialogManager : MonoBehaviour, IBlockResolver
{
    public Dialog dialog;

    private ClickBlocker _clickBlocker;

    private static DialogManager _instance;
    public static DialogManager Instance {
        get {
            if (_instance is null) {
                Logger.Warning("DialogManager must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    public static string TitleStyle { get; private set; }
    public static string MessageStyle { get; private set; }
    public static string ButtonStyle { get; private set; }

    public static void SetStyle(string titleStyle, string messageStyle, string buttonStyle)
    {
        TitleStyle = titleStyle;
        MessageStyle = messageStyle;
        ButtonStyle = buttonStyle;
    }

    private void Awake()
    {
        if (_instance != null) {
            Logger.Warning("DialogManager should only be attached once.");
            return;
        }
        _instance = this;


        dialog.Initialize(this);
        HideDialogs();
    }

    public void HideDialogs()
    {
        // remove click blocker
        if (_clickBlocker != default) {
            Object.Destroy(_clickBlocker.GetGameObject());
            _clickBlocker = default;
        }

        // hide all dialogs
        HideDialog(dialog);
    }

    private void HideDialog(Dialog dialog)
    {
        GameObject dialogGameObject = dialog.gameObject;
        dialogGameObject.SetActive(false);
    }

    public void ShowDialog(Dialog dialog)
    {
        GameObject dialogGameObject = dialog.gameObject;

        // add the clock blocker
        if (_clickBlocker == default) {
            _clickBlocker = ClickBlocker.MakeClickBlocker(gameObject, dialogGameObject);
        }

        // move dialog to top and show
        dialogGameObject.MoveToTop();
        dialogGameObject.SetActive(true);
    }

    public void OnBlockerRolled() { }

    public void OnBlockerClicked()
    {
        SoundHelper.PlayBeep();
    }
}