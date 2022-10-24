//
//  ImageComposite - ImageComposite package
//  Russell Lowke, October 6th 2022
//
//  Copyright (c) 2022 Lowke Media
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
using UnityEngine.UI;

public class ImageComposite : MonoBehaviour
{
    private Image _rootImage;

    public void Initialize(Sprite sprite, Color color = default)
    {
        _rootImage = gameObject.AddComponent<Image>();
        _rootImage.sprite = sprite;
        if (color != default) {
            _rootImage.color = color;
        }
        // image.preserveAspect = true;
    }

    public Sprite Sprite {
        get { return _rootImage.sprite; }
        set { _rootImage.sprite = value; }
    }

    public RectTransform RectTransform {
        get { return _rootImage.rectTransform; }
    }

    public bool RaycastTarget {
        get { return _rootImage.raycastTarget; }
        set { _rootImage.raycastTarget = value; }
    }

    public Vector4 RaycastPadding {
        get { return _rootImage.raycastPadding; }
        set { _rootImage.raycastPadding = value; }
    }

    public void AddImage(Sprite sprite, string name, Color color = default)
    {
        GameObject imageGameObject = new GameObject();
        imageGameObject.name = name;
        Image image = imageGameObject.AddComponent<Image>();
        image.sprite = sprite;
        if (color != default) {
            image.color = color;
        }
        image.raycastTarget = false;
        UtilsRect.AttachChild(gameObject, imageGameObject);
    }

    public static ImageComposite Make(GameObject parent, Sprite sprite, string name, Color color = default)
    {
        GameObject gameObject = new GameObject();
        gameObject.name = name;
        ImageComposite imageComposite = gameObject.AddComponent<ImageComposite>();
        imageComposite.Initialize(sprite, color);
        UtilsRect.AttachChild(parent, gameObject);

        return imageComposite;
    }
}
