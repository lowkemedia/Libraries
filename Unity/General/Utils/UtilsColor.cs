//
//  UtilsColor - Utils package
//  Russell Lowke, October 29th 2019
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

using System;
using UnityEngine;

public static class UtilsColor
{
    //
    // Native equivalent: ColorUtility.TryParseHtmlString(colorString, out Color color).
    // This wrapper returns black for null/empty input.
    // Convert a color string to Color
    //  e.g. UtilsColor.ConvertColor("#00000066");
    //  use black cover, last two values are alpha
    public static Color ConvertColor(string colorString)
    {
		if (string.IsNullOrEmpty(colorString)) {
			return Color.black;
        }
        ColorUtility.TryParseHtmlString(colorString, out Color returnColor);
        return returnColor;
    }

    // Native alternative for hex strings: ColorUtility.TryParseHtmlString("#CC8844", out Color color).
    // Color32 also converts byte channels to Color. This method unpacks numeric 0xRRGGBB.
    // Returns normalized channels with alpha 1; bits above the lowest 24 are ignored.
    public static Color ColorHexToRGB(uint colorHex)
    {
        float r = ((colorHex & 0xFF0000) >> 16) / 255f;
        float g = ((colorHex & 0xFF00) >> 8) / 255f;
        float b = (colorHex & 0xFF) / 255f;
        return new Color(r, g, b, 1);
    }

    // Native alternative for hex strings: ColorUtility.ToHtmlStringRGB(new Color(r, g, b)).
    // Packs normalized channels into numeric 0xRRGGBB (no alpha).
    // Clamps finite channels to [0, 1], then rounds to the nearest byte, with ties to even.
    public static uint RGBToColorHex(float r, float g, float b)
    {
        uint red = (uint)Math.Round(Mathf.Clamp01(r) * 255);
        uint green = (uint)Math.Round(Mathf.Clamp01(g) * 255);
        uint blue = (uint)Math.Round(Mathf.Clamp01(b) * 255);
        return (red << 16) | (green << 8) | blue;
    }
}
