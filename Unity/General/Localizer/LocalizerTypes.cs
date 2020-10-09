//
//  Localizer v 1.0 - Localizer package
//  Russell Lowke, October 7th 2020
//
//  Copyright (c) 2019 Lowke Media
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

namespace LocalizerTypes
{
    // British to American translator see
    // https://gotranscript.com/translation-services/british-to-american

    // Languages of the World with Language Code (ISO 639)
    // https://www.nationsonline.org/oneworld/language_code.htm
    // https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes
    // en ENGLISH, pt PORTUGUESE, fr FRENCH, es SPANISH, de GERMAN, 
    // ja JAPANESE, zh CHINESE, ko KOREAN, ru RUSSIAN,
    // fa FARSI/PERSIAN, my BURMESE/MYANMAR, mn MONGOLIAN

    // For suffixes see
    // see also https://en.wikipedia.org/wiki/Language_localisation

    public enum LanguageCode
    {
        en_GB,              // British English
        en_US,              // American English
        fr_FR,              // Standard French (especially in France)
        pt_BR,              // Brazilian Portuguese
        es_ES,              // Castilian Spanish (as spoken in Central-Northern Spain)
        de_DE,              // Standard German (as spoken in Germany)
        it_IT,              // Standard Italian (as spoken in Italy)
        ru,                 // Russian
        sv_SE,              // Standard Swedish (as spoken in Sweden)
        tr,                 // Turkish
        id,                 // Indonesian
        th,                 // Thai
        ja,                 // Japanese
        zh_CN,              // Mainland China, simplified characters
        ko_KR,              // Hangul, South Korean
        hi,                 // Hindi
        my,                 // Burmese
        la                  // Latin
    }

    public enum LanguageType
    {
        English,
        American,
        French,
        Portuguese,
        Spanish,
        German,
        Italian,
        Russian,
        Swedish,
        Turkish,
        Indonesian,
        Thai,
        Japanese,
        Chinese,
        Korean,
        Hindi,
        Burmese,            // Myanmar
        Latin
    };

    public enum LanguageName
    {
        English,            // English
        American,           // American
        Français,           // French
        Português,          // Portuguese
        Español,            // Spanish
        Deutsch,            // German
        Italiano,           // Italian
        Русский,            // Russian
        Svenska,            // Swedish
        Türkçe,             // Turkish
        bahasa,             // Indonesian
        ภาษาไทย,            // Thai
        日本語,              // Japanese
        简体中文,            // Chinese (Simplified)
        한국어,               // Korean
        हिन्दी,                // Hindi
        မြန်မာစာ,             // Burmese
        Latin               // Latin
    };

    public static class LocalizerID
    {
        //
        // error, warning and info IDs
        public const string LOG_PREFIX = "LOC";
        public const string SEVERE_CANT_LOAD_FILE = LOG_PREFIX + "00";
        public const string SEVERE_CANT_READ_KEY = LOG_PREFIX + "01";
        public const string WARNING_COULD_NOT_FIND_KEY = LOG_PREFIX + "02";
        public const string WARNING_DUPLICATE_KEY = LOG_PREFIX + "03";
        public const string WARNING_INVALID_KEY_PASSED = LOG_PREFIX + "04";
        public const string WARNING_HAS_EMBEDDED_AND_PASSED_VARIABLES = LOG_PREFIX + "05";
    }
}



/* Languages

Arabic (العربية)
Armenian (հայերեն)
Assyrian (ܣܘܪܝܬ)
Bangla (বাংলা)
Burmese (မြန်မာစာ)
Chinese-Simplified (简体中文)
Chinese-Traditional (繁體中文)
Croatian (Hrvatski)
Czech (Cestina)
Dari (دريلو)
Danish (Dansk)
Dinka (Thuɔŋjäŋ)
English (English)
Estonian (Eesti keel)
Farsi (فارسی)
Filipino (Wikang Tagalog)
Finnish (Suomi) 
FijianHindi ( फ़िजी हिंदी)
French (Français)
Gaelic (Gàidhlig)
Greek (Ελληνικά)
Gujrati (ગુજરાતી)
Hazaragi (آزرگی‎)
Hindi (हिन्दी)
Hungarian (Magyar)
Indonesian (bahasa)
Irish (Gaeilge)
Italian (Italiano)
Japanese (日本語)
Karen (Karen)
Khmer (ភាសាខ្មែរ)
Kinyarwanda (Kinyarwanda)
Kirundi (کوردی)
Korean (한국어)
Kurdish-Kurmanji (کورمانجی)
Kurdish-Sorani (سۆرانی)
Lao (ພາສາລາວ)
Latvian (Latviešu valoda)
Lithuanian (Lietuvių kalba)
Luxembourgish (LÎtzebuergesch)
Macedonian (Mакедонски)
Maltese (Malti)
Mandarin (普通话)
Mongolian (Монгол Хэл)
Nepali (नेपाली)
Norwegian (Nynorsk)
Pashto (پښتو)
Polish (Język polski)
Portuguese (Português)
Punjabi (पंजाबी)
Rohingya (Rohingya)
Romanian (Romana)
Russian (Русский)
Samoan (Gagana Sāmoa)
Serbian (Српски)
Sinhalese (සිංහල)
Slovak (Slovensky jazyk)
Slovenian (Slovenski jezik)
Somali (Somali)
Spanish (Español)
Swahili (Kiswahili)
Swedish (Svenska)
Tamil (தமிழ்)
Thai (ภาษาไทย)
Tibetan (བོད་སྐད་)
Tigrinya (ትግርኛ)
Tongan (Lea faka-Tonga)
Turkish (Türkçe)
Ukrainian (Ukrainian)
Urdu (اُردُو)
Vietnamese (Tiếng Việt Nam)
Welsh (Cymraeg)

*/
