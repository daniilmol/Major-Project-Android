using UnityEngine.UI;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections.Generic;

public class GameMaster : MonoBehaviour
{
    public static GameMaster gameMaster;
    public static Meople selectedMeople = null;
    public static Meople[] family;
    private GameObject indicator;
    private List<GameObject> meopleButtons = new List<GameObject>();
    private static List<GameObject> actionQueueButtons;
    private static List<List<GameObject>> buttonQueuesList = new List<List<GameObject>>();
    private int currentlySelectedMeople = 0;
    private static GameObject b;
    private static Image c;
    private Button[] speedButtons;
    [SerializeField] GameObject button;
    [SerializeField] GameObject sphere;
    [SerializeField] Image switchPanel;
    [SerializeField] Image queuePanel;
    [SerializeField] NeedBar[] needBars;
    [SerializeField] Material indicatorColor;
    void Awake(){
        Time.timeScale = 1;
        if(gameMaster == null){
            gameMaster = this;
            DontDestroyOnLoad(gameObject);
        }else{
            Destroy(gameObject);
        }
        b = button;
        c = queuePanel;
        speedButtons = new Button[3];
        speedButtons[0] = GameObject.Find("x1Speed").GetComponent<Button>();
        speedButtons[1] = GameObject.Find("x3Speed").GetComponent<Button>();
        speedButtons[2] = GameObject.Find("x5Speed").GetComponent<Button>();
    }
    void Start(){
        CreateMeopleSwitchButtons();
        CreateCurrentMeopleIndicator();
    }
    void Update(){
        if(selectedMeople != null){
            indicator.transform.position = new Vector3(selectedMeople.transform.position.x, selectedMeople.transform.position.y + 3, selectedMeople.transform.position.z);
        }
        UpdateNeedBarValues();
    }
    private void UpdateNeedBarValues(){
        Color[] needColors = new Color[6];
        for(int i = 0; i < needBars.Length; i++){
            needColors[i] = needBars[i].SetValue(selectedMeople.GetNeeds()[i]);
        }
        float totalR = 0f;
        float totalG = 0f;
        float totalB = 0f;
        foreach (Color color in needColors){
            totalR += color.r;
            totalG += color.g;
            totalB += color.b;
        }
        float averageR = totalR / needColors.Length;
        float averageG = totalG / needColors.Length;
        float averageB = totalB / needColors.Length;
        indicatorColor.color = new Color(averageR, averageG, averageB);
    }
    public static void DequeueActionQueueButtons(int index, Meople meople){
        for(int i = 0; i < family.Length; i++){
            if(meople == family[i] && buttonQueuesList[i].Count > 0){
                Destroy(buttonQueuesList[i][index]);
                buttonQueuesList[i].RemoveAt(index);
                RepositionQueueButtons(i);
                break;
            }
        }
    }
    public static void RepositionQueueButtons(int index){
        for(int i = 0; i < buttonQueuesList[index].Count; i++){
            float yPosition = -i * 50;
            buttonQueuesList[index][i].GetComponent<RectTransform>().anchoredPosition = new Vector2(50, yPosition);
            buttonQueuesList[index][i].GetComponent<Button>().onClick.RemoveAllListeners();
            int indexX = i;
            buttonQueuesList[index][i].GetComponent<Button>().onClick.AddListener(delegate { DequeueFromActionList(indexX); }); 
        }
    }
    public static void RenameConversation(Meople a, Meople b, string ax, string bx){
        int x = -1;
        int y = -1;
        for(int i = 0; i < family.Length; i++){
            if(a == family[i]){
                x = i;
            }if(b == family[i]){
                y = i;
            }
        }
        if(buttonQueuesList[x].Count > 0 && a.FindRepleneshingNeed() == 5){
            buttonQueuesList[x][0].GetComponent<Button>().GetComponentInChildren<TextMeshProUGUI>().text = ax;
            buttonQueuesList[y][0].GetComponent<Button>().GetComponentInChildren<TextMeshProUGUI>().text = bx;
        }
    }
    public static void CreateActionQueueButton(MeopleAction meopleAction, Meople meople){
        GameObject queueButton = Instantiate(b, c.transform);
        int x = -1;
        for(int i = 0; i < family.Length; i++){
            if(meople == family[i]){
                x = i;
            }
        }
        TextMeshProUGUI queueIndicator = queueButton.GetComponentInChildren<TextMeshProUGUI>();
        if(meopleAction.GetFurniture() != null){
            queueIndicator.SetText(meopleAction.GetFurniture().GetInteractions()[meopleAction.GetIndex()].GetName());
        }else{
            queueIndicator.SetText("Start Conversation");
        }
        float yPosition = 0;
        yPosition = -buttonQueuesList[x].Count * 50;
        queueButton.GetComponent<RectTransform>().anchoredPosition = new Vector2(50, yPosition);
        queueButton.GetComponent<RectTransform>().sizeDelta = new Vector2(250, 50);
        int buttonIndex = -1;
        for(int i = 0; i < family.Length; i++){
            if(meople == family[i]){
                buttonIndex = buttonQueuesList[i].Count;
                buttonQueuesList[i].Add(queueButton);
                if(meople != selectedMeople){
                    buttonQueuesList[i][buttonQueuesList[i].Count - 1].SetActive(false);
                }
            }
        }
        queueButton.GetComponent<Button>().onClick.AddListener(delegate { DequeueFromActionList(buttonIndex); }); 
    }
    private void ChangeActionQueueButtons(int index){
        for(int i = 0; i < buttonQueuesList.Count; i++){
            if(i != index){
                for(int j = 0; j < buttonQueuesList[i].Count; j++){
                    buttonQueuesList[i][j].SetActive(false);
                }
                continue;
            }
            for(int j = 0; j < buttonQueuesList[i].Count; j++){
                buttonQueuesList[i][j].SetActive(true);
            }
        }
    }
    public static void DequeueFromActionList(int x) {
        selectedMeople.DequeueAt(x);
    }
    public void ChangeTime(int speed){
        Time.timeScale = speed;
        if(speed == 1){
            speedButtons[0].interactable = false;
            speedButtons[1].interactable = true;
            speedButtons[2].interactable = true;
        }if(speed == 5){
            speedButtons[0].interactable = true;
            speedButtons[1].interactable = false;
            speedButtons[2].interactable = true;
        }if(speed == 10){
            speedButtons[0].interactable = true;
            speedButtons[1].interactable = true;
            speedButtons[2].interactable = false;
        }
    }
    private void CreateCurrentMeopleIndicator(){
        indicator = Instantiate(sphere, new Vector3(selectedMeople.transform.position.x, selectedMeople.transform.position.y + 3, selectedMeople.transform.position.z), Quaternion.identity);
    }
    private void CreateMeopleSwitchButtons(){
        for(int i = 0; i < family.Length; i++){
            GameObject meopleButton = Instantiate(button, switchPanel.transform);
            TextMeshProUGUI queueIndicator = meopleButton.GetComponentInChildren<TextMeshProUGUI>();
            queueIndicator.SetText(""+i);
            float yPosition = 0;
            yPosition = i * 50 - 330;
            meopleButton.GetComponent<RectTransform>().anchoredPosition = new Vector2(0, yPosition);
            meopleButton.GetComponent<RectTransform>().sizeDelta = new Vector2(50, 50);
            int familyIndex = i;
            meopleButton.GetComponent<Button>().onClick.AddListener(delegate { SelectMeople(familyIndex); }); 
            meopleButtons.Add(meopleButton);
            actionQueueButtons = new List<GameObject>();
            buttonQueuesList.Add(actionQueueButtons);
        }
        meopleButtons[0].GetComponent<Button>().interactable = false;
    }
    private void SelectMeople(int familyIndex){
        selectedMeople = family[familyIndex];
        for(int i = 0; i < meopleButtons.Count; i++){
            if(i == familyIndex){
                meopleButtons[i].GetComponent<Button>().interactable = false;
                continue;
            }
            meopleButtons[i].GetComponent<Button>().interactable = true;
        }
        ChangeActionQueueButtons(familyIndex);
    }
}
