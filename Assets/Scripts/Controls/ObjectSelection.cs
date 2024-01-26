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
        inputManager.OnEndTouch -= Move;
    }
    public void Move(Vector2 screenPosition, float time){
        RaycastHit hit;
        Vector3 x = new Vector3(screenPosition.x, screenPosition.y, 20);
        Ray selectionRay = mainCamera.ScreenPointToRay(x);
        //Debug.DrawRay(selectionRay.origin, selectionRay.direction * 20);
        if(Physics.Raycast(selectionRay, out hit)){
            GameObject selectedObject = hit.transform.gameObject;
            if(selectedObject.GetComponent<Interactable>() != null){
                print(selectedObject.name);
            }
        }
    }
}
