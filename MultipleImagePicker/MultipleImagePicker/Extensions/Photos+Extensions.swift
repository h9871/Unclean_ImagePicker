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
    
    /// 타입에 따른 갯 수 구하기
    func getAlbumInfo(mediaType: Array<PHAssetMediaType>) -> (firstObject: PHAsset?, count: Int) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        // 조회 조건 작성
        var queryArray: [NSPredicate] = []
        
        // 선택 캘린더를 반복하여 쿼리문 만들기
        for type in mediaType {
            // 각 아이템의 쿼리
            let predicate = NSPredicate(format: "mediaType = %d", type.rawValue)
            // 쿼리 배열에 넣기
            queryArray.append(predicate)
        }
        
        // 쿼리 배열이 없으면 찾을 필요도 없다
        if queryArray.count < 1 { return (firstObject: nil, count: 0) }
        
        // 쿼리 배열에 맞추어 완전체 쿼리 만들기 (또는 으로 설정해야 여러개를 조사한다)
        let query = NSCompoundPredicate(type: .or, subpredicates: queryArray)
        fetchOptions.predicate = query
        
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return (
            firstObject: result.firstObject,
            count: result.count
        )
    }
}
