using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Relationship
{
    public enum ValueStatus{
        Enemy,
        Disliked,
        Acquaintance,
        Friend,
        CloseFriend,
        BestFriend,
        RomancePartner
    }
    public enum RelationshipStatus{
        Father,
        Mother,
        Son,
        Daughter,
        Brother,
        Sister,
        Fiance,
        Girlfriend,
        Boyfriend,
        Husband,
        Wife
    }
    private float value;
    private float romanceValue;
    private ValueStatus valueStatus;
    private RelationshipStatus relationshipStatus;
    private Meople meople;

    public void AffectRelationship(float value){
        this.value += value;
        if(value < -50){
            valueStatus = ValueStatus.Enemy;
        }else if(value < -20){
            valueStatus = ValueStatus.Disliked;
        }else if(romanceValue > 30){
            valueStatus = ValueStatus.RomancePartner;
        }else if(value > -20 && value < 25){
            valueStatus = ValueStatus.Acquaintance;
        }else if(value < 45){
            valueStatus = ValueStatus.Friend;
        }else if(value < 80){
            valueStatus = ValueStatus.CloseFriend;
        }else if(value < 100){
            valueStatus = ValueStatus.BestFriend;
        }
    }
    public float GetValue(){
        return value;
    }
    public float GetRomanceValue(){
        return romanceValue;
    }
    public ValueStatus GetValueStatus(){
        return valueStatus;
    }
    public RelationshipStatus GetRelationshipStatus(){
        return relationshipStatus;
    }
    public Meople GetMeople(){
        return meople;
    }
}
