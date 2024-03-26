using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractionZone : MonoBehaviour
{
    private int maxOccupancy;
    private int occupiers;
    List<Meople> tenants = new List<Meople>();
    void Start(){
        occupiers = 0;
    }
    public void SetMaxOccupancy(int maxOccupancy){
        this.maxOccupancy = maxOccupancy;
    }
    public bool IsFull(){
        return occupiers >= maxOccupancy;
    }
    public void Use(bool done, Meople meople, bool recursive){
        int recursiveTemp = occupiers - 1;
        if(done && occupiers < maxOccupancy){
            occupiers++;
            tenants.Add(meople);
        }else if(!done && !recursive){
            occupiers--;
            tenants.Remove(meople);
        }else if(!done && recursive){
            tenants.Remove(meople);
            occupiers = recursiveTemp;
        }
        if(occupiers > maxOccupancy && !recursive){
            //occupiers = maxOccupancy;
            int x = occupiers - maxOccupancy;
            for(int i = 0; i < x; i++){
                Use(false, tenants[occupiers], true);
            }
        }
        if(occupiers < 0 && !recursive){
            occupiers = 0;
        }
    }
    public bool IsTenant(Meople meople){
        return tenants.Contains(meople);
    }
    public List<Meople> GetTenants(){
        return tenants;
    }
    private void OnTriggerStay(Collider other) {
        if(other.GetComponent<Meople>() != null && other.GetComponent<Meople>().GetTargetCollider() == GetComponent<BoxCollider>()){
            other.GetComponent<Meople>().WithinRange(other.GetComponent<Meople>().GetFirstName());
        }
    }
}
