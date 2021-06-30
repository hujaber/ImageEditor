//
//  ImageEditor.swift
//  ImageEditor
//
//  Created by Hussein Jaber on 14/06/2021.
//

import UIKit

class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {

        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
 
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }

        return CGSize(width: -1.0, height: -1.0)
    }

}

protocol ImageEditorDelegate: AnyObject {
    func didFinishEditing(_ editedImage: UIImage, in editor: ImageEditor)
}

final class ImageEditor: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView(frame: .init(x: 20, y: 64, width: view.frame.width - 40,
                                               height: view.frame.height - 158))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.layer.borderWidth = 0.4
        imgView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        imgView.accessibilityIdentifier = "original image view"
        return imgView
    }()

    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundColor = .clear
        toolbar.barTintColor = .black
        toolbar.tintColor = .white
        toolbar.accessibilityIdentifier = "Bottom tool bar"
        return toolbar
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self,
                                           action: #selector(cancelTapped(_:)))
        cancelButton.tintColor = .white
        cancelButton.accessibilityIdentifier = "Cancel editor button"
        return cancelButton
    }()
    
    private lazy var cropButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "Crop", style: .plain, target: self,
                                  action: #selector(cropImageTapped(_:)))
        btn.tintColor = .white
        btn.accessibilityIdentifier = "Crop button"
        return btn
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.commitCropping))
        btn.tintColor = .white
        btn.accessibilityIdentifier = "done edit button"
        return btn
    }()
    
    private lazy var flipButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "Flip", style: .plain, target: self, action: #selector(flipImage))
        btn.tintColor = .white
        return btn
    }()
    
    private lazy var rotateRightButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "RR", style: .plain, target: self, action: #selector(rotateRight))
        btn.tintColor = .white
        return btn
    }()
    
    private lazy var leftTopCropButton: CropButton = {
        let frame = CGRect(x: imageView.frame.minX, y: imageView.frame.minY,
                           width: 10, height: 10)
        let btn = CropButton(position: .topLeft, frame: frame)
        btn.addGestureRecognizer(panGesture)
        return btn
    }()
    
    private lazy var rightTopCropButton: CropButton = {
        let frame = CGRect(x: imageView.frame.maxX, y: imageView.frame.minY, width: 10, height: 10)
        let btn = CropButton(position: .topRight, frame: frame)
        btn.addGestureRecognizer(panGesture)
        return btn
    }()
    
    private lazy var bottomLeftButton: CropButton = {
        let frame = CGRect(x: imageView.frame.minX, y: imageView.frame.maxY, width: 10, height: 10)
        let btn = CropButton(position: .bottomLeft, frame: frame)
        btn.addGestureRecognizer(panGesture)
        return btn
    }()
    
    private lazy var bottomRightCropButton: CropButton = {
        let frame = CGRect.init(x: imageView.frame.maxX, y: imageView.frame.maxY, width: 10, height: 10)
        let btn = CropButton(position: .bottomRight, frame: frame)
        btn.addGestureRecognizer(panGesture)
        return btn
    }()
    
    
    private var image: UIImage
    
    private enum State {
        case cropping
        case idle
    }
    
    private var state: State = .idle {
        didSet {
            stateUpdated()
        }
    }
    
    weak var delegate: ImageEditorDelegate?
    
    init(with image: UIImage, delegate: ImageEditorDelegate) {
        self.image = image
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setupViews()
        let ratio = image.size.height / image.size.width
        let newWidth = imageView.frame.height / ratio
        let oldWidth = imageView.frame.width
        imageView.frame.size.width = min(newWidth, oldWidth)
        let heightRatio = image.size.width / image.size.height
        let newHeight = imageView.frame.width / heightRatio
        let oldHeight = imageView.frame.height
        imageView.frame.size.height = min(newHeight, oldHeight)
        if newHeight < oldHeight || newWidth < oldWidth {
            imageView.center = view.center.applying(.init(translationX: 0, y: -20))
        }
    }
    
    private func setupViews() {
        defer {
            activateConstraints()
        }
        
        view.addSubview(imageView)
        imageView.image = image
        view.addSubview(toolbar)
        toolbar.setItems([cancelButton, cropButton, flipButton, rotateRightButton, doneButton], animated: false)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func stateUpdated() {
        switch state {
        
        case .cropping:
            cancelButton.title = "Cancel Crop"
        case .idle:
            cancelButton.title = "Cancel"
        }
    }
    
    @objc
    private func cancelTapped(_ sender: UIBarButtonItem) {
        switch state {
        case .idle:
            dismiss(animated: true, completion: nil)
        case .cropping:
            state = .idle
            removeCroppingLayerView()
            imageView.image = image
          //  imageView.frame = originalImageViewFrame
        }
    }
    
    @objc
    private func cropImageTapped(_ sender: UIBarButtonItem) {
        if state == .cropping {
            return
        } else {
            state = .cropping
            addCroppingLayerView()
        }
        
    }
    
    private func addCroppingLayerView() {
        view.addSubview(leftTopCropButton)
        view.addSubview(rightTopCropButton)
        view.addSubview(bottomLeftButton)
        view.addSubview(bottomRightCropButton)
    }
    
    private func removeCroppingLayerView() {
        leftTopCropButton.removeFromSuperview()
        rightTopCropButton.removeFromSuperview()
        bottomLeftButton.removeFromSuperview()
        bottomRightCropButton.removeFromSuperview()
    }
    
    private var panGesture: UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(croppingLayerPanned(_:)))
        return gesture
    }
    
    private let minMargin: CGFloat = 30
    
    @objc
    private func croppingLayerPanned(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: view)
        guard let button = sender.view as? UIButton else { return }
        switch button {
        case leftTopCropButton:
            let x = max(imageView.frame.minX,
                        min(location.x, rightTopCropButton.frame.maxX - minMargin))
            let y = max(imageView.frame.minY,
                        min(location.y, bottomLeftButton.frame.maxY - minMargin))
            button.frame.origin.x = x
            button.frame.origin.y = y
            rightTopCropButton.frame.origin.y = y
            bottomLeftButton.frame.origin.x = x
        case rightTopCropButton:
            let x = max(leftTopCropButton.frame.minX + minMargin,
                        min(location.x, imageView.frame.maxX))
            let y = max(imageView.frame.minY,
                        min(location.y, bottomRightCropButton.frame.maxY - minMargin))
            button.frame.origin.x = x
            button.frame.origin.y = y
            
            leftTopCropButton.frame.origin.y = y
            
            var bottomRightFrame = bottomRightCropButton.frame
            bottomRightFrame.origin.x = x
            bottomRightCropButton.frame.origin.x = x
        case bottomLeftButton:
            let x = max(imageView.frame.minX,
                        min(location.x, bottomRightCropButton.frame.maxX - minMargin))
            let y = min(imageView.frame.maxY,
                        max(location.y, leftTopCropButton.frame.minY + minMargin))
            button.frame.origin.x = x
            button.frame.origin.y = y
            
            leftTopCropButton.frame.origin.x = x
            bottomRightCropButton.frame.origin.y = y
        case bottomRightCropButton:
            let x = max(bottomLeftButton.frame.minX + minMargin,
                        min(location.x, imageView.frame.maxX))
            let y = min(imageView.frame.maxY,
                        max(location.y, rightTopCropButton.frame.minY + minMargin))
            button.frame.origin.x = x
            button.frame.origin.y = y
            
            rightTopCropButton.frame.origin.x = x
            bottomLeftButton.frame.origin.y = y
            
        default: return
        }

    }
}

