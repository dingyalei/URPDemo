using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/YLRenderPipeline")]
public class YLRenderPiplineAsset : RenderPipelineAsset
{
    [SerializeField]
    bool useDynamicBatching = true, useGPUInstancing = true, useSRPBatcher = true;
    [SerializeField] ShadowSettings shadows = default;
    protected override RenderPipeline CreatePipeline()
    {
        return new YLRenderPipeline(useDynamicBatching,useGPUInstancing,useSRPBatcher,shadows);
    }
}
