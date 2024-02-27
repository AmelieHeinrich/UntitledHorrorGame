/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 17:22:52
 */

RWTexture2D<float4> Texture : register(u0);

#define FXAA_EDGE_THRESHOLD      (1.0/8.0)
#define FXAA_EDGE_THRESHOLD_MIN  (1.0/24.0)
#define FXAA_SEARCH_STEPS        32
#define FXAA_SEARCH_ACCELERATION 1
#define FXAA_SEARCH_THRESHOLD    (1.0/4.0)
#define FXAA_SUBPIX              1
#define FXAA_SUBPIX_FASTER       0
#define FXAA_SUBPIX_CAP          (3.0/4.0)
#define FXAA_SUBPIX_TRIM         (1.0/4.0)
#define FXAA_SUBPIX_TRIM_SCALE (1.0/(1.0 - FXAA_SUBPIX_TRIM))

float4 FxaaTexOff(RWTexture2D<float4> tex, float2 pos, int2 off)
{
    return tex[pos.xy + off.xy];
}

float FxaaLuma(float3 rgb)
{
    return rgb.y * (0.587 / 0.299) + rgb.x;
}

float3 FxaaLerp3(float3 a, float3 b, float amountOfA)
{
    return (float3(-amountOfA,0,0) * b) +
        ((a * float3(amountOfA,0,0)) + b);
}

float4 FxaaTexLod0(RWTexture2D<float4> tex, float2 pos)
{
    return tex[pos.xy];
}

