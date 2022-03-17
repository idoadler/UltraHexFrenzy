using UnityEngine;
using System.Collections;

public class ColorFullLights : MonoBehaviour {

	// Use this for initialization
	void Start () {
	GetComponent<Renderer>().sortingLayerName="Front";
		GetComponent<Renderer>().sortingOrder=3;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
