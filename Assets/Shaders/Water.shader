Shader "Unlit/Water"{
    Properties{
        _Color("Color", Color) = (1, 1, 1, 1)
		_EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
		_DepthFactor("Depth Factor", float) = 1.0
		_WaveSpeed("Wave Speed", float) = 1.0
		_WaveAmp("Wave Amp", float) = 0.2
		_NoiseTex("Noise Texture", 2D) = "white" {}
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
            float _WaveSpeed;
            float _WaveAmp;

            sampler2D _CameraDepthTexture;
            sampler2D _NoiseTex;

            struct MeshData{
                float4 vertex : POSITION;
                float4 texCoord : TEXCOORD1;
            };

            struct interpolators{
                float4 pos : SV_POSITION;
                float4 texCoord : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            interpolators vert(MeshData input){
                interpolators output;

                // Convert to camera clip space
                output.pos = UnityObjectToClipPos(input.vertex);

                // Wave animation
                float noiseSample = tex2Dlod(_NoiseTex, float4(input.texCoord.xy, 0, 0));
                output.pos.y += sin(_Time*_WaveSpeed*noiseSample)*_WaveAmp;
				//output.pos.x += cos(_Time*_WaveSpeed*noiseSample)*_WaveAmp;

                output.screenPos = ComputeScreenPos(output.pos);

                output.texCoord = input.texCoord;

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
