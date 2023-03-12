//
//  AppFlow.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 12/03/23.
//

import Foundation
import CoreData
import MLKit

final class AppFlow: NSObject {
    
    lazy var file: MathItemsStore = {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return CodableMathItemsStore(storeURL: directory.appendingPathComponent("math-file.store"))
    }()
    
    lazy var coredata: MathItemsStore = {
        try! CoreDataMathItemStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("math-store.sqlite"))
    }()
    
    lazy var loader: LocalMathItemsLoader = {
        return LocalMathItemsLoader()
    }()
    
    lazy var recognizer: MyMathTextExtractor = {
        let recognizer = MLKitTextRecognizer(recognizer: TextRecognizer.textRecognizer())
        return MathTextExtractor(recognizer: recognizer)
    }()
    
    lazy var isFromCamera: Bool = {
        return false
//        return Bundle.main.infoDictionary! ["API_BASE_URL"] as! Bool
    }()
    
    lazy var isRedTheme: Bool = {
        return true
//        return Bundle.main.infoDictionary! ["API_BASE_URL"] as! Bool
    }()
    
    private let navigationController: UINavigationController
    private var mainVC: MainViewController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.viewControllers = [createMainViewController()]
    }
    
    private func createMainViewController() -> MainViewController {
        mainVC = MainUIComposer.detailComposedWith(
            loader: loader,
            recognizer: recognizer,
            fileStore: file,
            databaseStore: coredata,
            onAddButtonPress: presentImagePicker)
        mainVC.view.backgroundColor = isRedTheme ? .systemRed : .systemGreen
        return mainVC
    }
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = isFromCamera ? .camera : .photoLibrary

        navigationController.present(imagePicker, animated: true)
    }
}

extension AppFlow: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let pickedImage = info[
            convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)]
                as? UIImage  {
            mainVC.processImage(image: pickedImage)
        }
        
        navigationController.dismiss(animated: true)
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
