//
//  Dialog - DialogManager package
//  Russell Lowke, June 14th 2021
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

public class Dialog : DialogBase
{
    public TextMeshProUGUI title;
    public TextMeshProUGUI message;

    public TextButton firstButton;
    public TextButton secondButton;
    public TextButton okButton;

    private Callback _firstBtnCallback;
    private Callback _sencondBtnCallback;
    private float _defaultHeight;

    // TODO: Bold style default button.
    // TODO: Red style caution button 
    // TODO: ShowInfo with info icon
    // TODO: ShowCaution with caution icon
    // TODO: ShowError with error icon

    override public void Initialize(DialogManager dialogManager)
    {
        base.Initialize(dialogManager);

        okButton.onClickEvent.AddListener(OnClickFirst);
        firstButton.onClickEvent.AddListener(OnClickFirst);
        secondButton.onClickEvent.AddListener(OnClickSecond);
        _defaultHeight = this.GetHeight();
    }

    public void SetupDialog(string titleKey, string messageKey,
                             string firstButtonKey, Callback firstBtnCallback, AudioSource firstBtnSound,
                             string secondButtonKey, Callback sencondBtnCallback = default, AudioSource secondButton = default)

    {
        // restore default size
        gameObject.SetSize(this.GetWidth(), _defaultHeight);

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

        base.SetupDialog();
    }

    public void EnlargeDialog(float extraHeight) {
        gameObject.SetSize(this.GetWidth(), _defaultHeight + extraHeight);
    }

    public void OnClickFirst(ClickButton button)
    {
        HideDialog();
        _firstBtnCallback?.Invoke();
    }

    public void OnClickSecond(ClickButton button)
    {
        HideDialog();
        _sencondBtnCallback?.Invoke();
    }

    //

    public static void ShowAlert(string titleKey, string messageKey,
                                 Callback okCallback = default, AudioSource okSound = default)
    {
        ShowDialog(titleKey, messageKey, ".ok", okCallback, okSound);
    }

    public static void ShowLargeAlert(string titleKey, string messageKey,
                             Callback okCallback = default, AudioSource okSound = default)
    {
        ShowDialog(titleKey, messageKey, ".ok", okCallback, okSound);
        Enlarge(60);
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

    public static void ShowLargeYesNo(string titleKey, string messageKey,
                             Callback yesCallback, AudioSource yesSound = default,
                             Callback noCallback = default, AudioSource noSound = default)
    {
        ShowDialog(titleKey, messageKey, ".no", noCallback, noSound, ".yes", yesCallback, yesSound);
        Enlarge(60);
    }

    private static void Enlarge(float extraHeight)
    {
        // TODO: Shoud be finding depth of text block and adjusting appropriately
        DialogManager dialogManager = DialogManager.Instance;
        Dialog dialog = dialogManager.GetDialog("Dialog") as Dialog;
        dialog.EnlargeDialog(60);
    }

    private static void ShowDialog(string titleKey, string messageKey,
                           string firstButtonKey = ".ok", Callback firstBtnCallback = default, AudioSource firstBtnSound = default,
                           string secondButtonKey = default, Callback sencondBtnCallback = default, AudioSource secondButton = default)
    {
        DialogManager dialogManager = DialogManager.Instance;
        Dialog dialog = dialogManager.GetDialog("Dialog") as Dialog;
        dialog.SetupDialog(titleKey, messageKey,
            firstButtonKey, firstBtnCallback, firstBtnSound,
            secondButtonKey, sencondBtnCallback, secondButton);
        dialog.ShowDialog();
    }
}
