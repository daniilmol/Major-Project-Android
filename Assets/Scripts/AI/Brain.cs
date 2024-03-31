 using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem.Interactions;
using UnityEngine.Timeline;

public class Brain
{
    private bool isBusy = false;
    private bool requiresPrivacy = false;
    
    public MeopleAction ProcessAdvertisements(ArrayList advertisements, Need[] needs, bool wokenUp){
        MeopleAction action;
        int interactionIndex = 0;
        Furniture furniture = null;
        isBusy = true;
        int highestScore = -100;
        ArrayList tieAds = new ArrayList();
        foreach(Advertisement ad in advertisements){
            bool available = true;
            int childCount = ad.GetInteraction().GetInteractableObject().transform.childCount;
            int[] fullCounter = new int[childCount];
            int full = 0;
            int i = 0;
            foreach(Transform zone in ad.GetInteraction().GetInteractableObject().transform){
                if(zone.GetComponent<InteractionZone>().IsFull()){
                    fullCounter[i] = 1;
                    full++;
                }
                i++;
            }
            if(full >= childCount){
                available = false;
            }
            if(needs[ad.GetNeedIndex()].GetScore() > highestScore && available){
                highestScore = needs[ad.GetNeedIndex()].GetScore();
                interactionIndex = ad.GetInteraction().GetIndex();
                furniture = ad.GetInteraction().GetInteractableObject().GetComponent<Furniture>();
                tieAds.Clear();
                tieAds.Add(ad);
            }else if(needs[ad.GetNeedIndex()].GetScore() == highestScore && available){
                tieAds.Add(ad);
            }
        }
        if(tieAds.Count > 1){
            Advertisement ad;
            int index = Random.Range(0, tieAds.Count);
            ad = (Advertisement)tieAds[index];
            interactionIndex = ad.GetInteraction().GetIndex();
            furniture = ad.GetInteraction().GetInteractableObject().GetComponent<Furniture>();
            if(furniture is Bed){
                if(TimeManager.currentTime < 300 || TimeManager.currentTime > 1200){
                    interactionIndex = 0;
                }else if(TimeManager.currentTime >= 300 || TimeManager.currentTime <= 1200){
                    interactionIndex = 1;
                }
            }
            action = new MeopleAction(furniture, interactionIndex);
            return action;
        }
        if(furniture is Bed){
            if(TimeManager.currentTime < 300 || TimeManager.currentTime > 1200 || wokenUp){
                interactionIndex = 0;
            }else if(TimeManager.currentTime >= 300 || TimeManager.currentTime <= 1200){
                interactionIndex = 1;
            }
        }
        action = new MeopleAction(furniture, interactionIndex);
        return action;
    }

    public bool IsBusy(){
        return isBusy;
    }

    public void Busy(bool isBusy){
        this.isBusy = isBusy;
    }
    public bool RequiresPrivacy(){
        return requiresPrivacy;
    }
    public void Privacy(bool privacy){
        requiresPrivacy = privacy;
    }
}
