using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bladder : Need
{
    public Bladder(float drainRate, float replenishRate) : base(drainRate, replenishRate){

    }
    public override int GetScore()
    {
        return (int)(Math.Pow(0.966, amount));
    }
}
