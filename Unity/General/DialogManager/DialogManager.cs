//
//  DialogManager - DialogManager package
//  Russell Lowke, April 20th 2021
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
using ClickBlockerTypes;
using CallbackTypes;

public class DialogManager : MonoBehaviour, IBlockResolver
{
    public GameObject dialog;

    public TextMeshProUGUI title;
    public TextMeshProUGUI message;

    public TextButton firstButton;
    public TextButton secondButton;
    public TextButton okButton;

    private ClickBlocker _clickBlocker;
    private Callback _firstBtnCallback;
    private Callback _sencondBtnCallback;

    private static DialogManager _instance;
    public static DialogManager Instance {
        get {
            if (_instance is null) {
                Logger.Warning("DialogManager must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    private static string _titleStyle;
    private static string _messageStyle;
    private static string _buttonStyle;

    public static void SetStyle(string titleStyle, string messageStyle, string buttonStyle)
	{
        _titleStyle = titleStyle;
        _messageStyle = messageStyle;
        _buttonStyle = buttonStyle;
    }

    private void Start()
    {
        _instance = this;
        okButton.onClickEvent.AddListener(OnClickFirst);
        firstButton.onClickEvent.AddListener(OnClickFirst);
        secondButton.onClickEvent.AddListener(OnClickSecond);

        HideDialog();
    }

    // TODO: Bold style default button.
    // TODO: Red style caution button 
    // TODO: ShowInfo with info icon
    // TODO: ShowCaution with caution icon
    // TODO: ShowError with error icon

    public static void ShowAlert(string titleKey, string messageKey, Callback okCallback = default)
    {
        Instance.ShowNotification(titleKey, messageKey, ".ok", okCallback);
    }

    public static void ShowOkayCancel(string titleKey, string messageKey, Callback okCallback)
    {
        Instance.ShowNotification(titleKey, messageKey, ".cancel", default, ".ok", okCallback);
    }

    public static void ShowYesNo(string titleKey, string messageKey, Callback yesCallback, Callback noCallback = default)
    {
        Instance.ShowNotification(titleKey, messageKey, ".no", noCallback, ".yes", yesCallback);
    }


    public void ShowNotification(string titleKey, string messageKey,
                                 string firstButtonKey = ".ok", Callback firstBtnCallback = default,
                                 string secondButtonKey = default, Callback sencondBtnCallback = default)
	{
        title.AddKey(titleKey, null, _titleStyle);
        message.AddKey(messageKey, null, _messageStyle);

        _firstBtnCallback = firstBtnCallback;
        _sencondBtnCallback = sencondBtnCallback;

        if (secondButtonKey == default) {
            firstButton.GetGameObject().SetActive(false);
            secondButton.GetGameObject().SetActive(false);
            okButton.GetGameObject().SetActive(true);
            okButton.textField.AddKey(firstButtonKey, null, _buttonStyle);
        } else {
            okButton.GetGameObject().SetActive(false);
            firstButton.GetGameObject().SetActive(true);
            firstButton.textField.AddKey(firstButtonKey, null, _buttonStyle);
            secondButton.GetGameObject().SetActive(true);
            secondButton.textField.AddKey(secondButtonKey, null, _buttonStyle);
        }

        if (_clickBlocker == default) {
            _clickBlocker = ClickBlocker.MakeClickBlocker(gameObject, dialog);
        }
        
        dialog.MoveToTop();
        dialog.SetActive(true);
    }

    public void OnClickFirst(ClickButton button)
    {
        _firstBtnCallback?.Invoke();
        HideDialog();
    }

    public void OnClickSecond(ClickButton button)
    {
        _sencondBtnCallback?.Invoke();
        HideDialog();
    }

    private void HideDialog()
	{
        if (_clickBlocker != default) {
            Object.Destroy(_clickBlocker.GetGameObject());
            _clickBlocker = default;
        }
        dialog.SetActive(false);
    }

    public void OnBlockerRolled() { }

    public void OnBlockerClicked()
    {
        beep();
    }

    private void beep()
	{
        SoundHelper.Play(SoundHelper.SoundType.Beep);
    }
}