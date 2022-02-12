using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

namespace Default
{
    public class LoadByAddress : MonoBehaviour
    {
        private string address = "Assets/Prefabs/AddressableCube.prefab";
        private AsyncOperationHandle<GameObject> _asyncHandle;

        public void LoadAsset()
        {
            // isLoaded
            if (_asyncHandle.IsValid() && _asyncHandle.IsDone) return;
            _asyncHandle = Addressables.LoadAssetAsync<GameObject>(address);
            _asyncHandle.Completed += AsyncOperationHandleOnCompleted;
        }

        private void AsyncOperationHandleOnCompleted(AsyncOperationHandle<GameObject> operation)
        {
            if (operation.Status == AsyncOperationStatus.Succeeded)
            {
                Instantiate(operation.Result, transform);
            }
            else
            {
                Debug.LogFormat("address: {0} failed to load", address);
            }
        }

        private void OnDestroy()
        {
            Addressables.Release(_asyncHandle);
        }
    }
}