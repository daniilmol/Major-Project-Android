using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cabinet : Furniture
{
    [SerializeField] string[] interactionNames;
    [SerializeField] int[] needIndices;
    [SerializeField] int[] minAge;
    [SerializeField] int[] maxAge;
    [SerializeField] int maxStorage;
    private Food[] foods;
    Dictionary<string, int> dictInteractions;
    void Awake(){
        dictInteractions = new Dictionary<string, int>();
        for(int i = 0; i < needIndices.Length; i++){
            dictInteractions.Add(interactionNames[i], needIndices[i]);
        }
        foods = new Food[maxStorage];
        SetData(dictInteractions, minAge, maxAge);
    }
    public void StoreGroceries(){

    }
    public void View(){

    }
}
