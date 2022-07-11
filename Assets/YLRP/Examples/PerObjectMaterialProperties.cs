using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public class PerObjectMaterialProperties : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");
    static int cutoffId =Shader.PropertyToID("_Cutoff");

    private static int matellicId = Shader.PropertyToID("_Metallic");
    private static int smoothId = Shader.PropertyToID("_Smoothness");
    static int emissionColorId = Shader.PropertyToID("_EmissionColor");
    
    [SerializeField, ColorUsage(false, true)]
    Color emissionColor = Color.black;
    [SerializeField] Color baseColor = Color.white;
    [SerializeField] float cutoff = 0.5f;
    [SerializeField] public float metallic = 0;
    [SerializeField] public float smoothness = 1;
    
    static MaterialPropertyBlock block;

    private void OnValidate()
    {
        if (block == null)
        {
            block = new MaterialPropertyBlock();;
        }

        block.SetColor(baseColorId, baseColor);
        block.SetFloat(cutoffId,cutoff);
        block.SetFloat(matellicId,metallic);
        block.SetFloat(smoothId,smoothness);
        block.SetColor(emissionColorId, emissionColor);
        GetComponent<Renderer>().SetPropertyBlock(block);
    }

    private void Awake()
    {
        OnValidate();
    }
}
