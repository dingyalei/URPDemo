using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Shadows
{
    const int maxShadowedDirectionalLightCount = 1;
    static int dirShadowAtlasId = Shader.PropertyToID("_DirectionalShadowAtlas");
    struct ShadowedDirectionalLight
    {
        public int visibleLightIndex;
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

    public void Setup(ScriptableRenderContext context, CullingResults results, ShadowSettings shadowSetting)
    {
        this.context = context;
        this.cullResults = results;
        this.shadowSetting = shadowSetting;
        ShadowedDirectionalLightCount = 0;
    }

    public void ReserveDirectionalShadows(Light light, int visibleLightIndex)
    {
        if (ShadowedDirectionalLightCount < maxShadowedDirectionalLightCount && light.shadows != LightShadows.None && light.shadowStrength > 0f
        && cullResults.GetShadowCasterBounds(visibleLightIndex,out Bounds b))
        {
            ShadowedDirectionalLights[ShadowedDirectionalLightCount++] = new ShadowedDirectionalLight(){visibleLightIndex = visibleLightIndex};
        }
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
    }

    private void RenderDirectionalShadows()
    {
        int atlasSize = (int) shadowSetting.directional.atlasSize;
        buffer.GetTemporaryRT(dirShadowAtlasId,atlasSize,atlasSize,32,FilterMode.Bilinear,RenderTextureFormat.Shadowmap);
        buffer.SetRenderTarget(dirShadowAtlasId,RenderBufferLoadAction.DontCare,RenderBufferStoreAction.Store);
        buffer.ClearRenderTarget(true,false,Color.clear);
       
        buffer.BeginSample(bufferName);
        ExecuteBuffer();
        for (int i = 0; i < ShadowedDirectionalLightCount; i++)
        {
            RenderDirectionalShadows(i,atlasSize);
        }
        buffer.EndSample(bufferName);
        ExecuteBuffer();
    }

    private void RenderDirectionalShadows(int index, int tileSize)
    {
        ShadowedDirectionalLight light = ShadowedDirectionalLights[index];
        var shadowSetting = new ShadowDrawingSettings(cullResults,light.visibleLightIndex);
        cullResults.ComputeDirectionalShadowMatricesAndCullingPrimitives(light.visibleLightIndex, 0, 1, Vector3.zero,
            tileSize, 0f, out Matrix4x4 viewMatrix, out Matrix4x4 projectionMatrix, out ShadowSplitData splitData
        );
        shadowSetting.splitData = splitData;
        buffer.SetViewProjectionMatrices(viewMatrix,projectionMatrix);
        ExecuteBuffer();
        context.DrawShadows(ref shadowSetting);
    }

    public void Cleanup()
    {
        buffer.ReleaseTemporaryRT(dirShadowAtlasId);
        ExecuteBuffer();
    }
}