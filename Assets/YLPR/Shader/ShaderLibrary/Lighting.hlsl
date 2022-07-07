#ifndef YLPR_LIGHTING_INCLUDE
#define YLPR_LIGHTING_INCLUDE


float3 IncomingLight(Surface surface, Light light)
{
    //return light.attenuation;
    return saturate(dot(surface.normal, light.direction) * light.attenuation) * light.color;
}

float3 GetLighting(Surface surface, BRDF brdf, Light light)
{
    //return IncomingLight(surface, light);
    return IncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
}

float3 GetLighting(Surface surface, BRDF brdf)
{
    float3 color = float3(0, 0, 0);
    ShadowData data = GetShadowData(surface);
    for (int i = 0; i < GetDirectionLightCount(); i++)
    {
        Light light = GetDirectionalLight(i, surface, data);
        color += GetLighting(surface, brdf, light);
    }
    return color;
}

#endif
