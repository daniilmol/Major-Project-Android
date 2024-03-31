using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bed : Furniture
{
    [SerializeField] string[] interactionNames;
    [SerializeField] int[] needIndices;
    [SerializeField] int[] minAge;
    [SerializeField] int[] maxAge;
    [SerializeField] bool[] availableSlots;
    Dictionary<string, int> dictInteractions;
    void Awake(){
        dictInteractions = new Dictionary<string, int>();
        for(int i = 0; i < needIndices.Length; i++){
            dictInteractions.Add(interactionNames[i], needIndices[i]);
        }
        SetData(dictInteractions, minAge, maxAge);
        InteractionZone zone = transform.GetChild(0).GetComponent<InteractionZone>();
        zone.SetMaxOccupancy(1);
        InteractionZone zone2 = transform.GetChild(1).GetComponent<InteractionZone>();
        zone2.SetMaxOccupancy(1);
    }
    public override void Interact(int index, Meople meople){
        switch(index){
            case 0:
            Sleep(0, meople);
            break;
            case 1:
            Nap(0, meople);
            break;
            case 2:
            LieDown(0, meople);
            break;
            case 3:
            YeeHaw(2, meople);
            break;
            case 4:
            TryForBaby(2, meople);
            break;
        }
    }
    public void Sleep(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void Nap(int index, Meople meople){
        int minimumNapTime = 30;
        int maximumNapTime = 60;
        int napTime = Random.Range(minimumNapTime, maximumNapTime);
        StartCoroutine(ReplenishNeeds(meople, index, napTime));
    }
    public void LieDown(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void YeeHaw(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, 20));
    }
    public void TryForBaby(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, 20));
    }
}
