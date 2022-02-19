using System;
using System.IO;
using UnityEditor;
using UnityEditor.AddressableAssets;
using UnityEngine;

namespace WizardsEditor.Custom
{
    public class UpdateAddressables : Editor
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
                // ignored
            }
        }

        // return list of asset paths found under dir
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
            // get addressable package
            var adrSettings = AddressableAssetSettingsDefaultObject.Settings;
            var usrGrp = adrSettings.FindGroup(groupName);
            if (!usrGrp)
            {
                throw new Exception($"Addressable: can't find group {groupName}");
            }

            // Add asset to group
            var guid = AssetDatabase.AssetPathToGUID(path);
            var entry = adrSettings.CreateOrMoveEntry(guid, usrGrp);
            if (entry == null)
            {
                throw new Exception($"Addressable : can't add {path} to group {groupName}");
            }

            // simplify addressName
            //entry.SetAddress(entry.MainAsset.name);
            entry.SetAddress("UserTexture");
            Debug.LogFormat("Added entry: {0}", entry.AssetPath);
        }
    }
}