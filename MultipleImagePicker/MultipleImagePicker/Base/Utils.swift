//
//  Utils.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/22.
//

import Foundation

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
    
}
