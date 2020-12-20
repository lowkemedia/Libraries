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
    public static char Last(this string value)
    {
        if (string.IsNullOrEmpty(value)) {
            return '\0';
        }
        return value[value.Length - 1];
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
