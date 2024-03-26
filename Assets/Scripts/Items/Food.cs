using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Food : MonoBehaviour
{
    private int quality;
    private float freshness;
    private float initFreshnessHours = 9;
    private TimeManager timeManager;
    void Start(){
        timeManager = GameObject.FindAnyObjectByType<TimeManager>();
        freshness = timeManager.GetSecondsPerHour() * initFreshnessHours;
        StartCoroutine(RotTheFood());
    }
    IEnumerator RotTheFood(){
        while(true){
            yield return new WaitForSeconds(1);
            freshness--;
        }
    }
}
