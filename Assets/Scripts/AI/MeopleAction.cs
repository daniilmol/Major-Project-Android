using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeopleAction 
{
    private Furniture furniture;
    private int index;
    private Meople meople;
    public MeopleAction(Furniture furniture, int index){
        this.furniture = furniture;
        this.index = index;
    }
    public MeopleAction(Meople meople){
        this.meople = meople;
    }
    public Furniture GetFurniture(){
        return furniture;
    }
    public int GetIndex(){
        return index;
    }
    public Meople GetMeople(){
        return meople;
    }
}
