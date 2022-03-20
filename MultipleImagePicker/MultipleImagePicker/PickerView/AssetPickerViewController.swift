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
    var id: String
    /// 선택 번째
    var selectNum: Int
    /// 미디어 데이터
    var asset: PHAsset
    /// 썸네일 이미지
    var thumbImage: UIImage?
}

class AssetPickerViewController: BaseViewController {
    
    /// 생성자
    /// - Returns: 피커 뷰 컨트롤러
    class func instance(option: PickerConfiguration) -> AssetPickerViewController {
        let view = AssetPickerViewController(nibName: "AssetPickerViewController", bundle: nil)
        view.option = option
        return view
    }
    
    // MARK: - 상수
    let CELL_ID = "AssetPickerCollectionViewCell"
    let SELECT_LIST_HEIGHT: CGFloat = 88
    let THUMB_HEIGHT: CGFloat = 50
    
    /// 네비게이션 뷰
    @IBOutlet weak var naviView: UIView!
    /// 뒤로가기 버튼
    @IBOutlet weak var backBtn: UIButton!
    /// 앨범 리스트 버튼
    @IBOutlet weak var albumListBtn: UIButton!
    /// 확인 버튼
    @IBOutlet weak var confirmBtn: UIButton!
    
    /// 메인 스택 뷰
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    /// 선택 리스트 뷰
    private lazy var selectListView: AssetPickerSelectListView = {
        let view = AssetPickerSelectListView.instance()
        return view
    }()
    
    /// 컬렉션 뷰
    private lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    }()
    
    // MARK: - 데이터 소스
    /// 섹션
    enum Section: CaseIterable {
        case main
    }
    /// 데이터 소스
    private var dataSource: UICollectionViewDiffableDataSource<Section, PHAsset>!
    
    // MARK: - 데이터
    /// 피커 타입
    lazy var option: PickerConfiguration = PickerConfiguration()
    /// 미디어 파일 배열
    private lazy var phAssets: Array<PHAsset> = []
    /// 선택 리스트
    private lazy var selectList: Array<SelectedPickerItem> = []
    /// 이미지 매니저
    private let manager = PHImageManager.default()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
}

// MARK: - ㄴ 뷰 셋팅
extension AssetPickerViewController {
    
    /// 뷰 생성
    private func initView() {
        // 메인 스택 뷰 넣기
        self.view.addSubview(self.mainStackView)
        
        // 스택 뷰 아이템 넣기
        self.mainStackView.addArrangedSubview(self.selectListView)
        self.mainStackView.addArrangedSubview(self.collectionView)
        
        // 레이아웃 설정
        self.updateLayoutView()
        
        // 컬렉션 뷰 초기화
        self.initCollectionView()
        
        // 뷰 로드 처리
        self.albumPermission {
            self.initLoadView()
        }
    }

    /// 뷰 레이아웃 설정
    private func updateLayoutView() {
        // 1. 메인 스택 뷰 레이아웃 설정
        self.mainStackView.snp.remakeConstraints { make in
            make.top.equalTo(self.naviView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // 2. 선택 리스트뷰 높이 설정
        self.selectListView.snp.remakeConstraints { make in
            make.height.equalTo(self.SELECT_LIST_HEIGHT)
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
            cell.configureCell(item, self.selectList)
            
            return cell
        })
        self.collectionView.dataSource = self.dataSource
        self.collectionView.collectionViewLayout = self.createLayout()
    }
    
    /// 화면 로드
    private func initLoadView() {
        // 선택 리스트 델리게이트
        self.selectListView.delegate = self
        
        // 선택 리스트 뷰 숨김
        self.selectListView.isHidden = true
        
        // 미디어 파일 추출
        self.fetchAssetList()
    }
}

// MARK: - ㄴ 네비게이션 관련
extension AssetPickerViewController {
    /// 뒤로가기 버튼 클릭 시
    /// - Parameter sender: 뒤로가기 버튼
    @IBAction func didTappedBackBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 확인 버튼 클릭 시
    /// - Parameter sender: 확인 버튼
    @IBAction func didTappedConfirmBtn(_ sender: UIButton) {
        print("확인 버튼 클릭")
    }
    
