//
//  SelectAlbumViewController.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/21.
//

import UIKit

class SelectAlbumViewController: UIViewController {
    
    // MARK: - 생성자
    /// 뷰 생성
    /// - Returns: 생성된 뷰
    class func instance() -> SelectAlbumViewController {
        let vc = SelectAlbumViewController()
        return vc
    }
    
    // MARK: - enum
    /// 시트 상태
    private enum SheetState {
        case CLOSE
        case PARTIAL
        case FULL
    }
    
    // MARK: - 상수
    let CELL_ID = "SelectAlbumTableViewCell"
    let FULL_VIEW_Y_POSITION: CGFloat = 100
    let PARTIAL_VIEW_Y_POSITION: CGFloat = UIScreen.main.bounds.height - 120
    
    // MARK: - 뷰
    /// 테이블 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // MARK: - 핸들러

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
}

// MARK: - ㄴ 뷰 셋팅
extension SelectAlbumViewController: SetTableView {
    /// 뷰 셋팅
    func initView() {
        // 테이블 뷰 넣기
        self.view.addSubview(self.tableView)
        
        // 레이아웃 설정
        self.updateLayoutView()
        
        // 컬렉션 뷰 초기화
        self.initTableView()
        
        // 뷰 로드 처리
        self.initLoadView()
    }
    
    /// 뷰 레이아웃 설정
    func updateLayoutView() {
        // 테이블 뷰 레이아웃 설정
        self.tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 테이블 뷰 설정
    func initTableView() {
        self.tableView.register(SelectAlbumTableViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.backgroundColor = .clear
    }
    
    /// 뷰 로드 설정
    func initLoadView() {
        // 색상 설정
        self.view.backgroundColor = UIColor.black
        self.view.alpha = 0.7
        
        // 뷰 디자인 설정
        self.view.layer.cornerRadius = 10
        self.view.clipsToBounds = true
        
        // 제스처 할당
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.panGesture))
        self.view.addGestureRecognizer(gesture)
        
        UIView.animate(withDuration: 0.6, animations: {
            self.moveView(state: .PARTIAL)
        })
    }
}

// MARK: - ㄴ 테이블 뷰 관련
extension SelectAlbumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID) as? SelectAlbumTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}

// MARK: - ㄴ 제스처 설정
extension SelectAlbumViewController {
    /// 뷰 움직임 (상태에 따라 변경)
    /// - Parameter state: 상태
    private func moveView(state: SheetState) {
        let yPosition = state == .PARTIAL ? self.PARTIAL_VIEW_Y_POSITION : self.FULL_VIEW_Y_POSITION
        self.view.frame = CGRect(x: 0, y: yPosition, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    /// 뷰 움직임 (제스처에 따라 변경)
    /// - Parameter recognizer: 제스처 정보
    private func moveView(panGestureRecognizer recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let minY = view.frame.minY
        
        if (minY + translation.y >= self.FULL_VIEW_Y_POSITION) && (minY + translation.y <= self.PARTIAL_VIEW_Y_POSITION) {
            self.view.frame = CGRect(x: 0, y: minY + translation.y, width: self.view.frame.width, height: self.view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: view)
        }
    }
    
    /// 제스처 함수
    /// - Parameter recognizer: 제스처 정보
    @objc
    private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        self.moveView(panGestureRecognizer: recognizer)
        
        if recognizer.state == .ended {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction], animations: {
                let state: SheetState = recognizer.velocity(in: self.view).y >= 0 ? .PARTIAL : .FULL
                self.moveView(state: state)
            }, completion: nil)
        }
    }
}
