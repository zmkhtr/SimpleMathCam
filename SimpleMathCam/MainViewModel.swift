//
//  MainViewModel.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 12/03/23.
//

import UIKit

class MainViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let loader: MathItemsLoader
    private let recognizer: MyMathTextExtractor
    
    public init(loader: MathItemsLoader, recognizer: MyMathTextExtractor) {
        self.loader = loader
        self.recognizer = recognizer
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onErrorStateChange: Observer<String?>?
    var onMathItemsLoad: Observer<[MathItem]>?
    
    func recognize(image: UIImage) {
        recognizer.extract(image: image) { [weak self] result in
            guard let self = self else { return }
//
//            switch result {
//            case let .success(item):
//
//            case let .failure(error):
//
//            }
        }
    }
    
    func load() {
        loader.get { [weak self] result in
            guard let self = self else { return }
//            
//            switch result {
//            case let .success(items):
//                
//            case let .failure(error):
//                
//            }
        }
    }
}
