using System.Collections;
using System.Collections.Generic;
using UnityEditor.PackageManager.UI;
using UnityEngine;
using UnityEngine.Rendering;

public class Shadows
{
    const int maxShadowedDirectionalLightCount = 4;
    private const int maxCascades = 4;
    static int dirShadowAtlasId = Shader.PropertyToID("_DirectionalShadowAtlas");
    static int dirShadowMatricesId = Shader.PropertyToID("_DirectionalShadowMatrices");
    private static int cascadeCountId = Shader.PropertyToID("_CascadeCount");
    private static int cascadeCullingSpheresId = Shader.PropertyToID("_CascadeCullingSpheres");
    private static int shadowDistanceId = Shader.PropertyToID("_ShadowDistance");
    private static int shadowDistanceFadeId = Shader.PropertyToID("_ShadowDistanceFade");
    private static int cascadeDataId = Shader.PropertyToID("_CascadeData");
    static int shadowAtlasSizeId = Shader.PropertyToID("_ShadowAtlasSize");

    static string[] shadowMaskKeywords =
    {
        "_SHADOW_MASK_DISTANCE"
    };

    private static string[] directionalFilterKeywords =
    {
        "_DIRECTIONAL_PCF3",
        "_DIRECTIONAL_PCF5",
        "_DIRECTIONAL_PCF7",
    };
    
    static string[] cascadeBlendKeywords = {"_CASCADE_BLEND_SOFT","_CASCADE_BLEND_DITHER"};
    

    static Vector4[] cascadeData = new Vector4[maxCascades];
    static Vector4[] cascadeCullingSpheres = new Vector4[maxCascades];


    static Matrix4x4[] dirShadowMatrices = new Matrix4x4[maxShadowedDirectionalLightCount * maxCascades];


    struct ShadowedDirectionalLight
    {
        public int visibleLightIndex;
        public float slopScaleBias;
        public float nearPlaneOffset;
    }

    ShadowedDirectionalLight[] ShadowedDirectionalLights = new ShadowedDirectionalLight[maxShadowedDirectionalLightCount];
    int ShadowedDirectionalLightCount;
    private const string bufferName = "Shadow";

    private CommandBuffer buffer = new CommandBuffer()
    {
        name = bufferName
    };

    private ScriptableRenderContext context;
    private CullingResults cullResults;
    private ShadowSettings shadowSetting;
    bool useShadowMask;
    public void Setup(ScriptableRenderContext context, CullingResults results, ShadowSettings shadowSetting)
    {
        this.context = context;
        this.cullResults = results;
        this.shadowSetting = shadowSetting;
        ShadowedDirectionalLightCount = 0;
        useShadowMask = false;
    }

