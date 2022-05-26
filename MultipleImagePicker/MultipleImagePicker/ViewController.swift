//
//  ViewController.swift
//  MultipleImagePicker
//
//  Created by yuhyeonjae on 2022/03/11.
//

import UIKit

class ViewController: UIViewController {

    /// 테스트 버튼
    @IBOutlet weak var testStartBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 시작 버튼 클릭 시
    /// - Parameter sender: 시작 버튼
    @IBAction func didTappedStartBtn(_ sender: UIButton) {
        let option = PickerConfiguration(type: .ALL, isOnePick: false, isCamera: true)
        let vc = AssetPickerViewController.instance(option: option) { list in
            print(list)
        } useCamera: {
            self.showCamera()
        }

        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - ㄴ 카메라 관련
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 카메라 표시
    private func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        
        let carmeraView = UIImagePickerController()
        carmeraView.delegate = self
        carmeraView.sourceType = .camera
        carmeraView.allowsEditing = false
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            carmeraView.modalPresentationStyle = .popover
            carmeraView.popoverPresentationController?.sourceView = self.testStartBtn
        }
        
        self.present(carmeraView, animated: true, completion: nil)
    }
    
    /// 촬영된 이미지 사용 진행 시
    /// - Parameters:
    ///   - picker: 피커 뷰
    ///   - info: 이미지 정보
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print(pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

