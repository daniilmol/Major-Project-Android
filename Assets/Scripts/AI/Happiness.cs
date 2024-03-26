using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Happiness : Need
{
    public Happiness(float drainRate, float replenishRate) : base(drainRate, replenishRate){

    }
    public override int GetScore()
    {
        return (int)(Math.Pow(0.91, 0.2 * amount) + 1);
    }
}
