//
//  ClickButtonStyle - Button package
//  Russell Lowke, July 12th 2020
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

using UnityEngine;

[CreateAssetMenu]
public class ClickButtonStyle : ScriptableObject
{
    // Sprite skin used for each state
    public Sprite normalSprite;         // up
    public Sprite highlightedSprite;    // over
    public Sprite pressedSprite;        // down
    public Sprite selectedSprite;       // selected
    public Sprite disabledSprite;       // disabled

    // color associated with each state,
    //  this is used for colorizing text or icons
    public string normalColor;
    public string highlightedColor;     // e.g. #FFFFFF7F is white with 50% alpha
    public string pressedColor;
    public string selectedColor;   
    public string disabledColor;

    // if true omits drawing the NormalSprite after a click,
    //  this is useful for tab menus or button toggles,
    //  otherwise you see the normal state flicker.
    public bool isTabOrToggle;

}
