using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.UI;
using TMPro;

public class Meople : MonoBehaviour
{
    private clothing meopleClothing;
    private Brain brain;
    private NavMeshAgent agent;
    private Need[] needs = new Need[6];
    private int happiness;
    private bool interacting;
    private bool withinInteractionRange = false;
    private bool wokenUp = false;
    private bool eating = false;
    private BoxCollider targetCollider;
    private int conversationIndex;
    [SerializeField] float[] needVals = {100, 100, 50, 100, 100, 100};
    private ArrayList advertisements = new ArrayList();
    private List<Relationship> relationships = new List<Relationship>();
    private List<MeopleAction> actionQueue = new List<MeopleAction>();
    [SerializeField] GameObject meople;
    [SerializeField] GameObject button;
    [SerializeField] GameObject conversationObject;
    
    void Start(){
        meopleClothing = GetComponent<clothing>();
        brain = new Brain();
        brain.SetMeople(this);
        agent = GetComponent<NavMeshAgent>();
        interacting = false;
        targetCollider = null;
        InitializeNeeds();
        StartCoroutine(Drain());
        StartCoroutine(ProcessAdvertisements());
    }
    void Update(){
        CheckForMoreImportantNeeds();
        CheckIfEating();
        for(int i = 0; i < needs.Length; i++){
            needVals[i] = needs[i].GetAmount();
            if(needs[i].Repleneshing()){
                needs[i].ReplenishNeed();
            }else{
                if(eating && i == 3){
                    continue;
                }
                needs[i].StopRepleneshing();
            }
        }
        if(actionQueue.Count > 0 && !interacting){
            Vector3 interactionZone = GetAvailableInteractionZone(actionQueue[0].GetFurniture());
            if((interactionZone == Vector3.zero && !withinInteractionRange && targetCollider == null) || targetCollider.GetComponent<InteractionZone>().IsFull() && !withinInteractionRange && !actionQueue[0].GetFurniture().CoroRunning()){
                print(interactionZone == Vector3.zero && !withinInteractionRange && targetCollider == null);
                //print(targetCollider.GetComponent<InteractionZone>().IsFull() && !withinInteractionRange && !actionQueue[0].GetFurniture().CoroRunning());
                Dequeue();
                return;
            }
            if(interactionZone != Vector3.zero)
                agent.SetDestination(interactionZone);
            if(withinInteractionRange && !targetCollider.GetComponent<InteractionZone>().IsFull()){
                targetCollider.GetComponent<InteractionZone>().Use(true, this, false);
                Busy(true);
                agent.ResetPath();
                interacting = true;
                Vector3 targetDirection = actionQueue[0].GetFurniture().transform.position - transform.position;
                Quaternion rotation = Quaternion.LookRotation(targetDirection, Vector3.up);
                transform.rotation = rotation;
                actionQueue[0].GetFurniture().Interact(actionQueue[0].GetIndex(), this);
            }else if(!withinInteractionRange && targetCollider.GetComponent<InteractionZone>().IsFull() && !interacting){
                Dequeue();
            }
        }
    }
    private void CheckIfEating(){
        if(actionQueue.Count > 0 && interacting && actionQueue[0].GetFurniture().GetInteractions()[actionQueue[0].GetIndex()].GetNeedIndex() == 1){
            needs[3].SetDrainAmount(0.25f);
            eating = true;
        }else if(!needs[3].Repleneshing()){
            needs[3].StopRepleneshing();
            eating = false;
        }
    }
    private void CheckForMoreImportantNeeds(){
        if(actionQueue.Count > 0 && needs[1].GetAmount() < -75 && actionQueue[0].GetFurniture().GetInteractions()[actionQueue[0].GetIndex()].GetNeedIndex() != 1){
            if(actionQueue[0].GetFurniture().GetInteractions()[actionQueue[0].GetIndex()].GetNeedIndex() == 0 && needs[0].GetAmount() < 60){
                wokenUp = true;
            }
            Dequeue();
        }else if(actionQueue.Count > 0 && needs[3].GetAmount() < -75 && actionQueue[0].GetFurniture().GetInteractions()[actionQueue[0].GetIndex()].GetNeedIndex() != 3){
            if(actionQueue[0].GetFurniture().GetInteractions()[actionQueue[0].GetIndex()].GetNeedIndex() == 0 && needs[0].GetAmount() < 60){
                wokenUp = true;
            }
            Dequeue();
        }
    }
    public Conversation GetConversation(){
        return conversationObject.GetComponent<Conversation>();
    }
    public int GetNumberOfActions(){
        return actionQueue.Count;
    }
    public List<Relationship> GetRelationships(){
        return relationships;
    }
    public void AddRelationship(Relationship relationship){
        relationships.Add(relationship);
    }
    public BoxCollider GetTargetCollider(){
        return targetCollider;
    }
    public void WithinRange(){
        if(!targetCollider.GetComponent<InteractionZone>().IsFull()){
            withinInteractionRange = true;
        }
    }
    private Vector3 GetAvailableInteractionZone(Furniture furniture){
        foreach(Transform zone in furniture.transform){
            if(zone.GetComponent<BoxCollider>() != null &&zone.GetComponent<BoxCollider>() == targetCollider){
                return Vector3.zero;
            }
        }
        foreach(Transform zone in furniture.transform){
            if(zone.GetComponent<InteractionZone>() != null && !zone.GetComponent<InteractionZone>().IsFull() && zone.GetComponent<BoxCollider>() != targetCollider){
                targetCollider = zone.GetComponent<BoxCollider>();
                return zone.position;
            }
        }
        return Vector3.zero;
    }
    public void Dequeue(){
        if(actionQueue.Count > 0){
            int needIndex = actionQueue[0].GetFurniture().GetInteractions()[actionQueue[0].GetIndex()].GetNeedIndex();
            if(actionQueue.Count > 0){
                bool empty = true;
                foreach(Transform zone in actionQueue[0].GetFurniture().transform){
                    if(zone.GetComponent<InteractionZone>() != null && (zone.GetComponent<InteractionZone>().IsFull() && zone.GetComponent<BoxCollider>() != targetCollider || zone.GetComponent<InteractionZone>().GetOccupiers() - 1 > 0)){
                        empty = false;
                    }
                }
                if(empty && interacting){
                    if(GameObject.Find(""+conversationIndex) != null){
                        Destroy(GameObject.Find(""+conversationIndex));
                        conversationIndex = -1;
                    }
                    actionQueue[0].GetFurniture().StopAllCoroutines();
                    actionQueue[0].GetFurniture().NotRunning();
                }

                actionQueue.RemoveAt(0);
            }
            if(interacting)
                targetCollider.GetComponent<InteractionZone>().Use(false, this, false);
            targetCollider = null;
            ResetDestination();
            brain.Privacy(false);
            brain.Busy(false);
            withinInteractionRange = false;
            if(needIndex != -1){
                needs[needIndex].StopRepleneshing();
            }else{
                int replenishingNeed = FindRepleneshingNeed();
            }
            GameMaster.DequeueActionQueueButtons(0, this);
            interacting = false;
        }
    }
    public void DequeueAt(int index){
        if(index == 0){
            int needIndex = actionQueue[0].GetFurniture().GetInteractions()[actionQueue[0].GetIndex()].GetNeedIndex();
            bool empty = true;
            foreach(Transform zone in actionQueue[0].GetFurniture().transform){
                if((zone.GetComponent<InteractionZone>().IsFull() && zone.GetComponent<BoxCollider>() != targetCollider) || zone.GetComponent<InteractionZone>().GetOccupiers() - 1 > 0){
                    empty = false;
                }
            }
            if(empty){
                if(GameObject.Find(""+conversationIndex) != null){
                    Destroy(GameObject.Find(""+conversationIndex));
                    conversationIndex = -1;
                }
                actionQueue[index].GetFurniture().StopAllCoroutines();
                actionQueue[index].GetFurniture().NotRunning();
            }
            if(interacting){
                targetCollider.GetComponent<InteractionZone>().Use(false, this, false);
            }
            targetCollider = null;
            brain.Privacy(false);
            brain.Busy(false);
            ResetDestination();
            withinInteractionRange = false;
            if(needIndex != -1){
                needs[needIndex].StopRepleneshing();
            }else{
                int replenishingNeed = FindRepleneshingNeed();
                if(replenishingNeed != -1)
                    needs[replenishingNeed].StopRepleneshing();
            }
            interacting = false;
        }
        actionQueue.RemoveAt(index);
        GameMaster.DequeueActionQueueButtons(index, this);
    }
    public int FindRepleneshingNeed(){
        for(int i = 0; i < needs.Length; i++){
            if(needs[i].Repleneshing()){
                return i;
            }
        }
        return -1;
    }
    public Brain GetBrain(){
        return brain;
    }
    public int GetConversationIndex(){
        return conversationIndex;
    }
    public void SetConversationIndex(int x){
        conversationIndex = x;
    }
    public void Enqueue(MeopleAction meopleAction){
        if(actionQueue.Count < 8){
            actionQueue.Add(meopleAction);
            GameMaster.CreateActionQueueButton(meopleAction, this);
        }
    }
    public void DequeueFromActionList(int x) {
        DequeueAt(x);
    }
    public void NoNeedToSleep(){
        wokenUp = false;
    }
    public bool WokenUp(){
        return wokenUp;
    }
    public bool IsBusy(){
        return brain.IsBusy();
    }
    public void Busy(bool busy){
        brain.Busy(busy);
    }
    public bool RequiresPrivacy(){
        return brain.RequiresPrivacy();
    }
    public void Privacy(bool privacy){
        brain.Privacy(privacy);
    }
    public List<MeopleAction> GetActions(){
        return actionQueue;
    }
    public IEnumerator ProcessAdvertisements(){
        while(true){
            if(advertisements.Count > 0 && actionQueue.Count < 9 && !interacting){
                MeopleAction meopleAction;
                if(wokenUp && needs[1].GetAmount() > -60 && needs[3].GetAmount() > -60){
                    Need[] trickToSleep = new Need[6];
                    trickToSleep[0] = new Energy(0.20f, 0.4f);
                    trickToSleep[1] = new Hunger(0.3f, 3f);
                    trickToSleep[2] = new Happiness(0.25f, 1f);
                    trickToSleep[3] = new Bladder(0.1f, 10f);
                    trickToSleep[4] = new Hygiene(0.1f, 5f);
                    trickToSleep[5] = new Social(0.05f, 2f);
                    trickToSleep[0].SetAmount(-100);
                    for(int i = 1; i < trickToSleep.Length; i++){
                        trickToSleep[i].SetAmount(100);
                    }
                    meopleAction = brain.ProcessAdvertisements(advertisements, trickToSleep, true);
                }else{
                    meopleAction = brain.ProcessAdvertisements(advertisements, needs, false);
                }
                if(meopleAction.GetFurniture() is Bed){
                    NoNeedToSleep();
                }
                if(!interacting && actionQueue.Count < 1)
                    Enqueue(meopleAction);
            }
            float AiDecisionMakingTimer = Random.Range(10, 20);
            yield return new WaitForSeconds(AiDecisionMakingTimer);
        }
    }

