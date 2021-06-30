//
//  ViewController.swift
//  ImageEditor
//
//  Created by Hussein Jaber on 14/06/2021.
//

import UIKit

class ViewController: UIViewController {
    
    private let images = [UIImage(named: "morphin")!, .init(named: "witcher")!, .init(named: "henry")!]
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        imgView.image = images.randomElement()!
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reset))
        tapGesture.numberOfTapsRequired = 3
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc
    private func reset() {
        imageView.image = images.randomElement()
    }

    
    @objc
    private func didTapImage() {
        let imageEditor = ImageEditor(with: imageView.image!, delegate: self)
        present(imageEditor, animated: true)
    }

}

extension ViewController: ImageEditorDelegate {
    func didFinishEditing(_ editedImage: UIImage, in editor: ImageEditor) {
        self.imageView.image = editedImage
        editor.dismiss(animated: true)
    }
}




