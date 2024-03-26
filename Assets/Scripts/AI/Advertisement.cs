using System.Collections;
using UnityEngine;

public class Advertisement
{
    private int needIndex;
    private Interaction interaction;

    public void SetInteraction(Interaction interaction){
        this.interaction = interaction;
    }
    public Interaction GetInteraction(){
        return interaction;
    }
    public int GetNeedIndex(){
        return needIndex;
    }
    public void SetIndex(int needIndex){
        this.needIndex = needIndex;
    }
}
