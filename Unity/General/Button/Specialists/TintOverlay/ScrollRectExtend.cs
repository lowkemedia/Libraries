using UnityEngine.EventSystems;
using UnityEngine.UI;

public class ScrollRectExtend : ScrollRect, IBeginDragHandler, IEndDragHandler
{
    public delegate void PointerEvent(PointerEventData pointerEventData);

    public event PointerEvent OnBeginDragEvent;
    public event PointerEvent OnEndDragEvent;

    public override void OnBeginDrag(PointerEventData pointerEventData)
    {
        base.OnBeginDrag(pointerEventData);
        OnBeginDragEvent?.Invoke(pointerEventData);
    }

    public override void OnEndDrag(PointerEventData pointerEventData)
    {
        base.OnEndDrag(pointerEventData);
        OnEndDragEvent?.Invoke(pointerEventData);
    }
}
