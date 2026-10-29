//
// System Alert - independent of gameplay UI, localization and sound.
// Layout based on Russell Lowke's Adobe com.lowke.alert.Alert (2011).
// Copyright (c) 2008-2026 Lowke Media.
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
using System.Collections.Generic;
using CallbackTypes;
using UnityEngine;
using UnityEngine.UI;

public sealed class Alert : MonoBehaviour
{
    public enum Icon { None, Info, Question, Warning, Error }

    public const string NO_ICON = "";
    public const string INFO_ICON = "i";
    public const string QUESTION_ICON = "?";
    public const string WARNING_ICON = "!";
    public const string ERROR_ICON = "X";

    private sealed class Notice
    {
        public readonly string Message;
        public readonly string Title;
        public readonly string ButtonText;
        public readonly Icon Icon;
        public readonly Callback OnAcknowledged;
        public readonly string CancelButtonText;
        public readonly Callback OnCancel;

        public Notice(string message, string title, Icon icon, Callback onAcknowledged, string buttonText,
                      string cancelButtonText = null, Callback onCancel = null)
        {
            Message = message ?? "";
            Title = title ?? "";
            Icon = icon;
            OnAcknowledged = onAcknowledged;
            ButtonText = string.IsNullOrEmpty(buttonText) ? "OK" : buttonText;
            CancelButtonText = cancelButtonText;
            OnCancel = onCancel;
        }
    }

    private static readonly object _queueLock = new object();
    private static Queue<Notice> _pending = new Queue<Notice>();
    private static Notice _current;
    private static Alert _instance;
    private Notice _displayed;
    private Vector2 _scroll;
    private Canvas _inputBlocker;
    private Texture2D _circle;
    private GUIStyle _bodyStyle;
    private GUIStyle _titleStyle;
    private GUIStyle _iconStyle;
    private GUIStyle _buttonStyle;
    private float _buttonReadyAt;
    private float _highlightUntil;
    private int _buttonControl;
    private bool _renderErrorReported;
    private Rect _panelScreenRect;
    private Notice _panelNotice;
    private int _panelScreenWidth;
    private int _panelScreenHeight;

    public static bool IsShowing {
        get { lock (_queueLock) { return _current != null || _pending.Count > 0; } }
    }

    // Safe to enqueue from a worker: all Unity object work happens on the host's main thread.
    // Runtime bootstrap installs the host before the first scene's Awake methods.
    public static void Show(string message, string title = "System Alert", Icon icon = Icon.Info,
                            string buttonText = "OK", Callback onAcknowledged = null)
    {
        lock (_queueLock) {
            _pending.Enqueue(new Notice(message, title, icon, onAcknowledged, buttonText));
        }
    }

    // Cancel is on the left; the primary action is on the right. Only the chosen callback runs.
    public static void Question(string message, string title = "Question",
                            string buttonText = "OK", Callback onAcknowledged = null,
                            string cancelButtonText = "Cancel", Callback onCancel = null,
                            bool log = false, string id = null)
    {
        if (log) { Logger.LogNoAlert(Logger.LogLevel.INFO, message, id); }
        lock (_queueLock) {
            _pending.Enqueue(new Notice(message, title, Icon.Question, onAcknowledged, buttonText,
                string.IsNullOrEmpty(cancelButtonText) ? "Cancel" : cancelButtonText, onCancel));
        }
    }

    // Log once without routing back into an automatic alert. Presentation remains unconditional.
    public static void Info(string message, string title = "Information",
                            string buttonText = "OK", Callback onAcknowledged = null,
                            bool log = false, string id = null)
    {
        if (log) { Logger.LogNoAlert(Logger.LogLevel.INFO, message, id); }
        Show(message, title, Icon.Info, buttonText, onAcknowledged);
    }

    public static void Warning(string message, string title = "Warning",
                            string buttonText = "OK", Callback onAcknowledged = null,
                            bool log = true, string id = null)
    {
        if (log) { Logger.LogNoAlert(Logger.LogLevel.WARNING, message, id); }
        Show(message, title, Icon.Warning, buttonText, onAcknowledged);
    }

