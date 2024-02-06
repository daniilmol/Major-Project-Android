using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Furniture : MonoBehaviour
{
    [SerializeField] int price;
    [SerializeField] int quality;
    [SerializeField] bool isSurface;
    [SerializeField] bool canGetDirty;
    [SerializeField] bool upgradeable;
    [SerializeField] bool canBreak;
    [SerializeField] float decoFactor;
    private bool isDirty;
    private int used;
    private int[] minAge;
    private int[] maxAge;
    private List<Interaction> interactions = new List<Interaction>();
    private List<GameObject> interactionZones = new List<GameObject>();
    void Start(){
        int i = 0;
        foreach(Transform child in gameObject.transform){
            interactionZones.Add(child.gameObject);
        }
    }
    protected void SetData(Dictionary<string, int> interactions, int[] minAge, int[] maxAge){
        int i = 0;
        foreach(KeyValuePair<string, int> entry in interactions){
            this.interactions.Add(new Interaction(entry.Key, entry.Value, minAge[i], maxAge[i++]));
        }
    }
    protected bool IsSurface(){
        return isSurface;
    }
    protected bool CanGetDirty(){
        return canGetDirty;
    }
    protected bool Upgradeable(){
        return upgradeable;
    }
    protected float GetDecoFactor(){
        return decoFactor;
    }
    protected float GetPrice(){
        return price;
    }
    public void Clean(){

    }
    public void Upgrade(){

    }
    public void Repair(){
        
    }
}
