//
//  DialogBase - DialogManager package
//  Russell Lowke, November 8th 2022
//
//  Copyright (c) 2021-2022 Lowke Media
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

public abstract class DialogBase : MonoBehaviour
{
    protected DialogManager _dialogManager;

    public bool DialogIsSetup { get; private set; }

    virtual public void Initialize(DialogManager dialogManager)
    {
        _dialogManager = dialogManager;
        this.gameObject.SetActive(false);
    }

    virtual public void SetupDialog()
    {
        // declare that dialog has been setup
        DialogIsSetup = true;
    }

    public void ShowDialog()
    {
        _dialogManager.ShowDialog(this);
    }

    public void HideDialog()
    {
        _dialogManager.HideDialog(this);
    }

    public void DialogShown()
    {
        // shown dialogs need to be setup before being shown again.
        DialogIsSetup = false;
    }
}
