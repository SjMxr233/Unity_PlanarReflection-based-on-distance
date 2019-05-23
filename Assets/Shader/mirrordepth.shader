// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/mirrordepth"
{
    Properties
    {
        _PlanePos("Plane Pos", Vector ) = (0,0,0,0)
		_PlaneNormal("Plane Normal", Vector ) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			float3 _PlanePos,_PlaneNormal;
            struct appdata
            {
                float4 vertex : POSITION;
     
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float3 dis:TEXCOORD0;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 wpos=mul(unity_ObjectToWorld,v.vertex);
				o.dis=saturate(length((_PlanePos-wpos)*_PlaneNormal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.dis,1.0);
            }
            ENDCG
        }
    }
}
