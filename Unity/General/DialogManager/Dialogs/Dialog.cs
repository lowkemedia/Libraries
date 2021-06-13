//
//  Dialog - DialogManager package
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

using TMPro;
using UnityEngine;
using CallbackTypes;

public class Dialog : MonoBehaviour
{
    public TextMeshProUGUI title;
    public TextMeshProUGUI message;

    public TextButton firstButton;
    public TextButton secondButton;
    public TextButton okButton;

    public static DialogManager _dialogManager;

    private Callback _firstBtnCallback;
    private Callback _sencondBtnCallback;

    // TODO: Bold style default button.
    // TODO: Red style caution button 
    // TODO: ShowInfo with info icon
    // TODO: ShowCaution with caution icon
    // TODO: ShowError with error icon

    public void Initialize(DialogManager dialogManager)
    {
        _dialogManager = dialogManager;

        okButton.onClickEvent.AddListener(OnClickFirst);
        firstButton.onClickEvent.AddListener(OnClickFirst);
        secondButton.onClickEvent.AddListener(OnClickSecond);
    }

    public void SetupDialog(string titleKey, string messageKey,
                             string firstButtonKey, Callback firstBtnCallback, AudioSource firstBtnSound,
                             string secondButtonKey, Callback sencondBtnCallback = default, AudioSource secondButton = default)

    {
        title.AddKey(titleKey, null, DialogManager.TitleStyle);
        message.AddKey(messageKey, null, DialogManager.MessageStyle);
        _firstBtnCallback = firstBtnCallback;
        if (firstBtnSound == default) {
            firstBtnSound = SoundHelper.Click;
        }

        _sencondBtnCallback = sencondBtnCallback;
        if (secondButton == default) {
            secondButton = SoundHelper.Click;
        }

        if (secondButtonKey == default) {
            firstButton.GetGameObject().SetActive(false);
            this.secondButton.GetGameObject().SetActive(false);
            okButton.GetGameObject().SetActive(true);
            okButton.textField.AddKey(firstButtonKey, null, DialogManager.ButtonStyle);
            okButton.ClickButton.clickSound = firstBtnSound;
        } else {
            okButton.GetGameObject().SetActive(false);
            firstButton.GetGameObject().SetActive(true);
            firstButton.textField.AddKey(firstButtonKey, null, DialogManager.ButtonStyle);
            firstButton.ClickButton.clickSound = firstBtnSound;
            this.secondButton.GetGameObject().SetActive(true);
            this.secondButton.textField.AddKey(secondButtonKey, null, DialogManager.ButtonStyle);
            this.secondButton.ClickButton.clickSound = secondButton;
        }
    }

    public void OnClickFirst(ClickButton button)
    {
        _dialogManager.HideDialogs();
        _firstBtnCallback?.Invoke();
    }

    public void OnClickSecond(ClickButton button)
    {
        _dialogManager.HideDialogs();
        _sencondBtnCallback?.Invoke();
    }

    //

    public static void ShowAlert(string titleKey, string messageKey,
                                 Callback okCallback = default, AudioSource okSound = default)
    {
        ShowDialog(titleKey, messageKey, ".ok", okCallback, okSound);
    }

    public static void ShowOkayCancel(string titleKey, string messageKey,
                                      Callback okCallback, AudioSource okSound = default)
    {
        ShowDialog(titleKey, messageKey, ".cancel", default, default, ".ok", okCallback, okSound);
    }

    public static void ShowYesNo(string titleKey, string messageKey,
                                 Callback yesCallback, AudioSource yesSound = default,
                                 Callback noCallback = default, AudioSource noSound = default)
    {
        ShowDialog(titleKey, messageKey, ".no", noCallback, noSound, ".yes", yesCallback, yesSound);
    }

    public static void ShowDialog(string titleKey, string messageKey,
                           string firstButtonKey = ".ok", Callback firstBtnCallback = default, AudioSource firstBtnSound = default,
                           string secondButtonKey = default, Callback sencondBtnCallback = default, AudioSource secondButton = default)
    {
        Dialog dialog = _dialogManager.dialog;
        dialog.SetupDialog(titleKey, messageKey,
            firstButtonKey, firstBtnCallback, firstBtnSound,
            secondButtonKey, sencondBtnCallback, secondButton);
        _dialogManager.ShowDialog(dialog);
    }
}
