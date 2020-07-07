﻿using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class TintOverlayButton : ClickButton, IPointerClickHandler

{
    private Color _tintHighlight;             // "over" tint
    private Color _tintPressed;               // "down" tint
    private Image _tintImage;

    public override void Initialize()
    {
        base.Initialize();
        
        _tintHighlight = Utils.ConvertColor("#00000033");
        _tintPressed = Utils.ConvertColor("#e9552575");             // e9552575         // ef805cbf

        GameObject child = gameObject.MakeGameObject("Tint");
        _tintImage = child.AddComponent<Image>();
        _tintImage.SetSize(_buttonImage.GetWidth(), _buttonImage.GetHeight());
        _tintImage.color = Color.clear;
    }


    override public void OnPointerEnter(PointerEventData clickEventData)
    {
        _tintImage.color = _tintHighlight;
        base.OnPointerEnter(clickEventData);
    }

    override public void OnPointerDown(PointerEventData clickEventData = null)
    {
        _tintImage.color = _tintPressed;

        // Block OnPointerDown call
        //   base.OnPointerDown(clickEventData);      
    }

    override public void OnPointerUp(PointerEventData clickEventData)
    {
        _tintImage.color = _tintHighlight;
        base.OnPointerUp(clickEventData);
    }

    override public void OnPointerExit(PointerEventData clickEventData)
    {
        _tintImage.color = Color.clear;
        base.OnPointerExit(clickEventData);
    }

    public void OnPointerClick(PointerEventData clickEventData)
    {
        base.OnPointerDown(clickEventData);
        base.OnPointerUp(clickEventData);
    }
}
