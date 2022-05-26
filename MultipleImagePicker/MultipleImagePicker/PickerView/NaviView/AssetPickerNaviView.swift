//
//  AssetPickerNaviView.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/04/01.
//

import UIKit
import SnapKit

protocol AssetPickerNaviViewDelegate {
    /// 뒤로가기 버튼 클릭 시
    func didTappedBackBtn(animated: Bool, completion: (() -> Void)?)
    /// 앨범 리스트 버튼 클릭 시
    func didTappedAlbumListBtn(isSelect: Bool)
    /// 확인 버튼 클릭 시
    func didTappedConfirmBtn()
}

class AssetPickerNaviView: UIView {
    /// 생성자
    /// - Returns: 뷰
    class func instance(delegate: AssetPickerNaviViewDelegate? = nil) -> AssetPickerNaviView {
        let view = AssetPickerNaviView()
        view.delegate = delegate
        view.initView()
        return view
    }
    
    // MARK: - 뷰
    /// 메인 스택 뷰
    private lazy var parentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(UIView())
        return view
    }()
    
    /// 배경 뷰
    private lazy var naviItemView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 뒤로가기 버튼
    private lazy var backBtn: UIButton = {
        let button = UIButton(type: .custom, primaryAction: UIAction(handler: { action in
            self.delegate?.didTappedBackBtn(animated: true, completion: nil)
        }))
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        return button
    }()
    
    /// 앨범 리스트 버튼
    private lazy var albumListBtn: UIButton = {
        let button = UIButton(type: .custom, primaryAction: UIAction(handler: { action in
            let isSelect = !self.albumListBtn.isSelected
            self.updateAlbumListBtn(isSelect)
            self.delegate?.didTappedAlbumListBtn(isSelect: isSelect)
        }))
        button.setTitle("사진첩", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    /// 갯 수 버튼
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        return label
    }()
    
    /// 확인 버튼
    private lazy var confirmBtn: UIButton = {
        let button = UIButton(type: .custom, primaryAction: UIAction(handler: { action in
            self.delegate?.didTappedConfirmBtn()
        }))
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        return button
    }()
    
    // MARK: - 데이터
    /// 델리게이트
    lazy var delegate: AssetPickerNaviViewDelegate? = nil
    /// 높이
    lazy var height: CGFloat = 60
    
}

extension AssetPickerNaviView: SetBaseView {
    func initView() {
        // 각 뷰 생성
        self.addSubview(self.parentStackView)
        self.parentStackView.addArrangedSubview(self.naviItemView)
        
        self.naviItemView.addSubview(self.backBtn)
        self.naviItemView.addSubview(self.albumListBtn)
        self.naviItemView.addSubview(self.countLabel)
        self.naviItemView.addSubview(self.confirmBtn)
        
        // 레이아웃 설정
        self.updateLayoutView()
        
        // 뷰 로드
        self.initLoadView()
    }
    
    func updateLayoutView() {
        // 부모 뷰 레이아웃 설정
        self.parentStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 아이템 뷰 레이아웃 설정
        self.naviItemView.snp.remakeConstraints { make in
            make.height.equalTo(self.height)
        }
        
        // 뒤로가기 버튼 레이아웃 설정
        self.backBtn.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(30)
        }
        
        // 앨범 리스트 버튼 레이아웃 설정
        self.albumListBtn.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        // 확인 버튼 레이아웃 설정
        self.confirmBtn.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(30)
        }
        
        // 갯 수 라벨 레이아웃 설정
        self.countLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(self.confirmBtn.snp.centerY)
            make.trailing.equalTo(self.confirmBtn.snp.leading)
        }
    }
    
    func initLoadView() {
        
    }
}

// MARK: - ㄴ 타이틀 관련
extension AssetPickerNaviView {
    /// 네비게이션 타이틀 설정
    /// - Parameter title: 타이틀
    func setNaviTitle(_ title: String) {
        self.albumListBtn.setTitle(title, for: .normal)
    }
}

// MARK: - ㄴ 앨범 리스트 관련
extension AssetPickerNaviView {
    /// 앨범 리스트 버튼 업데이트
    /// - Parameter isSelect: 선택 여부
    func updateAlbumListBtn(_ isSelect: Bool) {
        self.albumListBtn.isSelected = isSelect
        
        UIView.animate(withDuration: 0.2) {
            let angle: CGFloat = isSelect ? .pi : 0
            self.albumListBtn.imageView?.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}

// MARK: - ㄴ 카운트 관련
extension AssetPickerNaviView {
    /// 카운트 라벨 업데이트
    /// - Parameter count: 갯수
    func updateCountLabel(_ count: Int) {
        self.countLabel.isHidden = (count < 1)
        self.countLabel.text = "\(count)"
    }
}
