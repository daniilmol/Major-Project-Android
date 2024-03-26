using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Social : Need
{
    public Social(float drainRate, float replenishRate) : base(drainRate, replenishRate){

    }
    public override int GetScore()
    {
        return (int)(Math.Pow(0.91, 0.2 * amount) + 1);
    }
}
