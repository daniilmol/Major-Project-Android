using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class NeedBar : MonoBehaviour
{
    [SerializeField] Slider slider;
    [SerializeField] Gradient gradient;
    [SerializeField] Image fill;
    public Color SetValue(float value){
        slider.value = value;
        fill.color = gradient.Evaluate(slider.normalizedValue);
        return fill.color;
    }
}
