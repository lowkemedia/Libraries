//
//  LocalizedText v 1.0 - Localizer package
//  Russell Lowke, October 13th 2020
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


using TMPro;
using UnityEngine;
using LocalizerTypes;

[RequireComponent(typeof(TextMeshProUGUI))]
public class LocalizedText : MonoBehaviour
{
    private TextMeshProUGUI _textField;
    public TextMeshProUGUI TextField {
        get {
            LinkTextField();
            return _textField;
        }
    }
    private void LinkTextField()
    {
        if (!_textField) {
            _textField = GetComponent<TextMeshProUGUI>();
        }
    }

    public string Key { get; private set; }
    public string[] Variables { get; private set; }
    public string Style { get; private set; }
    private bool _listenerAdded;
    private bool _giveWarning = true;

    public bool PreventOrphans { get; set; }
    // NaN keeps orphan prevention unlimited; otherwise use a fraction of usable field width.
    public float MaxOrphanPairWidthRatio { get; set; } = 0.35f;
    private string _localizedText;
    private bool _orphanCheckPending;
    private float _orphanCheckWidth;

    // Keep orphan prevention enabled separately; this only removes its pair-width limit.
    public void RemoveOrphanPairWidthLimit() {
        MaxOrphanPairWidthRatio = float.NaN;
        _orphanCheckPending = true;
    }

    public void SetKey(string key,
                       string[] variables = default,
                       string style = default,
                       bool giveWarning = true)
    {
        Key = key;
        Variables = variables;
        Style = style;
        _giveWarning = giveWarning;
        LinkTextField();
        UpdateKey(giveWarning);

        if (!_listenerAdded) {
            _listenerAdded = true;
            Localizer.OnLanguageChangedEvent += OnLanguageChanged;
        }
    }

    private void OnLanguageChanged() {
        UpdateKey(_giveWarning);
    }

    public void UpdateKey(bool giveWarning = true)
    {
        if (_textField == default) {
            // The text field is missing or destroyed; remove the language-change listener
            //  through the same cleanup used by OnDestroy().
            OnDestroy();
            return;
        }

        Stylizer.ApplyStyle(_textField, Style, giveWarning);

        switch (Key) {
            case ".languageString":
                _textField.text = Localizer.LanguageString;
                break;
            case ".languageName":
                _textField.text = Localizer.LanguageName.ToString();
                break;
            case ".languageType":
                _textField.text = Localizer.LanguageType.ToString();
                break;
            case ".languageCode":
                _textField.text = Localizer.LanguageCode.ToString();
                break;
            default:
                _textField.text = Stylizer.ResolveInlineFonts(Localizer.Value(Key, Variables, giveWarning));
                break;
        }
        _localizedText = _textField.text;
        _orphanCheckPending = true;
    }

    private void LateUpdate()
    {
        if (!PreventOrphans || _localizedText == null) { return; }

        float width = TextField.rectTransform.rect.width;
        if (!_orphanCheckPending && Mathf.Approximately(width, _orphanCheckWidth)) { return; }
        _orphanCheckPending = false;
        _orphanCheckWidth = width;
        // Reflow from the resolved source, outside TMP's graphic rebuild loop.
        TextOrphanPrevention.Apply(TextField, _localizedText, MaxOrphanPairWidthRatio);
    }

    private void OnDestroy() {
        Localizer.OnLanguageChangedEvent -= OnLanguageChanged;
        _listenerAdded = false;
    }
}
