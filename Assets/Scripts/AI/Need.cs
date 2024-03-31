using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem.Interactions;

public abstract class Need 
{
    protected float amount;
    protected float drainRate;
    protected float baseDrainRate;
    protected float replenishRate;
    protected bool repleneshing = false;
    public float DrainRate => drainRate;
    public float ReplenishRate => replenishRate;
    public Need(float drainRate, float replenishRate){
        this.drainRate = drainRate;
        this.replenishRate = replenishRate;
        baseDrainRate = drainRate;
    }
    
    public void SetDrainAmount(float amount){
        drainRate = amount;
    }

    public void Drain(){
        this.amount -= drainRate;
        if(this.amount < -100){
            amount = -100;
        }if(this.amount > 100){
            amount = 100;
        }
    }
    public void ReplenishNeed(){
        drainRate = -replenishRate;
    }
    public virtual int GetScore(){
        return 0;
    }
    public void SetAmount(float amount){
        this.amount = amount;
    }
    public void Replenish(){
        repleneshing = true;
    }
    public void StopRepleneshing(){
        repleneshing = false;
        drainRate = baseDrainRate;
    }
    public bool Repleneshing(){
        return repleneshing;
    }
    public float GetAmount(){
        return amount;
    }
}