    private void InitializeNeeds(){
        needs[0] = new Energy(0.15f, 0.4f);
        needs[1] = new Hunger(0.3f, 3f);
        needs[2] = new Happiness(0.25f, 1f);
        needs[3] = new Bladder(0.1f, 10f);
        needs[4] = new Hygiene(0.1f, 5f);
        needs[5] = new Social(0.05f, 2f);
        for(int i = 0; i < needs.Length; i++){
            needs[i].SetAmount(needVals[i]);
        }
    }
    public IEnumerator Drain(){
        while(true){
            yield return new WaitForSeconds(1);
            for(int i = 0; i < needs.Length; i++){
                needs[i].Drain();
            }
        }
    }
    public void AddAdvertisement(Advertisement advertisement){
        advertisements.Add(advertisement);
    }
    public void ClearAdvertisements(){
        advertisements.Clear();
    }
    public void ResetDestination(){
        agent.ResetPath();
    }
    public void SetDestination(Vector3 position){
        agent.SetDestination(position);
    }
    public float[] GetNeeds(){
        return needVals;
    }
    public Need[] GetActualNeeds(){
        return needs;
    }
    public string GetFirstName(){
        return meopleClothing.firstName;
    }
    public string GetLastName(){
        return meopleClothing.lastName;
    }
    public int GetGender(){
        return meopleClothing.gender;
    }
    public int GetAge(){
        return meopleClothing.age;
    }
    public int GetSkinColor(){
        for(int i = 0; i < meopleClothing.skin_textures.Length; i++){
            if(meopleClothing.skin_body.GetComponent<Renderer>().materials[0].mainTexture == meopleClothing.skin_textures[i]){
                return i;
            }
        }
        return -1;
    }
    public int[] GetHair(){
        int[] hairData = new int[2];
        for(int i = 0; i < meopleClothing.hairStyles.Length; i++){
         if(meopleClothing.hairStyles[i].activeSelf){
            for(int j = 0; j < meopleClothing.hairTextures[i].Length; j++){
               if(meopleClothing.hairStyles[i].GetComponent<Renderer>().materials[0].mainTexture == meopleClothing.hairTextures[i][j]){
                  hairData[0] = i;
                  hairData[1] = j;
                  return hairData;
               }
            }
         }
      }
        return null;
    }
    public int[] GetTop(){
        int[] topData = new int[2];
        for(int i = 0; i < meopleClothing.tops.Length; i++){
            if(meopleClothing.tops[i].activeSelf){
                for(int j = 0; j < meopleClothing.topTextures[i].Length; j++){
                if(meopleClothing.tops[i].GetComponent<Renderer>().materials[0].mainTexture == meopleClothing.topTextures[i][j]){
                    topData[0] = i;
                    topData[1] = j;
                    return topData;
                }
                }
            }
        }
      return null;
    }
    public int[] GetBot(){
        int[] botData = new int[2];
        for(int i = 0; i < meopleClothing.bottoms.Length; i++){
            if(meopleClothing.bottoms[i].activeSelf){
                for(int j = 0; j < meopleClothing.bottomTextures[i].Length; j++){
                if(meopleClothing.bottoms[i].GetComponent<Renderer>().materials[0].mainTexture == meopleClothing.bottomTextures[i][j]){
                    botData[0] = i;
                    botData[1] = j;
                    return botData;
                }
                }
            }
        }
      return null;
    }
    public int[] GetShoe(){
        int[] shoeData = new int[2];
        for(int i = 0; i < meopleClothing.shoes.Length; i++){
            if(meopleClothing.shoes[i].activeSelf){
                for(int j = 0; j < meopleClothing.shoeTextures[i].Length; j++){
                if(meopleClothing.shoes[i].GetComponent<Renderer>().materials[0].mainTexture == meopleClothing.shoeTextures[i][j]){
                    shoeData[0] = i;
                    shoeData[1] = j;
                    return shoeData;
                }
                }
            }
        }
      return null;
    }
    public float GetWeight(){
        return meopleClothing.weight;
    }
    public float[] GetPersonality(){
        float[] personality = {meopleClothing.openness, meopleClothing.agreeableness, meopleClothing.conscientiousness, meopleClothing.extraversion, meopleClothing.neuroticism};
        return personality;
    }
    public void LoadMeople(){
        MeopleData[] meopleData = CharacterCreatorSaver.LoadFamily();
        for(int i = 0; i < meopleData.Length; i++){
            GameObject createdMeople = Instantiate(meople, new Vector3(i, 0, 0), Quaternion.identity);
            clothing meopleStats = createdMeople.GetComponent<clothing>();
            meopleStats.firstName = meopleData[i].GetFirstName();
            meopleStats.lastName = meopleData[i].GetLastName();
            meopleStats.gender = meopleData[i].GetGender();
            meopleStats.age = meopleData[i].GetAge();
            meopleStats.skinColor = meopleStats.skin_textures[meopleData[i].GetSkinColor()];
            meopleStats.skin_body.GetComponent<Renderer>().materials[0].mainTexture = meopleStats.skinColor;
            meopleStats.skin_head.GetComponent<Renderer>().materials[0].mainTexture = meopleStats.skinColor;
            int hairIndex = meopleData[i].GetHair()[0];
            int hairTextureIndex = meopleData[i].GetHair()[1];
            meopleStats.hairStyles[hairIndex].SetActive(true);
            meopleStats.hairStyles[hairIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.hairTextures[hairIndex][hairTextureIndex];
            int topIndex = meopleData[i].GetTop()[0];
            int topTextureIndex = meopleData[i].GetTop()[1];
            meopleStats.tops[topIndex].SetActive(true);
            meopleStats.tops[topIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.topTextures[topIndex][topTextureIndex];
            int botIndex = meopleData[i].GetBot()[0];
            int botTextureIndex = meopleData[i].GetBot()[1];
            meopleStats.bottoms[botIndex].SetActive(true);
            meopleStats.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.hairTextures[botIndex][botTextureIndex];
            int shoeIndex = meopleData[i].GetShoe()[0];
            int shoeTextureIndex = meopleData[i].GetShoe()[1];
            meopleStats.shoes[shoeIndex].SetActive(true);
            meopleStats.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.hairTextures[shoeIndex][shoeTextureIndex];
            meopleStats.weight = meopleData[i].GetWeight();
            float ageScale;
            float characterScale = meopleStats.weight * 0.008f - 0.2f;
            if(meopleStats.age == 0){
                ageScale = 0.4f;
            }else if(meopleStats.age == 1){
                ageScale = 0.6f;
            }else if(meopleStats.age == 2){
                ageScale = 0.8f;
            }else{
                ageScale = 1.0f;
            }
            createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
            meopleStats.openness = meopleData[i].GetPersonality()[0];
            meopleStats.agreeableness = meopleData[i].GetPersonality()[1];
            meopleStats.conscientiousness = meopleData[i].GetPersonality()[2];
            meopleStats.extraversion = meopleData[i].GetPersonality()[3];
            meopleStats.neuroticism = meopleData[i].GetPersonality()[4];
        }
    }
}
