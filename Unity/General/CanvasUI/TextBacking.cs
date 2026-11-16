// A generated Canvas backing fitted to rendered TMP text, independent of Localizer.
using TMPro;
using UnityEngine;
using UnityEngine.UI;

[DisallowMultipleComponent]
[RequireComponent(typeof(TextMeshProUGUI))]
public class TextBacking : MonoBehaviour
{
    public Color color = UnityEngine.Color.black;

    public Vector2 padding = new Vector2(20, 6);

    private TextMeshProUGUI _textField;
    private Image _backing;
    private Bounds _textBounds;
    private bool _hasVisibleText;

    private void Awake()
    {
        _textField = GetComponent<TextMeshProUGUI>();
        GameObject backingObject = new GameObject("Text Backing", typeof(RectTransform), typeof(CanvasRenderer),
            typeof(Image), typeof(LayoutElement));
        backingObject.layer = gameObject.layer;
        _backing = backingObject.GetComponent<Image>();
        _backing.color = color;
        _backing.raycastTarget = false;
        _backing.enabled = false;
        backingObject.GetComponent<LayoutElement>().ignoreLayout = true;

        // A child Image would draw over its parent text. Use the preceding sibling instead.
        RectTransform backingRect = _backing.rectTransform;
        backingRect.SetParent(transform.parent, false);
        backingRect.SetSiblingIndex(transform.GetSiblingIndex());
        backingRect.anchorMin = backingRect.anchorMax = backingRect.pivot = new Vector2(0.5f, 0.5f);
    }

    private void OnEnable() {
        _textField.OnPreRenderText += MeasureText;
        _textField.ForceMeshUpdate();
    }

    private void MeasureText(TMP_TextInfo textInfo)
    {
        // Only measure during TMP rebuild; resize the Image outside the rebuild loop.
        _textBounds = _textField.textBounds;
        _hasVisibleText = textInfo.characterCount > 0 && _textBounds.size.x > 0;
    }

    private void LateUpdate()
    {
        // TMP skips OnPreRenderText when cleared, so check for empty text directly.
        _backing.enabled = _textField.enabled && _hasVisibleText &&
            !string.IsNullOrEmpty(_textField.text);
        if (!_backing.enabled) { return; }

        RectTransform textRect = _textField.rectTransform;
        RectTransform backingRect = _backing.rectTransform;
        if (backingRect.parent != textRect.parent) {
            backingRect.SetParent(textRect.parent, false);
            backingRect.SetSiblingIndex(textRect.GetSiblingIndex());
        }
        backingRect.localRotation = textRect.localRotation;
        backingRect.localScale = textRect.localScale;
        backingRect.localPosition = textRect.localPosition +
            textRect.localRotation * Vector3.Scale(_textBounds.center, textRect.localScale);
        backingRect.sizeDelta = new Vector2(_textBounds.size.x + padding.x * 2,
            _textBounds.size.y + padding.y * 2);
        _backing.color = color;
    }

    private void OnDisable()
    {
        _textField.OnPreRenderText -= MeasureText;
        if (_backing != null) {
            _backing.enabled = false;
        }
    }

    private void OnDestroy()
    {
        if (_backing != null) {
            Destroy(_backing.gameObject);
        }
    }
}

public static class TextBackingExtensions
{
    public static TextBacking AddTextBacking(this TextMeshProUGUI textField)
    {
        TextBacking backing = textField.GetComponent<TextBacking>();
        if (backing == null) {
            backing = textField.gameObject.AddComponent<TextBacking>();
        }
        return backing;
    }
}
