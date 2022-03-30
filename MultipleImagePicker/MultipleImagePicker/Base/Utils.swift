//
//  Utils.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/22.
//

import Foundation
import Photos
import UIKit

/// 뷰 기본 베이스
protocol SetBaseView {
    /// 뷰 생성
    func initView()
    /// 뷰 레이아웃 설정
    func updateLayoutView()
    /// 뷰 로드
    func initLoadView()
}

/// 테이블 뷰 기본 베이스
protocol SetTableView: SetBaseView {
    /// 테이블 뷰 셋팅
    func initTableView()
}

/// 컬렉션 뷰 기본 베이스
protocol SetCollectionView: SetBaseView {
    /// 컬렉션 뷰 셋팅
    func initCollectionView()
}

class Utils {
    /// 이미지 매니저
    private static let manager = PHImageManager.default()
    
    /// 이미지 다운로드
    /// - Parameters:
    ///   - asset: 미디어
    ///   - targetSize: 사이즈
    ///   - progressValue: 프로그레스 핸들러
    ///   - completion: 완료 핸들러
    class func getImage(asset: PHAsset, targetSize: CGSize, progressValue: ((Double) -> Void)?, completion: @escaping (UIImage?) -> Void) {
        let option = PHImageRequestOptions()
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        option.progressHandler = {(progress, error, stop, info) in
            progressValue?(progress)
        }
        
        DispatchQueue.global().async {
            self.manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: option) { image, info in
                // 임시 썸네일이 출력되므로 해당 내용은 진행하지 않는다
                guard let info = info,
                      let realImageKey = info["PHImageResultIsDegradedKey"] as? Int,
                      realImageKey == 0 else {
                    return
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    /// 동영상 다운로드
    /// - Parameters:
    ///   - asset: 미디어
    ///   - targetSize: 사이즈
    ///   - progressValue: 프로그레스 핸들러
    ///   - completion: 반환 핸들러
    class func getVideo(asset: PHAsset, targetSize: CGSize, progressValue: ((Double) -> Void)?, completion: @escaping (AVAsset?) -> Void) {
        let option = PHVideoRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (progress, error, stop, info) in
            progressValue?(progress)
        }
        
        DispatchQueue.global().async {
            self.manager.requestAVAsset(forVideo: asset, options: option) { video, audio, info in
                DispatchQueue.main.async {
                    completion(video)
                }
            }
        }
    }
}
