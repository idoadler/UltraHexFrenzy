using UnityEngine;
using System.Collections;

public class SplashScreen : MonoBehaviour 
{
	void OnMouseDown() 
	{
		GetComponent<Renderer>().enabled=false;
		GetComponent<Collider2D>().enabled=false;
		MissionManager.Init();

	}

	// Use this for initialization
	void Start () 
	{
		play();
	}
	
	public void play()
	{
		GetComponent<Renderer>().enabled=true;
		GetComponent<Collider2D>().enabled=true;
	}
}
