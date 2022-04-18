//
//  AssetPickerViewModel.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/04/14.
//

import UIKit
import Photos

/// 피커 옵션
struct PickerConfiguration {
    /// 모달 타입
    var isFull: Bool = false
    /// 피커 타입
    var type: PickerType = .ALL
    /// 단일선택, 다중선택
    var isOnePick = false
}

/// 피커 타입
enum PickerType {
    /// 전체
    case ALL
    /// 사진
    case PHOTO
    /// 비디오
    case VIDEO
}

/// 선택 아이템
struct SelectedPickerItem {
    /// 고유 아이디 (Asset 의 고유 ID)
    var id: String = ""
    /// 선택 번째
    var selectNum: Int = 0
    /// 미디어 데이터
    var asset: PHAsset = PHAsset()
    /// 썸네일 이미지
    var thumbImage: UIImage?
}

class AssetPickerViewModel {
    /// 썸네일 사이즈
    let THUMB_HEIGHT: CGFloat = 50
    
    /// 사진 리스트
    let assetList: Observable<Array<PHAsset>> = Observable([])
    /// 선택 리스트
    let selectList: Observable<Array<SelectedPickerItem>> = Observable([])
    /// 선택 아이템
    let selectItem: Observable<(isRemove: Bool, item: SelectedPickerItem)> = Observable((false, SelectedPickerItem()))
    
    init() {
        
    }
}

// MARK: - ㄴ 데이터 가공 관련
extension AssetPickerViewModel {
    /// 선택 리스트 포맷하여 반환
    /// - Returns: 포맷된 리스트
    func getSelectList() -> Array<PHAsset> {
        return self.selectList.value.map { $0.asset }
    }
}

// MARK: - ㄴ 미디어 파일 관련
extension AssetPickerViewModel {
    /// 미디어 Fetch 옵션
    /// - Returns: 옵션
    private func getFetchOption() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        return fetchOptions
    }
    
    /// 미디어 리스트 추출
    /// - Parameter type: 타입
    func fetchAssetList(type: PickerType) {
        var fetchAssets = PHFetchResult<PHAsset>()
        switch type {
        case .ALL: fetchAssets = PHAsset.fetchAssets(with: self.getFetchOption())
        case .PHOTO: fetchAssets = PHAsset.fetchAssets(with: .image, options: self.getFetchOption())
        case .VIDEO: fetchAssets = PHAsset.fetchAssets(with: .video, options: self.getFetchOption())
        }
        
        // 데이터 설정
        var formatList: Array<PHAsset> = []
        fetchAssets.enumerateObjects { asset, count, stop in
            formatList.append(asset)
        }
        
        // 아이템 설정
        self.assetList.value = formatList
    }
    
    /// 앨범 리스트 선택
    /// - Parameter collection: 선택된 컬렉션
    func fetchAlbumAssetList(collection: PHAssetCollection) {
        let fetchAssets = PHAsset.fetchAssets(in: collection, options: self.getFetchOption())
        
        // 데이터 설정
        var formatList: Array<PHAsset> = []
        fetchAssets.enumerateObjects { asset, count, stop in
            formatList.append(asset)
        }
        
        // 아이템 설정
        self.assetList.value = formatList
    }
}

// MARK: - ㄴ 선택 리스트 관련
extension AssetPickerViewModel {
    /// 아이템 클릭 이벤트
    func selectedAsset(item: PHAsset) {
        // 이미 선택 중인지 확인
        for element in self.selectList.value where element.id == item.localIdentifier {
            // 선택해제
            self.removeSelected(id: element.id)
            
            // 선택 정보 설정
            self.selectItem.value = (true, element)
            return
        }
        
        // 선택 중이 아니라면 추가
        let thumbSize = CGSize(width: UIScreen.main.scale * self.THUMB_HEIGHT, height: UIScreen.main.scale * self.THUMB_HEIGHT)
        Utils.getImage(asset: item, targetSize: thumbSize) { progress in
            
        } completion: { image in
            let makeItem = SelectedPickerItem(id: item.localIdentifier,
                                              selectNum: self.selectList.value.count + 1,
                                              asset: item,
                                              thumbImage: image)
            var tempList = self.selectList.value
            tempList.append(makeItem)
            
            // 선택 정보 설정
            self.selectItem.value = (false, makeItem)
            
            // 아이템 설정
            self.selectList.value = tempList
        }
    }
    
    /// 선택 해제 처리
    /// - Parameter id: 선택해제할 미디어의 아이디
    func removeSelected(id: String) {
        // 없으면 진행하지 않는다
        if self.selectList.value.count < 1 { return }
        
        // 선택해제 처리 후 순서 재설정
        self.selectList.value = self.selectList.value.filter { $0.id != id }.enumerated().map({ (index, item) -> SelectedPickerItem in
            var tempItem = item
            tempItem.selectNum = index + 1
            return tempItem
        })
    }
}
