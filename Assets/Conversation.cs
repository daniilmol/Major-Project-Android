using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Conversation : MonoBehaviour
{
    private Relationship pairRelationship;
    private Relationship pairRelationship2;
    private bool processingConversation = false;
    private bool requireApology;
    private int apologyBy;
    private int minimumConversationTime;
    private int maximumConversationTime;
    private int conversationTime;
    private int pleasantness;
    private int negativity;
    public Conversation(Relationship pairRelationship, Relationship pairRelationShip2, int minimumConversationTime, int maximumConversationTime){
        this.pairRelationship = pairRelationship;
        this.pairRelationship2 = pairRelationShip2;
        this.minimumConversationTime = minimumConversationTime;
        this.maximumConversationTime = maximumConversationTime;
        conversationTime = Random.Range(minimumConversationTime, maximumConversationTime);
        InitializePleasantness();
    }
    void Start(){

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
        processingConversation = false;
        if(!processingConversation){
            processingConversation = true;
            int typeOfConversation = -1;
            int friendlyScore = Random.Range(-50, 100);
            int meopleInitiator = Random.Range(0, 2);
            friendlyScore += pleasantness;
            string interactionName = "";
            string interactedName = "";
            Relationship.ValueStatus status = pairRelationship.GetValueStatus();
            int[] negativeInteractions = {10, 13, 14, 15, 16};
            if(friendlyScore >= 0 && status == Relationship.ValueStatus.Acquaintance){
                typeOfConversation = Random.Range(0, 6);
            }else if(friendlyScore >= 0 && status == Relationship.ValueStatus.Friend){
                typeOfConversation = Random.Range(0, 7);
            }else if(friendlyScore >= 0 && status == Relationship.ValueStatus.CloseFriend){
                typeOfConversation = Random.Range(0, 8);
            }else if(friendlyScore >= 0 && status == Relationship.ValueStatus.BestFriend){
                typeOfConversation = Random.Range(0, 9);
            }else if(friendlyScore < 0 && status != Relationship.ValueStatus.Enemy){
                typeOfConversation = negativeInteractions[Random.Range(0, negativeInteractions.Length - 2)];
            }else if(friendlyScore < 0 && status == Relationship.ValueStatus.Enemy){
                typeOfConversation = negativeInteractions[Random.Range(0, negativeInteractions.Length)];
            }
            switch(typeOfConversation){
                case 0: //small talk
                pairRelationship.AffectRelationship(1);
                pairRelationship2.AffectRelationship(1);
                interactionName = "Small Talk";
                interactedName = interactionName;
                pleasantness += 2;
                break;
                case 1: //discuss new house
                pairRelationship.AffectRelationship(1);
                pairRelationship2.AffectRelationship(1);
                interactionName = "Discuss New House";
                interactedName = interactionName;
                pleasantness += 5;
                break;
                case 2: //discuss work
                pairRelationship.AffectRelationship(1);
                pairRelationship2.AffectRelationship(1);
                interactionName = "Discuss Work";
                interactedName = interactionName; 
                pleasantness += 5;           
                break;
                case 3: //discuss house members
                pairRelationship.AffectRelationship(1);
                pairRelationship2.AffectRelationship(1);
                interactionName = "Discuss House Members";
                interactedName = interactionName;
                pleasantness += 8;
                break;
                case 4: //tell joke
                pairRelationship.AffectRelationship(1);
                pairRelationship2.AffectRelationship(1);
                interactionName = "Tell Joke";
                interactedName = "Listen To Joke";
                pleasantness += 10;
                break;
                case 5: //tell story
                pairRelationship.AffectRelationship(1);
                pairRelationship2.AffectRelationship(1);
                interactionName = "Tell Story";
                interactedName = "Listen To Story";
                pleasantness += 5;
                break;
                case 6: //friendly hug
                pairRelationship.AffectRelationship(2);
                pairRelationship2.AffectRelationship(2);
                interactionName = "Friendly Hug";
                interactedName = "Be Hugged";
                pleasantness += 10;
                break;
                case 7: //share personal story
                pairRelationship.AffectRelationship(3);
                pairRelationship2.AffectRelationship(3);
                interactionName = "Share Personal Story";
                interactedName = "Listen To Story";
                pleasantness += 13;
                break;
                case 8: //express deep admiration
                pairRelationship.AffectRelationship(4);
                pairRelationship2.AffectRelationship(4);
                interactionName = "Express Admiration";
                interactedName = "Be Complimented";
                pleasantness += 17;
                break;
                case 9: //apologize
                pairRelationship.AffectRelationship(1);
                pairRelationship2.AffectRelationship(1);
                interactionName = "Apologize";
                interactedName = "Be Apologized To";
                pleasantness += 10;
                break;
                case 10: //insult
                pairRelationship.AffectRelationship(-2);
                pairRelationship2.AffectRelationship(-2);
                interactionName = "Insult";
                interactedName = "Be Insulted";
                pleasantness -= 8;
                break;
                case 11: //brag
                pairRelationship.AffectRelationship(0);
                pairRelationship2.AffectRelationship(0);
                interactionName = "Brag";
                interactedName = "Listen To Brag";
                break;
                case 12: //prank
                pairRelationship.AffectRelationship(0);
                pairRelationship2.AffectRelationship(0);
                interactionName = "Prank";
                interactedName = "Be Pranked";
                break;
                case 13: //patronize
                pairRelationship.AffectRelationship(-1);
                pairRelationship2.AffectRelationship(-1);
                interactionName = "Patronize";
                interactedName = "Be Patronized";
                pleasantness -= 2;
                break;
                case 14: //lie
                pairRelationship.AffectRelationship(-2);
                pairRelationship2.AffectRelationship(-2);
                interactionName = "Lie";
                interactedName = "Be Lied To";
                pleasantness -= 2;
                break;
                case 15: //yell at
                pairRelationship.AffectRelationship(-3);
                pairRelationship2.AffectRelationship(-3);
                interactionName = "Yell At";
                pleasantness -= 10;
                break;
                case 16: //fight
                pairRelationship.AffectRelationship(-5);
                pairRelationship2.AffectRelationship(-5);
                interactionName = "Fight";
                interactedName = interactionName;
                pleasantness -= 20;
                break;
            }
            if(meopleInitiator == 0){
                GameMaster.RenameConversation(pairRelationship.GetMeople(), pairRelationship2.GetMeople(), interactionName, interactedName);
            }else if(meopleInitiator == 1){
                GameMaster.RenameConversation(pairRelationship2.GetMeople(), pairRelationship.GetMeople(), interactionName, interactedName);
            }
                print("Relationship pleasantness " + pairRelationship.GetMeople().GetFirstName() + " and " + pairRelationship2.GetMeople().GetFirstName() + " is " + pleasantness);
                print("Relationship value " + pairRelationship.GetMeople().GetFirstName() + " and " + pairRelationship2.GetMeople().GetFirstName() + " is " + pairRelationship.GetValue());
        }
        processingConversation = false;
    }
    private void AffectPleasantness(int value){
        pleasantness += value;
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
