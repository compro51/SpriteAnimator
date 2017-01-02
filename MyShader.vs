// My Vertex Shader

// Globals

cbuffer MatrixBuffer
{
	matrix worldMatrix;
	matrix viewMatrix;
	matrix projectionMatrix;
};

cbuffer CameraBuffer
{
	float3 cameraPosition;
	float padding;
};

cbuffer FogBuffer
{
	float fogStart;
	float fogEnd;
	float padding1;
	float padding2;
};

cbuffer ReflectionBuffer
{
	matrix reflectionMatrix;
	uint reflectionEnabled;
};

cbuffer LightBuffer
{
	matrix lightViewMatrix;
	matrix lightProjectionMatrix;
	uint shadowEnabled;
};

cbuffer SkinnedBuffer
{
	matrix boneTransforms[64];
	uint skinnedEnabled;
	float3 padding5;
};

// Typedefs

struct VertexInputType
{
	float4 position :         POSITION;
	float2 tex :              TEXCOORD0;
	float3 normal :           NORMAL;
	float4 color :            COLOR;
	uint4  boneIndices :      BLENDINDICES;
	float3 weights :          BLENDWEIGHT;
	float3 instancePosition : TEXCOORD1;
};

struct PixelInputType
{
	float4 position : SV_POSITION;
	float2 tex :      TEXCOORD0;
	float3 normal :   NORMAL;
	float4 color :    COLOR;
	float3 viewDir :  TEXCOORD1;
	float fogFactor : FOG;
	float4 reflectionPosition : TEXCOORD2;
	float4 lightViewPosition : TEXCOORD3;
};

// Vertex Shader

PixelInputType MyVertexShader(VertexInputType input)
{
	PixelInputType output;

	input.position.w = 1.0f;

	if(skinnedEnabled != 0)
	{
		int numVertInfluences = 0;

		if(input.boneIndices[3] < 64)
		{
			numVertInfluences = 4;
		}
		else if(input.boneIndices[2] < 64)
		{
			numVertInfluences = 3;
		}
		else if(input.boneIndices[1] < 64)
		{
			numVertInfluences = 2;
		}
		else if(input.boneIndices[0] < 64)
		{
			numVertInfluences = 1;
		}

		if(numVertInfluences > 0)
		{
			float4 p = float4(0.0f, 0.0f, 0.0f, 1.0f);
			float4 n = float4(0.0f, 0.0f, 0.0f, 0.0f);

			int num = numVertInfluences - 1;
			float lastWeight = 0.0f;

			for(int i = 0; i < num; ++i)
			{
				lastWeight += input.weights[i];
				p += input.weights[i] * mul(input.position, boneTransforms[input.boneIndices[i]]);
				n += input.weights[i] * mul(input.normal,   boneTransforms[input.boneIndices[i]]);
			}

			lastWeight = 1.0f - lastWeight;
			p += lastWeight + mul(input.position, boneTransforms[input.boneIndices[i]]);
			n += lastWeight + mul(input.normal,   boneTransforms[input.boneIndices[i]]);

			input.position = p;
			input.position.w = 1.0f;

			input.normal = float3(n.x, n.y, n.z);
		}
	}

	output.position = mul(input.position, worldMatrix);

	output.position.x += input.instancePosition.x;
	output.position.y += input.instancePosition.y;
	output.position.z += input.instancePosition.z;

	if(shadowEnabled != 0)
	{
		output.lightViewPosition = mul(output.position, lightViewMatrix);
		output.lightViewPosition = mul(output.lightViewPosition, lightProjectionMatrix);
	}
	
	output.viewDir = normalize(cameraPosition - output.position.xyz);

	output.position = mul(output.position, viewMatrix);

	float d = fogEnd - fogStart;

	if(d != 0)
	{
		output.fogFactor = saturate((fogEnd - output.position.z) / d);
	}
	else
	{
		output.fogFactor = 1.0f;
	}

	output.position = mul(output.position, projectionMatrix);

	output.tex = input.tex;

	output.normal = mul(input.normal, (float3x3)worldMatrix);
	output.normal = normalize(output.normal);

	output.color = input.color;

	if(reflectionEnabled != 0)
	{
		matrix reflectProjectMatrix = mul(reflectionMatrix, projectionMatrix);
		reflectProjectMatrix = mul(worldMatrix, reflectProjectMatrix);

		output.reflectionPosition = mul(input.position, reflectProjectMatrix);
	}

	return output;
}