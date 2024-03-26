using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem.UI;
using UnityEngine.EventSystems;
using Unity.VisualScripting.ReorderableList;

public class ObjectSelection : MonoBehaviour
{
    private InputManager inputManager;
    private Camera mainCamera;
    private bool interactionMenuOpen;
    private GameObject interactionMenu;
    private bool clicking = false;
    private InteractionPanelCreator interactionPanelCreator;
    private InputSystemUIInputModule inputModule;

    private Vector2 touchStartPosition;

    private void Awake()
    {
        inputManager = InputManager.Instance;
        mainCamera = Camera.main;
        interactionMenuOpen = false; 
        interactionMenu = GameObject.Find("InteractionMenu");
        interactionMenu.SetActive(false);
        interactionPanelCreator = GameObject.Find("InteractionPanelCreator").GetComponent<InteractionPanelCreator>();
        inputModule = FindObjectOfType<InputSystemUIInputModule>();
    }

    private void OnEnable()
    {
        inputManager.OnStartTouch += OnTouchStart;
        inputManager.OnEndTouch += OnTouchEnd;
    }

    private void OnDisable()
    {
        inputManager.OnStartTouch -= OnTouchStart;
        inputManager.OnEndTouch -= OnTouchEnd;
    }

    private void OpenInteractionMenu(Furniture furniture, bool floor)
    {
        if(!floor){
            List<Interaction> interactions = furniture.GetInteractions();
            interactionMenu.SetActive(true);
            interactionPanelCreator.CreateButtons(interactions, furniture);
        }else if(floor){
            interactionMenu.SetActive(true);
            Interaction interaction = new Interaction("Go Here", -1, 0, 4, 0, null);
            List<Interaction> interactions = new List<Interaction>();
            interactions.Add(interaction);
            interactionPanelCreator.CreateButtons(interactions, null);
        }
    }

    private void CloseInteractionMenu()
    {
        interactionMenu.SetActive(false);
        inputManager.ClickedOff();
    }

    private void OnTouchStart(Vector2 screenPosition, float time)
    {
        touchStartPosition = screenPosition;
    }

    private void OnTouchEnd(Vector2 screenPosition, float time)
    {
        if(!interactionPanelCreator.Deselecting()){
            RaycastHit hit;
            Ray selectionRay = mainCamera.ScreenPointToRay(screenPosition);
            int layerMask = 1 << LayerMask.NameToLayer("Interaction Zone");
            layerMask = ~layerMask; 
            if (Physics.Raycast(selectionRay, out hit, Mathf.Infinity, layerMask))
            {
                GameObject selectedObject = hit.transform.gameObject;
                if (selectedObject.GetComponent<Furniture>() != null)
                {
                    OpenInteractionMenu(selectedObject.GetComponent<Furniture>(), false);
                }
                if(LayerMask.LayerToName(selectedObject.layer) == "Floor"){
                    OpenInteractionMenu(null, true);
                }
            }
        }
    }
}