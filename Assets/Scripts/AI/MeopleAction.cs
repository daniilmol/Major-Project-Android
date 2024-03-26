using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeopleAction 
{
    private Furniture furniture;
    private int index;
    public MeopleAction(Furniture furniture, int index){
        this.furniture = furniture;
        this.index = index;
    }
    public Furniture GetFurniture(){
        return furniture;
    }
    public int GetIndex(){
        return index;
    }
}
