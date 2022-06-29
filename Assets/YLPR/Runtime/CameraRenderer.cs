using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public partial class CameraRenderer
{
    private const string bufferName = "YLCamera";
    static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
    static ShaderTagId litShaderTagId = new ShaderTagId("YLLit");


    Lighting lighting = new Lighting();

    private CommandBuffer buffer = new CommandBuffer
    {
        name = bufferName
    };


    ScriptableRenderContext context;

    Camera camera;

    // 剔除
    CullingResults cullingResults;

    public void Render(ScriptableRenderContext contex, Camera camera, bool useDynamicBatching, bool useGPUInstancing,ShadowSettings shadowSettings)
    {
        this.context = contex;
        this.camera = camera;
        PrepareBuffer();
        PrepareForSceneWindow();

        if (!Cull(shadowSettings.maxDistance))
        {
            return;
        }

        buffer.BeginSample(SampleName);
        ExecuteBuffer();
        lighting.Setup(contex, cullingResults,shadowSettings);
        buffer.EndSample(SampleName);
        Setup();
        DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);
        DrawUnsupportedShaders();
        DrawGizmos();
        lighting.Cleanup();
        Submit();
    }


    bool Cull(float maxShadowDistance)
    {
        ScriptableCullingParameters p;
        if (camera.TryGetCullingParameters(out p))
        {
            p.shadowDistance = Mathf.Min(maxShadowDistance, camera.farClipPlane);
            cullingResults = context.Cull(ref p);
            return true;
        }

        return false;
    }

    void Setup()
    {
        context.SetupCameraProperties(camera);
        CameraClearFlags flags = camera.clearFlags;
        buffer.ClearRenderTarget(
            flags <= CameraClearFlags.Depth,
            flags == CameraClearFlags.Color,
            flags == CameraClearFlags.Color ? camera.backgroundColor.linear : Color.clear
        );
        buffer.BeginSample(SampleName);
        ExecuteBuffer();
    }

    void Submit()
    {
        buffer.EndSample(SampleName);
        ExecuteBuffer();
        
        context.Submit();
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    private void DrawVisibleGeometry(bool useDynamicBatching, bool useGPUInstancing)
    {
        var sortSetting = new SortingSettings(camera)
        {
            criteria = SortingCriteria.CommonOpaque
        };

        // 设置渲染shader pass & 排序模式
        var drawingSetting = new DrawingSettings(unlitShaderTagId, sortSetting)
        {
            enableInstancing = useGPUInstancing,
            enableDynamicBatching = useDynamicBatching
        };
        drawingSetting.SetShaderPassName(1, litShaderTagId);
        // 设置 可以被绘制的类型
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);

        context.DrawRenderers(cullingResults, ref drawingSetting, ref filteringSettings);
        context.DrawSkybox(camera);

        // 渲染透明物体
        sortSetting.criteria = SortingCriteria.CommonTransparent;
        drawingSetting.sortingSettings = sortSetting;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        context.DrawRenderers(cullingResults, ref drawingSetting, ref filteringSettings);
    }
}