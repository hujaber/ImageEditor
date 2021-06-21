//
//  ViewController.swift
//  ImageEditor
//
//  Created by Hussein Jaber on 14/06/2021.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "witcher")
        imgView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imgView.addGestureRecognizer(tapGesture)
        return imgView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: 50),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 50),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -50),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -50)
        ])
    }

    
    @objc
    private func didTapImage() {
        let imageEditor = ImageEditor(with: imageView.image!)
        present(imageEditor, animated: true)
    }

}




