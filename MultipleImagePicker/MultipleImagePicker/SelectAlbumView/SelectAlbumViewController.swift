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
    
    /// 테이블 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - ㄴ 뷰 셋팅
extension SelectAlbumViewController {
    
}
