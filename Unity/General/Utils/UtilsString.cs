//
//  UtilsString - Utils package
//  Russell Lowke, December 20th 2020
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

public static class UtilsString
{
    public static char First(this string value)
    {
        if (string.IsNullOrEmpty(value)) {
            return '\0';
        }

        // return 1st char of string
        return value[0];
    }

    public static char Last(this string value)
    {
        if (string.IsNullOrEmpty(value)) {
            return '\0';
        }

        // return last char of string
        return value[value.Length - 1];
    }

    public static bool CheckForQuote(string value, bool giveWarning = true)
    {
        // check for single quote
        //  see https://practicaltypography.com/straight-and-curly-quotes.html
        if (value.IndexOf("\'") != -1) {
            if (giveWarning) {
                Logger.Warning("Found single quote (\') in value:\"" + value + "\"  Should use ’ ");
            }
            return true;
        }

        return false;
    }

    public static string CorrectForQuotes(string value)
    {
        return Replace(value, '"', "\\\"");
    }

    public static string CorrectForTabs(string value)
    {
        return Replace(value, '\t', "\\t");
    }

    public static string Replace(string value, char character, string replacement)
    {
        // replace a character with a string

        if (string.IsNullOrEmpty(value)) {
            return null;
        }

        char[] charList = { character };
        string[] split = value.Split(charList);

        for (int i = 0; i < split.Length; ++i) {
            if (i == 0) {
                value = split[0];
            } else {
                value += replacement + split[i];
            }
        }

        return value;
    }


    public delegate string ApplyFunctionDelegate(string functionName, string[] parameters);
    public static string ApplyStringedFunction(string value, ApplyFunctionDelegate applyFunction)
    {
        if (!string.IsNullOrEmpty(value)) {

            // check for ending bracket
            if (value.Last() == ')') {

                // break apart brackets
                string trim = value.TrimEnd(')');
                string[] splitValue = trim.Split('(');

                // avoid normal brackets in text
                if (splitValue.Length >= 1 && splitValue.Length <= 2
                    && splitValue[0].Last() != ' ') {

                    // collect function name and paramters
                    string functionName = splitValue[0];
                    if (splitValue.Length == 2) {
                        string[] parameters = splitValue[1].Split(',');

                        // apply function
                        return applyFunction?.Invoke(functionName, parameters);
                    }
                }
            }
        }
        return value;
    }
}
