//
//  MXCheckmark.swift
//  MXCheckmark
//
//  Created by Maxim Krouk on 4/26/19.
//  Copyright © 2019 mxcat. All rights reserved.
//


import UIKit

public class MXCheckmark: UIControl {
    
    public enum Style {
        case plain
        case round
        case square
        case soft
        case none
    }
    
    // MARK: - Value Manipulations
    private var isChecked = false {
        didSet {
            update(true)
            sendActions(for: .valueChanged)
        }
    }
    public var changesValueOnTouch: Bool = true
    public var value: Bool { return isChecked }
    public func setValue(_ value: Bool) { isChecked = value }
    public func toggle() { isChecked.toggle() }
    
    // MARK: - View
    public var style: Style = .none {
        didSet { update(true) }
    }
    public var markLineCap: CAShapeLayerLineCap = .round {
        didSet { update(true) }
    }
    public var markLineJoin: CAShapeLayerLineJoin = .miter {
        didSet { update(true) }
    }
    public var borderLineJoin: CAShapeLayerLineJoin = .miter {
        didSet { update(true) }
    }
    
    // MARK: - Animatiors
    public var layerMaskUpdater: (() -> CALayer)?
    public var layerMaskAnimator: ((TimeInterval) -> CAAnimationGroup)?
    public var animationDuration: TimeInterval = 0.2
    
    // MARK: - Mask components
    private let border = CAShapeLayer()
    private let mark = CAShapeLayer()
    
    // MARK: - Init
    override public class var layerClass: Swift.AnyClass {
        return CAShapeLayer.self
    }
    
    public init(state: Bool, style: Style, color: UIColor = .black, frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.layer.backgroundColor = color.cgColor
        self.isChecked = state
        self.style = style
        
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        resetLayerMaskUpdater()
    }
    
    // MARK: - View updating
    override public func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    private func update(_ animated: Bool = false) {
        guard let mask = layerMaskUpdater?() else { return }
        mark.removeAllAnimations()
        if animated, let animations = layerMaskAnimator?(animationDuration) {
            mark.add(animations, forKey: "strokeEndAnimation")
        } else {
            mark.strokeEnd = isChecked ? 1.0 : -0.1
        }
        layer.mask = mask
    }
    
    // MARK: - Animations
    public func resetLayerMaskAnimator() {
        layerMaskAnimator = getDefaultLayerMaskAnimator()
    }
    
    private func getDefaultLayerMaskAnimator() -> ((TimeInterval) -> CAAnimationGroup) {
        
        return { [weak self] (duration: TimeInterval) in
            guard let checkmark = self else { return CAAnimationGroup() }
            let animationGroup = CAAnimationGroup()
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            animation.toValue = checkmark.isChecked ? 1.0 : -0.1
            
            animationGroup.animations = [animation]
            animationGroup.isRemovedOnCompletion = false
            animationGroup.fillMode = .forwards
            
            return animationGroup
        }
        
    }
    
    public func resetLayerMaskUpdater() {
        layerMaskUpdater = getDefaultLayerMaskUpdater()
    }
    
    private func getDefaultLayerMaskUpdater() -> (() -> CALayer) {
        return { [weak self] () -> CALayer in
            guard let checkmark = self else { return CALayer() }
            
            let mask = CAShapeLayer()
            
            let length = checkmark.bounds.height < checkmark.bounds.width ?
                checkmark.bounds.height :
                checkmark.bounds.width
            
            let pathForBorder = CGMutablePath()
            let pathForCheckMark = CGMutablePath()
            
            checkmark.mark.fillColor = UIColor.clear.cgColor
            checkmark.border.fillColor = UIColor.clear.cgColor
            
            checkmark.mark.strokeColor = UIColor.black.cgColor
            checkmark.border.strokeColor = UIColor.black.cgColor
            
            checkmark.mark.lineWidth = length / 11
            checkmark.border.lineWidth = length / 22
            
            checkmark.mark.lineCap = .round
            checkmark.mark.lineJoin = .miter
            
            switch  checkmark.style {
            case .round, .square, .soft:
                let rect = checkmark.bounds.insetBy(
                    dx: checkmark.border.lineWidth,
                    dy: checkmark.border.lineWidth)
                var size: CGSize = CGSize(width: 0, height: 0)
                
                if checkmark.style == .soft {
                    size = CGSize(width: rect.width / 5,
                                  height: rect.width / 5)
                } else if checkmark.style == .round {
                    size = CGSize(width: rect.width / 2,
                                  height: rect.height / 2)
                }
                
                checkmark.border.removeAllAnimations()
                
                pathForBorder.addRoundedRect(in: rect,
                                             cornerWidth: size.width,
                                             cornerHeight: size.height)
                fallthrough
            case .plain:
                pathForCheckMark.addLines(between: [
                    CGPoint(
                        x: checkmark.bounds.width * 0.307,
                        y: checkmark.bounds.height * 0.5),
                    CGPoint(
                        x: checkmark.bounds.width * 0.45,
                        y: checkmark.bounds.height * 0.636),
                    CGPoint(
                        x: checkmark.bounds.width * 0.727,
                        y: checkmark.bounds.height * 0.341)
                    ])
            case .none:
                return CALayer()
            }
            
            checkmark.border.path = pathForBorder
            checkmark.mark.path = pathForCheckMark
            
            mask.addSublayer(checkmark.border)
            mask.addSublayer(checkmark.mark)
            return mask
        }
    }
    
    // MARK: - User interaction
    @objc private func handleTapGesture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            sendActions(for: .touchDown)
        case .cancelled:
            sendActions(for: .touchCancel)
        case .ended:
            if changesValueOnTouch { isChecked.toggle() }
            let touchPoint = sender.location(in: self)
            if bounds.contains(touchPoint) {
                sendActions(for: .touchUpInside)
            } else {
                sendActions(for: .touchUpOutside)
            }
        default:
            print("Unimplemented tap state")
        }
    }
}
