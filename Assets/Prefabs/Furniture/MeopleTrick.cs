using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeopleTrick : Furniture
{
    [SerializeField] string[] interactionNames;
    [SerializeField] int[] needIndices;
    [SerializeField] int[] minAge;
    [SerializeField] int[] maxAge;
    [SerializeField] int[] socialTime;
    Dictionary<string, int> dictInteractions;
    void Awake(){
        dictInteractions = new Dictionary<string, int>();
        for(int i = 0; i < needIndices.Length; i++){
            dictInteractions.Add(interactionNames[i], needIndices[i]);
        }
        SetData(dictInteractions, minAge, maxAge);
        InteractionZone zone = transform.GetChild(0).GetComponent<InteractionZone>();
        zone.SetMaxOccupancy(1);
    }
    public void StartConversation(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void SmallTalk(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void DiscussNewHouse(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void DiscussWork(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void DiscussHouseMembers(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void TellJoke(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void TellStory(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void FriendlyHug(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void SharePersonalStory(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void ExpressDeepAdmiration(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void Apologize(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void Insult(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void Brag(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void Prank(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void Patronize(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void Lie(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void YellAt(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public void Fight(int index, Meople meople){
        StartCoroutine(ReplenishSocialNeeds(meople, index));
    }
    public override void Interact(int index, Meople meople){
        switch(index){
            case 0:
            StartConversation(5, meople);
            break;
            case 1:
            SmallTalk(5, meople);
            break;
            case 2:
            DiscussNewHouse(5, meople);
            break;
            case 3:
            DiscussWork(5, meople);
            break;
            case 4:
            DiscussHouseMembers(5, meople);
            break;
            case 5:
            TellJoke(5, meople);
            break;
            case 6:
            TellStory(5, meople);
            break;
            case 7:
            FriendlyHug(5, meople);
            break;
            case 8:
            SharePersonalStory(5, meople);
            break;
            case 9:
            ExpressDeepAdmiration(5, meople);
            break;
            case 10:
            Apologize(5, meople);
            break;
            case 11:
            Insult(5, meople);
            break;
            case 12:
            Brag(5, meople);
            break;
            case 13:
            Prank(5, meople);
            break;
            case 14:
            Patronize(5, meople);
            break;
            case 15:
            Lie(5, meople);
            break;
            case 16:
            YellAt(5, meople);
            break;
            case 17:
            Fight(5, meople);
            break;
        }
    }
}
