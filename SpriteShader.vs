// Sprite Shader

// Globals

cbuffer MatrixBuffer
{
	matrix worldMatrix;
	matrix spriteMatrix;
	matrix projectionMatrix;
};

// Typedefs

struct VertexInputType
{
	float4 position : POSITION;
	float2 tex :      TEXCOORD0;
	float4 color :    COLOR;
};

struct PixelInputType
{
	float4 position : SV_POSITION;
	float2 tex :      TEXCOORD0;
	float4 color :    COLOR;
};

// Vertex Shader

PixelInputType SpriteShader(VertexInputType input)
{
	PixelInputType output;

	input.position.w = 1.0f;

	output.position = mul(input.position, worldMatrix);
	output.position = mul(output.position, spriteMatrix);
	output.position = mul(output.position, projectionMatrix);

	output.tex = input.tex;
	output.color = input.color;

	return output;
}