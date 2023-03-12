//
//  MainUIComposer.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 12/03/23.
//

import UIKit

final class MainUIComposer {
    private init() {}
    
    public static func detailComposedWith(
        loader: LocalMathItemsLoader,
        recognizer: MyMathTextExtractor,
        fileStore: MathItemsStore,
        databaseStore: MathItemsStore,
        onAddButtonPress: @escaping (() -> Void)
    ) -> MainViewController {
        
        let viewModel = MainViewModel(
            loader: MainQueueDispatchDecorator(decoratee: loader),
            cache: MainQueueDispatchDecorator(decoratee: loader),
            recognizer: MainQueueDispatchDecorator(decoratee: recognizer),
            fileStore: fileStore,
            databaseStore: databaseStore)
        
        return MainUIComposer.makeMainViewController(with: viewModel, onAddButtonPress: onAddButtonPress)
    }
    
    private static func makeMainViewController(with viewModel: MainViewModel, onAddButtonPress: @escaping (() -> Void)) -> MainViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateInitialViewController { coder in
            return MainViewController(coder: coder, viewModel: viewModel, onAddButtonPress: onAddButtonPress)
        }
        
        return mainViewController!
    }
}

