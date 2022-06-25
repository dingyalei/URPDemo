#ifndef YLPR_BRDF_INCLUDE
#define YLPR_BRDF_INCLUDE

#define MIN_REFLECTIVITY 0.04
struct BRDF
{
    float3 diffuse;
    float3 specular;
    float3 roughness;
};

float OneMinusReflectivity (float metallic)
{
    float range = 1.0 - MIN_REFLECTIVITY;
    return range - metallic * range;
}

BRDF GetBRDF(Surface surface)
{
    BRDF brdf;
    
    float oneMinusReflectivity = 1.0f - surface.metallic;
    brdf.diffuse = surface.color * oneMinusReflectivity;
    brdf.specular = lerp(MIN_REFLECTIVITY,surface.color,surface.metallic);
    float perceptualRou = PerceptualRoughnessToRoughness(surface.smoothness);
    brdf.roughness = PerceptualRoughnessToRoughness(perceptualRou);
    return brdf;
}

#endif