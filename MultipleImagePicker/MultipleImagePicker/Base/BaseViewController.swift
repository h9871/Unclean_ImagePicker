//
//  BaseViewController.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/11.
//

import UIKit
import Photos

/// 베이스 뷰 컨트롤러
class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - ㄴ 화면 관련
extension BaseViewController {
    /// 화면 비율 계산 (regular, ragular)
    /// - Parameter trait: 뷰 화면 비율
    /// - Returns: 맞는지
    func isScreenTraitRR(trait: UITraitCollection) -> Bool {
        var isTraitRR:Bool = false
        
        // # 위치값에 따른 화면 전환
        switch (trait.horizontalSizeClass, trait.verticalSizeClass) {
        case (.regular, .regular):
           isTraitRR = true
        default:
           isTraitRR = false
           break
        }
        
        return isTraitRR
    }
    
    /// modal 스타일이 풀 화면인지 체크
    /// - Parameter style: 모달 스타일
    /// - Returns: 확인 여부
    func isFullScreen(style: UIModalPresentationStyle) -> Bool {
        var isFull = false
        
        switch style {
        case .fullScreen: isFull = true
        case .pageSheet: fallthrough
        case .formSheet: fallthrough
        case .currentContext: fallthrough
        case .custom: break
        case .overFullScreen: isFull = true
        case .overCurrentContext: fallthrough
        case .popover: fallthrough
        case .blurOverFullScreen: fallthrough
        case .none: fallthrough
        case .automatic: break
        @unknown default:
            fatalError()
        }
        return isFull
    }
}

// MARK: - ㄴ 앨범 권한 확인
extension BaseViewController {
    /// 앨범 권한 있는가?
    /// - Returns: 권한 여부 반환
    func isAlbumPermission() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    /// 앨범 권한 체크 실행
    func albumPermission(_ complete: @escaping (() -> Void))  {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:   // 허용
            complete()
        case .notDetermined:    // 아직 진행 안함
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    complete()
                } else {
                    DispatchQueue.main.async {
                        self.permissionErrorAlert()
                    }
                }
            }
        case .restricted:   // 권한을 부여할 수 없는 상황 (제한된 케이스)
            fallthrough
        case .denied:   // 거부
            fallthrough
        case .limited:  // 한계??
            DispatchQueue.main.async {
                self.permissionErrorAlert()
            }
        @unknown default:
            fatalError()
        }
    }
    
    /// 권한 관련 얼럿 띄우기 (다신 보지 않기 추가)
    func permissionErrorAlert() {
        let alert = UIAlertController(title: "접근 권한 설정",
                                      message: "앨범 권한이 제한되어 있습다.",
                                      preferredStyle: .alert)
        
        // 설정으로 이동 액션
        let settingAction = UIAlertAction(title: "설정으로 이동하기", style: .default) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting, options: [:]) { _ in 
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        alert.addAction(settingAction)
        
        // 뒤로 가기 및 화면 닫기 액션
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