extension ImageEditor {
    
    @objc
    private func rotateRight() {
       // imageView.transform = .init(rotationAngle: .pi / 2)
       // delegate?.didFinishEditing(snapshot(in: imageView, rect: imageView.bounds), in: self)
    }
    
    @objc private func flipImage() {
        imageView.transform = CGAffineTransform(translationX: imageView.frame.width, y: 0)
        imageView.image = imageView.image?.withHorizontallyFlippedOrientation()
        delegate?.didFinishEditing(snapshot(in: imageView, rect: imageView.bounds), in: self)
    }
    
    @objc
    private func commitCropping() {
        let x = leftTopCropButton.frame.origin.x
        let y = leftTopCropButton.frame.origin.y
        let width = rightTopCropButton.frame.origin.x - leftTopCropButton.frame.origin.x
        let height = bottomRightCropButton.frame.origin.y - rightTopCropButton.frame.origin.y
        var frame = CGRect(x: x, y: y, width: width, height: height)
        frame = imageView.convert(frame, from: view)
        let image = snapshot(in: imageView, rect: frame)
        delegate?.didFinishEditing(image, in: self)
    }
    
    func snapshot(in imageView: UIImageView, rect: CGRect) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect).image { _ in
            imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        }
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(origin: .zero, size: newSize)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

