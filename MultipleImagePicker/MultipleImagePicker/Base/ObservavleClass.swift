//
//  ObservavleClass.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/04/14.
//

import Foundation

final class Observable<T> {
    // MARK: - Typelias
    typealias Listener = (T) -> Void
    
    /// 리스너
    var listener: Listener?
    
    /// 값
    var value: T {
        didSet {
            // 리스너 실행
            self.listener?(value)
        }
    }
    
    /// 생성자
    init(_ value: T) {
        self.value = value
    }
    
    ///
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
