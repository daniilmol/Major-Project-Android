using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Conversation : MonoBehaviour
{
    private Relationship pairRelationship;
    private Relationship pairRelationship2;
    private int minimumConversationTime;
    private int maximumConversationTime;
    private int conversationTime;
    private int pleasantness;
    public Conversation(Relationship pairRelationship, Relationship pairRelationShip2, int minimumConversationTime, int maximumConversationTime){
        this.pairRelationship = pairRelationship;
        this.pairRelationship2 = pairRelationShip2;
        this.minimumConversationTime = minimumConversationTime;
        this.maximumConversationTime = maximumConversationTime;
        conversationTime = Random.Range(minimumConversationTime, maximumConversationTime);
        InitializePleasantness();
    }
    public void SetRelationships(Relationship a, Relationship b, int c, int d){
        pairRelationship = a;
        pairRelationship2 = b;
        conversationTime = Random.Range(c, d);
    }
    public Relationship[] GetTwoParties(){
        Relationship[] twoParties = {pairRelationship, pairRelationship2};
        return twoParties;
    }
    public int GetConversationTime(){
        return conversationTime;
    }
    public void SelectInteraction(){

    }
    private void InitializePleasantness(){
        switch(pairRelationship.GetValueStatus()){
            case Relationship.ValueStatus.Enemy:
            pleasantness = -25;
            break;
            case Relationship.ValueStatus.Disliked:
            pleasantness = -10;
            break;
            case Relationship.ValueStatus.Acquaintance:
            pleasantness = 0;
            break;
            case Relationship.ValueStatus.Friend:
            pleasantness = 10;
            break;
            case Relationship.ValueStatus.CloseFriend:
            pleasantness = 25;
            break;
            case Relationship.ValueStatus.BestFriend:
            pleasantness = 40;
            break;
        }
    }
}
