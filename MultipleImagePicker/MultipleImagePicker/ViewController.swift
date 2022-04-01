//
//  ViewController.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/11.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /// 시작 버튼 클릭 시
    /// - Parameter sender: 시작 버튼
    @IBAction func didTappedStartBtn(_ sender: UIButton) {
        let option = PickerConfiguration(type: .ALL, isOnePick: false)
        let vc = AssetPickerViewController.instance(option: option) { list in
            print(list)
        }
        self.present(vc, animated: true, completion: nil)
    }
}

