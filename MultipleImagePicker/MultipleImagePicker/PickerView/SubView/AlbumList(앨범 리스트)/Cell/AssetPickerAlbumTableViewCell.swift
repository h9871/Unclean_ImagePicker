//
//  AssetPickerAlbumTableViewCell.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/30.
//

import UIKit
import Photos

class AssetPickerAlbumTableViewCell: UITableViewCell {
    
    // MARK: - 상수
    let THUMB_IMAGE_SIZE: CGFloat = 40

    /// 이미지 뷰
    private lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 스택 뷰
    private lazy var labelStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()
    
    /// 타이틀 라벨
    private lazy var albumTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 15)
        label.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
        label.isHidden = true
        return label
    }()
    
    /// 미디어 갯수 라벨
    private lazy var albumMediaCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 15)
        label.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
        label.isHidden = true
        return label
    }()
    
    /// 이미지 매니저
    private let manager = PHImageManager.default()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 뷰 셋팅
    private func initView() {
        self.contentView.addSubview(self.thumbImageView)
        self.contentView.addSubview(self.labelStackView)
        
        // 선택 뷰 내용
        self.labelStackView.addArrangedSubview(self.albumTitleLabel)
        self.labelStackView.addArrangedSubview(self.albumMediaCountLabel)
        
        // 레이아웃 설정
        self.updateLayoutView()
    }
    
    /// 뷰 레이아웃 설정
    private func updateLayoutView() {
        // 썸네일 이미지 뷰 레이아웃
        self.thumbImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-19)
            make.width.equalTo(self.THUMB_IMAGE_SIZE)
        }
        
        // 선택 뷰 레이아웃
        self.labelStackView.snp.remakeConstraints { make in
            make.top.equalTo(self.thumbImageView.snp.top)
            make.bottom.equalTo(self.thumbImageView.snp.bottom)
            make.leading.equalTo(self.thumbImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    /// 셀 설정
    func configureCell(_ album: AlbumList) {
        if album.name.count > 0 {
            self.albumTitleLabel.isHidden = false
            self.albumTitleLabel.text = album.name
            self.albumMediaCountLabel.isHidden = false
            self.albumMediaCountLabel.text = "\(album.count)"
        }
        
        if let thumbAsset = album.thumbAsset {
            let thumbSize = CGSize(width: UIScreen.main.scale * self.THUMB_IMAGE_SIZE, height: UIScreen.main.scale * self.THUMB_IMAGE_SIZE)
            
            Utils.getImage(asset: thumbAsset, targetSize: thumbSize) { progress in
                
            } completion: { image in
                self.thumbImageView.image = image
            }
        }
    }
}
