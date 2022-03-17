using UnityEngine;

[RequireComponent (typeof (SpriteRenderer))]
public class ScoreScreen : MonoBehaviour 
{

	public GameObject CreditHeartHex;
	public GameObject Credit;

	private const float MIN_SHOW_TIME = 5f;
	public TextMesh score1;
	public TextMesh score2;
	public GameObject winner1;
	public GameObject winner2;

	public Sprite player1Won;
	public Sprite player2Won;
	public Sprite gameTie;
	public Sprite playAgain;



	void OnMouseDown() 
	{
		gameObject.SetActive(false);
		MissionManager.Init();
		CreditHeartHex.SetActive(false);
		Credit.SetActive(false);
	}

	public void play(int s1, int s2)
	{
	

		if (s1 == s2)
			GetComponent<SpriteRenderer>().sprite = gameTie;
		else if (s1 > s2)
			GetComponent<SpriteRenderer>().sprite = player1Won;
		else 
			GetComponent<SpriteRenderer>().sprite = player2Won;


		GetComponent<Collider2D>().enabled=false;
		gameObject.SetActive(true);
		score1.text = ""+s1;
		score2.text = ""+s2;
		winner1.SetActive(s1>=s2);
		winner2.SetActive(s2>=s1);
		Invoke("enableLeave",MIN_SHOW_TIME);
	}

	private void enableLeave()
	{
//		CreditHeartHex.SetActive(true);
		Credit.SetActive(true);
	//	CreditHeartHex.renderer.enabled=true;
		GetComponent<SpriteRenderer>().sprite = playAgain;
		GetComponent<Collider2D>().enabled=true;
	}
}
