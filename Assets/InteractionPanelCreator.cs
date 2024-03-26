using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Android;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.Events;

public class InteractionPanelCreator : MonoBehaviour
{
    [SerializeField] GameObject button;
    [SerializeField] Image panel;
    private bool deselecting;

     void Start()
    {
        deselecting = false;
        EventTrigger eventTrigger = panel.GetComponent<EventTrigger>();
        if (eventTrigger == null){
            eventTrigger = panel.AddComponent<EventTrigger>();
        }
        EventTrigger.Entry entry = new EventTrigger.Entry();
        entry.eventID = EventTriggerType.PointerDown;
        entry.callback.AddListener((eventData) => { PanelClickHandler(); });
        eventTrigger.triggers.Add(entry);
    }

    void PanelClickHandler()
    {
        foreach(Transform child in panel.transform){
            Destroy(child.gameObject);
        }
        panel.gameObject.SetActive(false);
        StartCoroutine(PreventRayCast());
    }

    public void CreateButtons(List<Interaction> interactions, Furniture furniture){
        int buttonHeight = 50;
        int initHeight = 0;
        float yButton = initHeight + (interactions.Count - 1) * 0.5f * buttonHeight;
        for(int i = 0; i < interactions.Count; i++){
            int index = i;
            float y2Button = yButton - i * buttonHeight;
            GameObject interactionButton = Instantiate(button, panel.transform);
            TextMeshProUGUI buttonText = interactionButton.GetComponentInChildren<TextMeshProUGUI>();
            buttonText.SetText(interactions[i].GetName());
            print(buttonText.text);
            interactionButton.GetComponent<RectTransform>().anchoredPosition = new Vector2(0, y2Button);
            interactionButton.GetComponent<RectTransform>().sizeDelta = new Vector2(250, 50);
            interactionButton.GetComponent<Button>().onClick.AddListener(delegate { Interact(index, furniture); }); 
        }
    }
    public void CloseInteractionMenu(){
        panel.gameObject.SetActive(false);
    }
    IEnumerator PreventRayCast(){
        deselecting = true;
        yield return new WaitForSeconds(0.1f);
        deselecting = false;
    }
    public bool Deselecting(){
        return deselecting;
    }
    public void Interact(int x, Furniture furniture)
    {
        MeopleAction meopleAction = new MeopleAction(furniture, x);
        GameMaster.selectedMeople.Enqueue(meopleAction);
        foreach(Transform child in panel.transform){
            Destroy(child.gameObject);
        }
        panel.gameObject.SetActive(false);
        StartCoroutine(PreventRayCast());
    }
}
