//
//  AssetPickerSelectListView.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/11.
//

import UIKit
import SnapKit
import Photos

protocol AssetPickerSelectListViewDelegate {
    /// 삭제 버튼 클릭 시
    func didTappedCloseBtn(_ item: SelectedPickerItem)
}

class AssetPickerSelectListView: UIView {
    /// 생성자
    /// - Returns: 뷰
    class func instance() -> AssetPickerSelectListView {
        let view = AssetPickerSelectListView()
        view.initView()
        return view
    }

    /// 스크롤 뷰
    private lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()
    
    /// 썸네일 스택 뷰
    private lazy var thumbStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        return stackView
    }()
    
    // MARK: - 데이터
    lazy var delegate: AssetPickerSelectListViewDelegate? = nil
}

// MARK: - ㄴ 뷰 셋팅
extension AssetPickerSelectListView {
    /// 뷰 생성
    private func initView() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.thumbStackView)
        
        self.updateLayoutView()
    }
    
    /// 뷰 레이아웃 설정
    private func updateLayoutView() {
        // 1. 스크롤 뷰 레이아웃 설정
        self.scrollView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(53)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview()
        }
        
        // 2. 스택 뷰 레이아웃 설정
        self.thumbStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(1)
        }
        
        // 화면 로드
        self.initLoadView()
    }
    
    /// 화면 로드
    private func initLoadView() {
        // 스크롤 감추기
        self.scrollView.showsHorizontalScrollIndicator = false
    }
}

// MARK: - ㄴ 데이터 관련
extension AssetPickerSelectListView {
    /// 리스트 추가
    /// - Parameter item: 추가할 아이템
    func addPickerItem(_ item: SelectedPickerItem) {
        let thumbView = AssetSelectedThumbView(frame: .zero, item: item) { item in
            self.removePickerItem(item)
            self.delegate?.didTappedCloseBtn(item)
        }
        self.thumbStackView.addArrangedSubview(thumbView)
        thumbView.widthAnchor.constraint(equalToConstant: 53).isActive = true
        self.layoutIfNeeded()
    }
    
    /// 리스트 삭제
    /// - Parameter item: 삭제할 아이템
    func removePickerItem(_ item: SelectedPickerItem) {
        self.thumbStackView.arrangedSubviews.forEach { thumbView in
            guard let thumbView = thumbView as? AssetSelectedThumbView else {
                return
            }
            
            // 아이디가 같다면 삭제 진행
            if item.id == thumbView.getItem()?.id {
                thumbView.removeFromSuperview()
                return
            }
        }
    }
}
