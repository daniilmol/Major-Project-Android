using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NeedDecorator : Need
{
    protected Need need;

    public NeedDecorator(Need need) : base(need.DrainRate, need.ReplenishRate)
    {
        this.need = need;
    }
}
