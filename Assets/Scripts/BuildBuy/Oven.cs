using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Oven : Furniture
{
    [SerializeField] string[] interactionNames;
    [SerializeField] int[] needIndices;
    [SerializeField] int[] minAge;
    [SerializeField] int[] maxAge;
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
    public override void Interact(int index, Meople meople){
        switch(index){
            case 0:
            HaveBreakfast(1, meople);
            break;
            case 1:
            ServeBreakfast(1, meople);
            break;
            case 2:
            HaveLunch(1, meople);
            break;
            case 3:
            ServeLunch(1, meople);
            break;
            case 4:
            HaveDinner(1, meople);
            break;
            case 5:
            ServeDinner(1, meople);
            break;
            case 6:
            Repair(index, meople);
            break;
            case 7:
            Upgrade(index, meople);
            break;
            case 8:
            Clean(index, meople);
            break;
        }
    }
    public void HaveBreakfast(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void HaveLunch(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void HaveDinner(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void ServeBreakfast(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void ServeLunch(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void ServeDinner(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
}
