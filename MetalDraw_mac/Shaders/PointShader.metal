//
//  PointShader.metal
//  TestPlot
//
//  Created by Kaz Yoshikawa on 2/24/17.
//  Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexIn {
	float2 position;
	float width;
	float unused;
	float4 color;
};

struct FragmentIn {
	float4 position [[ position ]];
	float4 color;
	float pointSize [[ point_size ]];
};

struct Uniforms {
	float4x4 transform;
	float scale;
	float ununsed1;
	float ununsed2;
	float ununsed3;
};

vertex FragmentIn point_vertex(
	device VertexIn * vertices [[ buffer(0) ]],
	constant Uniforms & uniforms [[ buffer(1) ]],
	uint vid [[ vertex_id ]]
) {
	FragmentIn outVertex;
	VertexIn inVertex = vertices[vid];
	
	outVertex.position = uniforms.transform * float4(inVertex.position, 0, 1);
	outVertex.color = float4(inVertex.color);
	outVertex.pointSize = inVertex.width * uniforms.scale;
	return outVertex;
}


fragment float4 point_fragment(
	FragmentIn fragmentIn [[ stage_in ]],
	float2 pointCoord [[ point_coord ]]
) {
	float2 point = pointCoord - float2(0.5);
	if (length(point) > 0.5) {
		discard_fragment();
	}
	return fragmentIn.color;
}
