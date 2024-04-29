using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Furniture : MonoBehaviour
{
    [SerializeField] int price;
    [SerializeField] int quality;
    [SerializeField] bool isSurface;
    [SerializeField] bool canGetDirty;
    [SerializeField] bool upgradeable;
    [SerializeField] bool canBreak;
    [SerializeField] float decoFactor;
    private bool isDirty;
    private int socialInteraction;
    protected int maxUseForDirty;
    protected int used;
    private List<Interaction> interactions = new List<Interaction>();
    private GameObject[] interactionZones;
    private float boredScore;
    void Start(){
        maxUseForDirty = 5;
        boredScore = 0;
        interactionZones = new GameObject[transform.childCount];
        SetAllZones();
    }
    void Update(){
        // if(GetComponent<Meople>() != null){
        //     Conversation[] conversations = GameObject.FindObjectsOfType<Conversation>();
        //     int[] indicies = new int[conversations.Length];
        //     for(int i = 0; i < indicies.Length; i++){
        //         indicies[i] = -1;
        //     }
        //     for(int i = 0; i < conversations.Length; i++){
        //         print(Int32.Parse(conversations[i].gameObject.name)); 
        //         if(Int32.Parse(conversations[i].gameObject.name) < indicies.Length && ++indicies[Int32.Parse(conversations[i].gameObject.name)] > 1){
        //             Destroy(conversations[i]);
        //         }
        //     }
        // }
        if(boredScore != 0){
            boredScore -= Time.deltaTime;
            if(boredScore < 0){
                boredScore = 0;
            }
        }
    }
    private void SetAllZones(){
        int i = 0;
        foreach(Transform child in transform){
            interactionZones[i++] = child.gameObject;
        }
    }
    public List<Interaction> GetInteractions(){
        return interactions;
    }
    public float GetBoredScore(){
        return boredScore;
    }
    public bool IsFull(){
        for(int i = 0; i < interactionZones.Length; i++){
            if(!interactionZones[i].GetComponent<InteractionZone>().IsFull()){
                return false;
            }
        }
        return true;
    }
    public virtual void Interact(int index, Meople meople){

    }

    public virtual void DiminishReturn(){

    }

    protected void SetData(Dictionary<string, int> interactions, int[] minAge, int[] maxAge){
        int i = 0;
        foreach(KeyValuePair<string, int> entry in interactions){
            this.interactions.Add(new Interaction(entry.Key, entry.Value, minAge[i], maxAge[i], i++, gameObject));
        }
    }
    protected bool IsSurface(){
        return isSurface;
    }
    protected bool CanGetDirty(){
        return canGetDirty;
    }
    protected bool Upgradeable(){
        return upgradeable;
    }
    protected float GetDecoFactor(){
        return decoFactor;
    }
    protected float GetPrice(){
        return price;
    }
    private bool coroRunning = false;
    public bool CoroRunning(){
        return coroRunning;
    }
    public void NotRunning(){
        coroRunning = false;
    }
    protected void ChangeSocialInteraction(int index){

    }
    protected IEnumerator ReplenishSocialNeeds(Meople meople, int needIndex){
        int time = 0;
        int maxInteractionTime = 10;
        int interactionTimer = 0;
        coroRunning = true;
        bool breaking = false;
        Conversation conversation;
        if(needIndex == 5){
            Meople interactedMeople = GetComponent<Meople>();
            List<Relationship> relationships = meople.GetRelationships();
            List<Relationship> relationshipsOfTarget = interactedMeople.GetRelationships();
            Relationship relationship = null;
            Relationship targetRelationship = null;
            for(int i = 0; i < relationships.Count; i++){
                if(relationships[i].GetMeople() == interactedMeople){
                    relationship = relationships[i];
                }
            }
            for(int i = 0; i < relationshipsOfTarget.Count; i++){
                if(relationshipsOfTarget[i].GetMeople() == meople){
                    targetRelationship = relationshipsOfTarget[i];
                }
            }
            Conversation conversationObject;
            if(relationship == null){
                Relationship noLongerStrangers = new Relationship(0, 0, Relationship.ValueStatus.Acquaintance, Relationship.RelationshipStatus.Stranger, interactedMeople);
                Relationship noLongerStrangers2 = new Relationship(0, 0, Relationship.ValueStatus.Acquaintance, Relationship.RelationshipStatus.Stranger, meople);
                meople.AddRelationship(noLongerStrangers);
                interactedMeople.AddRelationship(noLongerStrangers2);
                Conversation[] conversations = GameObject.FindObjectsOfType<Conversation>();
                if(meople.GetConversationIndex() == -1){
                    meople.SetConversationIndex(conversations.Length);
                    print("CONVO INDEX: " + meople.GetConversationIndex());
                }
                if(interactedMeople.GetConversationIndex() == -1){
                    interactedMeople.SetConversationIndex(conversations.Length);
                    print("CONVO INDEX: " + interactedMeople.GetConversationIndex());
                }
                int lastChance = conversations.Length;
                if(conversations.Length > 0 && Int32.Parse(conversations[conversations.Length - 1].name) == meople.GetConversationIndex() && conversations[conversations.Length - 1].GetIndex() == meople.GetConversationIndex()){
                    print(Int32.Parse(conversations[conversations.Length - 1].name) + " " + meople.GetConversationIndex() + " " + conversations[conversations.Length - 1].GetIndex() +" " + meople.GetConversationIndex());
                    conversationObject = conversations[conversations.Length - 1];
                    meople.SetConversationIndex(conversations.Length - 1);
                    interactedMeople.SetConversationIndex(conversations.Length - 1);
                }else{
                    if(conversations.Length > 0)
                        print(Int32.Parse(conversations[conversations.Length - 1].name) + " " + meople.GetConversationIndex() + " " + conversations[conversations.Length - 1].GetIndex() +" " + meople.GetConversationIndex());
                    conversationObject = Instantiate(meople.GetConversation());
                    conversationObject.SetIndex(meople.GetConversationIndex());
                    conversationObject.name = "" + meople.GetConversationIndex();
                    conversationObject.SetRelationships(noLongerStrangers, noLongerStrangers2, 30, 60);
                    conversations = GameObject.FindObjectsOfType<Conversation>();
                    int[] indicies = new int[conversations.Length];
                    for(int i = 0; i < indicies.Length; i++){
                        indicies[i] = 0;
                    }
                    for(int i = 0; i < conversations.Length; i++){
                        if(Int32.Parse(conversations[i].gameObject.name) < indicies.Length && ++indicies[Int32.Parse(conversations[i].gameObject.name)] > 1){
                            Destroy(conversations[i].gameObject);
                            conversationObject = conversations[conversations.Length - 1];
                            meople.SetConversationIndex(conversations.Length - 1);
                            interactedMeople.SetConversationIndex(conversations.Length - 1);
                        }
                    }
                }
            }else{
                Conversation[] conversations = GameObject.FindObjectsOfType<Conversation>();
                if(meople.GetConversationIndex() == -1){
                    meople.SetConversationIndex(conversations.Length);
                }
                if(interactedMeople.GetConversationIndex() == -1){
                    interactedMeople.SetConversationIndex(conversations.Length);
                }
                if(conversations.Length > 0 && Int32.Parse(conversations[conversations.Length - 1].name) == meople.GetConversationIndex() && conversations[conversations.Length - 1].GetIndex() == meople.GetConversationIndex()){
                    print(Int32.Parse(conversations[conversations.Length - 1].name) + " " + meople.GetConversationIndex() + " " + conversations[conversations.Length - 1].GetIndex() +" " + meople.GetConversationIndex());
                    conversationObject = conversations[conversations.Length - 1];
                    meople.SetConversationIndex(conversations.Length - 1);
                    interactedMeople.SetConversationIndex(conversations.Length - 1);
                }else{
                    if(conversations.Length > 0)
                        print(Int32.Parse(conversations[conversations.Length - 1].name) + " " + meople.GetConversationIndex() + " " + conversations[conversations.Length - 1].GetIndex() +" " + meople.GetConversationIndex());
                    conversationObject = Instantiate(meople.GetConversation());
                    conversationObject.SetIndex(meople.GetConversationIndex());
                    conversationObject.name = "" + meople.GetConversationIndex();
                    conversationObject.SetRelationships(relationship, targetRelationship, 30, 60);
                    conversations = GameObject.FindObjectsOfType<Conversation>();
                    int[] indicies = new int[conversations.Length];
                    for(int i = 0; i < indicies.Length; i++){
                        indicies[i] = 0;
                    }
                    for(int i = 0; i < conversations.Length; i++){
                        if(Int32.Parse(conversations[i].gameObject.name) < indicies.Length && ++indicies[Int32.Parse(conversations[i].gameObject.name)] > 1){
                            Destroy(conversations[i].gameObject);
                            conversationObject = conversations[conversations.Length - 1];
                            meople.SetConversationIndex(conversations.Length - 1);
                            interactedMeople.SetConversationIndex(conversations.Length - 1);
                        }
                    }
                }
            }
            conversationObject.SetAntiRaceConditionMeople(meople);
            while(time < conversationObject.GetConversationTime()){
                Conversation[] c = GameObject.FindObjectsOfType<Conversation>();
                for(int i = 0; i < c.Length; i++){
                    c[i].SetIndex(i);
                    c[i].name = ""+i;
                    Relationship[] both = c[i].GetTwoParties();
                    for(int j = 0; j < both.Length; j++){
                        both[j].GetMeople().SetConversationIndex(i);
                    }
                }
                if(interactionTimer > maxInteractionTime){
                    interactionTimer = 0;
                    conversationObject.SelectInteraction(meople);
                }
                meople.GetActualNeeds()[needIndex].Replenish();
                yield return new WaitForSeconds(1);
                time++;
                interactionTimer++;
            }
            interactedMeople.Talking(false);
            meople.Talking(false);
            meople.Dequeue();
            interactedMeople.Dequeue();
        }
        // if(!breaking){
        //     meople.Privacy(false);
        //     meople.Busy(false);
        //     meople.GetActualNeeds()[needIndex].StopRepleneshing();
        //     meople.ResetDestination();
        // }
        // meople.Dequeue();
    }
    protected IEnumerator ReplenishNeeds(Meople meople, int needIndex, int interactionTime){
        int time = 0;
        coroRunning = true;
        bool breaking = false;
        if(interactionTime == -1){
            while(meople.GetNeeds()[needIndex] < 100){
                if(!meople.IsBusy()){
                    breaking = true;
                    break;
                }
                meople.GetActualNeeds()[needIndex].Replenish();
                yield return null;
            }
        }else{
            while(time < interactionTime){
                if(meople.GetNeeds()[needIndex] > 99 && needIndex != 2 && needIndex != 5){
                    if(!meople.IsBusy()){
                        breaking = true;
                        break;
                    }
                    break;
                }
                meople.GetActualNeeds()[needIndex].Replenish();
                yield return new WaitForSeconds(1);
                time++;
            }
        }
        if(!breaking){
            meople.Privacy(false);
            meople.Busy(false);
            meople.GetActualNeeds()[needIndex].StopRepleneshing();
            meople.ResetDestination();
        }
        meople.Dequeue();
    }
    public void Clean(int index, Meople meople){

    }
    public void Upgrade(int index, Meople meople){

    }
    public void Repair(int index, Meople meople){
        
    }
}
