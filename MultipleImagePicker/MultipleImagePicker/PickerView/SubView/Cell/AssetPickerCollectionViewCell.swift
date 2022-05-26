//
//  AssetPickerCollectionViewCell.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/11.
//

import UIKit
import Photos

class AssetPickerCollectionViewCell: UICollectionViewCell {
    
    /// 카메라 뷰
    private lazy var cameraView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.12).cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        let centerImage = UIImageView()
        centerImage.contentMode = .scaleAspectFit
        centerImage.image = .remove
        centerImage.center = view.center
        view.addSubview(centerImage)
        
        centerImage.translatesAutoresizingMaskIntoConstraints = false
        centerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.isHidden = true
        
        return view
    }()
    
    /// 이미지 뷰
    private lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = UIColor(red: 77/255, green: 124/255, blue: 254/255, alpha: 1.0).cgColor
        imageView.layer.borderWidth = 0
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
        view.isHidden = true
        return view
    }()
    
    /// 체크 박스
    private lazy var checkNumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    /// 선택 라벨
    private lazy var selectCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 77/255, green: 124/255, blue: 254/255, alpha: 1.0)
        label.isHidden = true
        return label
    }()
    
    /// 프로그레스
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.stopAnimating()
        return indicator
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 이미지 삭제
        self.thumbImageView.isHidden = false
        self.thumbImageView.image = nil
        
        // 초기 숨기기
        self.cameraView.isHidden = true
        self.selectView.isHidden = true
        self.checkNumImageView.isHidden = true
        self.selectCountLabel.isHidden = true
    }
    
    /// 뷰 셋팅
    private func initView() {
        self.contentView.addSubview(self.cameraView)
        self.contentView.addSubview(self.thumbImageView)
        self.contentView.addSubview(self.selectView)
        self.contentView.addSubview(self.indicatorView)
        
        // 선택 뷰 내용
        self.selectView.addSubview(self.checkNumImageView)
        self.selectView.addSubview(self.selectCountLabel)
        
        // 레이아웃 설정
        self.updateLayoutView()
    }
    
    /// 뷰 레이아웃 설정
    private func updateLayoutView() {
        // 카메라 뷰 레이아웃
        self.cameraView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
        
        // 인디케이터 레이아웃
        self.indicatorView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 셀 설정
    func configureCell(_ model: AssetModel, _ selectedList: Array<SelectedPickerItem>) {
        // 선택 뷰 노출
        self.selectView.isHidden = model.isCamera
        
        if model.isCamera {
            // 썸네일 뷰 숨김
            self.thumbImageView.isHidden = true
            // 카메라 뷰 표시
            self.cameraView.isHidden = false
        } else {
            // 미디어 파일 로드
            self.loadThumbImage(model.asset)
            
            // 선택 이미지 설정
            self.setSelectedImage(model.asset, selectedList)
        }
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
            Utils.getImage(asset: asset, targetSize: thumbSize) { progress in
                
            } completion: { image in
                self.thumbImageView.image = image
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
