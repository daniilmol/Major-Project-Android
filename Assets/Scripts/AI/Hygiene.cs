using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Hygiene : Need
{
    public Hygiene(float drainRate, float replenishRate) : base(drainRate, replenishRate){

    }
    public override int GetScore()
    {
        return (int)(-amount * 0.1);
    }
}
