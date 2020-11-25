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

    public void SetKey(string key,
                       string[] variables = default,
                       string style = default,
                       bool giveWarning = true)
    {
        Key = key;
        Variables = variables;
        Style = style;
        LinkTextField();
        UpdateKey(giveWarning);

        if (!_listenerAdded) {
            _listenerAdded = true;
            Localizer.OnLanguageChangedEvent += UpdateKey;
        }
    }

    public void UpdateKey(bool giveWarning = true)
    {
        if (_textField == default) {
            // _textField has been deleted, but garbage collection
            //  has not called OnDestroy() yet.
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
                _textField.text = Localizer.Value(Key, Variables, giveWarning);
                break;
        }
    }

    private void OnDestroy() {
        Localizer.OnLanguageChangedEvent -= UpdateKey;
        _listenerAdded = false;
    }
}
