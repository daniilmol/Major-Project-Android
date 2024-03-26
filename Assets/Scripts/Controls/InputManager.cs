using System.Collections;
using System.Collections.Generic;

using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.UI;
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
    private InputSystemUIInputModule inputModule;
    private bool clicking = false;
    private int id;
    private bool mouseOverUI = false;
    private bool isTouchActive = false;
    private bool isSwipeActive = false;
    private void Awake(){
        touchControls = new TouchControls();
        cameraTransform = Camera.main.transform;
        inputModule = FindObjectOfType<InputSystemUIInputModule>();
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
        id = ctx.control.device.deviceId;
        startTouchPosition = touchControls.Touch.TouchPosition.ReadValue<Vector2>();
        if(OnStartTouch != null && !mouseOverUI && !isSwipeActive){
            isTouchActive = true;
            OnStartTouch(touchControls.Touch.TouchPosition.ReadValue<Vector2>(), (float)ctx.startTime);
        }
    }
    private void EndTouch(InputAction.CallbackContext ctx){
        id = ctx.control.device.deviceId;
        if(OnEndTouch != null && !mouseOverUI){
            Vector2 endTouchPosition = touchControls.Touch.TouchPosition.ReadValue<Vector2>();
            float swipeDistance = Vector2.Distance(startTouchPosition, endTouchPosition);
            if (swipeDistance > 128)
            {
                isSwipeActive = true;
                isTouchActive = false;
            }else{
                OnEndTouch(touchControls.Touch.TouchPosition.ReadValue<Vector2>(), (float)ctx.time);
            }
            isTouchActive = false;
        }
    }
    private void ZoomStart(){
        zoomCoroutine = StartCoroutine(ZoomDetection());
    }
    private void ZoomEnd(){
        StopCoroutine(zoomCoroutine);
    }
    private Vector2 startTouchPosition;
    private void StartTouchPrimary(InputAction.CallbackContext ctx){
        id = ctx.control.device.deviceId;
        if(OnStartSwipe != null && !mouseOverUI){
            isSwipeActive = true;
            OnStartSwipe(touchControls.Touch.PrimaryPosition.ReadValue<Vector2>(), (float)ctx.startTime);
        }
    }
    private void EndTouchPrimary(InputAction.CallbackContext ctx){
        id = ctx.control.device.deviceId;
        if(OnEndSwipe != null && !mouseOverUI){
            isSwipeActive = false;
            OnEndSwipe(touchControls.Touch.PrimaryPosition.ReadValue<Vector2>(), (float)ctx.time);
        }
    }
    public void ClickedOff(){
        mouseOverUI = false;
    }
    public Vector2 PrimaryPosition(){
        return touchControls.Touch.PrimaryPosition.ReadValue<Vector2>();
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
    void Update()
    {
        PointerEventData pointerEventData = new PointerEventData(EventSystem.current);
        pointerEventData.position = Mouse.current.position.ReadValue();
        List<RaycastResult> raycastResultsList = new List<RaycastResult>();
        EventSystem.current.RaycastAll(pointerEventData, raycastResultsList);
        mouseOverUI = false;
        foreach (RaycastResult raycastResult in raycastResultsList)
        {
            if (raycastResult.gameObject.layer == LayerMask.NameToLayer("UI"))
            {
                mouseOverUI = true;
                break;
            }
        }
    }
}