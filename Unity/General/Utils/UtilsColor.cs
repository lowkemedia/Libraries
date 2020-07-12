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
    // Convert a color string to Color
    //  e.g. Utils.ConvertColor("#00000066");
    //  use black cover, last two values are alpha
    public static Color ConvertColor(string colorString)
    {
        ColorUtility.TryParseHtmlString(colorString, out Color returnColor);
        return returnColor;
    }

	/*
	// Convert a 0x000000 colorHex uint into RGB percentiles
	// 
	// @param colorHex Color being converted to RGB
	// @return Returns an object with red green blue percentage values
	///
	public static Object colorHexToRGB(uint colorHex)
	{
		float r = ((colorHex & 0xFF0000) >> 16)/255;
		float g = ((colorHex & 0xFF00) >> 8)/255;
		float b = (colorHex & 0xFF)/255;

		return { r:r, g:g, b:b };
	}
	*/
		
		
	/*
	// Convert RGB percentiles to a 0x000000 colorHex
	// 
	public uint RGBtoColorHex(float r, float g, float b)
	{
		double red = Math.Round(r*255);
		double green = Math.Round(g*255);
		double blue = Math.Round(b*255);
		return (red << 16) | (green << 8) | blue;
	}
	*/
}
