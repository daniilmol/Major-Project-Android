using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Energy : Need
{
    public Energy(float drainRate, float replenishRate) : base(drainRate, replenishRate){

    }
    public override int GetScore()
    {
        return (int)Math.Pow(0.96, 0.6 * amount);
    }
}
