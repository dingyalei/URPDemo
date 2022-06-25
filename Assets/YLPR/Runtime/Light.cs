using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    const string bufferName = "Lighting";
    private CommandBuffer buffer = new CommandBuffer()
    {
        name = bufferName
    };
    const int maxDirLightCount = 4;
    
    CullingResults cullingResults;
    
    // static int dirLightColorId = Shader.PropertyToID("_DirectionalLightColor");
    // static int directDirectionId = Shader.PropertyToID("_DirectionalLigthDirection");
    static int dirLightCountId = Shader.PropertyToID("_DirectionalLightCount");
    static int dirLightColorsId = Shader.PropertyToID("_DirectionalLightColors");
    static int dirLightDirectionsId = Shader.PropertyToID("_DirectionalLightDirections");
    
    //存储可见光的颜色和方向
    static Vector4[] dirLightColors = new Vector4[maxDirLightCount];
    static Vector4[] dirLightDirections = new Vector4[maxDirLightCount];
    public void Setup(ScriptableRenderContext contex,CullingResults cullingResults)
    {
        this.cullingResults = cullingResults;
        buffer.BeginSample(bufferName);
        SetupLights();
        buffer.EndSample(bufferName);
        contex.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    void SetupDirectionLight(int index,VisibleLight visibleLight)
    {
        dirLightColors[index] = visibleLight.finalColor;
        dirLightDirections[index] = -visibleLight.localToWorldMatrix.GetColumn(2);
    }

    void SetupLights()
    {
        NativeArray<VisibleLight> visibleLights = cullingResults.visibleLights;
        int index = 0;
        for (int i = 0; i < visibleLights.Length; i++)
        {
            var light = visibleLights[i];
            if (light.lightType == LightType.Directional)
            {
                SetupDirectionLight(index++, light);
            }

            if (index > maxDirLightCount)
            {
                break;
            }
        }
        buffer.SetGlobalInt(dirLightCountId,dirLightCountId);
        buffer.SetGlobalVectorArray(dirLightColorsId,dirLightColors);
        buffer.SetGlobalVectorArray(dirLightDirectionsId,dirLightDirections);
    }
}
