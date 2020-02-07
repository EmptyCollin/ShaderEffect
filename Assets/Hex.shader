Shader "Custom/Hex"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Thresh("Line thickness", Float) = 0.02
		_Row("Row",Int)=1
		_Column("Column",Int) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;

			struct Input
			{
				float2 uv_MainTex;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
			float _Thresh;
			int _Row;
			int _Column;

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				// Use default color for fragments outside the hex
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
				//// Plot hex
				int N = 6; // Number of polygon sides: 6
				float pi = 3.1415926535897932;


				// Get position of fragment on texture
				float2 pos = IN.uv_MainTex;
				float theta, r, angle, real_r, diff, step, radius;
				int row = _Row, column = _Column;
				float2 center;
				center.x = floor(pos.x / (1 / (float)column)) * (1 / (float)column) + (1 / (float)column / (float)2);
				center.y = floor(pos.y / (1 / (float)row)) * (1 / (float)row) + (1 / (float)row / (float)2);
				// Center and scale the hex based on parameters
				pos -= center;

				radius = 0.5 / (float)max(row, column);
				pos *= 1.0 / radius;
				// Compute polar coordinates of the current point
				theta = atan2(pos.x, pos.y);
				r = sqrt(pos.x*pos.x + pos.y*pos.y);
				// Turn hex around if desired
				//theta = theta - (pi / N); 
				// Reduce angle to first quadrant
				angle = theta - 2.0 * pi / N * floor((N*theta + pi) / (2 * pi));
				// Compute the radius that this angle should have
				real_r = cos((pi) / N) / cos(angle);
				// Compare the two radii and use comparison value to draw the hex
				diff = real_r - r;
				if (diff >= 0.0) {
					// We are inside the hex
					o.Albedo = float3(1.0, 1.0, 0.0);
				}
				// Add a border around the hex
				step = smoothstep(0, _Thresh, abs(diff)); // [0.0, thresh] is mapped to [0, 1]
				o.Albedo = step * o.Albedo;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
