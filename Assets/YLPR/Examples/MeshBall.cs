using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

[ExecuteInEditMode]
public class MeshBall : MonoBehaviour
{
    private static int baseColorId = Shader.PropertyToID("_BaseColor");

    [SerializeField] private Mesh mesh = default;

    [SerializeField] private Material material = default;
    
    Matrix4x4[] matrices = new Matrix4x4[1023];
    Vector4[] baseColors = new Vector4[1023];

    private MaterialPropertyBlock block;

    private void Awake()
    {
        for (int j = 0; j < matrices.Length; j++)
        {
            matrices[j] = Matrix4x4.TRS(Random.insideUnitSphere*10f,Quaternion.Euler(Random.value*360f, Random.value * 360f, Random.value * 360f),Vector3.one*Random.Range(0.5f,1.5f));
            baseColors[j] = new Vector4(Random.value,Random.value,Random.value,Random.Range(0.5f,1f));
            
        }
    }

    void Update()
    {
        if (block == null)
        {
            block = new MaterialPropertyBlock();
            block.SetVectorArray(baseColorId,baseColors);
        }
        Graphics.DrawMeshInstanced(mesh,0,material,matrices,1023,block);
    }
}
