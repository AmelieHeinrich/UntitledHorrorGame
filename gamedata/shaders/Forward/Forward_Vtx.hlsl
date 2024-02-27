/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 14:38:03
 */

struct VertexIn
{
    float3 position: POSITION;
    float3 normal: NORMAL;
    float2 texcoord: TEXCOORD;
};

struct VertexOut
{
    float4 position: SV_POSITION;
    float3 normal: NORMAL;
    float2 texcoord: TEXCOORD;
};

cbuffer SceneData : register(b0)
{
    row_major float4x4 View;
    row_major float4x4 Projection;
};

cbuffer InstanceData : register(b1)
{
    row_major float4x4 Model;
};

VertexOut main(VertexIn input)
{
    VertexOut output = (VertexOut)0;

    output.position = mul(float4(input.position, 1.0), Model);
    output.position = mul(output.position, View);
    output.position = mul(output.position, Projection);
    output.normal = normalize(float4(mul(transpose(Model), float4(input.normal, 1.0))).xyz);
    output.texcoord = input.texcoord;

    return output;
}
