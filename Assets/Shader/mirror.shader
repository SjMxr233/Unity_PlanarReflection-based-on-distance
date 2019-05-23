Shader "Unlit/mirror"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_depthTex("depth tex",2D)="white"{}
		_blurTex("blurTex",2D)="white"{}
    }
	CGINCLUDE
    #include "UnityCG.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        float4 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
    };

    sampler2D _MainTex,_blurTex,_depthTex;
    v2f vert (appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = ComputeGrabScreenPos(o.vertex);
        return o;
    }

    fixed4 frag (v2f i) : SV_Target
    {
		fixed3 col=tex2Dproj(_MainTex,i.uv);
		fixed3 blurCol=tex2Dproj(_blurTex,i.uv);
		float d=tex2Dproj(_depthTex,i.uv).r;
		col=lerp(col,blurCol,d);
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
		   ENDCG
        }
    }
}
