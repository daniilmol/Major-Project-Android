using System.Collections;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;
[DefaultExecutionOrder(-1)]
public class InputManager : Singleton<InputManager>
{
    private TouchControls touchControls;
    private Coroutine zoomCoroutine;
    private Transform cameraTransform;
    private float speed = 4f;
    public delegate void StartTouchEvent(Vector2 position, float time);
    public event StartTouchEvent OnStartTouch;
    public delegate void EndTouchEvent(Vector2 position, float time);
    public event EndTouchEvent OnEndTouch;
    public delegate void StartSwipe(Vector2 position, float time);
    public event StartSwipe OnStartSwipe;
    public delegate void EndSwipe(Vector2 position, float time);
    public event EndSwipe OnEndSwipe;

    private void Awake(){
        touchControls = new TouchControls();
        cameraTransform = Camera.main.transform;
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
        touchControls.Touch.SecondaryTouchContact.started += _ => ZoomStart();
        touchControls.Touch.SecondaryTouchContact.canceled += _ => ZoomEnd();
        touchControls.Touch.PrimaryContact.started += ctx => StartTouchPrimary(ctx);
        touchControls.Touch.PrimaryContact.canceled += ctx => EndTouchPrimary(ctx);
    }
    private void StartTouch(InputAction.CallbackContext ctx){
        if(OnStartTouch != null){
            OnStartTouch(touchControls.Touch.TouchPosition.ReadValue<Vector2>(), (float)ctx.startTime);
        }
    }
    private void EndTouch(InputAction.CallbackContext ctx){
        if(OnEndTouch != null){
            OnEndTouch(touchControls.Touch.TouchPosition.ReadValue<Vector2>(), (float)ctx.time);
        }
    }
    private void ZoomStart(){
        zoomCoroutine = StartCoroutine(ZoomDetection());
    }
    private void ZoomEnd(){
        StopCoroutine(zoomCoroutine);
    }
    private void StartTouchPrimary(InputAction.CallbackContext ctx){
        if(OnStartSwipe != null){
            OnStartSwipe(Utils.ScreenToWorld(Camera.main, touchControls.Touch.PrimaryPosition.ReadValue<Vector2>()), (float)ctx.startTime);
        }
    }
    private void EndTouchPrimary(InputAction.CallbackContext ctx){
        if(OnEndSwipe != null){
            OnEndSwipe(Utils.ScreenToWorld(Camera.main, touchControls.Touch.PrimaryPosition.ReadValue<Vector2>()), (float)ctx.time);
        }
    }
    public Vector2 PrimaryPosition(){
        return Utils.ScreenToWorld(Camera.main, touchControls.Touch.PrimaryPosition.ReadValue<Vector2>());
    }
    IEnumerator ZoomDetection(){
        float previousDistance = 0f;
        float currentDistance = 0f;
        while(true){
            currentDistance = Vector2.Distance(touchControls.Touch.PrimaryFingerPosition.ReadValue<Vector2>(), touchControls.Touch.SecondaryFingerPosition.ReadValue<Vector2>());
            if(currentDistance > previousDistance){
                Vector3 targetPosition = cameraTransform.position;
                targetPosition.z += 1;
                targetPosition.y -= 1;
                cameraTransform.position = Vector3.Slerp(cameraTransform.position, targetPosition, Time.deltaTime * speed);
            }else if(currentDistance < previousDistance){
                Vector3 targetPosition = cameraTransform.position;
                targetPosition.z -= 1;
                targetPosition.y += 1;
                cameraTransform.position = Vector3.Slerp(cameraTransform.position, targetPosition, Time.deltaTime * speed);
            }
            previousDistance = currentDistance;
            yield return null;
        }
    }
}
