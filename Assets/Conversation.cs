using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Conversation
{
    private Relationship pairRelationship;
    private int minimumConversationTime;
    private int maximumConversationTime;
    private int conversationTime;
    private int pleasantness;
    public Conversation(Relationship pairRelationship){
        this.pairRelationship = pairRelationship;
        conversationTime = Random.Range(minimumConversationTime, maximumConversationTime);
        InitializePleasantness();
    }
    public int GetConversationTime(){
        return conversationTime;
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
