//
//  KUIDragStepperSlider.swift
//  KUIDragStepperSlider
//
//  Created by kofktu on 2016. 12. 15..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

@IBDesignable
public class KUIDragStepperSlider: UIControl {

    @IBInspectable public var sliderHeight: CGFloat = 2.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var thumbCircleRadius: CGFloat = 8.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var thumbCircleColor: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var thumbCircleShadowColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var thumbCircleShadowRadius: CGFloat? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var thumbCircleShadowSize: CGSize? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var minimumTrackTintColor: UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var maximumTrackTintColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var horizontalMargin: CGFloat = 15.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var minimumValue: CGFloat = 0
    @IBInspectable public var maximumValue: CGFloat = 100
    @IBInspectable public var value: CGFloat = 0.5 {
        didSet {
            if value < 0.0 {
                value = 0.0
            } else if value > 1.0 {
                value = 1.0
            } else {
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var dragEnabledThreshold: CGFloat = 40.0
    
    public var stepperMinimumValue: CGFloat {
        return min(minimumValue + (CGFloat(stepperIndex) * stepperRange), maximumValue)
    }
    public var stepperMaximumValue: CGFloat {
        return min(stepperMinimumValue + stepperRange, maximumValue)
    }
    public var stepperValue: CGFloat {
        return stepperMinimumValue + (stepperRange * value)
    }
    
    @IBInspectable public var stepperIndex = 0
    @IBInspectable public var stepperRange: CGFloat = 20.0
    @IBInspectable public var stepperThreshold: CGFloat = 0.7
    
    public var onStepperValueRangeHandler: ((CGFloat, CGFloat) -> Void)?
    
    public override func draw(_ rect: CGRect) {
        guard let contextRef = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            return
        }
        
        let minX = horizontalMargin + thumbCircleRadius
        let maxX = rect.width - minX
        let midY = rect.height / 2.0
        let width = maxX - minX
        
        // background
        contextRef.setFillColor(maximumTrackTintColor.cgColor)
        contextRef.fill(CGRect(origin: CGPoint(x: minX, y: midY - (sliderHeight / 2.0)), size: CGSize(width: width, height: sliderHeight)))
        
        // foreground
        contextRef.setFillColor(minimumTrackTintColor.cgColor)
        contextRef.fill(CGRect(origin: CGPoint(x: minX, y: midY - (sliderHeight / 2.0)), size: CGSize(width: width * value, height: sliderHeight)))
        
        // circle
        let cx = minX + (width * value) - thumbCircleRadius
        let cy = midY - thumbCircleRadius
        let circleRect = CGRect(origin: CGPoint(x: cx, y: cy), size: CGSize(width: thumbCircleRadius * 2.0, height: thumbCircleRadius * 2.0))
        
        if let color = thumbCircleShadowColor {
            let radius = thumbCircleShadowRadius ?? 2.0
            let size = thumbCircleShadowSize ?? CGSize(width: 0.0, height: 2.0)
            
            contextRef.saveGState()
            contextRef.setShadow(offset: size, blur: radius, color: color.cgColor)
            contextRef.fillEllipse(in: circleRect)
            contextRef.restoreGState()
        }
        
        contextRef.setFillColor(thumbCircleColor.cgColor)
        contextRef.fillEllipse(in: circleRect)
    }

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return offsetHandler(touch.previousLocation(in: self), offset: touch.location(in: self))
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return offsetHandler(touch.previousLocation(in: self), offset: touch.location(in: self))
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let touch = touch else { return }
        let _ = offsetHandler(touch.previousLocation(in: self), offset: touch.location(in: self))
    }
    
    public override func cancelTracking(with event: UIEvent?) {
    }
    
    // MARK: - Private
    private func offsetHandler(_ prev: CGPoint, offset: CGPoint, stepper: Bool = true) -> Bool {
        let width = frame.width
        let sliderWidth = width - (horizontalMargin * 2.0)
        let minX = horizontalMargin + thumbCircleRadius
        let cx = minX + (sliderWidth * self.value)
        
        guard fabs(prev.x - cx) < dragEnabledThreshold else { return false }
        
        if stepper {
            let value = horizontalMargin * stepperThreshold
            
            if offset.x < value {
                if decrease() {
                    return false
                }
            } else if offset.x > width - value {
                if increase() {
                    return false
                }
            }
        }
        
        self.value = (offset.x - horizontalMargin) / sliderWidth
        sendActions(for: .valueChanged)
        
        return true
    }
    
    private func increase() -> Bool {
        let maxIndex = Int(maximumValue / stepperRange)
        guard stepperIndex + 1 < maxIndex else { return false }
        
        stepperIndex += 1
        value = 0.5
        onStepperValueRangeHandler?(stepperMinimumValue, stepperMaximumValue)
        return true
    }
    
    private func decrease() -> Bool {
        guard stepperIndex - 1 >= 0 else { return false }
        
        stepperIndex -= 1
        value = 0.5
        onStepperValueRangeHandler?(stepperMinimumValue, stepperMaximumValue)
        return true
    }
    
}