float3 FXAAFilter(RWTexture2D<float4> tex, uint2 pos, uint2 dimensions)
{
    float2 rcpFrame = float2(1.0f / dimensions.x, 1.0f / dimensions.y);

    float3 rgbN = FxaaTexOff(tex, pos.xy, int2(0, -1)).xyz;
    float3 rgbW = FxaaTexOff(tex, pos.xy, int2(-1, 0)).xyz;
    float3 rgbM = FxaaTexOff(tex, pos.xy, int2(0, 0)).xyz;
    float3 rgbE = FxaaTexOff(tex, pos.xy, int2(1, 0)).xyz;
    float3 rgbS = FxaaTexOff(tex, pos.xy, int2(0, 1)).xyz;
    float lumaN = FxaaLuma(rgbN);
    float lumaW = FxaaLuma(rgbW);
    float lumaM = FxaaLuma(rgbM);
    float lumaE = FxaaLuma(rgbE);
    float lumaS = FxaaLuma(rgbS);
    float rangeMin = min(lumaM, min(min(lumaN, lumaW), min(lumaS, lumaE)));
    float rangeMax = max(lumaM, max(max(lumaN, lumaW), max(lumaS, lumaE)));
    float range = rangeMax - rangeMin;
    if (range < max(FXAA_EDGE_THRESHOLD_MIN, rangeMax * FXAA_EDGE_THRESHOLD))
    {
        return rgbM;
    }
    float3 rgbL = rgbN + rgbW + rgbM + rgbE + rgbS;
    
    //COMPUTE LOWPASS
    #if FXAA_SUBPIX != 0
        float lumaL = (lumaN + lumaW + lumaE + lumaS) * 0.25;
        float rangeL = abs(lumaL - lumaM);
    #endif
    #if FXAA_SUBPIX == 1
        float blendL = max(0.0,
            (rangeL / range) - FXAA_SUBPIX_TRIM) * FXAA_SUBPIX_TRIM_SCALE;
        blendL = min(FXAA_SUBPIX_CAP, blendL);
    #endif
    
    
    //CHOOSE VERTICAL OR HORIZONTAL SEARCH
    float3 rgbNW = FxaaTexOff(tex, pos.xy, int2(-1, -1)).xyz;
    float3 rgbNE = FxaaTexOff(tex, pos.xy, int2(1, -1)).xyz;
    float3 rgbSW = FxaaTexOff(tex, pos.xy, int2(-1, 1)).xyz;
    float3 rgbSE = FxaaTexOff(tex, pos.xy, int2(1, 1)).xyz;
    #if (FXAA_SUBPIX_FASTER == 0) && (FXAA_SUBPIX > 0)
        rgbL += (rgbNW + rgbNE + rgbSW + rgbSE);
        rgbL *= float3(1.0 / 9.0,0,0);
    #endif
    float lumaNW = FxaaLuma(rgbNW);
    float lumaNE = FxaaLuma(rgbNE);
    float lumaSW = FxaaLuma(rgbSW);
    float lumaSE = FxaaLuma(rgbSE);
    float edgeVert =
        abs((0.25 * lumaNW) + (-0.5 * lumaN) + (0.25 * lumaNE)) +
        abs((0.50 * lumaW) + (-1.0 * lumaM) + (0.50 * lumaE)) +
        abs((0.25 * lumaSW) + (-0.5 * lumaS) + (0.25 * lumaSE));
    float edgeHorz =
        abs((0.25 * lumaNW) + (-0.5 * lumaW) + (0.25 * lumaSW)) +
        abs((0.50 * lumaN) + (-1.0 * lumaM) + (0.50 * lumaS)) +
        abs((0.25 * lumaNE) + (-0.5 * lumaE) + (0.25 * lumaSE));
    bool horzSpan = edgeHorz >= edgeVert;
    float lengthSign = horzSpan ? -rcpFrame.y : -rcpFrame.x;
    if (!horzSpan)
        lumaN = lumaW;
    if (!horzSpan)
        lumaS = lumaE;
    float gradientN = abs(lumaN - lumaM);
    float gradientS = abs(lumaS - lumaM);
    lumaN = (lumaN + lumaM) * 0.5;
    lumaS = (lumaS + lumaM) * 0.5;
    
    
    //CHOOSE SIDE OF PIXEL WHERE GRADIENT IS HIGHEST
    bool pairN = gradientN >= gradientS;
    if (!pairN)
        lumaN = lumaS;
    if (!pairN)
        gradientN = gradientS;
    if (!pairN)
        lengthSign *= -1.0;
    float2 posN;
    posN.x = pos.x + (horzSpan ? 0.0 : lengthSign * 0.5);
    posN.y = pos.y + (horzSpan ? lengthSign * 0.5 : 0.0);
    
    //CHOOSE SEARCH LIMITING VALUES
    gradientN *= FXAA_SEARCH_THRESHOLD;

    //SEARCH IN BOTH DIRECTIONS UNTIL FIND LUMA PAIR AVERAGE IS OUT OF RANGE
    float2 posP = posN;
    float2 offNP = horzSpan ?
        float2(rcpFrame.x, 0.0) :
        float2(0.0f, rcpFrame.y);
    float lumaEndN = lumaN;
    float lumaEndP = lumaN;
    bool doneN = false;
    bool doneP = false;
    #if FXAA_SEARCH_ACCELERATION == 1
        posN += offNP * float2(-1.0, -1.0);
        posP += offNP * float2(1.0, 1.0);
    #endif
    for (int i = 0; i < FXAA_SEARCH_STEPS; i++)
    {
    #if FXAA_SEARCH_ACCELERATION == 1
        if (!doneN)
            lumaEndN =
                FxaaLuma(FxaaTexLod0(tex, posN.xy).xyz);
        if (!doneP)
            lumaEndP =
                FxaaLuma(FxaaTexLod0(tex, posP.xy).xyz);
    #endif
        doneN = doneN || (abs(lumaEndN - lumaN) >= gradientN);
        doneP = doneP || (abs(lumaEndP - lumaN) >= gradientN);
        if (doneN && doneP)
            break;
        if (!doneN)
            posN -= offNP;
        if (!doneP)
            posP += offNP;
    }
    
    
    //HANDLE IF CENTER IS ON POSITIVE OR NEGATIVE SIDE
    float dstN = horzSpan ? pos.x - posN.x : pos.y - posN.y;
    float dstP = horzSpan ? posP.x - pos.x : posP.y - pos.y;
    bool directionN = dstN < dstP;
    lumaEndN = directionN ? lumaEndN : lumaEndP;
    
    //CHECK IF PIXEL IS IN SECTION OF SPAN WHICH GETS NO FILTERING   
    if (((lumaM - lumaN) < 0.0) == ((lumaEndN - lumaN) < 0.0)) 
        lengthSign = 0.0;
    
    float spanLength = (dstP + dstN);
    dstN = directionN ? dstN : dstP;
    float subPixelOffset = (0.5 + (dstN * (-1.0 / spanLength))) * lengthSign;
    float3 rgbF = FxaaTexLod0(tex, float2(pos.x + (horzSpan ? 0.0 : subPixelOffset),
                                          pos.y + (horzSpan ? subPixelOffset : 0.0))).xyz;
    return FxaaLerp3(rgbL, rgbF, blendL);
}

[numthreads(32, 32, 1)]
void main(uint3 ThreadID : SV_DispatchThreadID)
{
    uint Width, Height;
    Texture.GetDimensions(Width, Height);

    if (ThreadID.x < Width && ThreadID.y < Height)
    {
        float3 BaseColor = Texture[ThreadID.xy].xyz;
        BaseColor = FXAAFilter(Texture, uint2(ThreadID.x, ThreadID.y), uint2(Width, Height));
        Texture[ThreadID.xy] = float4(BaseColor, 1.0f);
    }
}