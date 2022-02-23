using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

namespace Default
{
    public class LoadByReference : MonoBehaviour
    {
        public AssetReference reference;
        private AsyncOperationHandle<GameObject> _asyncHandle;

        public void LoadAsset()
        {
            if (IsLoaded(_asyncHandle)) return;
            _asyncHandle = reference.InstantiateAsync(transform);
            _asyncHandle.Completed += AsyncHandleOnCompleted;
        }

        public void UnloadAsset()
        {
            if (IsLoaded(_asyncHandle))
            {
                reference.ReleaseInstance(_asyncHandle.Result);
            }
        }

        private bool IsLoaded(AsyncOperationHandle _handle)
        {
            return _handle.IsValid() && _handle.IsDone;
        }

        private void AsyncHandleOnCompleted(AsyncOperationHandle<GameObject> operation)
        {
            if (operation.Status == AsyncOperationStatus.Failed)
            {
                Debug.LogFormat("reference: {0} could not be loaded", reference.RuntimeKey);
            }
        }

        private void OnDestroy()
        {
            UnloadAsset();
        }
    }
}