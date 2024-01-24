using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;
[DefaultExecutionOrder(-1)]
public class InputManager : Singleton<InputManager>
{
    private TouchControls touchControls;
    public delegate void StartTouchEvent(Vector3 position, float time);
    public event StartTouchEvent OnStartTouch;
    public delegate void EndTouchEvent(Vector3 position, float time);
    public event EndTouchEvent OnEndTouch;

    private void Awake(){
        touchControls = new TouchControls();
    }
    private void OnEnable(){
        touchControls.Enable();
    }
    private void OnDisable() {
        touchControls.Disable();
    }
    private void Start(){
        touchControls.Touch.TouchPress.started += ctx => StartTouch(ctx);
        touchControls.Touch.TouchPress.canceled += ctx => EndTouch(ctx);
    }
    private void StartTouch(InputAction.CallbackContext ctx){
        if(OnStartTouch != null){
            OnStartTouch(touchControls.Touch.TouchPosition.ReadValue<Vector3>(), (float)ctx.startTime);
        }
    }
    private void EndTouch(InputAction.CallbackContext ctx){
        if(OnEndTouch != null){
            OnEndTouch(touchControls.Touch.TouchPosition.ReadValue<Vector3>(), (float)ctx.time);
        }
    }
}
