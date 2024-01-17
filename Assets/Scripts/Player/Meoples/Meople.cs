using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Meople : MonoBehaviour
{
    private clothing meopleClothing;
    [SerializeField] GameObject meople;
    void Start(){
        meopleClothing = GetComponent<clothing>();
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
        }
    }
}
