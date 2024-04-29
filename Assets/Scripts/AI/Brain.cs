 using System.Collections;
using System.Collections.Generic;
using System.Net.Http.Headers;
using System.Security.Cryptography.X509Certificates;
using Unity.VisualScripting;
using Unity.VisualScripting.Antlr3.Runtime;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Analytics;
using UnityEngine.InputSystem.Interactions;
using UnityEngine.Timeline;

public class Brain
{
    private bool isBusy = false;
    private bool requiresPrivacy = false;
    private bool changeMind = false;
    private Meople meople;
    
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
                if(zone.GetComponent<InteractionZone>() != null && zone.GetComponent<InteractionZone>().IsFull()){
                    fullCounter[i] = 1;
                    full++;
                }
                i++;
            }
            if(full >= childCount){
                available = false;
            }
            if(needs[ad.GetNeedIndex()].GetScore() > highestScore && available){
                if(ad.GetNeedIndex() == 5 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetBrain() == this){
                    continue;
                }
                if(ad.GetNeedIndex() == 5){
                    int replenishingNeedOfMeopleToTalkTo = ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().FindRepleneshingNeed();
                    if(replenishingNeedOfMeopleToTalkTo != 2 && replenishingNeedOfMeopleToTalkTo != -1){
                        continue;
                    }
                    if(replenishingNeedOfMeopleToTalkTo == 2 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetNumberOfActions() < 2){
                        continue;
                    }else if(replenishingNeedOfMeopleToTalkTo == -1 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetNumberOfActions() > 0){
                        continue;
                    }
                }
                highestScore = needs[ad.GetNeedIndex()].GetScore();
                interactionIndex = ad.GetInteraction().GetIndex();
                furniture = ad.GetInteraction().GetInteractableObject().GetComponent<Furniture>();
                tieAds.Clear();
                tieAds.Add(ad);
            }else if(needs[ad.GetNeedIndex()].GetScore() == highestScore && available){
                if(ad.GetNeedIndex() == 5 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetBrain() == this){
                    continue;
                }
                if(ad.GetNeedIndex() == 5){
                    int replenishingNeedOfMeopleToTalkTo = ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().FindRepleneshingNeed();
                    if(replenishingNeedOfMeopleToTalkTo != 2 && replenishingNeedOfMeopleToTalkTo != -1){
                        continue;
                    }
                    if(replenishingNeedOfMeopleToTalkTo == 2 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetNumberOfActions() < 2){
                        continue;
                    }else if(replenishingNeedOfMeopleToTalkTo == -1 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetNumberOfActions() > 0){
                        continue;
                    }
                }
                tieAds.Add(ad);
            }
        }
        if(tieAds.Count > 1){
            Advertisement ad;
            float e = meople.GetPersonality()[3];
            float socialChance = Random.Range(0, 101);
            int index = -1;
            if(e < 0.5f){
                if(socialChance > 30){
                    for(int i = 0; i < tieAds.Count; i++){
                        Advertisement adX = (Advertisement)tieAds[i];
                        if(adX.GetNeedIndex() != 2){
                            continue;
                        }else{
                            index = i;
                            break;
                        }
                    }
                    if(index == -1){
                        index = Random.Range(0, tieAds.Count);
                    }
                }else{
                    for(int i = 0; i < tieAds.Count; i++){
                        Advertisement adX = (Advertisement)tieAds[i];
                        if(adX.GetNeedIndex() != 5){
                            continue;
                        }else{
                            index = i;
                            break;
                        }
                    }
                    if(index == -1){
                        index = Random.Range(0, tieAds.Count);
                    }
                }
            }else{
                index = Random.Range(0, tieAds.Count);
            }
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
            if(ad != null && ad.GetNeedIndex() == 5 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetActions().Count < 1 && meople.GetActions().Count < 1){
                Debug.Log(meople.GetFirstName() + " Initiated conversation with " + ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetFirstName());
                MeopleAction returnConvo = new MeopleAction(meople.GetComponent<Furniture>(), 0);
                ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().Enqueue(returnConvo);
                ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetBrain().ChangeMind(true);
            }else if(action.GetFurniture().GetInteractions()[interactionIndex].GetNeedIndex() == 5 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetActions().Count > 0){
                return null;
            }
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
        if(action.GetFurniture().GetInteractions()[interactionIndex].GetNeedIndex() == 5 && 
        furniture.GetComponent<Meople>().GetActions().Count < 1 && meople.GetActions().Count < 1){
            MeopleAction returnConvo = new MeopleAction(meople.GetComponent<Furniture>(), 0);
            furniture.GetComponent<Meople>().Enqueue(returnConvo);
            furniture.GetComponent<Meople>().GetBrain().ChangeMind(true);
        }else if(action.GetFurniture().GetInteractions()[interactionIndex].GetNeedIndex() == 5 && 
        furniture.GetComponent<Meople>().GetActions().Count > 0){
            return null;
        }
        return action;
    }

    public void ChangeMind(bool changeMind){
        this.changeMind = changeMind;
    }

    public bool MindChanged(){
        return changeMind;
    }
    
    public void SetMeople(Meople meople){
        this.meople = meople;
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
