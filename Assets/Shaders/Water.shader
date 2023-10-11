Shader "Unlit/Water"{
    Properties{
        _Color("Color", Color) = (1, 1, 1, 1)
		_EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
		_DepthFactor("Depth Factor", float) = 1.0
    }
    SubShader{
        Pass{

            CGPROGRAM
            // Required to use ComputeScreenPos()
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

			float4 _Color;
			float4 _EdgeColor;
			float  _DepthFactor;
            sampler2D _CameraDepthTexture;

            struct MeshData{
                float4 vertex : POSITION;
            };

            struct interpolators{
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            interpolators vert(MeshData input){
                interpolators output;

                output.pos = UnityObjectToClipPos(input.vertex);

                output.screenPos = ComputeScreenPos(output.pos);

                return output;
            }

            fixed4 frag (interpolators input) : COLOR{
                // Sample camera depth texture
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
                float depth = LinearEyeDepth(depthSample).r;

                float foamLine = 1 - saturate(_DepthFactor * (depth - input.screenPos.w));

                float4 col = _Color + foamLine * _EdgeColor;
                return col;
            }
            ENDCG
        }
    }
}
