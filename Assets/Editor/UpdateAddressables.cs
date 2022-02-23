using System;
using System.IO;
using UnityEditor;
using UnityEditor.AddressableAssets;
using UnityEngine;

namespace WizardsEditor.Custom
{
    /// <summary>
    /// WIP
    /// Simple Tool to update addressable bundle from code,
    /// the goal is test how to automate bundling assets from external sources like cloud storage.
    /// </summary>
    public static class UpdateAddressables
    {
        private const string userAssetsPath = "Assets/UserAssets";
        private const string userAssetsGroup = "UserAssets";

        [MenuItem("Wizards/UpdateAddressables %g")]
        private static void BuildAddressables()
        {
            ImportAssetFromExternalSource();
            var assetPaths = GetAllAssetsIn(userAssetsPath);
            foreach (var path in assetPaths)
            {
                AddAssetToGroup(userAssetsGroup, path);
            }
        }

        private static void ImportAssetFromExternalSource()
        {
            // the asset path is meant to be provide from ci/cd pipeline
            const string asset = "E:/UserAssets/51e91bc4bd25ce56bc4963ea01bb1527.jpg";
            var newAssetPath = Path.Combine(userAssetsPath, Path.GetFileName(asset));
            var userAssets = Application.dataPath.Replace("/Assets", $"/{newAssetPath}");

            Debug.Log($"{asset} to {userAssets}");
            try
            {
                File.Copy(asset, userAssets, true);
                AssetDatabase.ImportAsset(newAssetPath);
            }
            catch (Exception ex)
            {
                Debug.LogError(ex.Message);
            }
        }

        private static string[] GetAllAssetsIn(string path)
        {
            var foundAssets = AssetDatabase.FindAssets(string.Empty, new[] {path});

            for (var i = 0; i < foundAssets.Length; i++)
            {
                foundAssets[i] = AssetDatabase.GUIDToAssetPath(foundAssets[i]);
            }

            return foundAssets;
        }

        private static void AddAssetToGroup(string groupName, string path)
        {
            var addressableSettings = AddressableAssetSettingsDefaultObject.Settings;
            var usrGrp = addressableSettings.FindGroup(groupName);
            if (!usrGrp)
            {
                throw new Exception($"Addressable: can't find group {groupName}");
            }

            var guid = AssetDatabase.AssetPathToGUID(path);
            var entry = addressableSettings.CreateOrMoveEntry(guid, usrGrp);
            if (entry == null)
            {
                throw new Exception($"Addressable : can't add {path} to group {groupName}");
            }

            // simplify addressName
            entry.SetAddress(entry.MainAsset.name);
        }
    }
}