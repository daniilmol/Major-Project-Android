using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fridge : Furniture
{
    [SerializeField] string[] interactionNames;
    [SerializeField] int[] needIndices;
    [SerializeField] int[] minAge;
    [SerializeField] int[] maxAge;
    [SerializeField] int maxStorage;
    [SerializeField] int coolDuration;
    private Food[] foods;
    Dictionary<string, int> dictInteractions;
    void Awake(){
        dictInteractions = new Dictionary<string, int>();
        for(int i = 0; i < needIndices.Length; i++){
            dictInteractions.Add(interactionNames[i], needIndices[i]);
        }
        foods = new Food[maxStorage];
        SetData(dictInteractions, minAge, maxAge);
        InteractionZone zone = transform.GetChild(0).GetComponent<InteractionZone>();
        zone.SetMaxOccupancy(1);
    }
    public override void Interact(int index, Meople meople){
        switch(index){
            case 0:
            HaveSnack(1, meople);
            break;
            case 1:
            HaveBreakfast(1, meople);
            break;
            case 2:
            HaveLunch(1, meople);
            break;
            case 3:
            HaveDinner(1, meople);
            break;
            case 4:
            StoreRefrigeratableItems(index, meople);
            break;
            case 5:
            ThrowSpoiledFood(index, meople);
            break;
            case 6:
            View(index, meople);
            break;
        }
    }
    public void HaveSnack(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, 10));
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
    public void StoreRefrigeratableItems(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void ThrowSpoiledFood(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
    public void View(int index, Meople meople){
        StartCoroutine(ReplenishNeeds(meople, index, -1));
    }
}
