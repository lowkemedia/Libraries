//
//  Localizer v 1.0 - Localizer package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2019 Lowke Media
//  see http://www.lowkemedia.com for more information
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
    // language codes, see http://www.loc.gov/standards/iso639-2/php/code_list.php
    // en ENGLISH, pt PORTUGUESE, fr FRENCH, es SPANISH, de GERMAN, 
    // ja JAPANESE, zh CHINESE, ko KOREAN, ru RUSSIAN
    public enum LanguageCode
    {
        en,
        pt,
        fr,
        es,
        de,
        ja,
        zh,
        ko,
        ru,
        th,
        tr,
        id,
        ar,
        hi
    }

    public enum LanguageType
    {
        English,
        Portuguese,
        French,
        Spanish,
        German,
        Japanese,
        Chinese,
        Korean,
        Russian,
        Thai,
        Turkish,
        Indonesian,
        Arabic,
        Hindi
    };

    public static class LocalizerID
    {
        //
        // error, warning and info IDs
        public const string LOG_PREFIX = "LOC";
        public const string SEVERE_COULD_NOT_FIND_KEY = LOG_PREFIX + "00";
        public const string WARNING_INVALID_KEY_PASSED = LOG_PREFIX + "01";
        public const string WARNING_HAS_EMBEDDED_AND_PASSED_VARIABLES = LOG_PREFIX + "02";
    }
}