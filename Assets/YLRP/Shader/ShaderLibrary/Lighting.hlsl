#ifndef YLRP_LIGHTING_INCLUDE
#define YLRP_LIGHTING_INCLUDE


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

float3 GetLighting(Surface surface, BRDF brdf,GI gi)
{
    // float3 color = gi.diffuse;
    ShadowData data = GetShadowData(surface);
    float3 color = gi.diffuse * brdf.diffuse;
    for (int i = 0; i < GetDirectionLightCount(); i++)
    {
        Light light = GetDirectionalLight(i, surface, data);
        color += GetLighting(surface, brdf, light);
    }
    return color;
}

#endif
