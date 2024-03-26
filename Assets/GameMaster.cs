using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameMaster : MonoBehaviour
{
    public static GameMaster gameMaster;
    public static Meople selectedMeople;
    public static Meople[] family;
    void Awake(){
        if(gameMaster == null){
            gameMaster = this;
            DontDestroyOnLoad(gameObject);
        }else{
            Destroy(gameObject);
        }
    }
    
}
