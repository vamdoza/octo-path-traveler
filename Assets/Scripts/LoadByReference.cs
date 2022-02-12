using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

namespace Default
{
    public class LoadByReference : MonoBehaviour
    {
        public AssetReference reference;
        private AsyncOperationHandle<GameObject> _asyncOperationHandle;

        public void LoadAsset()
        {
            if (IsLoaded(_asyncOperationHandle)) return;

            _asyncOperationHandle = reference.LoadAssetAsync<GameObject>();
            _asyncOperationHandle.Completed += AsyncHandleOnCompleted;
        }

        private bool IsLoaded(AsyncOperationHandle _handle)
        {
            return _handle.IsValid() && _handle.IsDone;
        }

        private void AsyncHandleOnCompleted(AsyncOperationHandle<GameObject> operation)
        {
            if (operation.Status == AsyncOperationStatus.Succeeded)
            {
                Instantiate(reference.Asset, transform);
            }
            else
            {
                Debug.LogFormat("reference: {0} could not be loaded", reference.RuntimeKey);
            }
        }

        private void OnDestroy()
        {
            reference.ReleaseAsset();
        }
    }
}