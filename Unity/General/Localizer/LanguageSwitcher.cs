//
//  Localizer v 1.0 - Localizer package
//  Russell Lowke, October 21st 2020
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
using LocalizerTypes;

public class LanguageSwitcher : MonoBehaviour
{
    public const LanguageCode DEFAULT_LANGUAGE = LanguageCode.en_GB;
    private static bool SHOW_ENGLISH_TOGGLE = false;

	public ClickButton languageButton;
    public ClickButton foreignButton;
    public ClickButton englishButton;

    public static LanguageCode[] LanguageCodes { get; } = new LanguageCode[] { LanguageCode.en_GB, LanguageCode.fr_FR };
    // LanguageCode.de_DE, LanguageCode.ru, LanguageCode.ja

    private static LanguageSwitcher _instance;
    public static LanguageSwitcher Instance {
        get {
            if (_instance == default) {
                Logger.Warning("LanguageSwitcher must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    private void Awake()
    {
        if (_instance != null) {
            Logger.Warning("LanguageSwitcher should only be attached once.");
            return;
        }
        _instance = this;
    }

    private static string[] _languages;
    public static string[] Languages {
        get {
            if (_languages == default) {
                // build languages array
                _languages = new string[LanguageCodes.Length];
                for (int i = 0; i < LanguageCodes.Length; ++i) {
                    LanguageCode languageCode = LanguageCodes[i];
                    string languageName = Localizer.GetLanguageNameString(languageCode);
                    _languages[i] = languageName;
                }
            }
            return _languages;
        }
    }
    public static string Language {
        get {
            int index = Array.IndexOf(LanguageCodes, Localizer.LanguageCode);
            return Languages[index];
        }
    }

    public static LanguageCode StoredLanguage { get; private set; } = DEFAULT_LANGUAGE;

    public static void CycleLanguage()
    {
        int index = Array.IndexOf(Languages, Language);
        ++index;
        if (index == Languages.Length) {
            index = 0;
        }
        Localizer.LanguageCode = LanguageCodes[index];
        StoredLanguage = Localizer.LanguageCode;
    }


    public void Start()
	{
        if (languageButton is null) {
            languageButton = GameObject.Find("Language Button").GetComponent<ClickButton>();
        }
		languageButton.onClickEvent.AddListener(OnClickLanguage);

        if (foreignButton is null) {
            foreignButton = GameObject.Find("Foreign Button").GetComponent<ClickButton>();
        }
		foreignButton.onClickEvent.AddListener(OnClickForeign);

        if (englishButton is null) {
            englishButton = GameObject.Find("English Button").GetComponent<ClickButton>();
        } 
		englishButton.onClickEvent.AddListener(OnClickEnglish);

        // languageButton defaults in the scene as visible,
        //  if it's not visible, then it's not meant to be shown.
        if (languageButton.gameObject.activeSelf) {
            UpdateButtons();
        }
    }

    public void UpdateButtons()
	{
        // languageButton.gameObject.SetActive(StoredGame.ShowLanguageSwitcher);
        languageButton.gameObject.SetActive(true);

        if (!SHOW_ENGLISH_TOGGLE || StoredLanguage == DEFAULT_LANGUAGE) {
            englishButton.gameObject.SetActive(false);
            foreignButton.gameObject.SetActive(false);
        } else {
            englishButton.gameObject.SetActive(!(Localizer.LanguageCode == DEFAULT_LANGUAGE));
            foreignButton.gameObject.SetActive(Localizer.LanguageCode == DEFAULT_LANGUAGE);
        }
    }

    public static void UpdateLanguageButtons()
    {
        Instance.UpdateButtons();
    }

	public void OnClickLanguage(ClickButton button)
	{
		CycleLanguage();
        UpdateButtons();
    }

	public void OnClickEnglish(ClickButton button)
	{
        Localizer.LanguageCode = DEFAULT_LANGUAGE;
        UpdateButtons();
    }

	public void OnClickForeign(ClickButton button)
	{
        Localizer.LanguageCode = StoredLanguage;
        UpdateButtons();
    }

    public static bool LanguageButtonActive {
        get { return Instance.languageButton.gameObject.activeSelf; }
    }
}
