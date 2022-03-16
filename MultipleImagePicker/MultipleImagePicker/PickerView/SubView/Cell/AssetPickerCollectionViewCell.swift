//
//  AssetPickerCollectionViewCell.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/11.
//

import UIKit
import Photos

class AssetPickerCollectionViewCell: UICollectionViewCell {
    
    /// 이미지 뷰
    private lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = UIColor(red: 77/255, green: 124/255, blue: 254/255, alpha: 1.0).cgColor
        imageView.layer.borderWidth = 0
        return imageView
    }()
    
    /// 선택 뷰
    private lazy var selectView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.68).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = view.frame.height / 2
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 체크 박스
    private lazy var checkNumImageView: UIImageView = {
        return UIImageView()
    }()
    
    /// 선택 라벨
    private lazy var selectCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 77/255, green: 124/255, blue: 254/255, alpha: 1.0)
        return label
    }()
    
    /// 이미지 매니저
    private let manager = PHImageManager.default()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 하일라이트일때 액션 체크중.
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                    self.thumbImageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                })
            }
            else {
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                    self.thumbImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            }
        }
    }
    
    /// 뷰 셋팅
    private func initView() {
        self.contentView.addSubview(self.thumbImageView)
        self.contentView.addSubview(self.selectView)
        
        // 선택 뷰 내용
        self.selectView.addSubview(self.checkNumImageView)
        self.checkNumImageView.isHidden = true
        self.selectView.addSubview(self.selectCountLabel)
        self.selectCountLabel.isHidden = true
        
        // 레이아웃 설정
        self.updateLayoutView()
    }
    
    /// 뷰 레이아웃 설정
    private func updateLayoutView() {
        // 썸네일 이미지 뷰 레이아웃
        self.thumbImageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 선택 뷰 레이아웃
        self.selectView.snp.remakeConstraints { make in
            make.top.equalTo(self.thumbImageView).offset(8)
            make.trailing.equalTo(self.thumbImageView).offset(-8)
            make.width.height.equalTo(26)
        }
        
        // 체크 표시
        self.checkNumImageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 번호 표시
        self.selectCountLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 셀 설정
    func configureCell(_ asset: PHAsset, _ selectedList: Array<SelectedPickerItem>) {
        // 미디어 파일 로드
        self.loadThumbImage(asset)
        
        // 선택 이미지 설정
        self.setSelectedImage(asset, selectedList)
    }
}

// MARK: - ㄴ 셀 디자인 관련
extension AssetPickerCollectionViewCell {
    /// 이미지 로드
    /// - Parameter asset: 미디어 파일
    private func loadThumbImage(_ asset: PHAsset) {
        let scale = UIScreen.main.scale
        let thumbSize = CGSize(width: scale * self.thumbImageView.frame.width, height: scale * self.thumbImageView.frame.height)
        
        switch asset.mediaType {
        case .video: fallthrough
        case .audio: fallthrough
        default:
            DispatchQueue.global().async {
                self.manager.requestImage(for: asset, targetSize: thumbSize, contentMode: .aspectFill, options: nil) { image, info in
                    DispatchQueue.main.async {
                        self.thumbImageView.image = image
                    }
                }
            }
        }
    }
    
    /// 선택 뷰 디자인 설정
    /// - Parameters:
    ///   - asset: 미디어 파일
    ///   - selectedList: 선택 아이템 리스트
    private func setSelectedImage(_ asset: PHAsset, _ selectedList: Array<SelectedPickerItem>) {
        // 선택 여부 확인
        let (isSelected, index) = isSelectedItem(asset, selectedList)
        
        if isSelected {
            self.selectCountLabel.isHidden = false
            self.selectCountLabel.text = "\(index)"
            
            self.thumbImageView.layer.borderWidth = 3
        } else {
            self.selectCountLabel.isHidden = true
            self.selectCountLabel.text = ""
            
            self.thumbImageView.layer.borderWidth = 0
        }
    }
    
    /// 선택 여부 확인 하기
    /// - Parameters:
    ///   - asset: 미디어 파일
    ///   - selectedItem: 선택 아이템 리스트
    /// - Returns: 선택중, 몇 번째 인지
    private func isSelectedItem(_ asset: PHAsset, _ selectedItem: Array<SelectedPickerItem>) -> (Bool, Int) {
        if selectedItem.count < 1 { return (false, 0) }
        
        for element in selectedItem where element.id == asset.localIdentifier {
            return (true, element.selectNum)
        }
        
        return (false, 0)
    }
}
