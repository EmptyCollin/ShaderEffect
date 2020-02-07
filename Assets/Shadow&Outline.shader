Shader "Custom/Shadow&Outline"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
			// Three colors to be interpolated
			_Color1("Light Color", Color) = (1,1,1,1)
			_Color2("Shadow Color", Color) = (1,1,1,1)
			_Color3("Outline Color", Color) = (1,1,1,1)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Use our own illumination model "MyModel"
			#pragma surface surf MyModel fullforwardshadows

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;

			struct Input
			{
				float2 uv_MainTex;
				float3 worldPos;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
			float4 _Color1;
			float4 _Color2;
			float4 _Color3;
			float3 pos;

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

				// Our own illumination model
			half4 LightingMyModel(SurfaceOutput s, half3 viewDir, UnityGI gi)
				{
				// Calculate a quantity similar to diffuse shading, 
				// but consider also the negative dot products

				float aCos = dot(normalize(s.Normal), normalize(_WorldSpaceCameraPos - pos));
				if (aCos <= 0.22) {
					return _Color3;
				}

				float intensity = (dot(s.Normal, gi.light.dir) + 1.0) / 2.0;
				// Interpolate two colors based on the shading
				float4 c1 = _Color1;
				float4 c2 = _Color2;
				return intensity * c1 + (1 - intensity) * c2;
			}

			// We also need to add this function to define a new illumination model
			// Just use the standard function that calls "UnityGlobalIllumination"
			void LightingMyModel_GI(SurfaceOutput s, UnityGIInput data, inout UnityGI gi)
			{
				gi = UnityGlobalIllumination(data, 1.0, s.Normal);
			}

			void surf(Input IN, inout SurfaceOutput o)
			{
				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color1;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Alpha = c.a;

				pos = IN.worldPos;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
