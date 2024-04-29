using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[System.Serializable]
public class MeopleData
{
    private string firstName;
    private string lastName;
    private int gender;
    private int age;
    private int skinColor;
    private int[] hairData;
    private int[] topData;
    private int[] botData;
    private int[] shoeData;
    private float[] personalityData;
    private float weight;
    private string[] relationshipData;
    public MeopleData(Meople m){
        firstName = m.GetFirstName();
        lastName = m.GetLastName();
        gender = m.GetGender();
        age = m.GetAge();
        skinColor = m.GetSkinColor();
        hairData = m.GetHair();
        topData = m.GetTop();
        botData = m.GetBot();
        shoeData = m.GetShoe();
        weight = m.GetWeight();
        personalityData = m.GetPersonality();
        relationshipData = m.GetRelationshipStatuses();
    }
    public string GetFirstName(){
        return firstName;
    }
    public string GetLastName(){
        return lastName;
    }
    public int GetGender(){
        return gender;
    }
    public int GetAge(){
        return age;
    }
    public int GetSkinColor(){
        return skinColor;
    }
    public int[] GetHair(){
        return hairData;
    }
    public int[] GetTop(){
        return topData;
    }
    public int[] GetBot(){
        return botData;
    }
    public int[] GetShoe(){
        return shoeData;
    }
    public float GetWeight(){
        return weight;
    }
    public float[] GetPersonality(){
        return personalityData;
    }
    public string[] GetRelationshipStatuses(){
        return relationshipData;
    }
}
