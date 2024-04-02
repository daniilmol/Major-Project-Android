using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Advertiser : MonoBehaviour
{
    private bool coroutineFinished;
    private float timeBetweenAdvertisements;
    private Meople[] meoples;
    private List<Advertisement> advertisements = new List<Advertisement>();
    private bool meoplesAdded;

    void Start(){
        coroutineFinished = true;
        meoplesAdded = false;
    }

    void Update(){
        if(coroutineFinished){
            StartCoroutine(Advertise());
        }
        if(!meoplesAdded){
            AddMeoples();
        }
    }
    private void AddMeoples(){
        meoples = GameObject.FindObjectsOfType<Meople>();
        for(int i = 0; i < meoples.Length; i++){
            Interaction socialInteraction = new Interaction("Start Conversation", 5, 0, 4, -1, meoples[i].gameObject);
        }
        meoplesAdded = true;
    }
    public void AddAd(Advertisement ad){
        advertisements.Add(ad);
    }
    private IEnumerator Advertise(){
        meoples = GameObject.FindObjectsOfType<Meople>();
        coroutineFinished = false;
        timeBetweenAdvertisements = Random.Range(5, 10);
        yield return new WaitForSeconds(2);
        for(int i = 0; i < meoples.Length; i++){
            meoples[i].ClearAdvertisements();
        }
        for(int j = 0; j < advertisements.Count; j++){
            for(int i = 0; i < meoples.Length; i++){
                meoples[i].AddAdvertisement(advertisements[j]);
            }
        }
        coroutineFinished = true;
    }
}
