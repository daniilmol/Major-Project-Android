using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Analytics;
using UnityEngine.InputSystem.Interactions;

public class Interaction
{
    private Advertisement advertisement;
    private Advertiser advertiser;
    private string interactionName;
    private int minAge;
    private int maxAge;
    private GameObject interactableObject;
    private int index;
    private int needIndex;
    public Interaction(string interactionName, int needIndex, int minAge, int maxAge, int index, GameObject interactableObject){
        if(needIndex == -1 || needIndex == 7){
            advertisement = null;
        }else{
            if(needIndex == 5 && interactionName != "Start Conversation"){
                advertisement = null;
                return;
            }
            advertisement = new Advertisement();
            advertisement.SetIndex(needIndex);
            advertisement.SetInteraction(this);
            this.interactableObject = interactableObject;
            advertiser = GameObject.Find("Advertiser").GetComponent<Advertiser>();
            advertiser.AddAd(advertisement);
        }
        this.needIndex = needIndex;
        this.minAge = minAge;
        this.maxAge = maxAge;
        this.interactionName = interactionName;
        this.index = index;
    }
    public GameObject GetInteractableObject(){
        return interactableObject;
    }
    public string GetName(){
        return interactionName;
    }
    public Advertisement GetAdvertisement(){
        return advertisement;
    }
    public bool IsAdvertisement(){
        return advertisement != null;
    }
    public int GetIndex(){
        return index;
    }
    public int GetNeedIndex(){
        return needIndex;
    }
}
