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
    void Start(){
        dictInteractions = new Dictionary<string, int>();
        for(int i = 0; i < needIndices.Length; i++){
            dictInteractions.Add(interactionNames[i], needIndices[i]);
        }
        foods = new Food[maxStorage];
        SetData(dictInteractions, minAge, maxAge);
    }
    public void HaveSnack(){

    }
    public void HaveBreakfast(){

    }
    public void HaveLunch(){

    }
    public void HaveDinner(){

    }
    public void StoreRefrigeratableItems(){

    }
    public void ThrowSpoiledFood(){

    }
    public void View(){

    }
}
