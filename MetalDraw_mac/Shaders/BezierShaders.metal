//
//  BezierShaders.metal
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/8/17.
//

#include <metal_stdlib>
using namespace metal;

enum PathElementType {
	PathElementTypeLineTo = 1,
	PathElementTypeQuadCurveTo = 2,
	PathElementTypeCurveTo = 3
};


struct PathElement {
	uint8_t pathElementType;
	uint8_t unused1;
	uint8_t unused2;
	uint8_t unused3;

	uint32_t numberOfVertexes; // number of vertexes

	float2 p0;
	float2 p1;
	float2 p2; // may be nan
	float2 p3; // may be nan

	float w1;
	float w2;
};

struct VertexIn {
	half2 position;
	half width;
	half ununsed;
	VertexIn(float2 position, float width) {
		this->position = half2(position);
		this->width = half(width);
		this->ununsed = 0;
	}
};

struct FragmentIn {
	float4 position [[ position ]];
	float pointSize [[ point_size ]];
	half unused;
};

struct Uniforms {
	float4x4 transform;
	float scale;
	float unused1, unused2, unused3;
};


kernel void bezier_kernel(
	constant PathElement* elements [[ buffer(0) ]],
	device VertexIn* outVerticies [[ buffer(1) ]],
	uint index [[ thread_position_in_grid ]]
) {
	PathElement element = *elements;
	int numberOfVertexes = element.numberOfVertexes;

	float2 p0 = element.p0;
	float2 p1 = element.p1;
	float2 p2 = element.p2;
	float2 p3 = element.p3;
	float w1 = element.w1;
	float w2 = element.w2;

	if (index < uint(numberOfVertexes)) {
		switch (element.pathElementType) {
		case PathElementTypeLineTo: {
				float t = float(index) / float(numberOfVertexes);  // 0.0 ... 1.0
				float2 q = p0 + (p1 - p0) * t;
				float w = w1 + (w2 - w1) * t;
				VertexIn v = VertexIn(q, w);
				outVerticies[index] = v;
			}
			break;
		case PathElementTypeQuadCurveTo: {
				float t = float(index) / float(numberOfVertexes);  // 0.0 ... 1.0
				float2 q1 = p0 + (p1 - p0) * t;
				float2 q2 = p1 + (p2 - p1) * t;
				float2 r = q1 + (q2 - q1) * t;
				float w = w1 + (w2 - w1) * t;
				VertexIn v = VertexIn(r, w);
				outVerticies[index] = v;
			}
			break;
		case PathElementTypeCurveTo: {
				float t = float(index) / float(numberOfVertexes);  // 0.0 ... 1.0
				float2 q1 = p0 + (p1 - p0) * t;
				float2 q2 = p1 + (p2 - p1) * t;
				float2 q3 = p2 + (p3 - p2) * t;
				float2 r1 = q1 + (q2 - q1) * t;
				float2 r2 = q2 + (q3 - q2) * t;
				float2 s = r1 + (r2 - r1) * t;
				float w = w1 + (w2 - w1) * t;
				VertexIn v = VertexIn(s, w);
				outVerticies[index] = v;
			}
			break;
		}
	}
}


vertex FragmentIn bezier_vertex(
	device VertexIn * verticies [[ buffer(0) ]],
	constant Uniforms & uniforms [[ buffer(1) ]],
	uint vid [[ vertex_id ]]
) {
	VertexIn inVertex = verticies[vid];
	FragmentIn outVertex;
	outVertex.position = uniforms.transform * float4(float2(inVertex.position), 0, 1);
	outVertex.pointSize = inVertex.width * uniforms.scale;
	return outVertex;
}


fragment float4 bezier_fragment(
	FragmentIn fragmentIn [[ stage_in ]],
	texture2d<float, access::sample> brushTexture [[ texture(0) ]],
	sampler brushSampler [[ sampler(0) ]],
	float2 texcoord [[ point_coord ]]
) {
	float4 color = brushTexture.sample(brushSampler, texcoord);
	return color;
}


