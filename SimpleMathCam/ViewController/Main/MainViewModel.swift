//
//  MainViewModel.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 12/03/23.
//

import UIKit

class MainViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let loader: LocalMathItemsLoader
    private let recognizer: MyMathTextExtractor
    
    private let fileStore: MathItemsStore
    private let databaseStore: MathItemsStore
    
    public init(loader: LocalMathItemsLoader, recognizer: MyMathTextExtractor, fileStore: MathItemsStore, databaseStore: MathItemsStore) {
        self.loader = loader
        self.recognizer = recognizer
        self.fileStore = fileStore
        self.databaseStore = databaseStore
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onErrorStateChange: Observer<String?>?
    var onMathItemsLoad: Observer<[MathItem]>?
    
    var onLoadingRecognizeStateChange: Observer<Bool>?
    var onErrorRecognizeStateChange: Observer<String?>?
    
    func recognize(image: UIImage) {
        onLoadingRecognizeStateChange?(true)
        
        recognizer.extract(image: image) { [weak self] result in
            guard let self = self else { return }
            self.onLoadingRecognizeStateChange?(false)

            switch result {
            case .success:
                self.load()
            case let .failure(error):
                self.onErrorRecognizeStateChange?(error.localizedDescription)
            }
        }
    }
    
    func load() {
        onLoadingStateChange?(true)

        loader.get { [weak self] result in
            guard let self = self else { return }
            self.onLoadingStateChange?(false)

            switch result {
            case let .success(items):
                self.onMathItemsLoad?(items)
            case let .failure(error):
                self.onErrorStateChange?(error.localizedDescription)

            }
        }
    }
    
    func changeDatabase(toFileStorage: Bool) {
        if toFileStorage {
            loader.store = fileStore
        } else {
            loader.store = databaseStore
        }
        load()
    }
}
