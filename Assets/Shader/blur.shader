// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "mxr/gaosiblur"
{
	Properties{
		_MainTex("MainTex",2D)="white"{}
		_BlurSpread("Blur Spread",Float)=0.6
	}
	SubShader{
		Pass
		{
			ZWrite Off
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _BlurSpread;
			struct v2f{
				float4 pos:SV_POSITION;
				half2 uv[5]:TEXCOORD0;
			};
			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv[0]=v.texcoord.xy;
				o.uv[1]=v.texcoord.xy+_MainTex_TexelSize.y*half2(0,1)*_BlurSpread;
				o.uv[2]=v.texcoord.xy+_MainTex_TexelSize.y*half2(0,-1)*_BlurSpread;
				o.uv[3]=v.texcoord.xy+_MainTex_TexelSize.y*half2(0,2)*_BlurSpread;
				o.uv[4]=v.texcoord.xy+_MainTex_TexelSize.y*half2(0,-2)*_BlurSpread;
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				float weight[3]={0.4026,0.2442,0.0545};
				fixed3 color=tex2D(_MainTex,i.uv[0]).rgb*weight[0];
				for(int k=1;k<=2;k++)
				{
					color+=tex2D(_MainTex,i.uv[k*2-1]).rgb*weight[k];
					color+=tex2D(_MainTex,i.uv[k*2]).rgb*weight[k];
				}
				return fixed4(color,1.0);
			}
			ENDCG
		}
		Pass
		{
			ZWrite Off
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _BlurSpread;
			struct v2f{
				float4 pos:SV_POSITION;
				half2 uv[5]:TEXCOORD0;
			};
			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv[0]=v.texcoord.xy;
				o.uv[1]=v.texcoord.xy+_MainTex_TexelSize.x*half2(1,0)*_BlurSpread;
				o.uv[2]=v.texcoord.xy+_MainTex_TexelSize.x*half2(-1,0)*_BlurSpread;
				o.uv[3]=v.texcoord.xy+_MainTex_TexelSize.x*half2(2,0)*_BlurSpread;
				o.uv[4]=v.texcoord.xy+_MainTex_TexelSize.x*half2(-2,0)*_BlurSpread;
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				float weight[3]={0.4026,0.2442,0.0545};
				fixed3 color=tex2D(_MainTex,i.uv[0]).rgb*weight[0];
				for(int k=1;k<=2;k++)
				{
					color+=tex2D(_MainTex,i.uv[k*2-1]).rgb*weight[k];
					color+=tex2D(_MainTex,i.uv[k*2]).rgb*weight[k];
				}
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
	FallBack Off
}