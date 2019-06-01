Shader "Unlit/mirror"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_depthTex("depth tex",2D)="white"{}
		_blurTex("blurTex",2D)="white"{}
		_Cube("cube map",cube)=""{}
		[Toggle]_UseFade("use fade",float)=0
		_Fade("fade",Range(0,3))=1
		
    }
	CGINCLUDE
    #include "UnityCG.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
		float3 normal:NORMAL;
    };

    struct v2f
    {
        float4 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
		float3 normal:TEXCOORD1;
		float3 rDir:TEXCOORD2;
    };

    sampler2D _MainTex,_blurTex,_depthTex;
	half _Fade;
	samplerCUBE _Cube;
    v2f vert (appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = ComputeGrabScreenPos(o.vertex);
		o.normal=v.normal;
		float3 worldNormal = UnityObjectToWorldNormal(v.normal);
		float3 worldViewDir = WorldSpaceViewDir(v.vertex);
		o.rDir = reflect(-worldViewDir, worldNormal);
        return o;
    }

    fixed4 frag (v2f i) : SV_Target
    {
		i.normal=normalize(i.normal);
		fixed3 col=tex2Dproj(_MainTex,i.uv);
		fixed3 blurCol=tex2Dproj(_blurTex,i.uv);
		float d=tex2Dproj(_depthTex,i.uv).r;
		col=lerp(col,blurCol,d);
		#if _USEFADE_ON
			float3 coll=texCUBE(_Cube,i.rDir);
			return fixed4(coll+saturate(_Fade-d)*col,1.0);
		#endif
		return fixed4(col,1.0);
    }
    ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		
        Pass
        {
           CGPROGRAM
		   #pragma vertex vert
		   #pragma fragment frag
		   #pragma shader_feature _USEFADE_ON
		   ENDCG
        }
    }
}
