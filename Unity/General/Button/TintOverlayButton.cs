using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class TintOverlayButton : ClickButton, IPointerClickHandler

{
    private Color _tintHighlight;             // "over" tint
    private Color _tintPressed;               // "down" tint
    private Image _tintImage;

    protected override void Start()
    {
        base.Start();
        
        _tintHighlight = UtilsColor.ConvertColor("#00000033");
        _tintPressed = UtilsColor.ConvertColor("#e9552575");             // e9552575         // ef805cbf

        GameObject child = gameObject.MakeGameObject("Tint");
        _tintImage = child.AddComponent<Image>();
        _tintImage.SetSize(ButtonImage.GetWidth(), ButtonImage.GetHeight());
        _tintImage.color = Color.clear;
    }


    public override void OnPointerEnter(PointerEventData clickEventData)
    {
        _tintImage.color = _tintHighlight;
        base.OnPointerEnter(clickEventData);
    }

    public override void OnPointerDown(PointerEventData clickEventData = null)
    {
        _tintImage.color = _tintPressed;

        // Block OnPointerDown call
        //   base.OnPointerDown(clickEventData);      
    }

    public override void OnPointerUp(PointerEventData clickEventData)
    {
        _tintImage.color = _tintHighlight;
        base.OnPointerUp(clickEventData);
    }

    public override void OnPointerExit(PointerEventData clickEventData)
    {
        _tintImage.color = Color.clear;
        base.OnPointerExit(clickEventData);
    }

    public override void OnPointerClick(PointerEventData clickEventData)
    {
        _tintImage.color = _tintPressed;
        base.OnPointerDown(clickEventData);
        base.OnPointerUp(clickEventData);
        base.OnPointerClick(clickEventData);
    }
}

