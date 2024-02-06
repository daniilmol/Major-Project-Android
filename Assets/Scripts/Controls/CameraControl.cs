using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    private InputManager inputManager;
    private Camera mainCamera;
    private Vector2 startPosition;
    private Vector3 camStartPos;
    private float startTime;
    private float speed = 0.01f;
    // private float minimumDistance = 0.2f;
    // private float directionThreshold = 0.9f;
    private bool moving;

    private void Awake(){
        inputManager = InputManager.Instance;
        mainCamera = Camera.main;
    }
    
    private void OnEnable(){
        inputManager.OnStartSwipe += SwipeStart;
        inputManager.OnEndSwipe += SwipeEnd;
    }
    
    private void OnDisable(){
        inputManager.OnStartSwipe -= SwipeStart;
        inputManager.OnEndSwipe -= SwipeEnd;
    }
    
    private void SwipeStart(Vector2 position, float time){
        camStartPos = mainCamera.transform.position;
        startPosition = position;
        startTime = time;
        moving = true;
    }

    private void SwipeEnd(Vector2 position, float time){
        moving = false;
    }

    void Update(){
        if (!moving) return;
        Vector2 pos = inputManager.PrimaryPosition();
        Vector2 diff = pos - startPosition;
        Vector3 moveVector = new Vector3(diff.x, 0, diff.y) * speed;
        mainCamera.transform.position = camStartPos - moveVector;
    }

    public static Vector3 ScreenToWorld(Camera camera, Vector3 position){
        position.z = camera.nearClipPlane;
        return camera.ScreenToWorldPoint(position);
    }
}