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
    
    private var items: [MathItem] = []
    private var viewModel: MainViewModel?
    private var onAddButtonPress: (() -> Void)?

    init?(coder: NSCoder, viewModel: MainViewModel, onAddButtonPress: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.onAddButtonPress = onAddButtonPress
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupAddButton()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel?.load()
        
        viewModel?.onMathItemsLoad = { [weak self] items in
            guard let self = self else { return }
            print("Items \(items.count)")
            self.items = items
            self.tableView.reloadData()
        }
        
        viewModel?.onErrorStateChange = { error in
            print("onErrorStateChange \(error)")
        }
        
        viewModel?.onLoadingStateChange = { isLoading in
            print("onLoadingStateChange \(isLoading)")

        }
        
        viewModel?.onErrorRecognizeStateChange = { error in
            print("onErrorRecognizeStateChange \(error)")

        }
        
        viewModel?.onLoadingRecognizeStateChange = { isLoading in
            print("onLoadingRecognizeStateChange \(isLoading)")

        }
    }
    
    private func setupAddButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addButtonAction(tapGestureRecognizer:)))
        buttonAdd.isUserInteractionEnabled = true
        buttonAdd.addGestureRecognizer(tapGesture)
    }
    
    @objc func addButtonAction(tapGestureRecognizer: UITapGestureRecognizer) {
        onAddButtonPress?()
    }
    
    @IBAction func changeToFileStorageAction(_ sender: UIButton) {
        let unselectedImage = UIImage(systemName: "circle")
        let selectedImage = UIImage(systemName: "circle.fill")
        buttonFileStorage.setImage(selectedImage, for: .normal)
        buttonDatabaseStorage.setImage(unselectedImage, for: .normal)
        viewModel?.changeDatabase(toFileStorage: true)
    }
    
    @IBAction func changeToDatabaseStorageAction(_ sender: UIButton) {
        let unselectedImage = UIImage(systemName: "circle")
        let selectedImage = UIImage(systemName: "circle.fill")
        buttonFileStorage.setImage(unselectedImage, for: .normal)
        buttonDatabaseStorage.setImage(selectedImage, for: .normal)
        viewModel?.changeDatabase(toFileStorage: false)
    }
    
    func processImage(image: UIImage) {
        viewModel?.recognize(image: image)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MathCell", for: indexPath) as! MathCell
        let item = items[indexPath.row]
        cell.labelQuestion.text = "Question: \(item.question)"
        cell.labelAnswer.text = "Answer: \(item.answer)"
        return cell
    }
    
    
}
