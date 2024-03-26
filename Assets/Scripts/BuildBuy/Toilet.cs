using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Toilet : Furniture
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
            Use(3, meople);
            break;
        }
    }

    private void Use(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
}
