//
//  GyroLookAroundButton - Button package
//  Russell Lowke, July 22nd 2020
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

public class GyroLookAroundButton : LookAroundButton
{
	private Gyroscope _gyro;
	private Quaternion _rot;

	protected override void Start()
	{
		base.Start();

		/*
		const string CONTAINER_NAME = "Gyro Container";
		GameObject parent = lookAroundCamera.GetParent();
		if (parent == null) {
			_gyroContainer = new GameObject(CONTAINER_NAME);
		} else {
			_gyroContainer = parent.MakeGameObject(CONTAINER_NAME);
		}
		lookAroundCamera.SetParent(_gyroContainer);
		*/

		if (SystemInfo.supportsGyroscope) {
			_gyro = Input.gyro;

			// _gyroContainer.transform.rotation = Quaternion.Euler(90f, 90f, 0f);
			_rot = new Quaternion(0, 0, 1, 0);
		}
	}

	private void Update()
	{
		if (_gyro != null) {
			Transform cameraTransform = lookAroundCamera.gameObject.transform;
			cameraTransform.localRotation = _gyro.attitude * _rot;
		}
	}

	protected override void VerticalRotation()
	{
		if (_gyro != null) {
			// ignore vertical rotation if gyro enabled
			return;
		}

		base.VerticalRotation();
	}
}
