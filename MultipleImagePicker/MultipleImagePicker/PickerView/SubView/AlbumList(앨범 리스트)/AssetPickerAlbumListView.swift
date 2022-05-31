//
//  AssetPickerAlbumListView.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/29.
//

import UIKit
import Photos           // 미디어 파일 사용

// MARK: - Struct
struct AlbumList {
    /// 이름
    var name: String = ""
    /// 갯수
    var count: Int = 0
    /// 썸네일 오브젝트
    var thumbAsset: PHAsset? = nil
    /// 컬렉션
    var collection: PHAssetCollection
    
    init(name: String, count: Int, thumbAsset: PHAsset?, collection: PHAssetCollection) {
        self.name = name
        self.count = count
        self.thumbAsset = thumbAsset
        self.collection = collection
    }
}

class AssetPickerAlbumListView: UIView {
    /// 생성자
    /// - Returns: 뷰
    class func instance() -> AssetPickerAlbumListView {
        let view = AssetPickerAlbumListView()
        view.initView()
        return view
    }
    
    // MARK: - 상수
    let CELL_ID = "AssetPickerAlbumTableViewCell"
    
    // MARK: - 뷰
    /// 테이블 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // MARK: - 데이터
    /// 사진 목록
    private lazy var albumList: Array<AlbumList> = []
    
    // MARK: - 핸들러
    // 반환데이터
    var onSelect: ((String, PHAssetCollection) -> ())?
}

// MARK: - ㄴ 뷰 셋팅
extension AssetPickerAlbumListView: SetTableView {
    func initView() {
        self.addSubview(self.tableView)
        
        // 레이아웃 설정
        self.updateLayoutView()
        
        // 테이블 뷰 초기화
        self.initTableView()
    }
    
    func updateLayoutView() {
        // 테이블 뷰 레이아웃 설정
        self.tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func initTableView() {
        self.tableView.register(AssetPickerAlbumTableViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = 78
    }
    
    func initLoadView() {
        
    }
    
    /// 뷰 표시/숨김 처리
    func setShowView() {
        self.isHidden = false
        self.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    func setHideView() {
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
            self.alpha = 0
        }) { complete in
            if complete {
                self.isHidden = true
            }
        }
    }
}

// MARK: - ㄴ 데이터 관련
extension AssetPickerAlbumListView {
    /// 앨범 리스트 조회
    /// - Parameter mediaType: 미디어 타입
    public func requestLoadAlbumList(mediaType: Array<PHAssetMediaType>) {
        self.albumList.removeAll()
        
        // 조회 후 배열에 넣어주기
        self.getAlbumList(albumType: .smartAlbum, mediaType: mediaType) { list in
            self.albumList.append(list)
            self.tableView.reloadData()
        }
        
        // 조회 후 배열에 넣어주기
        self.getAlbumList(albumType: .album, mediaType: mediaType) { list in
            self.albumList.append(list)
            self.tableView.reloadData()
        }
    }
    
    /// 앨범 리스트 조회
    /// - Parameters:
    ///   - albumType: 앨범 타입
    ///   - fetchOptions: 조회 옵션
    ///   - completion: 완료 리스트
    private func getAlbumList(albumType: PHAssetCollectionType, mediaType: Array<PHAssetMediaType>,
                              completion: @escaping (AlbumList) -> Void) {
        let collectionAlbum = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: .any, options: PHFetchOptions())
        
        collectionAlbum.enumerateObjects{ (object: Any, count: Int, stop: UnsafeMutablePointer) in
            if object is PHAssetCollection,
               let collectionObject = object as? PHAssetCollection {
                let albumInfo = collectionObject.getAlbumInfo(mediaType: mediaType)
                let newAlbum = AlbumList(name: collectionObject.localizedTitle ?? "",
                                         count: albumInfo.count,
                                         thumbAsset: albumInfo.firstObject,
                                         collection: collectionObject)
                // 갯수가 있는 것만 배열 넣기
                if newAlbum.count > 0 {
                    completion(newAlbum)
                }
            }
        }
    }
}

// MARK: - ㄴ 테이블 뷰 관련
extension AssetPickerAlbumListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as? AssetPickerAlbumTableViewCell else {
            return UITableViewCell()
        }
        
        let row = indexPath.row
        let album = self.albumList[row]
        cell.configureCell(album)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        let album = self.albumList[row]
        self.onSelect?(album.name, album.collection)
    }
}