    /// 앨범리스트 버튼 클릭 시
    /// - Parameter sender: 리스트 버튼
    @IBAction func didTappedAlbumListBtn(_ sender: UIButton) {
        print("앨범 리스트 버튼 클릭")
    }
}

// MARK: - ㄴ 데이터 추출
extension AssetPickerViewController {
    /// 미디어 리스트 추출
    private func fetchAssetList() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        var fetchAssets = PHFetchResult<PHAsset>()
        switch self.option.type {
        case .ALL: fetchAssets = PHAsset.fetchAssets(with: fetchOptions)
        case .PHOTO: fetchAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        case .VIDEO: fetchAssets = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        }
        
        // 데이터 설정
        fetchAssets.enumerateObjects { asset, count, stop in
            self.phAssets.append(asset)
        }
        
        // 리로드
        self.reloadCollectionView(self.phAssets)
    }
}

// MARK: - ㄴ 데이터 관련
extension AssetPickerViewController {
    /// 컬렉션 뷰 리로드
    private func reloadCollectionView(_ list: Array<PHAsset>, animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PHAsset>()
        snapshot.appendSections([.main])
        snapshot.appendItems(list)
        snapshot.reloadItems(list)
        self.dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    /// 선택 해제 처리
    /// - Parameter id: 선택해제할 미디어의 아이디
    private func removeSelected(id: String) {
        // 없으면 진행하지 않는다
        if self.selectList.count < 1 { return }
        
        // 선택해제 처리 후 순서 재설정
        self.selectList = self.selectList.filter { $0.id != id }.enumerated().map({ (index, item) -> SelectedPickerItem in
            var tempItem = item
            tempItem.selectNum = index + 1
            return tempItem
        })
    }
}

// MARK: - ㄴ 선택 리스트 뷰 관련
extension AssetPickerViewController: AssetPickerSelectListViewDelegate {
    /// 썸네일 리스트 뷰에서 닫기 버튼 클릭 시
    /// - Parameter item: 삭제할 아이템
    func didTappedCloseBtn(_ item: SelectedPickerItem) {
        // 선택해제
        self.removeSelected(id: item.id)
        // 리프레쉬 뷰
        self.refreshView()
    }
    
    /// 뷰 리프레쉬
    private func refreshView() {
        // 선택 리스트 뷰 표시 여부
        self.showSelectListView(isHidden: self.selectList.count < 1)
        
        // 컬렉션 뷰 리로드
        self.reloadCollectionView(self.phAssets)
    }
    
    /// 선택 뷰 표시 여부
    private func
    showSelectListView(isHidden: Bool) {
        self.selectListView.isHidden = isHidden
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - ㄴ 컬렉션 뷰 관련
extension AssetPickerViewController: UICollectionViewDelegate {
    /// 컬렉션 뷰 셀 선택 시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        // 이미 선택 중인지 확인
        for element in self.selectList where element.id == item.localIdentifier {
            // 선택해제
            self.removeSelected(id: element.id)
            // 선택 리스트 뷰 삭제
            self.selectListView.removePickerItem(element)
            // 리프레쉬 뷰
            self.refreshView()
            return
        }
        
        // 선택 중이 아니라면 추가
        let thumbSize = CGSize(width: UIScreen.main.scale * self.THUMB_HEIGHT, height: UIScreen.main.scale * self.THUMB_HEIGHT)
        self.manager.requestImage(for: item, targetSize: thumbSize, contentMode: .aspectFill, options: nil) { (image, info) in
            // 임시 썸네일이 출력되므로 해당 내용은 진행하지 않는다
            guard let info = info,
                  let realImageKey = info["PHImageResultIsDegradedKey"] as? Int,
                  realImageKey == 0 else {
                return
            }
            
            let makeItem = SelectedPickerItem(id: item.localIdentifier,
                                              selectNum: self.selectList.count + 1,
                                              asset: item,
                                              thumbImage: image)
            // 아이템 생성
            self.selectList.append(makeItem)
            // 선택 리스트 뷰 추가
            self.selectListView.addPickerItem(makeItem)
            // 리프레쉬 뷰
            self.refreshView()
        }
    }
    
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
