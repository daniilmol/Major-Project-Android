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
    public bool IsFull(){
        for(int i = 0; i < interactionZones.Length; i++){
            if(!interactionZones[i].GetComponent<InteractionZone>().IsFull()){
                return false;
            }
        }
        return true;
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
    private bool coroRunning = false;
    public bool CoroRunning(){
        return coroRunning;
    }
    public void NotRunning(){
        coroRunning = false;
    }
    protected IEnumerator ReplenishNeeds(Meople meople, int needIndex, int interactionTime){
        print(meople.GetFirstName() + " is now interacting with " + this + " repleneshing " + needIndex + " for " + interactionTime + " seconds");
        int time = 0;
        coroRunning = true;
        bool breaking = false;
        if(interactionTime == -1){
            while(meople.GetNeeds()[needIndex] < 100){
                if(!meople.IsBusy()){
                    breaking = true;
                    print("broke");
                    break;
                }
                meople.GetActualNeeds()[needIndex].Replenish();
                yield return null;
            }
        }else{
            while(time < interactionTime){
                if(meople.GetNeeds()[needIndex] > 99 && needIndex != 2 && needIndex != 5){
                    if(!meople.IsBusy()){
                        breaking = true;
                        break;
                    }
                    break;
                }
                meople.GetActualNeeds()[needIndex].Replenish();
                yield return new WaitForSeconds(1);
                time++;
            }
        }
        if(!breaking){
            meople.Privacy(false);
            meople.Busy(false);
            meople.GetActualNeeds()[needIndex].StopRepleneshing();
            meople.ResetDestination();
            print(meople.GetFirstName() + "DEQUEUED IN FURNITURE");
        }
        meople.Dequeue();
    }
    public void Clean(int index, Meople meople){

    }
    public void Upgrade(int index, Meople meople){

    }
    public void Repair(int index, Meople meople){
        
    }
}