    // With logging enabled and not filtered, Unity Error Pause can pause Editor Play Mode.
    // This does not pause standalone players; the alert's OK button does not unpause the Editor.
    public static void Severe(string message, string title = "Severe",
                            string buttonText = "OK", Callback onAcknowledged = null,
                            bool log = true, string id = null)
    {
        if (log) { Logger.LogNoAlert(Logger.LogLevel.SEVERE, message, id); }
        Show(message, title, Icon.Error, buttonText, onAcknowledged);
    }
    public static void Error(string message, string title = "Error",
                            string buttonText = "OK", Callback onAcknowledged = null,
                            bool log = true, string id = null)
    {
        // Recoverable errors use warning output and its icon, retaining the Error title.
        Warning(message, title, buttonText, onAcknowledged, log, id);
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void ResetSession()
    {
        lock (_queueLock) { _pending.Clear(); _current = null; }
        _instance = null;
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    private static void Install()
    {
        if (_instance != null) { return; }
        // Also reuse the host when the Editor has disabled scene reload.
        _instance = FindObjectOfType<Alert>();
        if (_instance == null) {
            _instance = new GameObject("System Alert").AddComponent<Alert>();
        }
        DontDestroyOnLoad(_instance.gameObject);
    }

    private static Notice NextNotice()
    {
        lock (_queueLock) {
            if (_current == null && _pending.Count > 0) { _current = _pending.Dequeue(); }
            return _current;
        }
    }

    private static void Acknowledge(Notice notice)
    {
        Complete(notice, false);
    }

    private static void Cancel(Notice notice)
    {
        if (notice == null || notice.CancelButtonText == null) { return; }
        Complete(notice, true);
    }

    private static void Complete(Notice notice, bool cancelled)
    {
        lock (_queueLock) {
            if (notice == null || !ReferenceEquals(_current, notice)) { return; }
            // Clear before invoking user code: double clicks, re-entry and exceptions cannot repeat it.
            _current = null;
        }
        Callback callback = cancelled ? notice.OnCancel : notice.OnAcknowledged;
        callback?.Invoke();
    }

    private void Update()
    {
        if (_instance != null && _instance != this) { enabled = false; return; }
        _instance = this;
        Notice notice = NextNotice();
        if (!ReferenceEquals(_displayed, notice)) {
            _displayed = notice;
            _scroll = Vector2.zero;
            _highlightUntil = 0f;
            _buttonReadyAt = Time.realtimeSinceStartup + 0.2f;
            _renderErrorReported = false;
        }
        if (notice != null) { EnsureInputBlocker(); }
        if (_inputBlocker != null) { _inputBlocker.gameObject.SetActive(notice != null); }
        if (notice != null && ReferenceEquals(_panelNotice, notice) &&
            _panelScreenWidth == Screen.width && _panelScreenHeight == Screen.height) {
            // Poll independently of IMGUI: ModalWindow can suppress outside mouse events.
            // Touch takes precedence over its simulated mouse event to avoid duplicate beeps.
            if (Input.touchCount > 0) {
                for (int i = 0; i < Input.touchCount; i++) {
                    Touch touch = Input.GetTouch(i);
                    if (touch.phase == TouchPhase.Began) { CheckOutsidePress(touch.position); }
                }
            } else {
                for (int button = 0; button < 3; button++) {
                    if (Input.GetMouseButtonDown(button)) { CheckOutsidePress(Input.mousePosition); }
                }
            }
        }
    }

    private void EnsureInputBlocker()
    {
        if (_inputBlocker != null) { return; }
        // IMGUI supplies the alert's input, including in scenes without an EventSystem.
        // This transparent canvas intercepts uGUI raycasts if a gameplay EventSystem is present.
        var host = new GameObject("System Alert input blocker", typeof(RectTransform),
            typeof(Canvas), typeof(GraphicRaycaster), typeof(Image));
        host.transform.SetParent(transform, false);
        _inputBlocker = host.GetComponent<Canvas>();
        _inputBlocker.renderMode = RenderMode.ScreenSpaceOverlay;
        _inputBlocker.sortingOrder = short.MaxValue;
        host.GetComponent<Image>().color = Color.clear;
    }

    private void EnsureStyles()
    {
        if (_bodyStyle != null) { return; }
        _bodyStyle = new GUIStyle {
            fontSize = 14, wordWrap = true, richText = false,
            padding = new RectOffset(), alignment = TextAnchor.UpperLeft
        };
        _bodyStyle.normal.textColor = Color.black;
        _titleStyle = new GUIStyle(_bodyStyle) { fontSize = 16, fontStyle = FontStyle.Bold };
        _iconStyle = new GUIStyle(_bodyStyle) {
            fontSize = 34, fontStyle = FontStyle.Bold, alignment = TextAnchor.MiddleCenter
        };
        _buttonStyle = new GUIStyle { fontSize = 14, richText = false, alignment = TextAnchor.MiddleCenter };
        // Explicit colours avoid inheriting the Editor's dark theme or a game's GUISkin styling.
        foreach (var state in new[] { _buttonStyle.normal, _buttonStyle.hover, _buttonStyle.active,
                                      _buttonStyle.focused }) {
            state.background = Texture2D.whiteTexture;
            state.textColor = Color.black;
        }
        // GUI.Button selects active on mouse-down; acknowledge only on release.
        _buttonStyle.active.background = Texture2D.blackTexture;
        _buttonStyle.active.textColor = Color.white;
        _circle = new Texture2D(48, 48, TextureFormat.RGBA32, false);
        var pixels = new Color[48 * 48];
        for (int y = 0; y < 48; y++) for (int x = 0; x < 48; x++) {
            pixels[y * 48 + x] = new Vector2(x - 23.5f, y - 23.5f).sqrMagnitude <= 24 * 24
                ? Color.white : Color.clear;
        }
        _circle.SetPixels(pixels);
        _circle.Apply();
    }

    private void OnGUI()
    {
        Notice notice;
        lock (_queueLock) { notice = _current; }
        if (notice == null || !ReferenceEquals(notice, _displayed)) { return; }
        Matrix4x4 previousMatrix = GUI.matrix;
        Color previousColor = GUI.color;
        Color previousBackground = GUI.backgroundColor;
        Color previousContent = GUI.contentColor;
        bool previousEnabled = GUI.enabled;
        int previousDepth = GUI.depth;
        try {
            GUI.depth = -10000;
            GUI.color = GUI.contentColor = GUI.backgroundColor = Color.white;
            GUI.enabled = true;
            EnsureStyles();
            Rect safe = Screen.safeArea;
            if (safe.width <= 0 || safe.height <= 0) { safe = new Rect(0, 0, Screen.width, Screen.height); }
            if (safe.width <= 0 || safe.height <= 0) { return; }
            // Scale the entire 400-unit layout, including text and buttons, to two-thirds
            // of the shorter safe-area axis. Recalculate each frame for rotation/resizing.
            const float layoutWidth = 400f;
            float scale = Mathf.Min(safe.width, safe.height) * (2f / 3f) / layoutWidth;
            GUI.matrix = Matrix4x4.Scale(new Vector3(scale, scale, 1));
            Rect area = new Rect(safe.x / scale, (Screen.height - safe.yMax) / scale,
                safe.width / scale, safe.height / scale);
            float width = layoutWidth;
            float textX = notice.Icon == Icon.None ? 18 : 84;
            float textWidth = width - textX - 18;
            float titleHeight = string.IsNullOrEmpty(notice.Title) ? 0 :
                _titleStyle.CalcHeight(new GUIContent(notice.Title), textWidth) + 10;
            float messageHeight = _bodyStyle.CalcHeight(new GUIContent(notice.Message), textWidth - 20);
            float height = Mathf.Min(Mathf.Max(126, messageHeight + titleHeight + 88), area.height - 36);
            Rect panel = new Rect(area.x + (area.width - width) / 2,
                area.y + Mathf.Clamp(area.height / 3 - height / 2, 18, area.height - height - 18), width, height);
            if (Event.current.type == EventType.Repaint) {
                _panelScreenRect = new Rect(panel.x * scale, panel.y * scale,
                    panel.width * scale, panel.height * scale);
                _panelNotice = notice;
                _panelScreenWidth = Screen.width;
                _panelScreenHeight = Screen.height;
            }
            // Consume any outside press delivered to IMGUI; Update handles the sound.
            Event input = Event.current;
            bool releaseButton = input.rawType == EventType.MouseUp && input.button == 0;
            if (input.rawType == EventType.MouseDown && !panel.Contains(input.mousePosition)) {
                input.Use();
            }
            Fill(new Rect(0, 0, Screen.width / scale, Screen.height / scale), new Color(0, 0, 0, 0.28f));
            Fill(new Rect(panel.x + 3, panel.y + 3, width, height), new Color(0, 0, 0, 0.35f));
            if (Time.realtimeSinceStartup < _highlightUntil) {
                // Draw outside the window so its clipping cannot trim the expanded outline.
                Fill(new Rect(panel.x - 2, panel.y - 2, width + 4, height + 4), Color.black);
            }
            GUI.ModalWindow(GetInstanceID(), panel,
                id => DrawNotice(notice, width, height, textX, textWidth, titleHeight, messageHeight),
                GUIContent.none, GUIStyle.none);
            // ModalWindow can filter releases outside its bounds. Let the button handle
            // an inside release first, then clear only the capture owned by our button.
            if (releaseButton) { ReleaseButtonCapture(); }
        }
        catch (ExitGUIException) { throw; }
        catch (System.Exception error) {
            // Never route a presentation failure back through Logger or acknowledge it implicitly.
            ReportRenderFailure(error);
        }
        finally {
            GUI.matrix = previousMatrix;
            GUI.color = previousColor;
            GUI.backgroundColor = previousBackground;
            GUI.contentColor = previousContent;
            GUI.enabled = previousEnabled;
            GUI.depth = previousDepth;
        }
    }

    private void ReportRenderFailure(System.Exception error)
    {
        if (_renderErrorReported) { return; }
        _renderErrorReported = true;
        // Keep the original exception/stack as the inner exception; never queue another alert.
        UnityEngine.Debug.LogException(new System.Exception(
            "#" + AlertID.SEVERE_RENDER_FAILED + ": System Alert rendering failed.", error));
    }

    private void DrawNotice(Notice notice, float width, float height, float textX,
                            float textWidth, float titleHeight, float messageHeight)
    {
        // Briefly invert and thicken the frame after an outside press.
        bool highlighted = Time.realtimeSinceStartup < _highlightUntil;
        float border = highlighted ? 4f : 2f;
        Fill(new Rect(0, 0, width, height), highlighted ? Color.white : Color.black);
        Fill(new Rect(border, border, width - 2 * border, height - 2 * border),
            new Color32(204, 204, 204, 255));
        if (notice.Icon != Icon.None) {
            bool round = notice.Icon == Icon.Info || notice.Icon == Icon.Question;
            Color32 iconColor;
            string symbol;
            switch (notice.Icon) {
                case Icon.Warning:
                    iconColor = new Color32(255, 255, 153, 255); // 0xFFFF99 yellow
                    symbol = WARNING_ICON;
                    break;
                case Icon.Error:
                    iconColor = new Color32(204, 102, 102, 255); // 0xCC6666 red
                    symbol = ERROR_ICON;
                    break;
                case Icon.Question:
                case Icon.Info:
                    iconColor = new Color32(101, 152, 255, 255); // 0x6598FF blue
                    symbol = notice.Icon == Icon.Question ? QUESTION_ICON : INFO_ICON;
                    break;
                default:
                    iconColor = new Color32(238, 238, 238, 255); // 0xEEEEEE light grey
                    symbol = NO_ICON;
                    break;
            }
            GUI.color = iconColor;
            GUI.DrawTexture(new Rect(18, 18, 48, 48), round ? _circle : Texture2D.whiteTexture);
            GUI.color = Color.white;
            _iconStyle.normal.textColor = round ? Color.white : Color.black;
            GUI.Label(new Rect(18, 18, 48, 48), symbol, _iconStyle);
        }
        GUI.Label(new Rect(textX, 18, textWidth, titleHeight), notice.Title, _titleStyle);
        Rect viewport = new Rect(textX, 18 + titleHeight, textWidth, Mathf.Max(24, height - titleHeight - 88));
        Rect content = new Rect(0, 0, textWidth - 20, Mathf.Max(viewport.height, messageHeight));
        // Touch dragging, plus mouse wheel/scrollbar, keeps long diagnostics accessible.
        Event input = Event.current;
        if (input.type == EventType.MouseDrag && viewport.Contains(input.mousePosition)) {
            _scroll.y = Mathf.Clamp(_scroll.y - input.delta.y, 0, Mathf.Max(0, content.height - viewport.height));
            input.Use();
        }
        _scroll = GUI.BeginScrollView(viewport, _scroll, content);
        GUI.Label(new Rect(0, 0, content.width, messageHeight), notice.Message, _bodyStyle);
        GUI.EndScrollView();
        bool cancelled = false;
        if (notice.CancelButtonText != null) {
            cancelled = DrawButton(new Rect(width - 212, height - 52, 88, 34), notice.CancelButtonText);
        }
        bool accepted = DrawButton(new Rect(width - 106, height - 52, 88, 34), notice.ButtonText);
        if (accepted || cancelled) {
            ReleaseButtonCapture();
            Click.Play();
            // Blocker is disabled before callback-driven scene navigation, never after it.
            if (_inputBlocker != null) { _inputBlocker.gameObject.SetActive(false); }
            if (cancelled) { Cancel(notice); }
            else { Acknowledge(notice); }
        }
    }

    private bool DrawButton(Rect button, string text)
    {
        Fill(new Rect(button.x - 3, button.y - 3, button.width + 6, button.height + 6), Color.black);
        GUI.backgroundColor = new Color32(238, 238, 238, 255);
        GUI.enabled = Time.realtimeSinceStartup >= _buttonReadyAt;
        int previousControl = GUIUtility.hotControl;
        bool accepted = GUI.Button(button, text, _buttonStyle);
        if (GUIUtility.hotControl != 0 && GUIUtility.hotControl != previousControl) {
            _buttonControl = GUIUtility.hotControl;
        }
        GUI.enabled = true;
        return accepted;
    }

    private void ReleaseButtonCapture()
    {
        if (_buttonControl != 0 && GUIUtility.hotControl == _buttonControl) {
            GUIUtility.hotControl = 0;
        }
        _buttonControl = 0;
    }

    private void CheckOutsidePress(Vector2 position)
    {
        // Input uses bottom-left pixels; the cached GUI rectangle uses top-left pixels.
        Vector2 guiPosition = new Vector2(position.x, Screen.height - position.y);
        if (position.x >= 0 && position.x < Screen.width && position.y >= 0 &&
            position.y < Screen.height && !_panelScreenRect.Contains(guiPosition)) {
            _highlightUntil = Time.realtimeSinceStartup + 0.18f;
            Beep.Play();
        }
    }

    private static void Fill(Rect rect, Color color)
    {
        Color previous = GUI.color;
        GUI.color = color;
        GUI.DrawTexture(rect, Texture2D.whiteTexture);
        GUI.color = previous;
    }

    private void OnDestroy()
    {
        if (_instance == this) { _instance = null; }
        if (_circle != null) { Destroy(_circle); }
        // Destruction is not acknowledgement. Never run a recovery continuation here.
    }
}

public static class AlertID
{
    // Error, warning and info IDs.
    public const string SEVERE_RENDER_FAILED = "ALT00";
}
