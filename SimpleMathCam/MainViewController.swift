//
//  MainViewController.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 09/03/23.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonAdd: UIImageView!
    
    @IBOutlet weak var buttonFileStorage: UIButton!
    
    @IBOutlet weak var buttonDatabaseStorage: UIButton!
    
    private var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupImagePicker()
        setupAddButton()
    }

    private func setupAddButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addButtonAction(tapGestureRecognizer:)))
        buttonAdd.isUserInteractionEnabled = true
        buttonAdd.addGestureRecognizer(tapGesture)
    }
    
    @objc func addButtonAction(tapGestureRecognizer: UITapGestureRecognizer) {
        openCamera()
    }
    
    @IBAction func changeToFileStorageAction(_ sender: UIButton) {
        let unselectedImage = UIImage(systemName: "circle")
        let selectedImage = UIImage(systemName: "circle.fill")
        buttonFileStorage.setImage(selectedImage, for: .normal)
        buttonDatabaseStorage.setImage(unselectedImage, for: .normal)
    }
    
    @IBAction func changeToDatabaseStorageAction(_ sender: UIButton) {
        let unselectedImage = UIImage(systemName: "circle")
        let selectedImage = UIImage(systemName: "circle.fill")
        buttonFileStorage.setImage(unselectedImage, for: .normal)
        buttonDatabaseStorage.setImage(selectedImage, for: .normal)
    }
   
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }

    func openPhotoLibrary() {
      imagePicker.sourceType = .photoLibrary
      present(imagePicker, animated: true)
    }

    func openCamera() {
      guard
        UIImagePickerController.isCameraDeviceAvailable(.front)
          || UIImagePickerController
            .isCameraDeviceAvailable(.rear)
      else {
        return
      }
      imagePicker.sourceType = .camera
      present(imagePicker, animated: true)
    }
}

extension MainViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage =
          info[
            convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)]
          as? UIImage
        {
//          updateImageView(with: pickedImage)
//            viewModel.detect(pickedImage)
        }
        dismiss(animated: true)
    }
    
    private func convertFromUIImagePickerControllerInfoKeyDictionary(
      _ input: [UIImagePickerController.InfoKey: Any]
    ) -> [String: Any] {
      return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
    }
    
    private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey)
      -> String
    {
      return input.rawValue
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
