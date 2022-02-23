using UnityEngine;

namespace Default
{
    public class CubeRotator : MonoBehaviour
    {
        public float angularSpeed = 30;

        private void Update()
        {
            transform.RotateAround(transform.position, transform.up + transform.right, Time.deltaTime * angularSpeed);
        }
    }
}