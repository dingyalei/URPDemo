#ifndef YLPR_BASE_LIGHT_MODEL_INCLUDE
#define YLPR_BASE_LIGHT_MODEL_INCLUDE

struct VertexInput_HalfLambert
{
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct VertexOutput_HalfLambert
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float3 positionWS : TEXCOORD1;
};

VertexOutput_HalfLambert Vert_HalfLambert(VertexInput_HalfLambert v)
{
    VertexOutput_HalfLambert o = (VertexOutput_HalfLambert)0;
    o.position = UnityObjectToClipPos(v.position);
    o.positionWS = mul(unity_ObjectToWorld,v.position);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.uv = v.uv;
    return o;
}

half4 Frag_HalfLambert(VertexOutput_HalfLambert i) :SV_Target
{
    half3 viewDirection = _WorldSpaceCameraPos.xyz - i.positionWS;
    half3 dirLightColor = GetDirectLightHalfLambert(MAX_DIRECTIONAL_LIGHT_COUNT,normalize(viewDirection),normalize(i.normal),_DirectionalLightDirections,_DirectionalLightColors);
    half4 color = half4 (_Color.rgb,1.0) * tex2D(_MainTex,i.uv);
    color.rgb *= dirLightColor;
    return color;
}
#endif
