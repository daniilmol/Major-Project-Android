using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Hunger : Need
{
    public Hunger(float drainRate, float replenishRate) : base(drainRate, replenishRate){

    }
    public override int GetScore()
    {
        return (int)(Math.Pow(0.965, amount));
    }
}
