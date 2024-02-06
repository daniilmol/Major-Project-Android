using System.Collections;
using System.Collections.Generic;
using UnityEditor.Advertisements;
using UnityEngine;

public class Interaction 
{
    private Advertisement advertisement;
    private string interactionName;
    private int minAge;
    private int maxAge;
    public Interaction(string interactionName, int needIndex, int minAge, int maxAge){
        if(needIndex == -1){
            advertisement = null;
        }else{
            advertisement = new Advertisement(needIndex);
        }
        this.minAge = minAge;
        this.maxAge = maxAge;
        this.interactionName = interactionName;
    }
    public string GetName(){
        return interactionName;
    }
}
