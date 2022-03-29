//
//  AssetPickerAlbumListView.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/29.
//

import UIKit
import Photos           // 미디어 파일 사용

class AssetPickerAlbumListView: UIView {
    /// 생성자
    /// - Returns: 뷰
    class func instance() -> AssetPickerAlbumListView {
        let view = AssetPickerAlbumListView()
        view.initView()
        return view
    }
    
    // MARK: - Struct
    struct AlbumList {
        /// 이름
        var name: String = ""
        /// 갯수
        var count: Int = 0
        /// 컬렉션
        var collection: PHAssetCollection
        
        init(name: String, count: Int, collection: PHAssetCollection) {
            self.name = name
            self.count = count
            self.collection = collection
        }
    }
    
    // MARK: - 상수
    
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
    var onSelect: ((PHAssetCollection) -> ())?
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
        self.tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func initTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func initLoadView() {
        
    }
}

// MARK: - ㄴ 데이터 관련
extension AssetPickerAlbumListView {
    /// 앨범 리스트 조회
    /// - Parameter mediaType: 미디어 타입
    public func requestLoadAlbumList(mediaType: Array<PHAssetMediaType>) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        // 조회 조건 작성
        var queryArray: [NSPredicate] = []
        
        // 선택 캘린더를 반복하여 쿼리문 만들기
        for type in mediaType {
            // 각 아이템의 쿼리
            let predicate = NSPredicate(format: "mediaType = %d", type.rawValue)
            // 쿼리 배열에 넣기
            queryArray.append(predicate)
        }
        
        // 쿼리 배열이 없으면 찾을 필요도 없다
        if queryArray.count < 1 { return }
        
        // 쿼리 배열에 맞추어 완전체 쿼리 만들기 (또는 으로 설정해야 여러개를 조사한다)
        let query = NSCompoundPredicate(type: .or, subpredicates: queryArray)
        fetchOptions.predicate = query
        
        // 조회 후 배열에 넣어주기
        self.getAlbumList(albumType: .smartAlbum, fetchOptions: fetchOptions) { list in
            self.albumList.append(list)
            self.tableView.reloadData()
        }
        
        // 조회 후 배열에 넣어주기
        self.getAlbumList(albumType: .album, fetchOptions: fetchOptions) { list in
            self.albumList.append(list)
            self.tableView.reloadData()
        }
    }
    
    /// 앨범 리스트 조회
    /// - Parameters:
    ///   - albumType: 앨범 타입
    ///   - fetchOptions: 조회 옵션
    ///   - completion: 완료 리스트
    private func getAlbumList(albumType: PHAssetCollectionType, fetchOptions: PHFetchOptions,
                              completion: @escaping (AlbumList) -> Void) {
        let collectionAlbum = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: .any, options: fetchOptions)
        
        collectionAlbum.enumerateObjects{ (object: Any, count: Int, stop: UnsafeMutablePointer) in
            if object is PHAssetCollection,
               let collectionObject = object as? PHAssetCollection {
                let newAlbum = AlbumList(name: collectionObject.localizedTitle ?? "",
                                         count: collectionObject.photosCount,
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
