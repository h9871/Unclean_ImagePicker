//
//  AssetPickerViewController.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/11.
//

import UIKit
import Photos           // 미디어 파일 사용

/// 피커 옵션
struct PickerConfiguration {
    /// 모달 타입
    var isFull: Bool = false
    /// 피커 타입
    var type: PickerType = .ALL
    /// 단일선택, 다중선택
    var isOnePick = false
}

/// 피커 타입
enum PickerType {
    /// 전체
    case ALL
    /// 사진
    case PHOTO
    /// 비디오
    case VIDEO
}

/// 선택 아이템
struct SelectedPickerItem {
    /// 고유 아이디 (Asset 의 고유 ID)
    var id: String = ""
    /// 선택 번째
    var selectNum: Int = 0
    /// 미디어 데이터
    var asset: PHAsset = PHAsset()
    /// 썸네일 이미지
    var thumbImage: UIImage?
}

class AssetPickerViewController: BaseViewController {
    
    /// 생성자
    /// - Returns: 피커 뷰 컨트롤러
    class func instance(option: PickerConfiguration, complete: @escaping (Array<PHAsset>) -> Void) -> AssetPickerViewController {
        let view = AssetPickerViewController()
        view.option = option
        view.confirmHandler = complete
        return view
    }
    
    // MARK: - 상수
    let CELL_ID = "AssetPickerCollectionViewCell"
    let SELECT_LIST_HEIGHT: CGFloat = 88
    
    // MARK: - 뷰
    /// 네비게이션 뷰
    private lazy var naviView: AssetPickerNaviView = {
        let view = AssetPickerNaviView.instance(delegate: self)
        return view
    }()
    /// 메인 스택 뷰
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    /// 선택 리스트 뷰
    private lazy var selectListView: AssetPickerSelectListView = {
        let view = AssetPickerSelectListView.instance(delegate: self)
        return view
    }()
    /// 컬렉션 뷰
    private lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    }()
    /// 앨범 리스트 뷰
    private lazy var albumListView: AssetPickerAlbumListView = {
        let view = AssetPickerAlbumListView.instance()
        view.alpha = 0
        view.isHidden = true
        return view
    }()
    
    // MARK: - 데이터 소스
    /// 섹션
    enum Section: CaseIterable {
        case main
    }
    /// 데이터 소스
    private var dataSource: UICollectionViewDiffableDataSource<Section, PHAsset>!
    /// 스냅샷
    private var snapshot = NSDiffableDataSourceSnapshot<Section, PHAsset>()
    
    // MARK: - 데이터
    /// 피커 타입
    private lazy var option: PickerConfiguration = PickerConfiguration()
    /// 뷰 모델 설정
    private lazy var assetVM: AssetPickerViewModel = AssetPickerViewModel()
    
    /// 이미지 매니저
    private let manager = PHImageManager.default()
    
    // MARK: - 핸들러
    /// 확인 핸들러
    private var confirmHandler: ((Array<PHAsset>) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
}

// MARK: - ㄴ 뷰 셋팅
extension AssetPickerViewController {
    /// 뷰 생성
    private func initView() {
        // 네비게이션 뷰 넣기
        self.view.addSubview(self.naviView)
        
        // 메인 스택 뷰 넣기
        self.view.addSubview(self.mainStackView)
        
        // 스택 뷰 아이템 넣기
        self.mainStackView.addArrangedSubview(self.selectListView)
        self.mainStackView.addArrangedSubview(self.collectionView)
        
        // 앨범 리스트 뷰 넣기
        self.view.addSubview(self.albumListView)
        
        // 레이아웃 설정
        self.updateLayoutView()
        
        // 컬렉션 뷰 초기화
        self.initCollectionView()
        
        // 바인드 데이터
        self.initBindData()
        
        // 뷰 로드 처리
        self.albumPermission {
            DispatchQueue.main.async {
                self.initLoadView()
            }
        }
    }

    /// 뷰 레이아웃 설정
    private func updateLayoutView() {
        // 1. 네비게이션 뷰 레이아웃 설정
        self.naviView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            var addHeight: CGFloat = 0
            if self.isFullScreen(style: self.modalPresentationStyle) {
                addHeight = Utils.getSafeAreaTop()
            }
            make.height.equalTo(self.naviView.height + addHeight)
        }
        
