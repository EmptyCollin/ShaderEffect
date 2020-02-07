using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class SphereControl : MonoBehaviour {

    public Material planeMat;
    public Material forceFieldMat;

    private GameObject camera;
    // Use this for initialization
    void Start () {
        planeMat.SetFloat("_Radius", 5);
        camera = GameObject.Find("MainCamera");
        forceFieldMat.SetVector("_CameraPos", camera.transform.position);
        //GetComponent<Material>().SetVector("_CameraPos", new Vector3(10, 0, 11));
    }
	
	// Update is called once per frame
	void Update () {
        float z_offset = 0.0f;
        if (Input.GetKey(KeyCode.Q)) z_offset = 50 * Time.deltaTime;
        if (Input.GetKey(KeyCode.E)) z_offset = -50 * Time.deltaTime;

        transform.Translate(Input.GetAxis("Horizontal") * 50 * Time.deltaTime, z_offset,
                            Input.GetAxis("Vertical") * 50 * Time.deltaTime);
        planeMat.SetVector("_Center", transform.position);
        planeMat.SetFloat("_Radius", planeMat.GetFloat("_Radius") + z_offset/5);
        forceFieldMat.SetVector("_CameraPos", camera.transform.position);
        double malti = Math.Abs(Math.Sin(Time.realtimeSinceStartup)/4)*20;
        forceFieldMat.SetFloat("_Malti", (float)malti);
        forceFieldMat.SetVector("_Center", transform.position);
    }
}
