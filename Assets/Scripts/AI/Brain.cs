 using System.Collections;
using System.Collections.Generic;
using System.Net.Http.Headers;
using System.Security.Cryptography.X509Certificates;
using Unity.VisualScripting;
using Unity.VisualScripting.Antlr3.Runtime;
using UnityEngine;
using UnityEngine.InputSystem.Interactions;
using UnityEngine.Timeline;

public class Brain
{
    private bool isBusy = false;
    private bool requiresPrivacy = false;
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
                Debug.Log("BRAIN: " + ad.GetNeedIndex() + ad.GetInteraction().GetName());
                if(ad.GetNeedIndex() == 5 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetBrain() == this){
                    continue;
                }
                if(ad.GetNeedIndex() == 5){
                    Debug.Log("NEED INDEX IS %");
                    int replenishingNeedOfMeopleToTalkTo = ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().FindRepleneshingNeed();
                    if(replenishingNeedOfMeopleToTalkTo != 2 && replenishingNeedOfMeopleToTalkTo != -1){
                        continue;
                    }
                    if(replenishingNeedOfMeopleToTalkTo == 2 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetNumberOfActions() < 2){
                        continue;
                    }else if(replenishingNeedOfMeopleToTalkTo == -1 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetNumberOfActions() > 0){
                        continue;
                    }
                    // Meople a = ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetConversation().GetTwoParties()[0].GetMeople();
                    // Meople b = ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetConversation().GetTwoParties()[1].GetMeople();
                    // if(replenishingNeedOfMeopleToTalkTo == 5 && )
                    MeopleAction returnConvo = new MeopleAction(meople.GetComponent<Furniture>(), 0);
                    ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().Enqueue(returnConvo);
                    Debug.Log("ENQUEUED");
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
                    Debug.Log("NEED INDEX IS %");
                    int replenishingNeedOfMeopleToTalkTo = ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().FindRepleneshingNeed();
                    if(replenishingNeedOfMeopleToTalkTo != 2 && replenishingNeedOfMeopleToTalkTo != -1){
                        continue;
                    }
                    if(replenishingNeedOfMeopleToTalkTo == 2 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetNumberOfActions() < 2){
                        continue;
                    }else if(replenishingNeedOfMeopleToTalkTo == -1 && ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetNumberOfActions() > 0){
                        continue;
                    }
                    // Meople a = ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetConversation().GetTwoParties()[0].GetMeople();
                    // Meople b = ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().GetConversation().GetTwoParties()[1].GetMeople();
                    // if(replenishingNeedOfMeopleToTalkTo == 5 && )
                    // MeopleAction returnConvo = new MeopleAction(meople.GetComponent<Furniture>(), 0);
                    // ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().Enqueue(returnConvo);
                    // Debug.Log("ENQUEUED");
                }
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
            if(ad != null && ad.GetNeedIndex() == 5){
                MeopleAction returnConvo = new MeopleAction(meople.GetComponent<Furniture>(), 0);
                ad.GetInteraction().GetInteractableObject().GetComponent<Meople>().Enqueue(returnConvo);
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
        if(action.GetFurniture().GetInteractions()[interactionIndex].GetNeedIndex() == 5){
            MeopleAction returnConvo = new MeopleAction(meople.GetComponent<Furniture>(), 0);
            furniture.GetComponent<Meople>().Enqueue(returnConvo);
        }
        return action;
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
