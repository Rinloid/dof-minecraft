#version 120

uniform sampler2D gcolor;
uniform sampler2D depthtex1;

uniform float centerDepthSmooth;
uniform float viewWidth, viewHeight;

varying vec2 uv;

#define ENABLE_DOF
#define DOF_STEPS 6 // [1 2 3 4 5 6 7 8 9 10]

mat2 getRotationMatrix(const float angle) {
	return mat2(cos(angle), sin(angle), -sin(angle), cos(angle));
}

const float centerDepthHalflife = 2.0; // [0.0 1.0 2.0 3.0 4.0 5.0]

void main() {
vec3 albedo = texture2D(gcolor, uv).rgb;
float depth = texture2D(depthtex1, uv).r;

float centreDepth = centerDepthSmooth;
vec2 screenResolution = vec2(viewWidth, viewHeight);

vec2 pixelSize = 1.0 / screenResolution;
float unfocused = smoothstep(0.0, 0.01, abs(depth - centreDepth));
vec3 blurred = vec3(0.0, 0.0, 0.0);

const int steps = DOF_STEPS;

#ifdef ENABLE_DOF
	if (unfocused > 0.0) {
		for (int i = -steps; i < steps; i++) {
			for (int j = -steps; j < steps; j++) {
				vec2 offset = vec2(i, j) * pixelSize;
				offset *= getRotationMatrix(float(steps * 2 * steps * 2));

				blurred += texture2D(gcolor, uv + offset * unfocused).rgb;
			}
		} blurred /= float(steps * 2 * steps * 2);

		albedo = blurred;
	}
#endif

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(albedo, 1.0); // gcolor
}