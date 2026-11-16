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
    private Callback _secondBtnCallback;
    private float _defaultHeight;
    private float _minimumHeight;
    private float _pendingHeight;
    private bool _resizePending;

    public float messageButtonGap = 32;

    // TODO: Bold style default button.
    // TODO: Red style caution button 
    // TODO: ShowInfo with info icon
    // TODO: ShowCaution with caution icon
    // TODO: ShowError with error icon

    override public void Initialize(DialogManager dialogManager)
    {
        base.Initialize(dialogManager);

        okButton.OnClickEvent.AddListener(OnClickFirst);
        firstButton.OnClickEvent.AddListener(OnClickFirst);
        secondButton.OnClickEvent.AddListener(OnClickSecond);
        _defaultHeight = this.GetHeight();
        _minimumHeight = _defaultHeight;
        message.OnPreRenderText += MeasureRequiredDialogHeight;
    }

    public void SetupDialog(string titleKey, string messageKey,
                             string firstButtonKey, Callback firstBtnCallback, AudioSource firstBtnSound,
                             string secondButtonKey, Callback secondBtnCallback = default, AudioSource secondButton = default)
    {
        // Restore the minimum size for each new message.
        _resizePending = false;
        _minimumHeight = _defaultHeight;
        gameObject.SetSize(this.GetWidth(), _defaultHeight);

        title.AddKey(titleKey, DialogManager.TitleStyle);
        message.AddKey(messageKey, DialogManager.MessageStyle, preventOrphans: true)
            .RemoveOrphanPairWidthLimit();

        _firstBtnCallback = firstBtnCallback;
        if (firstBtnSound == default) {
            firstBtnSound = SoundHelper.Click;
        }

        _secondBtnCallback = secondBtnCallback;
        if (secondButton == default) {
            secondButton = SoundHelper.Click;
        }

        if (secondButtonKey == default) {
            firstButton.GetGameObject().SetActive(false);
            this.secondButton.GetGameObject().SetActive(false);
            okButton.GetGameObject().SetActive(true);
            okButton.textField.AddKey(firstButtonKey, DialogManager.ButtonStyle);
            okButton.ClickButton.clickSound = firstBtnSound;
        } else {
            okButton.GetGameObject().SetActive(false);
            firstButton.GetGameObject().SetActive(true);
            firstButton.textField.AddKey(firstButtonKey, DialogManager.ButtonStyle);
            firstButton.ClickButton.clickSound = firstBtnSound;
            this.secondButton.GetGameObject().SetActive(true);
            this.secondButton.textField.AddKey(secondButtonKey, DialogManager.ButtonStyle);
            this.secondButton.ClickButton.clickSound = secondButton;
        }

        base.SetupDialog();
    }

    public void EnlargeDialog(float extraHeight) {
        _minimumHeight = _defaultHeight + extraHeight;
        gameObject.SetSize(this.GetWidth(), Mathf.Max(this.GetHeight(), _minimumHeight));
    }

    private void OnDestroy() {
        message.OnPreRenderText -= MeasureRequiredDialogHeight;
    }

    private void MeasureRequiredDialogHeight(TMP_TextInfo textInfo)
    {
        if (textInfo.characterCount == 0) { return; }

        RectTransform dialogRect = (RectTransform)transform;
        // Measure the rendered text, including wrapping and sprites, after TMP lays it out.
        float messageBottom = dialogRect.InverseTransformPoint(
            message.rectTransform.TransformPoint(new Vector3(0, message.textBounds.min.y, 0))).y;
        float buttonTop = okButton.gameObject.activeSelf ? GetButtonTop(okButton) :
            Mathf.Max(GetButtonTop(firstButton), GetButtonTop(secondButton));
        float requiredHeight = dialogRect.rect.height + buttonTop + messageButtonGap - messageBottom;
        _pendingHeight = Mathf.Ceil(requiredHeight);
        _resizePending = true;
    }

    private void LateUpdate()
    {
        if (!_resizePending) { return; }
        _resizePending = false;

        // TMP's callback runs inside a graphic rebuild. Resize outside that loop.
        RectTransform dialogRect = (RectTransform)transform;
        float height = Mathf.Max(_minimumHeight, _pendingHeight);
        if (!Mathf.Approximately(dialogRect.rect.height, height)) {
            // The message stays top-anchored; the buttons stay bottom-anchored.
            dialogRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, height);
        }
    }

    private float GetButtonTop(TextButton button)
    {
        RectTransform buttonRect = (RectTransform)button.transform;
        return transform.InverseTransformPoint(
            buttonRect.TransformPoint(new Vector3(0, buttonRect.rect.yMax, 0))).y;
    }

    public void OnClickFirst(ClickButton button) {
        HideDialog();
        _firstBtnCallback?.Invoke();
    }

    public void OnClickSecond(ClickButton button) {
        HideDialog();
        _secondBtnCallback?.Invoke();
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
        DialogManager dialogManager = DialogManager.Instance;
        Dialog dialog = dialogManager.GetDialog("Dialog") as Dialog;
        dialog.EnlargeDialog(extraHeight);
    }

    private static void ShowDialog(string titleKey, string messageKey,
                           string firstButtonKey = ".ok", Callback firstBtnCallback = default, AudioSource firstBtnSound = default,
                           string secondButtonKey = default, Callback secondBtnCallback = default, AudioSource secondButton = default)
    {
        DialogManager dialogManager = DialogManager.Instance;
        Dialog dialog = dialogManager.GetDialog("Dialog") as Dialog;
        dialog.SetupDialog(titleKey, messageKey,
            firstButtonKey, firstBtnCallback, firstBtnSound,
            secondButtonKey, secondBtnCallback, secondButton);
        dialog.ShowDialog();
    }
}
