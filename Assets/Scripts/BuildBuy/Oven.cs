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
    }
    public void HaveFood(){

    }
    public void ServeFood(){

    }
}