        // 1. 메인 스택 뷰 레이아웃 설정
        self.mainStackView.snp.remakeConstraints { make in
            make.top.equalTo(self.naviView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // 2. 선택 리스트뷰 높이 설정
        self.selectListView.snp.remakeConstraints { make in
            make.height.equalTo(self.SELECT_LIST_HEIGHT)
        }
        
        // 3. 앨범 리스트 뷰 높이 설정
        self.albumListView.snp.remakeConstraints { make in
            make.top.equalTo(self.naviView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    /// 컬렉션 뷰 초기화
    private func initCollectionView() {
        self.collectionView.register(AssetPickerCollectionViewCell.self, forCellWithReuseIdentifier: self.CELL_ID)
        self.collectionView.delegate = self
        
        self.dataSource = UICollectionViewDiffableDataSource<Section, PHAsset>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.CELL_ID, for: indexPath) as? AssetPickerCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(item, self.assetVM.selectList.value)
            
            return cell
        })
        self.collectionView.dataSource = self.dataSource
        self.collectionView.collectionViewLayout = self.createLayout()
    }
    
    /// 화면 로드
    private func initLoadView() {
        // 배경색 설정
        self.view.backgroundColor = .white
        
        // 선택 리스트 뷰 숨김
        self.selectListView.isHidden = true
        
        // 1. 사진첩 리스트 조회
        self.assetVM.fetchAssetList(type: self.option.type)        
        
        // 2. 앨범 리스트 추출
        self.albumListView.onSelect = { collection in
            self.naviView.updateAlbumListBtn(false)
            self.albumListView.setHideView()
            // 앨범 리스트 조회
            self.assetVM.fetchAlbumAssetList(collection: collection)
        }
    }
    
    /// 바인딩 처리
    private func initBindData() {
        /// 미디어 리스트 바인딩
        self.assetVM.assetList.bind { [weak self] assetList in
            guard let self = self else { return }
            self.reloadCollectionView(assetList)
        }
        
        /// 선택 리스트 바인딩
        self.assetVM.selectList.bind { [weak self] selectList in
            guard let self = self else { return }
            // 리로드
            self.reloadCollectionView(self.assetVM.assetList.value)
            // 선택 뷰 표시
            self.showSelectListView(isHidden: selectList.count < 1)
            // 카운트 업데이트
            self.naviView.updateCountLabel(selectList.count)
        }
        
        /// 선택 아이템 바인딩
        self.assetVM.selectItem.bind { [weak self] (isRemove: Bool, item: SelectedPickerItem) in
            guard let self = self else { return }
            
            guard item.id != "" else { return }
            
            isRemove ? self.selectListView.removePickerItem(item) : self.selectListView.addPickerItem(item)
        }
    }
}

// MARK: - ㄴ 네비게이션 관련
extension AssetPickerViewController: AssetPickerNaviViewDelegate {
    /// 뒤로가기 버튼 클릭 시
    func didTappedBackBtn() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 앨범 리스트 버튼 클릭 시
    /// - Parameter isSelect: 선택여부
    func didTappedAlbumListBtn(isSelect: Bool) {
        self.setAlbumListView(isSelect)
    }
    
    /// 확인 버튼 클릭 시
    func didTappedConfirmBtn() {
        self.confirmHandler?(self.assetVM.getSelectList())
        self.didTappedBackBtn()
    }
}

// MARK: - ㄴ 데이터 관련
extension AssetPickerViewController {
    /// 컬렉션 뷰 리로드
    /// - Parameters:
    ///   - list: 리스트
    ///   - animated: 애니메이션
    private func reloadCollectionView(_ list: Array<PHAsset>, animated: Bool = true) {
        self.snapshot = NSDiffableDataSourceSnapshot<Section, PHAsset>()
        self.snapshot.appendSections([.main])
        self.snapshot.appendItems(list)
        self.snapshot.reloadItems(list)
        DispatchQueue.global(qos: .background).async {
            self.dataSource.apply(self.snapshot, animatingDifferences: animated)
        }
    }
}

// MARK: - ㄴ 선택 리스트 뷰 관련
extension AssetPickerViewController: AssetPickerSelectListViewDelegate {
    /// 썸네일 리스트 뷰에서 닫기 버튼 클릭 시
    /// - Parameter item: 삭제할 아이템
    func didTappedCloseBtn(_ item: SelectedPickerItem) {
        // 선택 해제
        self.assetVM.removeSelected(id: item.id)
    }
    
    /// 선택 뷰 표시 여부
    /// - Parameter isHidden: 숨김 표시
    private func showSelectListView(isHidden: Bool) {
        self.selectListView.isHidden = isHidden
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - ㄴ 앨범 리스트 뷰 관련
extension AssetPickerViewController {
    /// 앨범 리스트 프로세스
    /// - Parameter isSelect: 선택 여부
    private func setAlbumListView(_ isSelect: Bool) {        
        if !isSelect {
            self.albumListView.setHideView()
            return
        }
        
        var typeList: Array<PHAssetMediaType> = []
        switch self.option.type {
        case .PHOTO: typeList.append(.image)
        case .VIDEO: typeList.append(.video)
        default:
            typeList.append(.image)
            typeList.append(.video)
        }
        
        self.albumListView.requestLoadAlbumList(mediaType: typeList)
        self.albumListView.setShowView()
    }
}

// MARK: - ㄴ 컬렉션 뷰 관련
extension AssetPickerViewController: UICollectionViewDelegate {
    /// 컬렉션 뷰 셀 선택 시
    /// - Parameters:
    ///   - collectionView: 컬렉션 뷰
    ///   - indexPath: 인덱스
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        // 선택 처리 진행
        self.assetVM.selectedAsset(item: item)
    }
}

// MARK: - ㄴ 컬렉션 뷰 레이아웃 관련
extension AssetPickerViewController {
    /// 컬렉션 뷰 레이아웃 생성 (Compositional Layout)
    /// - Returns: 레이아웃
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            return self.createBoxLayout()
        }
    }
    
    /// 사진형 레이아웃
    /// - Returns: 섹션
    private func createBoxLayout() -> NSCollectionLayoutSection {
        let count = self.isScreenTraitRR(trait: self.traitCollection) ? 6 : 3
        
        let fraction: CGFloat = 1 / CGFloat(count)
        
        // 아이템 사이즈
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

        // 아이템을 기반으로 한 그룹 크기
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(fraction))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: count)
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}
