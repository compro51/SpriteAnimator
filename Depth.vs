// Depth Shader

// Globals

cbuffer MatrixBuffer
{
	matrix worldMatrix;
	matrix viewMatrix;
	matrix projectionMatrix;
};

// Typedefs

struct VertexInputType
{
	float4 position :         POSITION;
	float2 tex :              TEXCOORD0;
	float3 normal :           NORMAL;
	float4 color :            COLOR;
	float3 instancePosition : TEXCOORD1;
};

struct PixelInputType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD1;
	float4 color : COLOR;
};

// Vertex Shader

PixelInputType DepthVertexShader(VertexInputType input)
{
	PixelInputType output;

	input.position.w = 1.0f;

	output.position = mul(input.position, worldMatrix);

	output.position.x += input.instancePosition.x;
	output.position.y += input.instancePosition.y;
	output.position.z += input.instancePosition.z;

	output.position = mul(output.position, viewMatrix);
	output.position = mul(output.position, projectionMatrix);

	output.tex = input.tex;
	output.color = input.color;

	return output;
}