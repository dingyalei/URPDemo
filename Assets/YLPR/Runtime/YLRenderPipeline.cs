using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class YLRenderPipeline : RenderPipeline
{
    CameraRenderer renderer = new CameraRenderer();
    bool useDynamicBatching, useGPUInstancing;

    public YLRenderPipeline(bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatcher)
    {
        this.useDynamicBatching = useDynamicBatching;
        this.useGPUInstancing = useGPUInstancing;
        GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;
        // gamma -> liner
        GraphicsSettings.lightsUseLinearIntensity = true;
    }


    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach (var camera in cameras)
        {
            renderer.Render(context, camera, useDynamicBatching, useGPUInstancing);
        }


        #region No use

        // Camera camera = cameras[0];
        // if (camera != null)
        // {
        //     context.SetupCameraProperties(camera);
        //     CommandBuffer cmd = new CommandBuffer();
        //     cmd.name = "YLRenderPipeline";
        //     
        //     cmd.ClearRenderTarget(true,true,Color.white);
        //     context.ExecuteCommandBuffer(cmd);
        //
        //     camera.TryGetCullingParameters(out var cullingParameters);
        //     var cullingResult = context.Cull(ref cullingParameters);
        //     
        //     ShaderTagId shaderTagId = new ShaderTagId("YLBase");
        //     SortingSettings sortingSettings = new SortingSettings(camera);
        //     DrawingSettings drawingSettings = new DrawingSettings(shaderTagId,sortingSettings);
        //     FilteringSettings filteringSettings = FilteringSettings.defaultValue;
        //     
        //     context.DrawRenderers(cullingResult,ref drawingSettings,ref filteringSettings);
        //     
        //     context.DrawSkybox(camera);
        //     if (Handles.ShouldRenderGizmos())
        //     {
        //         context.DrawGizmos(camera,GizmoSubset.PreImageEffects);
        //         context.DrawGizmos(camera,GizmoSubset.PostImageEffects);
        //     }
        //     context.Submit();
        // }

        #endregion
    }
}