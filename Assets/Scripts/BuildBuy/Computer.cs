using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Computer : Furniture
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
    public void PlayGames(int index, Meople meople){
        int minimumPlayTime = 30;
        int maximumPlayTime = 60;
        int playTime = Random.Range(minimumPlayTime, maximumPlayTime);
        StartCoroutine(ReplenishNeeds(meople, index, playTime));
    }
    
    public override void Interact(int index, Meople meople){
        switch(index){
            case 0:
            PlayGames(2, meople);
            break;
        }
    }
}
