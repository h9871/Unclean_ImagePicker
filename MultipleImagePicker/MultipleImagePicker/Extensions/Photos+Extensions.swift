//
//  Photos+Extensions.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/29.
//

import Photos

// MARK:- ㄴ 앨범 이미지 셋 확장
extension PHAssetCollection {
    /// 사진 갯수
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }

    /// 동영상 갯수
    var videoCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}