    public Vector3 ReserveDirectionalShadows(Light light, int visibleLightIndex)
    {
        if (ShadowedDirectionalLightCount < maxShadowedDirectionalLightCount && light.shadows != LightShadows.None && light.shadowStrength > 0f
            && cullResults.GetShadowCasterBounds(visibleLightIndex, out Bounds b))
        {
            ShadowedDirectionalLights[ShadowedDirectionalLightCount] = new ShadowedDirectionalLight()
                {visibleLightIndex = visibleLightIndex, slopScaleBias = light.shadowBias, nearPlaneOffset = light.shadowNearPlane};
            return new Vector3(light.shadowStrength, shadowSetting.directional.cascadeCount * ShadowedDirectionalLightCount++, light.shadowNormalBias);
        }

        return Vector3.zero;
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    public void Render()
    {
        if (ShadowedDirectionalLightCount > 0)
        {
            RenderDirectionalShadows();
        }
        buffer.BeginSample(bufferName);
        SetKeywords(shadowMaskKeywords,useShadowMask?0:-1);
        buffer.EndSample(bufferName);
        ExecuteBuffer();
    }

    private void RenderDirectionalShadows()
    {
        int atlasSize = (int) shadowSetting.directional.atlasSize;
        buffer.GetTemporaryRT(dirShadowAtlasId, atlasSize, atlasSize, 32, FilterMode.Bilinear, RenderTextureFormat.Shadowmap);
        buffer.SetRenderTarget(dirShadowAtlasId, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
        buffer.ClearRenderTarget(true, false, Color.clear);

        buffer.BeginSample(bufferName);
        ExecuteBuffer();
        int tiles = ShadowedDirectionalLightCount * shadowSetting.directional.cascadeCount;
        int split = tiles <= 1 ? 1 : tiles <= 4 ? 2 : 4;
        int tileSize = atlasSize / split;

        for (int i = 0; i < ShadowedDirectionalLightCount; i++)
        {
            RenderDirectionalShadows(i, split, tileSize);
        }

        float f = 1f - shadowSetting.directional.cascadeFade;
        
        buffer.SetGlobalInt(cascadeCountId, shadowSetting.directional.cascadeCount);
        buffer.SetGlobalVectorArray(cascadeCullingSpheresId, cascadeCullingSpheres);
        buffer.SetGlobalVectorArray(cascadeDataId, cascadeData);
        buffer.SetGlobalMatrixArray(dirShadowMatricesId, dirShadowMatrices);
        buffer.SetGlobalFloat(shadowDistanceId, shadowSetting.maxDistance);
        buffer.SetGlobalVector(shadowDistanceFadeId, new Vector4(1f / shadowSetting.maxDistance, 1f / shadowSetting.distanceFade, 1f / (1f - f * f)));
        SetKeywords(directionalFilterKeywords, (int)shadowSetting.directional.filter - 1);
        SetKeywords(cascadeBlendKeywords, (int)shadowSetting.directional.cascadeBlend - 1);
        buffer.SetGlobalVector(shadowAtlasSizeId,new Vector4(atlasSize,1f/atlasSize));
        buffer.EndSample(bufferName);
        ExecuteBuffer();
    }

    void SetCascadeData(int index, Vector4 cullingSphere, float tileSize)
    {
        float texelSize = 2f * cullingSphere.w / tileSize;
        // 缩小采样范围，边界
        float filterSize = texelSize * ((float)shadowSetting.directional.filter + 1f);
        cullingSphere.w -= filterSize;
        cullingSphere.w *= cullingSphere.w;
        cascadeData[index] = new Vector4(1f / cullingSphere.w, filterSize * 1.4142136f);
        cascadeCullingSpheres[index] = cullingSphere;
    }

    private void RenderDirectionalShadows(int index, int split, int tileSize)
    {
        ShadowedDirectionalLight light = ShadowedDirectionalLights[index];
        var shadowSetting = new ShadowDrawingSettings(cullResults, light.visibleLightIndex);

        int cascadeCount = this.shadowSetting.directional.cascadeCount;
        int tileOffset = index * cascadeCount;
        Vector3 ratios = this.shadowSetting.directional.CacadeRatios;
        float cullingFactor = Mathf.Max(0f, 0.8f - this.shadowSetting.directional.cascadeFade);
        for (int i = 0; i < cascadeCount; i++)
        {
            cullResults.ComputeDirectionalShadowMatricesAndCullingPrimitives(light.visibleLightIndex, i, cascadeCount, ratios, tileSize, light.nearPlaneOffset,
                out Matrix4x4 viewMatrix, out Matrix4x4 projectionMatrix, out ShadowSplitData splitData);
            splitData.shadowCascadeBlendCullingFactor = cullingFactor;
            if (index == 0)
            {
                SetCascadeData(i, splitData.cullingSphere, tileSize);
            }

            int tileIndex = tileOffset + i;
            dirShadowMatrices[tileIndex] = ConvertToAtlasMatrix(projectionMatrix * viewMatrix,
                SetTileViewport(tileIndex, split, tileSize), split);
            buffer.SetViewProjectionMatrices(viewMatrix, projectionMatrix);
            buffer.SetGlobalDepthBias(0f, light.slopScaleBias);
            ExecuteBuffer();
            context.DrawShadows(ref shadowSetting);
            buffer.SetGlobalDepthBias(0f, 0f);
        }
    }

    void SetKeywords(string[] keywords, int enabledIndex)
    {
        for (int i = 0; i < keywords.Length; i++)
        {
            if (i == enabledIndex)
            {
                buffer.EnableShaderKeyword(keywords[i]);
            }
            else
            {
                buffer.DisableShaderKeyword(keywords[i]);
            }
        }
        // for (int i = 0; i < directionalFilterKeywords.Length; i++)
        // {
        //     if (i == enabledIndex)
        //     {
        //         buffer.EnableShaderKeyword(directionalFilterKeywords[i]);
        //     }
        //     else
        //     {
        //         buffer.DisableShaderKeyword(directionalFilterKeywords[i]);
        //     }
        // }
    }

    Vector2 SetTileViewport(int index, int split, float tileSize)
    {
        Vector2 offset = new Vector2(index % split, index / split);
        buffer.SetViewport(new Rect(offset.x * tileSize, offset.y * tileSize, tileSize, tileSize));
        return offset;
    }

    public void Cleanup()
    {
        buffer.ReleaseTemporaryRT(dirShadowAtlasId);
        ExecuteBuffer();
    }

    //返回一个从世界空间到阴影图块空间的转换矩阵
    Matrix4x4 ConvertToAtlasMatrix(Matrix4x4 m, Vector2 offset, int split)
    {
        //如果使用了反向Zbuffer
        if (SystemInfo.usesReversedZBuffer)
        {
            m.m20 = -m.m20;
            m.m21 = -m.m21;
            m.m22 = -m.m22;
            m.m23 = -m.m23;
        }

        //设置矩阵坐标
        float scale = 1f / split;
        m.m00 = (0.5f * (m.m00 + m.m30) + offset.x * m.m30) * scale;
        m.m01 = (0.5f * (m.m01 + m.m31) + offset.x * m.m31) * scale;
        m.m02 = (0.5f * (m.m02 + m.m32) + offset.x * m.m32) * scale;
        m.m03 = (0.5f * (m.m03 + m.m33) + offset.x * m.m33) * scale;
        m.m10 = (0.5f * (m.m10 + m.m30) + offset.y * m.m30) * scale;
        m.m11 = (0.5f * (m.m11 + m.m31) + offset.y * m.m31) * scale;
        m.m12 = (0.5f * (m.m12 + m.m32) + offset.y * m.m32) * scale;
        m.m13 = (0.5f * (m.m13 + m.m33) + offset.y * m.m33) * scale;
        m.m20 = 0.5f * (m.m20 + m.m30);
        m.m21 = 0.5f * (m.m21 + m.m31);
        m.m22 = 0.5f * (m.m22 + m.m32);
        m.m23 = 0.5f * (m.m23 + m.m33);
        return m;
    }
}