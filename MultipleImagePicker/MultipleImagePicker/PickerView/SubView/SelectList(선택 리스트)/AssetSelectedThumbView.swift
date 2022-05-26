//
//  AssetSelectedThumbView.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/16.
//

import UIKit

/*
 선택 중인 뷰 썸네일
 */
class AssetSelectedThumbView: UIView {
    
    /// 썸네일 이미지 뷰
    private lazy var thumbImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// 닫기 버튼
    private lazy var closeImageBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    /// 전체 닫기 버튼
    private lazy var closeBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        
        return button
    }()
    
    // MARK: - 데이터
    private lazy var item: SelectedPickerItem? = nil
    
    // MARK: - 핸들러
    private lazy var closeHandler: ((SelectedPickerItem) -> ())? = nil
    
    // 생성자
    init(frame: CGRect, item: SelectedPickerItem, closeHandelr: @escaping ((SelectedPickerItem) -> ())) {
        super.init(frame: frame)
        self.item = item
        self.closeHandler = closeHandelr
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ㄴ 뷰 셋팅
extension AssetSelectedThumbView {
    /// 뷰 초기 설정
    private func initView() {
        self.addSubview(self.thumbImage)
        self.addSubview(self.closeImageBtn)
        self.closeImageBtn.addTarget(self, action: #selector(self.didTappedCloseBtn(_:)), for: .touchUpInside)
        self.addSubview(self.closeBtn)
        self.closeBtn.addTarget(self, action: #selector(self.didTappedCloseBtn(_:)), for: .touchUpInside)
        
        self.updateLayoutView()
    }
    
    /// 뷰 레이아웃 설정
    private func updateLayoutView() {
        self.thumbImage.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(3)
            make.trailing.equalToSuperview().offset(-3)
            make.leading.bottom.equalToSuperview()
        }
        
        self.closeImageBtn.snp.remakeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        self.closeBtn.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 뷰 로드
        self.initLoadView()
    }
    
    /// 뷰 로드
    private func initLoadView() {
        // 이미지 설정
        self.thumbImage.image = self.item?.thumbImage
    }
}

// MARK: - ㄴ 데이터 관련
extension AssetSelectedThumbView {
    /// 아이템 반환
    func getItem() -> SelectedPickerItem? {
        return self.item
    }
}

// MARK: - ㄴ 버튼 동작 관련
extension AssetSelectedThumbView {
    /// 닫기 버튼 클릭 시
    /// - Parameter sender: 닫기 버튼
    @objc
    private func didTappedCloseBtn(_ sender: UIButton) {
        guard let item = self.item else { return }
        self.closeHandler?(item)
    }
}
