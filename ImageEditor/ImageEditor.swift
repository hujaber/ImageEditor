//
//  ImageEditor.swift
//  ImageEditor
//
//  Created by Hussein Jaber on 14/06/2021.
//

import UIKit

final class ImageEditor: UIViewController {
    
    private lazy var originalImageViewFrame: CGRect = .init(x: 20, y: 64,
                                                            width: view.frame.width - 40,
                                                            height: view.frame.height - 158)
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView(frame: .init(x: 20, y: 64, width: view.frame.width - 40,
                                               height: view.frame.height - 158))
        imgView.contentMode = .scaleAspectFill
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
    
    private lazy var leftTopCropButton: CropButton = {
        let frame = CGRect(x: imageView.frame.minX, y: imageView.frame.minY,
                           width: 10, height: 10)
        let btn = CropButton(position: .topLeft, frame: frame)
        btn.delegate = self
        btn.setTitle("X", for: .normal)
        btn.addGestureRecognizer(panGesture)
        return btn
    }()
    
    private lazy var rightTopCropButton: CropButton = {
        let frame = CGRect(x: imageView.frame.maxX, y: imageView.frame.minY, width: 10, height: 10)
        let btn = CropButton(position: .topRight, frame: frame)
        btn.delegate = self
        btn.setTitle("X", for: .normal)
        btn.addGestureRecognizer(panGesture)
        return btn
    }()
    
    private lazy var bottomLeftButton: CropButton = {
        let frame = CGRect(x: imageView.frame.minX, y: imageView.frame.maxY, width: 10, height: 10)
        let btn = CropButton(position: .bottomLeft, frame: frame)
        btn.delegate = self
        btn.setTitle("X", for: .normal)
        btn.addGestureRecognizer(panGesture)
        return btn
    }()
    
    private lazy var bottomRightCropButton: CropButton = {
        let frame = CGRect.init(x: imageView.frame.maxX, y: imageView.frame.maxY, width: 10, height: 10)
        let btn = CropButton(position: .bottomRight, frame: frame)
        btn.delegate = self
        btn.setTitle("X", for: .normal)
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
    
    init(with image: UIImage) {
        self.image = image
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
        image = resizeImage(image: image, targetSize: imageView.frame.size)!

        setupViews()
    }
    
    private func setupViews() {
        defer {
            activateConstraints()
        }
        
        view.addSubview(imageView)
        imageView.image = image
        view.addSubview(toolbar)
        toolbar.setItems([cancelButton, cropButton], animated: false)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50),
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
            let x = max(originalImageViewFrame.minX,
                        min(location.x, rightTopCropButton.frame.maxX - minMargin))
            let y = max(originalImageViewFrame.minY,
                        min(location.y, bottomLeftButton.frame.maxY - minMargin))
            button.frame.origin.x = x
            button.frame.origin.y = y
            rightTopCropButton.frame.origin.y = y
            bottomLeftButton.frame.origin.x = x
        case rightTopCropButton:
            let x = max(leftTopCropButton.frame.minX + minMargin,
                        min(location.x, originalImageViewFrame.maxX))
            let y = max(originalImageViewFrame.minY,
                        min(location.y, bottomRightCropButton.frame.maxY - minMargin))
            button.frame.origin.x = x
            button.frame.origin.y = y
            
            leftTopCropButton.frame.origin.y = y
            
            var bottomRightFrame = bottomRightCropButton.frame
            bottomRightFrame.origin.x = x
            bottomRightCropButton.frame.origin.x = x
        case bottomLeftButton:
            let x = max(originalImageViewFrame.minX,
                        min(location.x, bottomRightCropButton.frame.maxX - minMargin))
            let y = min(originalImageViewFrame.maxY,
                        max(location.y, leftTopCropButton.frame.minY + minMargin))
            button.frame.origin.x = x
            button.frame.origin.y = y
            
            leftTopCropButton.frame.origin.x = x
            bottomRightCropButton.frame.origin.y = y
        case bottomRightCropButton:
            let x = max(bottomLeftButton.frame.minX + minMargin,
                        min(location.x, originalImageViewFrame.maxX))
            let y = min(originalImageViewFrame.maxY,
                        max(location.y, rightTopCropButton.frame.minY + minMargin))
            button.frame.origin.x = x
            button.frame.origin.y = y
            
            rightTopCropButton.frame.origin.x = x
            bottomLeftButton.frame.origin.y = y
            
        default: return
        }

    }
}

extension ImageEditor: CropButtonDelegate {
    func didChangeFrame(for button: CropButton, position: CropButton.Position) {
        cropImage()
    }
    
    private func cropImage() {
        let x = leftTopCropButton.frame.origin.x
        let y = leftTopCropButton.frame.origin.y
        let width = rightTopCropButton.frame.origin.x - leftTopCropButton.frame.origin.x
        let height = bottomRightCropButton.frame.origin.y - rightTopCropButton.frame.origin.y
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let croppedImage = cropImage(image, toRect: frame, viewWidth: imageView.frame.width,
                                     viewHeight: imageView.frame.height)
        self.imageView.image = croppedImage
        
        self.imageView.frame = frame
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        let imageViewScale: CGFloat = max(inputImage.size.width / viewWidth,
                                          inputImage.size.height / viewHeight)

        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)

        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }

        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
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

