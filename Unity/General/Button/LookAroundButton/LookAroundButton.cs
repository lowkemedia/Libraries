//
//  LookAroundButton - Button package
//  Russell Lowke, July 22nd 2020
//
//  Copyright (c) 2019-2020 Lowke Media
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
using UnityEngine.EventSystems;
using System;

public class LookAroundButton : ClickButton, IDragHandler, IEndDragHandler, IPointerClickHandler
{
	// Speed depends on device resolution vs drag delta
	private const float SPEED = 1.2f;

	// Maximum change for transform, otherwise camera zips out of control on 1st press
	private const float BREAK = 12.0f;

	public Camera lookAroundCamera;

	private GameObject _lookAroundContainer;
	private bool _isDragging;

	protected override void Start()
	{
		base.Start();

		const string CONTAINER_NAME = "LookAround Container";
		GameObject parent = lookAroundCamera.GetParent();
		if (parent is null) {
			_lookAroundContainer = new GameObject(CONTAINER_NAME);
		} else {
			_lookAroundContainer = parent.MakeUiObject(CONTAINER_NAME);
		}
		lookAroundCamera.SetParent(_lookAroundContainer);
		_lookAroundContainer.transform.rotation = Quaternion.Euler(90f, 90f, 0f);
	}

	public void OnDrag(PointerEventData pointerEventData)
	{
		_isDragging = true;
		HorizontalRotation();
		VerticalRotation();
	}

	public void OnEndDrag(PointerEventData pointerEventData)
	{
		_isDragging = false;
	}

	public override void OnPointerClick(PointerEventData pointerEventData)
	{
		if (!_isDragging) {
			base.OnPointerClick(pointerEventData);
		}
	}

	protected virtual void HorizontalRotation()
	{
		float dMouseX = SPEED * Input.GetAxis("Mouse X");
		if (Math.Abs(dMouseX) < BREAK) {
			TurnCameraX(dMouseX);
		}
	}

	protected virtual void VerticalRotation()
	{
		float dMouseY = SPEED * Input.GetAxis("Mouse Y");
		if (Math.Abs(dMouseY) < BREAK) {
			TurnCameraY(dMouseY);
		}
	}

	public void TurnCameraX(float angleX)
	{
		Transform cameraTransform = _lookAroundContainer.transform;
		cameraTransform.RotateAround(cameraTransform.position, -Vector3.up, angleX);
	}

	public void TurnCameraY(float angleY)
	{
		Transform cameraTransform = _lookAroundContainer.transform;
		cameraTransform.RotateAround(cameraTransform.position, cameraTransform.right, angleY);
	}

	public void TurnCameraZ(float angleZ)
	{
		// TODO: Fix. Turning on Z causes gimbal issues
		Transform cameraTransform = _lookAroundContainer.transform;
		cameraTransform.RotateAround(cameraTransform.position, cameraTransform.forward, angleZ);
	}
}