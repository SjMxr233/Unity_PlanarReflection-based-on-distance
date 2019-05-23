using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Reflection : MonoBehaviour
{

    private Camera cam, reflection_cam, depthcam;
    private Material reflection_mat, blurmat;
    private Renderer render;
    private bool isRendering = false;
    private Matrix4x4 reflectionMat;
    public Shader depthshader;
    public RenderTexture reflectionTex, depthTex, blurTex;
    public LayerMask m_reflectiLayermask = ~0;
    public float planeOffset;
    public int downsample = 0;
    public float _BlurSpread;
    public void Awake()
    {
        GameObject g = new GameObject("reflection cam", typeof(Camera));
        render = GetComponent<Renderer>();
        reflection_mat = render.sharedMaterial;
        reflection_cam = g.GetComponent<Camera>();
        reflectionTex = new RenderTexture(1024, 1024, 24);
        if (depthshader)
        {
            GameObject d = new GameObject("depth cam", typeof(Camera));
            depthcam = d.GetComponent<Camera>();
            depthTex = new RenderTexture(1024, 1024, 24);
            blurTex = new RenderTexture(1024>>downsample, 1024>>downsample, 24);
            blurmat=new Material(Shader.Find("mxr/gaosiblur"));
        }


    }
    private void OnWillRenderObject()
    {
      
        if (isRendering) return;
        isRendering = true;
        if (cam != Camera.current)
        {
            cam = Camera.current;
            reflection_cam.fieldOfView = cam.fieldOfView;
            reflection_cam.aspect = cam.aspect;
            reflection_cam.targetTexture = reflectionTex;
            reflection_cam.cullingMask = m_reflectiLayermask;
        }
        reflection_cam.enabled = false;
        float d = -dot(transform.up, transform.position) - planeOffset;
        Vector3 normal = transform.up;
        Vector4 plane = new Vector4(normal.x, normal.y, normal.z, d);
        reflectionMat = Matrix4x4.identity;
        CalculateReflectionMatrix(ref reflectionMat, plane);

        reflection_cam.worldToCameraMatrix = cam.worldToCameraMatrix * reflectionMat;

        Vector4 viewplane = CameraSpacePlane(reflection_cam.worldToCameraMatrix, transform.position, normal);
        reflection_cam.projectionMatrix = reflection_cam.CalculateObliqueMatrix(viewplane);
        GL.invertCulling = true;
        reflection_cam.Render();
        reflection_mat.SetTexture("_MainTex", reflectionTex);


        if (depthshader)
        {
            updateDepthCam();
            Shader.SetGlobalVector("_PlanePos", transform.position);
            Shader.SetGlobalVector("_PlaneNormal", -normal);
            depthcam.RenderWithShader(depthshader, "");
            depthcam.enabled = false;
            reflection_mat.SetTexture("_depthTex", depthTex);

            RenderTexture temp = RenderTexture.GetTemporary(1024 >> downsample, 1024 >> downsample, 24);
            Graphics.Blit(reflectionTex, blurTex, blurmat, 0);
            Graphics.Blit(blurTex, temp, blurmat, 1);
            Graphics.Blit(temp, blurTex);
            RenderTexture.ReleaseTemporary(temp);
            reflection_mat.SetTexture("_blurTex", blurTex);
        }
        GL.invertCulling = false;



        isRendering = false;
    }
    void updateDepthCam()
    {
        depthcam.CopyFrom(reflection_cam);
        depthcam.worldToCameraMatrix = reflection_cam.worldToCameraMatrix;
        depthcam.projectionMatrix = reflection_cam.projectionMatrix;
        depthcam.clearFlags = CameraClearFlags.SolidColor;
        depthcam.backgroundColor = Color.white;
        depthcam.targetTexture = depthTex;
    }
    static float dot(Vector3 a,Vector3 b)
    {
        return a.x * b.x + a.y * b.y+a.z*b.z;
    }
    static void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat,Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
        reflectionMat.m01 = (-2F * plane[0] * plane[1]);
        reflectionMat.m02 = (-2F * plane[0] * plane[2]);
        reflectionMat.m03 = (-2F * plane[3] * plane[0]);

        reflectionMat.m10 = (-2F * plane[1] * plane[0]);
        reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
        reflectionMat.m12 = (-2F * plane[1] * plane[2]);
        reflectionMat.m13 = (-2F * plane[3] * plane[1]);

        reflectionMat.m20 = (-2F * plane[2] * plane[0]);
        reflectionMat.m21 = (-2F * plane[2] * plane[1]);
        reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
        reflectionMat.m23 = (-2F * plane[3] * plane[2]);
    }
    private Vector4 CameraSpacePlane(Matrix4x4 worldToCameraMatrix, Vector3 pos, Vector3 normal)
    {
        Vector3 offsetPos = pos + normal * planeOffset;
        Vector3 cpos = worldToCameraMatrix.MultiplyPoint3x4(offsetPos);
        Vector3 cnormal = worldToCameraMatrix.MultiplyVector(normal).normalized;
        float d = -dot(cpos, cnormal);
        return new Vector4(cnormal.x, cnormal.y, cnormal.z, d);
    }
}
