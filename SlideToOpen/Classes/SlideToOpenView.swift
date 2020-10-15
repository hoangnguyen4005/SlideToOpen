//
//  SlideToOpenView.swift
//  SlideToOpenView
//
//  Created by Chi Hoang on 15/10/20.
//  Copyright © 2020 Hoang Nguyen Chi. All rights reserved.
//

import UIKit

enum ColorTheme {
    static let green = #colorLiteral(red: 0.2470588235, green: 0.6117647059, blue: 0.2078431373, alpha: 1)
    static let white = #colorLiteral(red: 0.9019607843, green: 0.9058823529, blue: 0.9098039216, alpha: 1)
}

public protocol SlideToOpenViewDelegate: class {
    func didFinishSlideToOpenView(_ sender: SlideToOpenView)
}

public class SlideToOpenView: UIView {

    let textLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let sliderTextLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let thumnailImageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .center
        return view
    }()

    let sliderHolderView: UIView = {
        let view = UIView()
        return view
    }()

    let draggedView: UIView = {
        let view = UIView()
        return view
    }()

    let view: UIView = {
        let view = UIView()
        return view
    }()

    // MARK: Private Properties
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var leadingThumbnailViewConstraint: NSLayoutConstraint?
    private var leadingTextLabelConstraint: NSLayoutConstraint?
    private var topSliderConstraint: NSLayoutConstraint?
    private var topThumbnailViewConstraint: NSLayoutConstraint?
    private var trailingDraggedViewConstraint: NSLayoutConstraint?
    private var isFinished: Bool = false
    private var animationVelocity: Double = 0.2

    // swiftlint:disable implicit_getter
    private var xEndingPoint: CGFloat {
        get {
            return (self.view.frame.maxX - thumnailImageView.bounds.width)
        }
    }

    private var sliderViewTopDistance: CGFloat = 0.0 {
        didSet {
            topSliderConstraint?.constant = sliderViewTopDistance
            layoutIfNeeded()
        }
    }

    private var thumbnailViewTopDistance: CGFloat = 0.0 {
        didSet {
            topThumbnailViewConstraint?.constant = thumbnailViewTopDistance
            layoutIfNeeded()
        }
    }

    // MARK: Public properties
    public weak var delegate: SlideToOpenViewDelegate?

    public var showSliderText: Bool = true {
        didSet {
            sliderTextLabel.isHidden = !showSliderText
        }
    }

    public var sliderBackgroundColor: UIColor = ColorTheme.green.withAlphaComponent(0.15) {
        didSet {
            sliderHolderView.backgroundColor = sliderBackgroundColor
            sliderTextLabel.textColor = sliderBackgroundColor
        }
    }

    public var slidingColor: UIColor = ColorTheme.green.withAlphaComponent(0.15) {
        didSet {
            draggedView.backgroundColor = slidingColor
        }
    }

    public var thumbnailColor: UIColor = ColorTheme.green {
        didSet {
            thumnailImageView.backgroundColor = thumbnailColor
        }
    }

    public var text: String? {
        didSet {
            textLabel.text = text
            sliderTextLabel.text = text
        }
    }

    public var textFont: UIFont? {
        didSet {
            textLabel.font = textFont
            sliderTextLabel.font = textFont
        }
    }

    public var textColor: UIColor = ColorTheme.green.withAlphaComponent(0.6) {
        didSet {
            textLabel.textColor = textColor
        }
    }

    public var icon: UIImage? {
        didSet {
            let image = icon?.withRenderingMode(.alwaysTemplate)
            thumnailImageView.image = image?.imageFlippedForRightToLeftLayoutDirection()
            thumnailImageView.tintColor = ColorTheme.white
        }
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    public override  init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupView()
    }

    private func setupView() {
        self.addSubview(view)
        view.addSubview(thumnailImageView)
        view.addSubview(sliderHolderView)
        view.addSubview(draggedView)
        draggedView.addSubview(sliderTextLabel)
        sliderHolderView.addSubview(textLabel)
        view.bringSubviewToFront(thumnailImageView)

        setupConstraint()
        setStyle()

        panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        thumnailImageView.addGestureRecognizer(panGestureRecognizer)
    }

    private func setupConstraint() {
        view.translatesAutoresizingMaskIntoConstraints = false
        thumnailImageView.translatesAutoresizingMaskIntoConstraints = false
        sliderHolderView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderTextLabel.translatesAutoresizingMaskIntoConstraints = false
        draggedView.translatesAutoresizingMaskIntoConstraints = false

        // Setup for view
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        leadingThumbnailViewConstraint = thumnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leadingThumbnailViewConstraint?.isActive = true

        topThumbnailViewConstraint = thumnailImageView.topAnchor.constraint(equalTo: view.topAnchor,
                                                                            constant: thumbnailViewTopDistance)
        topThumbnailViewConstraint?.isActive = true

        thumnailImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        thumnailImageView.widthAnchor.constraint(equalToConstant: 86.0).isActive = true

        // Setup for slider holder view
        topSliderConstraint = sliderHolderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0)
        topSliderConstraint?.isActive = true

        sliderHolderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sliderHolderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sliderHolderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Setup for textLabel
        textLabel.topAnchor.constraint(equalTo: sliderHolderView.topAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: sliderHolderView.centerYAnchor).isActive = true

        leadingTextLabelConstraint = textLabel.leadingAnchor.constraint(equalTo: sliderHolderView.leadingAnchor,
                                                                        constant: 54.0)
        leadingTextLabelConstraint?.isActive = true
        textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: CGFloat(-8)).isActive = true

        // Setup for sliderTextLabel
        sliderTextLabel.topAnchor.constraint(equalTo: textLabel.topAnchor).isActive = true
        sliderTextLabel.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor).isActive = true
        sliderTextLabel.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor).isActive = true
        sliderTextLabel.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor).isActive = true

        // Setup for Dragged View
        draggedView.leadingAnchor.constraint(equalTo: sliderHolderView.leadingAnchor).isActive = true
        draggedView.topAnchor.constraint(equalTo: sliderHolderView.topAnchor).isActive = true
        draggedView.centerYAnchor.constraint(equalTo: sliderHolderView.centerYAnchor).isActive = true

        trailingDraggedViewConstraint = draggedView.trailingAnchor.constraint(equalTo: thumnailImageView.trailingAnchor, constant: 0.0)
        trailingDraggedViewConstraint?.isActive = true
    }

    private func setStyle() {
        thumnailImageView.clipsToBounds = true
        thumnailImageView.backgroundColor = thumbnailColor
        thumnailImageView.layer.cornerRadius = 4.0

        textLabel.text = text
        textLabel.font = textFont
        textLabel.textColor = textColor
        textLabel.textAlignment = .center

        sliderTextLabel.text = text
        sliderTextLabel.font = textFont
        sliderTextLabel.textColor = sliderBackgroundColor
        sliderTextLabel.textAlignment = .center
        sliderTextLabel.isHidden = !showSliderText

        if isOnRightToLeftLanguage() {
            textLabel.flipView()
            sliderTextLabel.flipView()
        }

        sliderHolderView.backgroundColor = sliderBackgroundColor
        sliderHolderView.layer.cornerRadius = 4.0

        draggedView.backgroundColor = slidingColor
        draggedView.layer.cornerRadius = 4.0
        draggedView.clipsToBounds = true
        draggedView.layer.masksToBounds = true
    }

    private func updateThumbnailXPosition(_ x: CGFloat) {
        leadingThumbnailViewConstraint?.constant = x
        setNeedsLayout()
    }

    // MARK: UIPanGestureRecognizer
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if isFinished { return }
        let translatedPoint = sender.translation(in: view).x * (self.isOnRightToLeftLanguage() ? -1 : 1)
        switch sender.state {
        case .changed:
            if translatedPoint >= xEndingPoint {
                updateThumbnailXPosition(xEndingPoint)
                return
            }
            if translatedPoint <= 0.0 {
                textLabel.alpha = 1
                updateThumbnailXPosition(0.0)
                return
            }
            updateThumbnailXPosition(translatedPoint)
            textLabel.alpha = (xEndingPoint - translatedPoint) / xEndingPoint
        case .ended:
            if translatedPoint >= xEndingPoint {
                textLabel.alpha = 0
                updateThumbnailXPosition(xEndingPoint)
                isFinished = true
                delegate?.didFinishSlideToOpenView(self)
                return
            }
            if translatedPoint <= 0.0 {
                textLabel.alpha = 1
                updateThumbnailXPosition(0.0)
                return
            }
            UIView.animate(withDuration: animationVelocity) {
                self.leadingThumbnailViewConstraint?.constant = 0.0
                self.textLabel.alpha = 1
                self.layoutIfNeeded()
            }
        default:
            break
        }
    }

    public func resetStateWithAnimation(_ animated: Bool) {
        let action = {
            self.leadingThumbnailViewConstraint?.constant = 0.0
            self.textLabel.alpha = 1
            self.layoutIfNeeded()
            self.isFinished = false
        }
        if animated {
            UIView.animate(withDuration: animationVelocity) { action() }
        } else {
            action()
        }
    }

    private func isOnRightToLeftLanguage() -> Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
}
