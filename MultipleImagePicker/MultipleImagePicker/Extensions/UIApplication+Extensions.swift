//
//  UIApplication+Extensions.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/04/07.
//

import UIKit

// MARK: - ㄴ UIApplication 관련 확장
extension UIApplication {
    /// 윈도우 추출
    /// 세부적으로 체크 진행
    @objc(currentWindow)
    var currentWindow: UIWindow? {
        connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    }
    
    // 윈도우 추출
    // [주의] iOS13 이상 부터 connectedScenes 을 사용할 수 있다
    @objc(getWindow)
    var getWindow: UIWindow? {
        connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
    }
}
