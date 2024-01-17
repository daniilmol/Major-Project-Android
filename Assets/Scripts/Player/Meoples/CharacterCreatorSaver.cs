using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
public static class CharacterCreatorSaver
{
    public static void SaveFamily(List<GameObject> meoples){
        BinaryFormatter formatter = new BinaryFormatter();
        string path = Application.persistentDataPath + "/family.meople";
        FileStream stream = new FileStream(path, FileMode.Create);
        MeopleData[] meopleData = new MeopleData[meoples.Count];
        for(int i = 0; i < meopleData.Length; i++){
            meopleData[i] = new MeopleData(meoples[i].GetComponent<Meople>());
        }
        formatter.Serialize(stream, meopleData);
        stream.Close();
    }

    public static MeopleData[] LoadFamily(){
        string path = Application.persistentDataPath + "/family.meople";
        if(File.Exists(path)){
            FileStream stream = new FileStream(path, FileMode.Open);
            BinaryFormatter formatter = new BinaryFormatter();
            MeopleData[] meopleData = formatter.Deserialize(stream) as MeopleData[];
            stream.Close();
            return meopleData;
        }else{
            Debug.LogError("Save file not found in " + path);
            return null;
        }
    }
}
