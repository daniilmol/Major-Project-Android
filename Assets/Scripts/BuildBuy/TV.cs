using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TV : Furniture
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
        zone.SetMaxOccupancy(8);
    }
    public void WatchTV(int index, Meople meople){
        int minimumWatchTime = 30;
        int maximumWatchTime = 60;
        int watchTime = Random.Range(minimumWatchTime, maximumWatchTime);
        InteractionZone zone = transform.GetChild(0).GetComponent<InteractionZone>();
        StartCoroutine(ReplenishNeeds(meople, index, watchTime));
    }
    
    public override void Interact(int index, Meople meople){
        switch(index){
            case 0:
            WatchTV(2, meople);
            break;
        }
    }
}
