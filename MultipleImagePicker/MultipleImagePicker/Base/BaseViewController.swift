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

// MARK: - ㄴ 화면 비율 계산
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
}

// MARK: - ㄴ 앨범 권한 확인
extension BaseViewController {
    /// 앨범 권한 있는가?
    /// - Returns: 권한 여부 반환
    func isAlbumPermission() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    /// 앨범 권한 체크 실행
    func albumPermission() async {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:   // 허용
            return
        case .notDetermined:    // 아직 진행 안함
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    return
                } else {
                    Task {
                        await self.permissionErrorAlert()
                    }
                }
            }
        case .restricted:   // 권한을 부여할 수 없는 상황 (제한된 케이스)
            fallthrough
        case .denied:   // 거부
            fallthrough
        case .limited:  // 한계??
            Task {
                await self.permissionErrorAlert()
            }
        @unknown default:
            fatalError()
        }
    }
    
    /// 권한 관련 얼럿 띄우기 (다신 보지 않기 추가)
    func permissionErrorAlert() async {
        let alert = UIAlertController(title: "접근 권한 설정",
                                      message: "앨범 권한이 제한되어 있습다.",
                                      preferredStyle: .alert)
        
        // 설정으로 이동 액션
        let settingAction = UIAlertAction(title: "설정으로 이동하기", style: .default) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting, options: [:], completionHandler: nil)
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
