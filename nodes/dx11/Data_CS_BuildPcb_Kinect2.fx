float4x4 tW : WORLD;

Texture2D texRGB <string uiname="RGB";>;
Texture2D texDepth <string uiname="Depth";>;
Texture2D texRayTable <string uiname="RayTable";>;
Texture2D texRGBDepth <string uiname="RGBDepth";>;
int drawIndex : DRAWINDEX;
int IdOffset;
float2 Resolution;

SamplerState sPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
};

#include "_PointData.fxh"
AppendStructuredBuffer<pointData> pcBuffer : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(8, 8, 1)]
void CSBuildPointcloudBuffer( uint3 i : SV_DispatchThreadID )
{
	
	uint w,h, dummy;
	texDepth.GetDimensions(0,w,h,dummy);
	if (i.x >= w || i.y >= h) { return; }
	
	float2 coord = i.xy * float2(w / Resolution.x, h / Resolution.y) / Resolution;
	
	float depth =  texDepth.SampleLevel(sPoint,coord,0).r * 65.535 ;
	if (depth > 0){
		
		float4 pos = float4(0,0,0,1);
		float2 raytable =  texRayTable.SampleLevel(sPoint,coord,0).xy;
		pos.x = depth * raytable.x * -1;
		pos.y = depth * raytable.y;
		pos.z = depth;
		pos = mul(pos, tW);
			
		float2 map = texRGBDepth.SampleLevel(sPoint, coord ,0).rg;
		map.x /= 1920.0f;
		map.y /= 1080.0f;
		float4 col = texRGB.SampleLevel(sPoint,map,0);
		//col = float4(1,1,1,1);
		pointData pd = {pos.xyz, col, drawIndex + IdOffset};
		pcBuffer.Append(pd);
	}
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 BuildPointcloudBuffer
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSBuildPointcloudBuffer() ) );
	}
}
