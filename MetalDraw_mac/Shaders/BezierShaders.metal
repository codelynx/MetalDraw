//
//  BezierShaders.metal
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/8/17.
//

#include <metal_stdlib>
using namespace metal;

enum PathElementType {
	PathElementTypeLineTo = 2,
	PathElementTypeQuadCurveTo = 3,
	PathElementTypeCurveTo = 4
};


struct PathElement {
	unsigned char pathElementType;
	unsigned char unused1;
	unsigned char unused2;
	unsigned char unused3;

	uint32_t numberOfVertexes; // number of vertexes

	float2 p0;
	float2 p1;
	float2 p2; // may be nan
	float2 p3; // may be nan
};

struct VertexIn {
	half2 position;
	VertexIn(half2 position) {
		this->position = position;
	}
};

struct FragmentIn {
	float4 position [[ position ]];
	float4 color;
	float pointSize [[ point_size ]];
};

struct Uniforms {
	float4x4 transform;
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

	switch (element.pathElementType) {
	case PathElementTypeLineTo: {
			float t = float(index) / float(numberOfVertexes);  // 0.0 ... 1.0
			float2 q = p0 + (p1 - p0) * t;
			VertexIn v = VertexIn(half2(q.x, q.y));
			outVerticies[index] = v;
		}
		break;
	case PathElementTypeQuadCurveTo: {
			float t = float(index) / float(numberOfVertexes);  // 0.0 ... 1.0
			float2 q1 = p0 + (p1 - p0) * t;
			float2 q2 = p1 + (p2 - p1) * t;
			float2 r = q1 + (q2 - q1) * t;
			VertexIn v = VertexIn(half2(r.x, r.y));
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
			VertexIn v = VertexIn(half2(s.x, s.y));
			outVerticies[index] = v;
		}
		break;
	}
}


vertex FragmentIn bezier_vertex(
	device VertexIn * verticies [[ buffer(0) ]],
	constant Uniforms & uniforms [[ buffer(1) ]],
	uint vid [[ vertex_id ]]
) {
	VertexIn inVertex = verticies[vid];
	FragmentIn outVertex;
	outVertex.position = uniforms.transform * float4(float2(inVertex.position), 0.0, 1.0);
	outVertex.color = float4(1, 0, 0, 1);
	outVertex.pointSize = 16;
	return outVertex;
}


fragment float4 bezier_fragment(
	FragmentIn fragmentIn [[ stage_in ]],
	float2 pointCoord [[ point_coord ]]
) {
	float2 point = pointCoord - float2(0.5);
	if (length(point) > 0.5) {
		discard_fragment();
	}
	return fragmentIn.color;
}

/*
fragment float4 bezier_fragment(
	FragmentIn fragmentIn [[ stage_in ]],
	texture2d<float, access::sample> shapeTexture [[ texture(0) ]],
	sampler shapeSampler [[ sampler(0) ]],
	float2 texcoord [[ point_coord ]]
) {
	float4 shapeColor = shapeTexture.sample(shapeSampler, texcoord);
	float4 patternColor = shapeTexture.sample(shapeSampler, float2(fragmentIn.position.xy) + texcoord);
	float4 color = float4(patternColor.rgb, shapeColor.a);
	return color;
}
*/

