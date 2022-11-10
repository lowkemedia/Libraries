//
//  DialogManager - DialogManager package
//  Russell Lowke, November 8th 2022
//
//  Copyright (c) 2021-2022 Lowke Media
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
using UnityEngine.EventSystems;
using CallbackTypes;
using System.Collections.Generic;
using System.Collections;

public class DialogManager : MonoBehaviour
{
    public DialogBase[] dialogs;
    public Dialog dialog;

    private static DialogManager _instance;
    public static DialogManager Instance {
        get {
            if (_instance is null) {
                Logger.Warning("DialogManager must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    private static Stack<DialogBase> _stack;
    public static DialogBase ActiveDialog {
        get {
            if (_stack.Count > 0) {
                return _stack.Peek();
            }
            return default;
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

    private void Start()
    {
        if (_instance != null) {
            Logger.Warning("DialogManager should only be attached once.");
            return;
        }

        _instance = this;
        _stack = new Stack<DialogBase>();

        foreach (DialogBase dialog in dialogs) {
            dialog.Initialize(this);
        }
    }

    public DialogBase GetDialog(string name)
    {
        foreach(DialogBase dialog in dialogs) {
            if (dialog.name == name) {
                return dialog;
            }
        }

        Logger.Severe("Could not find dialog called \"" + name + "\"");
        return default;
    }


    public void ShowDialog(DialogBase dialog)
    {
        foreach (DialogBase openDialog in _stack) {
            if (openDialog == dialog) {
                Logger.Severe("Dialog \"" + dialog.name + "\" is already open.");
                return;
            }
        }
        if (!dialog.DialogIsSetup) {
            Logger.Severe("Dialog \"" + dialog.name + "\" has not been setup yet. SetupDialog() needs to be called before ShowDialog()");
        }

        // make open dialog object with click blocker
        Canvas canvas = gameObject.GetCanvas();
        GameObject canvasGameObject = canvas.gameObject;
        GameObject dialogParent = canvasGameObject.MakeUiObject();
        dialogParent.CopyRect(gameObject);
        dialogParent.name = "Open Dialog";
        ClickBlocker.MakeClickBlocker(dialogParent, OnBlockerClicked);

        // move dialog to open dialog object and show
        dialog.SetParent(dialogParent);
        dialog.gameObject.SetActive(true);
        dialog.DialogShown();
        _stack.Push(dialog);
    }

    public void HideDialog(DialogBase dialog)
    {
        // give dialog back and hide
        GameObject dialogParent = dialog.GetParent();
        dialog.SetParent(gameObject);
        dialog.gameObject.SetActive(false);

        // destroy open dialog object
        Destroy(dialogParent);
        _stack.Pop();
    }

    public void OnBlockerClicked(PointerEventData pointerEventData)
    {
        SoundHelper.PlayBeep();
    }
}