#ifndef YLRP_COMMON_LIGHTING_INCLUDE
#define YLRP_COMMON_LIGHTING_INCLUDE
#include "LightModelInput.hlsl"

half3 GetDirectionLightLambert(int maxDirectLightCount, half3 viewDir, half3 normalDir, half4 _DirectionalLightDirections[4], half4 _DirectionalLightColors[4])
{
    half3 resColor = 0;
    for (int i = 0; i < maxDirectLightCount; i++)
    {
        half lambert = saturate(dot(normalize(normalDir), normalize(_DirectionalLightDirections[i].xyz)));
        resColor += _DirectionalLightColors[i].rgb * lambert;
    }
    return resColor;
}


half3 GetDirectLightHalfLambert(int maxDirectLightCount, half3 viewDir, half3 normalDir, half4 _DirectionalLightDirections[4], half4 _DirectionalLightColors[4])
{
    half3 resColor = 0;
    for (int i = 0; i < maxDirectLightCount; i++)
    {
        half halfLambert = saturate(0.5 * dot(normalize(normalDir), normalize(_DirectionalLightDirections[i]).xyz) + 0.5);
        resColor += _DirectionalLightColors[i].rgb * halfLambert;
    }
    return resColor;
}

half3 GetPointLightHalfLambert(int maxDirectLightCount, half3 viewDir, half3 normalDir, half4 _DirectionalLightDirections[4], half4 _DirectionalLightColors[4])
{
    half3 resColor = 0;
    // for(int i=0;i<maxDirectLightCount;i++)
    // {
    //     half halfLambert = saturate(0.5 * dot(normalize(normalDir),normalize(_DirectionalLightDirections[i]).xyz) + 0.5);
    //     resColor += _DirectionalLightColors[i].rgb  * halfLambert;
    //     
    // }
    return resColor;
}

half3 GetSpotightHalfLambert(int maxDirectLightCount, half3 viewDir, half3 normalDir, half4 _DirectionalLightDirections[4], half4 _DirectionalLightColors[4])
{
    half3 resColor = 0;
    // for(int i=0;i<maxDirectLightCount;i++)
    // {
    //     half halfLambert = saturate(0.5 * dot(normalize(normalDir),normalize(_DirectionalLightDirections[i]).xyz) + 0.5);
    //     resColor += _DirectionalLightColors[i].rgb  * halfLambert;
    //     
    // }
    return resColor;
}

half3 GetDirectLightPhong(int maxDirectLightCount, half3 viewDir, half3 normalDir, half4 _DirectionalLightDirections[4], half4 _DirectionalLightColors[4])
{
    half3 resColor = 0;
    for (int i = 0; i < maxDirectLightCount; i++)
    {
        half3 reflectDir = normalize(reflect(-_DirectionalLightDirections[i].xyz,normalDir));
        half halfLambert = saturate(dot(normalize(normalDir),normalize(_DirectionalLightDirections[i].xyz)));
        resColor = resColor + (1 + pow(saturate(dot(reflectDir,viewDir)),_SpecularPow)) * _DirectionalLightColors[i].rgb * halfLambert;
    }
    return resColor;
}

half3 GetDirectLightBlinnPhong(int maxDirectLightCount, half3 viewDir, half3 normalDir, half4 _DirectionalLightDirections[4], half4 _DirectionalLightColors[4])
{
    half3 resColor = 0;
    for (int i = 0; i < maxDirectLightCount; i++)
    {
        half3 reflectDir = normalize(reflect(-_DirectionalLightDirections[i].xyz,normalDir));
        half3 halfDir = normalize(viewDir + _DirectionalLightDirections[i].xyz);
        half halfLambert = saturate(dot(normalize(normalDir),normalize(_DirectionalLightDirections[i].xyz)));
        resColor =  resColor + (1 + pow(max(0,saturate(dot(reflectDir,halfDir))),_SpecularPow)) * _DirectionalLightColors[i].rgb * halfLambert;
    }
    return resColor;
}

#endif
