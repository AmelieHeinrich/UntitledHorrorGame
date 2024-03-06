/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 14:42:02
 */

struct FragmentIn
{
    float4 position: SV_POSITION;
    float3 normal: NORMAL;
    float2 texcoord: TEXCOORD;
};

sampler TextureSampler : register(s0);
Texture2D Albedo : register(t0);

float4 main(FragmentIn input) : SV_Target
{
    return Albedo.Sample(TextureSampler, input.texcoord);
}
