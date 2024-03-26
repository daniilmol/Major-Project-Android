using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class CharacterCreator : MonoBehaviour
{
    [SerializeField] GameObject meopologyPanel;
    [SerializeField] GameObject bodyPanel;
    [SerializeField] GameObject clothingPanel;
    [SerializeField] GameObject areYouSurePanel;
    [SerializeField] Slider weightSlider;
    [SerializeField] Slider opennessSlider;
    [SerializeField] Slider agreeablenessSlider;
    [SerializeField] Slider conscientiousnessSlider;
    [SerializeField] Slider extraversionSlider;
    [SerializeField] Slider neuroticismSlider;
    [SerializeField] TMP_Dropdown jacketDropdown;
    [SerializeField] TMP_Dropdown TShirtDropdown;
    [SerializeField] TMP_Dropdown ShirtDropdown;
    [SerializeField] TMP_Dropdown SweaterDropdown;
    [SerializeField] TMP_Dropdown TanktopDropdown;
    [SerializeField] TMP_Dropdown shortsDropdown;
    [SerializeField] TMP_Dropdown pantsDropdown;
    [SerializeField] TMP_Dropdown sneakersDropdown;
    [SerializeField] TMP_Dropdown flippersDropdown;
    [SerializeField] TMP_Dropdown bootsDropdown;
    [SerializeField] TMP_Dropdown hairDropdown;
    [SerializeField] TMP_Text areYouSureText;
    [SerializeField] TMP_InputField firstName;
    [SerializeField] TMP_InputField lastName;
    [SerializeField] Button whiteBlueButton;
    [SerializeField] Button whiteGreenButton;
    [SerializeField] Button whiteBrownButton;
    [SerializeField] Button lightBrownButton;
    [SerializeField] Button brownButton;
    [SerializeField] Button maleButton;
    [SerializeField] Button femaleButton;
    [SerializeField] Button addButton;
    [SerializeField] Button doneButton;
    [SerializeField] Button deleteButton;
    [SerializeField] Button nextButton;
    [SerializeField] Button[] ages;
    [SerializeField] GameObject[] hairStylesA;
    [SerializeField] GameObject[] hairStylesB;
    [SerializeField] GameObject[] hairStylesC;
    [SerializeField] GameObject[] hairStylesD;
    [SerializeField] GameObject[] hairStylesE;
    [SerializeField] GameObject character;
    [SerializeField] GameObject meople;
    [SerializeField] Animator anyAnimator;
    [SerializeField] Animator toddlerAnimator;
    private clothing characterClothing;
    private Vector3 touchStart;
    private GameObject[] skinButtons = new GameObject[5];
    [SerializeField] GameObject[] hairButtons;
    private GameObject[] hairStyleButtons;
    private List<GameObject> meoples = new List<GameObject>(8);
    private int age;
    private int curSim;
    private int state;
    public float openness;
    public float agreeableness;
    public float extraversion;
    public float conscientiousness;
    public float neuroticism;
    private bool manualNameChange;
    private bool loadingCharacterPersonality;
    void Start()
    {
        curSim = 0;
        skinButtons[0] = brownButton.transform.Find("Selected").gameObject;
        skinButtons[1] = lightBrownButton.transform.Find("Selected").gameObject;
        skinButtons[2] = whiteBlueButton.transform.Find("Selected").gameObject;
        skinButtons[3] = whiteBrownButton.transform.Find("Selected").gameObject;
        skinButtons[4] = whiteGreenButton.transform.Find("Selected").gameObject;
        manualNameChange = true;
        loadingCharacterPersonality = false;
        InitializeCharacter();
    }
    void InitializeCharacter()
    {
        age = 3;
        GameObject createdCharacter = Instantiate(character, new Vector3(0, 0, 0), Quaternion.Euler(0, 180, 0));
        meoples.Add(createdCharacter);
        curSim = meoples.Count - 1;
        characterClothing = meoples[curSim].GetComponent<clothing>();
        characterClothing.age = age;
        characterClothing.weight = 25;
        Debug.Log("Inside initialize character");
        GenerateCharacter();
    }
    void Update()
    {
        if (CanPlayGame())
        {
            doneButton.interactable = true;
        }
        else
        {
            doneButton.interactable = false;
        }
    }
    private bool CanPlayGame()
    {
        List<clothing> allCharacterStats = new List<clothing>();
        for (int i = 0; i < meoples.Count; i++)
        {
            allCharacterStats.Add(meoples[i].GetComponent<clothing>());
        }
        for (int i = 0; i < allCharacterStats.Count; i++)
        {
            if (string.IsNullOrEmpty(allCharacterStats[i].firstName) || string.IsNullOrEmpty(allCharacterStats[i].firstName))
            {
                return false;
            }
        }
        return true;
    }
    public void openMeopologyPanel()
    {
        bodyPanel.SetActive(false);
        clothingPanel.SetActive(false);
        meopologyPanel.SetActive(true);

    }
    public void openBodyPanel()
    {
        bodyPanel.SetActive(true);
        clothingPanel.SetActive(false);
        meopologyPanel.SetActive(false);
    }
    public void openClothingPanel()
    {
        bodyPanel.SetActive(false);
        clothingPanel.SetActive(true);
        meopologyPanel.SetActive(false);
    }
    public void ChangeWeight()
    {
        float weight = weightSlider.value; //0 = 0.8, 25 = 1.0, 50 = 1.2
        float characterScale = weight * 0.008f - 0.2f;
        float ageScale;
        if (age == 0)
        {
            ageScale = 0.4f;
        }
        else if (age == 1)
        {
            ageScale = 0.6f;
        }
        else if (age == 2)
        {
            ageScale = 0.8f;
        }
        else
        {
            ageScale = 1.0f;
        }
        meoples[curSim].transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
        characterClothing.weight = weight;
    }
    public void ChangePersonality(){
        if(!loadingCharacterPersonality){
            characterClothing.openness = opennessSlider.value;
            characterClothing.agreeableness = agreeablenessSlider.value;
            characterClothing.conscientiousness = conscientiousnessSlider.value;
            characterClothing.extraversion = extraversionSlider.value;
            characterClothing.neuroticism = neuroticismSlider.value;
            openness = opennessSlider.value;
            agreeableness = agreeablenessSlider.value;
            conscientiousness = conscientiousnessSlider.value;
            extraversion = extraversionSlider.value;
            neuroticism = neuroticismSlider.value;
        }
    }
    public void AssignJacket()
    {
        if (jacketDropdown.value == 0)
        {
            characterClothing.jacket.SetActive(false);
            return;
        }
        characterClothing.jacket.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { jacketDropdown, SweaterDropdown, ShirtDropdown, TShirtDropdown, TanktopDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Jacket_Dropdown")
            {
                d.value = 0;
            }
        }
        characterClothing.jacket.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.jacket_textures[jacketDropdown.value - 1];
    }
    public void AssignShirt()
    {
        if (ShirtDropdown.value == 0)
        {
            characterClothing.shirt.SetActive(false);
            return;
        }
        characterClothing.shirt.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { jacketDropdown, SweaterDropdown, ShirtDropdown, TShirtDropdown, TanktopDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Shirt_Dropdown")
            {
                d.value = 0;
            }
        }
        characterClothing.shirt.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.shirt_textures[ShirtDropdown.value - 1];
    }
    public void AssignSweater()
    {
        if (SweaterDropdown.value == 0)
        {
            characterClothing.pullover.SetActive(false);
            return;
        }
        characterClothing.pullover.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { jacketDropdown, SweaterDropdown, ShirtDropdown, TShirtDropdown, TanktopDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Sweater_Dropdown")
            {
                d.value = 0;
            }
        }
        characterClothing.pullover.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.pullover_textures[SweaterDropdown.value - 1];
    }
    public void AssignTShirt()
    {
        if (TShirtDropdown.value == 0)
        {
            characterClothing.t_shirt.SetActive(false);
            return;
        }
        Debug.Log(TShirtDropdown.value);
        characterClothing.t_shirt.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { jacketDropdown, SweaterDropdown, ShirtDropdown, TShirtDropdown, TanktopDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "T_Shirt_Dropdown")
            {
                d.value = 0;
            }
        }
        Debug.Log(TShirtDropdown.value);
        characterClothing.t_shirt.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.t_shirt_textures[TShirtDropdown.value - 1];
    }
    public void AssignTanktop()
    {
        if (TanktopDropdown.value == 0)
        {
            characterClothing.tank_top.SetActive(false);
            return;
        }
        characterClothing.tank_top.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { jacketDropdown, SweaterDropdown, ShirtDropdown, TShirtDropdown, TanktopDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Tanktop_Dropdown")
            {
                d.value = 0;
            }
        }
        Debug.Log(TanktopDropdown.value);
        characterClothing.tank_top.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.tank_top_textures[TanktopDropdown.value - 1];
    }
    public void AssignShorts()
    {
        if (shortsDropdown.value == 0)
        {
            characterClothing.shortpants.SetActive(false);
            return;
        }
        characterClothing.shortpants.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { pantsDropdown, shortsDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Shorts_Dropdown")
            {
                d.value = 0;
            }
        }
        characterClothing.shortpants.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.shortpants_textures[shortsDropdown.value - 1];
    }
    public void AssignPants()
    {
        if (pantsDropdown.value == 0)
        {
            characterClothing.trousers.SetActive(false);
            return;
        }
        characterClothing.trousers.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { pantsDropdown, shortsDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Pants_Dropdown")
            {
                d.value = 0;
            }
        }
        characterClothing.trousers.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.trousers_textures[pantsDropdown.value - 1];
    }
    public void AssignSneakers()
    {
        if (sneakersDropdown.value == 0)
        {
            characterClothing.shoes1.SetActive(false);
            return;
        }
        characterClothing.shoes1.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { sneakersDropdown, flippersDropdown, bootsDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Sneakers_Dropdown")
            {
                d.value = 0;
            }
        }
        characterClothing.shoes1.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.shoes1_textures[sneakersDropdown.value - 1];
    }
    public void AssignFlippers()
    {
        if (flippersDropdown.value == 0)
        {
            characterClothing.shoes2.SetActive(false);
            return;
        }
        characterClothing.shoes2.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { sneakersDropdown, flippersDropdown, bootsDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Flippers_Dropdown")
            {
                d.value = 0;
            }
        }
        characterClothing.shoes2.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.shoes2_textures[flippersDropdown.value - 1];
    }
    public void AssignBoots()
    {
        if (bootsDropdown.value == 0)
        {
            characterClothing.shoes3.SetActive(false);
            return;
        }
        characterClothing.shoes3.SetActive(true);
        TMP_Dropdown[] clothingDropdowns = { sneakersDropdown, flippersDropdown, bootsDropdown };
        foreach (TMP_Dropdown d in clothingDropdowns)
        {
            if (d.name != "Boots_Dropdown")
            {
                d.value = 0;
            }
        }
        characterClothing.shoes3.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.shoes3_textures[bootsDropdown.value - 1];
    }
    public void AssignSkinColor(int index)
    {
        characterClothing.skin_head.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.skin_textures[index];
        characterClothing.skin_body.GetComponent<Renderer>().materials[0].mainTexture = characterClothing.skin_textures[index];
        for (int i = 0; i < skinButtons.Length; i++)
        {
            if (i != index)
            {
                skinButtons[i].SetActive(false);
                continue;
            }
            skinButtons[i].SetActive(true);
        }
        characterClothing.skinColor = characterClothing.skin_textures[index];
    }
    public void AssignHair()
    {
        GameObject[][] maleHairStyles = { hairStylesA, hairStylesB, hairStylesE };
        GameObject[][] femaleHairStyles = { hairStylesC, hairStylesD };
        for (int i = 0; i < maleHairStyles.Length; i++)
        {
            for (int j = 0; j < maleHairStyles[i].Length; j++)
            {
                maleHairStyles[i][j].SetActive(false);
            }
        }
        for (int i = 0; i < femaleHairStyles.Length; i++)
        {
            for (int j = 0; j < femaleHairStyles[i].Length; j++)
            {
                femaleHairStyles[i][j].SetActive(false);
            }
        }
        if (hairDropdown.value == 0)
        {
            characterClothing.hair_a.SetActive(false);
            characterClothing.hair_b.SetActive(false);
            characterClothing.hair_c.SetActive(false);
            characterClothing.hair_d.SetActive(false);
            characterClothing.hair_e.SetActive(false);
            return;
        }
        GameObject[] maleHair = { characterClothing.hair_a, characterClothing.hair_b, characterClothing.hair_e };
        GameObject[] femaleHair = { characterClothing.hair_c, characterClothing.hair_d };
        if (characterClothing.gender == 0)
        {
            for (int i = 0; i < maleHair.Length; i++)
            {
                if (i != hairDropdown.value - 1)
                {
                    maleHair[i].SetActive(false);
                }
            }
            maleHair[hairDropdown.value - 1].SetActive(true);
            for (int i = 0; i < maleHairStyles[hairDropdown.value - 1].Length; i++)
            {
                maleHairStyles[hairDropdown.value - 1][i].SetActive(true);
            }
        }
        else if (characterClothing.gender == 1)
        {
            for (int i = 0; i < femaleHair.Length; i++)
            {
                if (i != hairDropdown.value - 1)
                {
                    femaleHair[i].SetActive(false);
                }
            }
            femaleHair[hairDropdown.value - 1].SetActive(true);
            for (int i = 0; i < femaleHairStyles[hairDropdown.value - 1].Length; i++)
            {
                femaleHairStyles[hairDropdown.value - 1][i].SetActive(true);
            }
        }
    }
    public void AssignHairColor(int index)
    {
        for (int i = 0; i < hairButtons.Length; i++)
        {
            hairButtons[i].SetActive(false);
        }
        GameObject[][] maleHairStyles = { hairStylesA, hairStylesB, hairStylesE };
        GameObject[][] femaleHairStyles = { hairStylesC, hairStylesD };
        GameObject[] maleHair = { characterClothing.hair_a, characterClothing.hair_b, characterClothing.hair_e };
        GameObject[] femaleHair = { characterClothing.hair_c, characterClothing.hair_d };
        if (characterClothing.gender == 0)
        {
            for (int i = 0; i < maleHair.Length; i++)
            {
                if (maleHair[i].activeSelf)
                {
                    maleHair[i].GetComponent<Renderer>().materials[0].mainTexture = maleHairStyles[i][index].GetComponent<Image>().mainTexture;
                    if (i < 2)
                    {
                        hairButtons[i * 6 + index].SetActive(true);
                    }
                    else
                    {
                        hairButtons[(i + 1) * 6 + index].SetActive(true);
                    }
                }
            }
        }
        else if (characterClothing.gender == 1)
        {
            for (int i = 0; i < femaleHair.Length; i++)
            {
                if (femaleHair[i].activeSelf)
                {
                    femaleHair[i].GetComponent<Renderer>().materials[0].mainTexture = femaleHairStyles[i][index].GetComponent<Image>().mainTexture;
                    if (i == 0)
                    {
                        hairButtons[12 + index].SetActive(true);
                    }
                    else
                    {
                        hairButtons[15 + index].SetActive(true);
                    }
                }
            }
        }
    }
    public void AssignGender(int index)
    {
        GameObject[] maleHair = { characterClothing.hair_a, characterClothing.hair_b, characterClothing.hair_e };
        GameObject[] femaleHair = { characterClothing.hair_c, characterClothing.hair_d };
        List<string> maleOptions = new List<string> { "None", "Option A", "Option B", "Option C" };
        List<string> femaleOptions = new List<string> { "None", "Option A", "Option B" };
        GameObject[][] maleHairStyles = { hairStylesA, hairStylesB, hairStylesE };
        GameObject[][] femaleHairStyles = { hairStylesC, hairStylesD };
        characterClothing.gender = index;
        hairDropdown.ClearOptions();
        for (int i = 0; i < maleHairStyles.Length; i++)
        {
            for (int j = 0; j < maleHairStyles[i].Length; j++)
            {
                maleHairStyles[i][j].SetActive(false);
            }
        }
        for (int i = 0; i < femaleHairStyles.Length; i++)
        {
            for (int j = 0; j < femaleHairStyles[i].Length; j++)
            {
                femaleHairStyles[i][j].SetActive(false);
            }
        }
        if (index == 0)
        {
            hairDropdown.AddOptions(maleOptions);
            maleButton.interactable = false;
            femaleButton.interactable = true;
            for (int i = 0; i < femaleHair.Length; i++)
            {
                if (i != hairDropdown.value - 1)
                {
                    femaleHair[i].SetActive(false);
                }
            }
            int hairIndex = Random.Range(0, maleHair.Length);
            maleHair[hairIndex].SetActive(true);
            hairDropdown.value = hairIndex + 1;
            for (int j = 0; j < maleHairStyles[hairDropdown.value - 1].Length; j++)
            {
                maleHairStyles[hairDropdown.value - 1][j].SetActive(true);
            }
        }
        else if (index == 1)
        {
            hairDropdown.AddOptions(femaleOptions);
            femaleButton.interactable = false;
            maleButton.interactable = true;
            for (int i = 0; i < maleHair.Length; i++)
            {
                if (i != hairDropdown.value - 1)
                {
                    maleHair[i].SetActive(false);
                }
            }
            int hairIndex = Random.Range(0, femaleHair.Length);
            femaleHair[hairIndex].SetActive(true);
            hairDropdown.value = hairIndex + 1;
            for (int j = 0; j < femaleHairStyles[hairDropdown.value - 1].Length; j++)
            {
                femaleHairStyles[hairDropdown.value - 1][j].SetActive(true);
            }
        }
    }
    public void AssignAge(int index)
    {
        for (int i = 0; i < ages.Length; i++)
        {
            ages[i].interactable = true;
        }
        ages[index].interactable = false;
        meoples[curSim].transform.Find("Custom simple human_prefab").gameObject.GetComponent<Animator>().SetBool("isToddler", false);
        meoples[curSim].transform.position = new Vector3(0, 0, 0);
        meoples[curSim].transform.eulerAngles = new Vector3(0, 180, 0);
        switch (index)
        {
            case 0:
                float weight = weightSlider.value; //0 = 0.8, 25 = 1.0, 50 = 1.2
                float characterScale = weight * 0.008f - 0.2f;
                meoples[curSim].transform.localScale = new Vector3(0.4f + characterScale, 0.4f, 0.4f + characterScale);
                meoples[curSim].transform.position = new Vector3(-0.88f, 0.27f, -0.85f);
                meoples[curSim].transform.eulerAngles = new Vector3(0, 90, 0);
                meoples[curSim].transform.Find("Custom simple human_prefab").gameObject.GetComponent<Animator>().SetBool("isToddler", true);
                age = 0;
                break;
            case 1:
                weight = weightSlider.value; //0 = 0.8, 25 = 1.0, 50 = 1.2
                characterScale = weight * 0.008f - 0.2f;
                meoples[curSim].transform.localScale = new Vector3(0.6f + characterScale, 0.6f, 0.6f + characterScale);
                age = 1;
                break;
            case 2:
                weight = weightSlider.value; //0 = 0.8, 25 = 1.0, 50 = 1.2
                characterScale = weight * 0.008f - 0.2f;
                meoples[curSim].transform.localScale = new Vector3(0.8f + characterScale, 0.8f, 0.8f + characterScale);
                age = 2;
                break;
            case 3:
                weight = weightSlider.value; //0 = 0.8, 25 = 1.0, 50 = 1.2
                characterScale = weight * 0.008f - 0.2f;
                meoples[curSim].transform.localScale = new Vector3(1f + characterScale, 1f, 1f + characterScale);
                age = 3;
                break;
            case 4:
                weight = weightSlider.value; //0 = 0.8, 25 = 1.0, 50 = 1.2
                characterScale = weight * 0.008f - 0.2f;
                meoples[curSim].transform.localScale = new Vector3(1f + characterScale, 1f, 1f + characterScale);
                age = 4;
                break;
        }
        characterClothing.age = age;
    }
    public void PlayGame()
    {
        SaveFamily();
        MeopleData[] meopleData = CharacterCreatorSaver.LoadFamily();
        for (int i = 0; i < meopleData.Length; i++)
        {
            GameObject createdMeople = Instantiate(meople, new Vector3(i * 5, 0, 0), Quaternion.identity);
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
            meopleStats.bottoms[botIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.bottomTextures[botIndex][botTextureIndex];
            int shoeIndex = meopleData[i].GetShoe()[0];
            int shoeTextureIndex = meopleData[i].GetShoe()[1];
            meopleStats.shoes[shoeIndex].SetActive(true);
            meopleStats.shoes[shoeIndex].GetComponent<Renderer>().materials[0].mainTexture = meopleStats.shoeTextures[shoeIndex][shoeTextureIndex];
            meopleStats.weight = meopleData[i].GetWeight();
            float ageScale;
            float characterScale = meopleStats.weight * 0.008f - 0.2f;
            if (meopleStats.age == 0)
            {
                ageScale = 0.4f;
            }
            else if (meopleStats.age == 1)
            {
                ageScale = 0.6f;
            }
            else if (meopleStats.age == 2)
            {
                ageScale = 0.8f;
            }
            else
            {
                ageScale = 1.0f;
            }
            createdMeople.transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
        }
    }
    public void DeleteMeople()
    {
        if (meoples.Count > 1)
        {
            areYouSurePanel.SetActive(true);
            areYouSureText.text = "Are you sure you want to delete this meople?";
            state = 0;
        }
        else
        {
            deleteButton.interactable = false;
            nextButton.interactable = false;
        }
    }
    public void AddMeople()
    {
        if (meoples.Count <= 7)
        {
            meoples[curSim].SetActive(false);
            nextButton.interactable = true;
            deleteButton.interactable = true;
            InitializeCharacter();
        }
        else
        {
            addButton.interactable = false;
        }
        ResetOptions();
        SetCorrectOptions();
    }
    public void NextMeople()
    {
        meoples[curSim].SetActive(false);
        if (curSim + 1 >= meoples.Count)
        {
            curSim = 0;
            meoples[curSim].SetActive(true);
            characterClothing = meoples[curSim].GetComponent<clothing>();
        }
        else
        {
            Debug.Log("next");
            meoples[++curSim].SetActive(true);
            characterClothing = meoples[curSim].GetComponent<clothing>();
        }
        ResetOptions();
        SetCorrectOptions();
    }
    public void Confirm(bool confirm)
    {
        if (confirm)
        {
            switch (state)
            {
                case 0:
                    GameObject tmpMeople = meoples[curSim];
                    meoples.Remove(meoples[curSim]);
                    Destroy(tmpMeople);
                    curSim = meoples.Count - 1;
                    meoples[curSim].SetActive(true);
                    characterClothing = meoples[curSim].GetComponent<clothing>();
                    addButton.interactable = true;
                    if (meoples.Count < 2)
                    {
                        deleteButton.interactable = false;
                        nextButton.interactable = false;
                    }
                    ResetOptions();
                    SetCorrectOptions();
                    break;
                case 1:
                    SaveFamily();
                    break;
            }
        }
        areYouSurePanel.SetActive(false);
    }
    public void NameChange()
    {
        if (manualNameChange)
        {
            characterClothing.firstName = firstName.text;
            characterClothing.lastName = lastName.text;
            print("Sim " + curSim + " name set to " + characterClothing.firstName);
        }
        manualNameChange = true;
    }
    private void ResetOptions()
    {
        maleButton.interactable = true;
        femaleButton.interactable = true;
        for (int i = 0; i < ages.Length; i++)
        {
            ages[i].interactable = true;
        }
        manualNameChange = false;
        firstName.text = string.Empty;
        manualNameChange = false;
        lastName.text = string.Empty;
        for (int i = 0; i < skinButtons.Length; i++)
        {
            skinButtons[i].SetActive(false);
        }
        for (int i = 0; i < hairButtons.Length; i++)
        {
            hairButtons[i].SetActive(false);
        }
    }
    private void SetCorrectOptions()
    {
        TMP_Dropdown[] topDropdowns = { jacketDropdown, SweaterDropdown, ShirtDropdown, TShirtDropdown, TanktopDropdown };
        TMP_Dropdown[] botDropdowns = { shortsDropdown, pantsDropdown };
        TMP_Dropdown[] shoeDropdowns = { sneakersDropdown, flippersDropdown, bootsDropdown };
        List<string> maleOptions = new List<string> { "None", "Option A", "Option B", "Option C" };
        List<string> femaleOptions = new List<string> { "None", "Option A", "Option B" };
        hairDropdown.ClearOptions();
        if (characterClothing.gender == 0)
        {
            maleButton.interactable = false;
            hairDropdown.AddOptions(maleOptions);
        }
        else
        {
            femaleButton.interactable = false;
            hairDropdown.AddOptions(femaleOptions);
        }
        for (int i = 0; i < ages.Length; i++)
        {
            if (characterClothing.age == i)
            {
                ages[i].interactable = false;
            }
        }
        manualNameChange = false;
        firstName.text = characterClothing.firstName;
        manualNameChange = false;
        lastName.text = characterClothing.lastName;
        for (int i = 0; i < characterClothing.hairStyles.Length; i++)
        {
            if (characterClothing.hairStyles[i].activeSelf)
            {
                for (int j = 0; j < characterClothing.hairTextures[i].Length; j++)
                {
                    if (characterClothing.hairStyles[i].GetComponent<Renderer>().materials[0].mainTexture == characterClothing.hairTextures[i][j])
                    {
                        hairButtons[i].SetActive(true);
                        hairDropdown.value = i + 1;
                    }
                }
            }
        }
        for (int i = 0; i < characterClothing.skin_textures.Length; i++)
        {
            if (characterClothing.skinColor == characterClothing.skin_textures[i])
            {
                skinButtons[i].SetActive(true);
            }
        }
        for (int i = 0; i < characterClothing.tops.Length; i++)
        {
            if (characterClothing.tops[i].activeSelf)
            {
                for (int j = 0; j < characterClothing.topTextures[i].Length; j++)
                {
                    if (characterClothing.tops[i].GetComponent<Renderer>().materials[0].mainTexture == characterClothing.topTextures[i][j])
                    {
                        topDropdowns[i].value = j + 1;
                    }
                }
            }
        }
        for (int i = 0; i < characterClothing.bottoms.Length; i++)
        {
            if (characterClothing.bottoms[i].activeSelf)
            {
                for (int j = 0; j < characterClothing.bottomTextures[i].Length; j++)
                {
                    if (characterClothing.bottoms[i].GetComponent<Renderer>().materials[0].mainTexture == characterClothing.bottomTextures[i][j])
                    {
                        botDropdowns[i].value = j + 1;
                    }
                }
            }
        }
        for (int i = 0; i < characterClothing.shoes.Length; i++)
        {
            if (characterClothing.shoes[i].activeSelf)
            {
                for (int j = 0; j < characterClothing.shoeTextures[i].Length; j++)
                {
                    if (characterClothing.shoes[i].GetComponent<Renderer>().materials[0].mainTexture == characterClothing.shoeTextures[i][j])
                    {
                        shoeDropdowns[i].value = j + 1;
                    }
                }
            }
        }
        weightSlider.value = characterClothing.weight;
        float characterScale = characterClothing.weight * 0.008f - 0.2f;
        float ageScale;
        if (characterClothing.age == 0)
        {
            ageScale = 0.4f;
            meoples[curSim].transform.Find("Custom simple human_prefab").gameObject.GetComponent<Animator>().SetBool("isToddler", true);
        }
        else if (characterClothing.age == 1)
        {
            ageScale = 0.6f;
        }
        else if (characterClothing.age == 2)
        {
            ageScale = 0.8f;
        }
        else
        {
            ageScale = 1.0f;
        }
        meoples[curSim].transform.localScale = new Vector3(ageScale + characterScale, ageScale, ageScale + characterScale);
        loadingCharacterPersonality = true;
        opennessSlider.value = characterClothing.openness;
        agreeablenessSlider.value = characterClothing.agreeableness;
        conscientiousnessSlider.value = characterClothing.conscientiousness;
        extraversionSlider.value = characterClothing.extraversion;
        neuroticismSlider.value = characterClothing.neuroticism;
        loadingCharacterPersonality = false;
    }
    private void SaveFamily()
    {
        CharacterCreatorSaver.SaveFamily(meoples);
    }
    private void GenerateCharacter()
    {
        characterClothing.GenerateRandomCharacter(jacketDropdown, ShirtDropdown, TShirtDropdown, SweaterDropdown, TanktopDropdown,
        shortsDropdown, pantsDropdown, sneakersDropdown, flippersDropdown, bootsDropdown, hairDropdown, skinButtons, maleButton,
        femaleButton, opennessSlider, agreeablenessSlider, conscientiousnessSlider, extraversionSlider, neuroticismSlider);
    }
}
