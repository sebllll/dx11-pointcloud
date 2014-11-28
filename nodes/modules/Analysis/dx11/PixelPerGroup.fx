//@author: tmp 
//@help: Generates a colored PointCloud
//@tags: DX11, Kinect, Pointcloud
//@credits: vvvv

struct pointData
{
	float4 pos;
	float4 col;
	int groupId;
};
StructuredBuffer<pointData> pcBuffer;

float pixPos;
float slice;


struct vsInput
{
	uint ii :  SV_VertexID;
};

struct vs2ps
{
    float4 pos: SV_POSITION;
	float4 col: COLOR;
};

/* ===================== VERTEX SHADER ===================== */

vs2ps VS(vsInput input)
{
    vs2ps output = (vs2ps)0;
    
	// set pixel position - each filter has its own pixel position
	output.pos  = float4(pixPos, 0.0 ,0.0 ,1.0);
	
	// now check if the particles filterId equals the current filterId

	if (pcBuffer[input.ii].groupId == slice){
		output.col = float4(pcBuffer[input.ii].pos.xyz,1.0f);
	}
	else output.col = float4(0,0,0,0.0f);
	
	//if (slice == 2) output.col = float4(0,0,0,0);
	//output.col = float4(pcBuffer[input.ii].pos.xyz,1.0f);

	return output;
}

/* ===================== PIXEL SHADER ===================== */

float4 PS(vs2ps input): SV_Target
{
    return input.col;
}

/* ===================== TECHNIQUE ===================== */

technique10 Process
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}