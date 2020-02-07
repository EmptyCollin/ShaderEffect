Shader "Custom/DrawCircle"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_Center("Center", Vector) = (0, 0, 0, 0)
		_Radius("Radius", Float) = 10
		_BandColor("Band color", Color) = (1, 0, 0, 1)
		_BandWidth("Band width", Float) = 2
		_BandFade("Band fade", Float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
			float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		float3 _Center;
		float _Radius;
		fixed4 _BandColor;
		float _BandWidth;
		float _BandFade;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			/*
			// Draw circle
			// Compute distance from object center to current fragment
			float dist = distance(_Center, IN.worldPos);
			// Check the distance against the circle's band parameters
			if (dist > (_Radius - _BandWidth - _BandFade) && dist < (_Radius - _BandWidth + _BandFade)) {
				// We are inside a fading part of the circle
				float low = _Radius - _BandWidth - _BandFade;
				float high = _Radius - _BandWidth + _BandFade;
				float f = (dist - low) / (high - low);
				o.Albedo = f * _BandColor + (1.0 - f)*c.rgb;
			}
			else if (dist >(_Radius + _BandWidth - _BandFade) && dist < (_Radius + _BandWidth + _BandFade)) {
				// We are inside a fading part of the circle
				float high = _Radius + _BandWidth - _BandFade;
				float low = _Radius + _BandWidth + _BandFade;
				float f = (dist - low) / (high - low);
				o.Albedo = f * _BandColor + (1.0 - f)*c.rgb;
			}
			else if (dist >(_Radius - _BandWidth) && dist < (_Radius + _BandWidth)) {
				// We are inside the solid region of the circle
				o.Albedo = _BandColor;
			}

			*/

			float3 area = IN.worldPos- _Center;
			
			if (area.x <= _Radius + _BandWidth && area.x >= -_Radius - _BandWidth && 
				area.z <= _Radius + _BandWidth && area.z >= -_Radius - _BandWidth) {
				if (area.x < _Radius  && area.x > -_Radius && area.z < _Radius  && area.z > -_Radius)
					o.Albedo = c.rgb;
				else o.Albedo = _BandColor;
			}



        }
        ENDCG
    }
    FallBack "Diffuse"
}
