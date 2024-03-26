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
    private Advertiser advertiser;
    private Advertisement advertisement;
    private bool isDirty;
    protected int maxUseForDirty;
    protected int used;
    private List<Interaction> interactions = new List<Interaction>();
    private GameObject[] interactionZones;
    void Start(){
        maxUseForDirty = 5;
        interactionZones = new GameObject[transform.childCount];
        SetAllZones();
    }
    private void SetAllZones(){
        int i = 0;
        foreach(Transform child in transform){
            interactionZones[i++] = child.gameObject;
        }
    }
    public List<Interaction> GetInteractions(){
        return interactions;
    }
    public virtual void Interact(int index, Meople meople){

    }
    protected void SetData(Dictionary<string, int> interactions, int[] minAge, int[] maxAge){
        int i = 0;
        foreach(KeyValuePair<string, int> entry in interactions){
            this.interactions.Add(new Interaction(entry.Key, entry.Value, minAge[i], maxAge[i], i++, gameObject));
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
    protected IEnumerator ReplenishNeeds(Meople meople, int needIndex, int interactionTime){
        int time = 0;
        if(interactionTime == -1){
            while(meople.GetNeeds()[needIndex] < 100){
                meople.GetActualNeeds()[needIndex].Replenish();
                //print(meople.GetFirstName() + " REPLENESHING" + needIndex);
                yield return null;
            }
        }else{
            while(time < interactionTime){
                meople.GetActualNeeds()[needIndex].Replenish();
                yield return new WaitForSeconds(1);
                time++;
            }
        }
        meople.Privacy(false);
        meople.Busy(false);
        meople.GetActualNeeds()[needIndex].StopRepleneshing();
        meople.ResetDestination();
        meople.Dequeue();
    }
    public void Clean(int index, Meople meople){

    }
    public void Upgrade(int index, Meople meople){

    }
    public void Repair(int index, Meople meople){
        
    }
}
