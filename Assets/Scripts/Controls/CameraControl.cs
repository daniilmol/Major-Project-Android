using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    private InputManager inputManager;
    private Camera mainCamera;
    private Vector2 startPosition;
    private float startTime;
    private Vector2 endPosition;
    private float endTime;
    private float minimumDistance = 0.2f;
    private float directionThreshold = 0.9f;

    private Vector3 newPos;
    private Coroutine coroutine;

    private void Awake(){
        inputManager = InputManager.Instance;
        mainCamera = Camera.main;
        newPos = mainCamera.transform.position;
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
        startPosition = position;
        //newPos = new Vector3(inputManager.PrimaryPosition().x, mainCamera.transform.position.y, mainCamera.transform.position.z + inputManager.PrimaryPosition().y);
        mainCamera.transform.position = newPos;
        coroutine = StartCoroutine(Pan());
    }
    private void SwipeEnd(Vector2 position, float time){
        endPosition = position;
        StopCoroutine(coroutine);
        DetectSwipe();
    }
    private void DetectSwipe(){
        if(Vector3.Distance(startPosition, endPosition) >= minimumDistance){
            Debug.Log("SWIPE HAS BEEN DETECTED");
            Vector3 direction = endPosition - startPosition;
            Vector2 direction2D = new Vector2(direction.x, direction.y).normalized;
            //SwipeDirection(direction2D);
        }
    }
    /**private void SwipeDirection(Vector2 direction){
        if(Vector2.Dot(Vector2.up, direction) > directionThreshold){
            Debug.Log("Swipe Up");
        }else if(Vector2.Dot(Vector2.down, direction) > directionThreshold){
            Debug.Log("Swipe Down");
        }else if(Vector2.Dot(Vector2.left, direction) > directionThreshold){
            Debug.Log("Swipe Left");
        }else if(Vector2.Dot(Vector2.right, direction) > directionThreshold){
            Debug.Log("Swipe Right");
        }
    }*/
    private IEnumerator Pan(){
        while(true){
            endPosition = new Vector2(inputManager.PrimaryPosition().x, inputManager.PrimaryPosition().y);
            Vector3 direction = endPosition - startPosition;
            Vector3 direction2D = new Vector3(direction.x, direction.z).normalized;
            Vector3 targetPos = mainCamera.transform.position + direction2D;
            mainCamera.transform.position = targetPos;
            yield return null;
        }
    }
}
