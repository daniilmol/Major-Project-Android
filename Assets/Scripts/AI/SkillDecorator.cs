using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SkillDecorator : NeedDecorator
{
    private float hungerLevel;
    public SkillDecorator(Need need, float hungerLevel) : base(need) {
        this.hungerLevel = hungerLevel;
    }

}
