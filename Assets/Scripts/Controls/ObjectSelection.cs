using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSelection : MonoBehaviour
{
    private InputManager inputManager;
    private Camera mainCamera;
    private void Awake(){
        inputManager = InputManager.Instance;
        mainCamera = Camera.main;
    }
    private void OnEnable(){
        inputManager.OnStartTouch += Move;
    }
    private void OnDisable(){
        inputManager.OnStartTouch -= Move;
    }
    public void Move(Vector3 screenPosition, float time){
        Destroy(this);
        RaycastHit hit;
        Ray selectionRay = mainCamera.ScreenPointToRay(screenPosition);
        if(Physics.Raycast(selectionRay, out hit)){
            GameObject selectedObject = hit.transform.gameObject;
            print(selectedObject.name);
        }
    }
}
