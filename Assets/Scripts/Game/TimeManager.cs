using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Experimental.GlobalIllumination;
using UnityEngine.TerrainTools;

public class TimeManager : MonoBehaviour
{
    [SerializeField] GameObject sun;
    [SerializeField] float secondsForHour;
    [SerializeField] TextMeshProUGUI timeUI;
    private Vector3 rot;
    private float amountToRotate;
    private float time;
    private int hour;
    private int actualHour;
    private int minute;
    private int labelIndex;
    private string[] timeLabels = new string[2];
    public static float currentTime;
    private void ToggleLabelIndex(){
        if(labelIndex == 0){
            labelIndex = 1;
            return;
        }
        labelIndex = 0;
    }
    public float GetSecondsPerHour(){
        return secondsForHour;
    }
    // Start is called before the first frame update
    void Start()
    {
        //amountToRotate = 180 / (12 * secondsForHour);
        rot = Vector3.zero;
        hour = 6;
        actualHour = hour;
        minute = 0;
        timeLabels[0] = "AM";
        timeLabels[1] = "PM";
        labelIndex = 0;
        currentTime = hour;
    }

    // Update is called once per frame
    void Update()
    {
        time += Time.deltaTime * (60 / secondsForHour);
        //rot.x = Time.deltaTime * amountToRotate;
        sun.transform.Rotate(rot, Space.Self);
        minute = (int)time;
        currentTime = actualHour * 60 + minute;
        if(minute > 59){
            minute = 0;
            time = 0;
            hour++;
            actualHour++;
            if(hour > 12){
                hour = 1;
            }else if(hour > 11){
                ToggleLabelIndex();
                if(actualHour > 23){
                    actualHour = 0;
                }
            }
        }
        if(minute > 9){
            timeUI.text = hour + ":" + minute + timeLabels[labelIndex];
        }else{
            timeUI.text = hour + ":0" + minute + timeLabels[labelIndex];
        }
    }
}
