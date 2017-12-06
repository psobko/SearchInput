//: Implementation of search microinteraction concept by Preveem Bisht
//: https://www.uplabs.com/posts/search-away-microinteraction

import UIKit
import PlaygroundSupport
import CoreGraphics

class MyViewController : UIViewController {
    let searchInput = SearchInput.init(frame: CGRect(x:0, y:0, width: 300, height: 64))

    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        view.addSubview(searchInput)
        self.view = view
    }
    
    override func viewDidLayoutSubviews() {
        searchInput.center = CGPoint(x:view.center.x ,y:220)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

/////////////////////////////////////////////////////////////
//MARK: Search Input
/////////////////////////////////////////////////////////////

class SearchInput : UIView {
    var buttonColor = UIColor(red:0.227, green:0.678, blue:0.863, alpha:1.000)
    var buttonBackground = UIColor(red:1, green:1, blue:1, alpha:1)
    var isExpanded = false;
    
    let backgroundView = UIView.init()
    let containerView = UIView.init()
    let textField = UITextField.init()
    let button = UIButton.init(type: .system)
    let searchShape = CAShapeLayer.searchShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit();
    }
    
    required init(coder: NSCoder){
        super.init(coder: coder)!
        self.commonInit();
    }
    
    private func commonInit(){
        self.backgroundColor = UIColor.clear

        addSubview(backgroundView)
        addSubview(containerView)
        addSubview(textField)
        addSubview(button)
        self.clipsToBounds = false;

        let spacerView = UIView(frame:CGRect(x:0, y:0, width:frame.height/2, height:1))
        textField.leftViewMode = .always
        textField.leftView = spacerView
        textField.placeholder = "Type here to search..."
        textField.alpha = 0;
        
        if let placeholder = textField.placeholder {
            let attributes = NSAttributedString(string:placeholder,
                                                attributes: [.foregroundColor: buttonColor])
            textField.attributedPlaceholder = attributes;
        }
        UITextField.appearance(whenContainedInInstancesOf: [SearchInput.self]).tintColor =  buttonColor

        button.backgroundColor = buttonColor
        button.layer.addSublayer(searchShape)
        setupButtonTouchEvents()
        
        searchShape.fillColor = buttonBackground.cgColor
        containerView.backgroundColor = buttonBackground
        backgroundView.backgroundColor = buttonColor
    
        containerView.layer.shadowColor =  #colorLiteral(red: 0.348329276, green: 0.3515846898, blue: 0.3515846898, alpha: 0.801242236).cgColor
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 3, height:3)
        containerView.layer.shadowOpacity = 0.4
        
    }
    
    //MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews();
        containerView.frame = self.bounds
        if(isExpanded) {
            setExpandedPosition()
        } else {
            setInitialPosition()
        }
    }
    
    private func setInitialPosition() {
        let iconSize:CGFloat = 24.0
        button.bounds = CGRect(x:0, y:0,
                               width:frame.height,
                               height:frame.height)
        button.center = CGPoint(x:frame.width/2,
                                y:frame.height/2)
        button.layer.cornerRadius = frame.height/2
        searchShape.frame = CGRect(x:(frame.height - iconSize)/2,
                                   y:(frame.height - iconSize)/2,
                                   width:iconSize,
                                   height:iconSize)
        searchShape.transform = CATransform3DMakeScale(0.8, 0.8, 1);
        backgroundView.frame = button.frame;
        backgroundView.layer.cornerRadius = frame.height/2
        containerView.frame = button.frame;
        containerView.layer.cornerRadius = frame.height/2;
        textField.frame = CGRect(x:0,
                                 y:30,
                                 width: frame.width - frame.height * 1.5,
                                 height:frame.height)
    }
    
    private func setExpandedPosition() {
        let splitFrame = containerView.frame.divided(atDistance:frame.height,
                                                     from: CGRectEdge.maxXEdge)
        button.frame = splitFrame.slice
        containerView.frame = self.bounds
        textField.frame = splitFrame.remainder
    }
    
    private func minimumScaleToCoverView() -> CGFloat {
        let maxLength = fmax((UIApplication.shared.keyWindow?.frame.height)!, (UIApplication.shared.keyWindow?.frame.width)!)
        var difference:CGFloat = 0
        
        if(superview != nil && !__CGPointEqualToPoint(center, superview!.center)){
            difference = max(superview!.center.x - abs(center.x), superview!.center.y - abs(center.y))
        }
        return (maxLength + difference*2)/backgroundView.frame.height * 1.2
    }
    
//MARK - Actions
    
    func setupButtonTouchEvents() {
        button.addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(handleTouchUp), for: .touchCancel)
        button.addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
    }
    
    @objc private func handleTouchDown() {
        if(!isExpanded)
        {
            UIView.animate(withDuration: 0.35) {
                self.backgroundView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            }
        }
        
    }
    @objc private func handleTouchUp() {
        if(!isExpanded)
        {
            UIView.animate(withDuration: 0.35) {
                self.backgroundView.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc private func handleTouchUpInside() {
        handleTouchUp()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.toggleInputState(expanded:!self.isExpanded, animated:true)
        }
    }

//MARK - Public
    
    public func toggleInputState(expanded:Bool, animated:Bool = true){
        isExpanded = expanded
        endEditing(true)

        UIView.animate(withDuration:animated ? 0.5 : 0) {
            if(expanded){
                self.setExpandedPosition()
                self.button.backgroundColor = self.buttonBackground
                let scale = self.minimumScaleToCoverView()
                self.textField.alpha = 1
                self.backgroundView.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            }
            else
            {
                self.setInitialPosition()
                self.button.backgroundColor = self.buttonColor
            }
        }
        if(!expanded) {
            UIView.animate(withDuration:animated ? 0.35 : 0) {
                self.textField.alpha = 0
            }
            UIView.animate(withDuration:animated ? 0.65 : 0) {
                self.backgroundView.transform = CGAffineTransform.identity
            }
        }
    
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.fromValue = (!expanded) ? buttonColor.cgColor :  buttonBackground.cgColor
        colorAnimation.toValue = (!expanded) ? buttonBackground.cgColor :  buttonColor.cgColor
        colorAnimation.duration = animated ? 0.5 : 0
        colorAnimation.fillMode = kCAFillModeForwards
        colorAnimation.isRemovedOnCompletion = false
        searchShape.add(colorAnimation, forKey: "fillColor")
        
        if(expanded){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.textField.becomeFirstResponder()
            }
        }
    }
}


/////////////////////////////////////////////////////////////
//MARK: Shape
/////////////////////////////////////////////////////////////

extension CAShapeLayer {
    public static func searchShapeLayer() -> CAShapeLayer {
        let searchLayer = CAShapeLayer.init()
        let searchPath = UIBezierPath.init()
        searchPath.move(to: CGPoint(x:5.77, y:5.77))
        searchPath.addCurve(to: CGPoint(x:5.77, y:16.73),
                            controlPoint1: CGPoint(x:2.74, y:8.8),
                            controlPoint2: CGPoint(x:2.74, y:13.7))
        searchPath.addCurve(to: CGPoint(x:16.73, y:16.73),
                            controlPoint1: CGPoint(x:8.8, y:19.76),
                            controlPoint2: CGPoint(x:13.7, y:19.76))
        searchPath.addCurve(to: CGPoint(x:16.73, y:5.77),
                            controlPoint1: CGPoint(x:19.76, y:13.7),
                            controlPoint2: CGPoint(x:19.76, y:8.8))
        searchPath.addCurve(to: CGPoint(x:5.77, y:5.77),
                            controlPoint1: CGPoint(x:13.7, y:2.74),
                            controlPoint2: CGPoint(x:8.8, y:2.74))
        searchPath.close()
        searchPath.move(to: CGPoint(x:18.78, y:3.22))
        searchPath.addCurve(to: CGPoint(x:18.78, y:18.78),
                            controlPoint1: CGPoint(x:23.07, y:7.52),
                            controlPoint2: CGPoint(x:23.07, y:14.48))
        searchPath.addCurve(to: CGPoint(x:18.56, y:18.99),
                            controlPoint1: CGPoint(x:18.71, y:18.85),
                            controlPoint2: CGPoint(x:18.63, y:18.92))
        searchPath.addCurve(to: CGPoint(x:21.46, y:19.74),
                            controlPoint1: CGPoint(x:19.21, y:19.16),
                            controlPoint2: CGPoint(x:21.46, y:19.74))
        searchPath.addLine(to: CGPoint(x:29.79, y:28.51))
        searchPath.addLine(to: CGPoint(x:27.39, y:30.75))
        searchPath.addLine(to: CGPoint(x:19.24, y:21.91))
        searchPath.addCurve(to: CGPoint(x:18.43, y:19.11),
                            controlPoint1: CGPoint(x:19.24, y:21.91),
                            controlPoint2: CGPoint(x:18.61, y:19.73))
        searchPath.addCurve(to: CGPoint(x:3.22, y:18.78),
                            controlPoint1: CGPoint(x:14.12, y:23.07),
                            controlPoint2: CGPoint(x:7.4, y:22.96))
        searchPath.addCurve(to: CGPoint(x:3.22, y:3.22),
                            controlPoint1: CGPoint(x:-1.07, y:14.48),
                            controlPoint2: CGPoint(x:-1.07, y:7.52))
        searchPath.addCurve(to: CGPoint(x:18.78, y:3.22),
                            controlPoint1: CGPoint(x:7.52, y:-1.07),
                            controlPoint2: CGPoint(x:14.48, y:-1.07))
        searchPath.close()
        searchLayer.path = searchPath.cgPath;
        searchLayer.fillColor = UIColor.blue.cgColor
        return searchLayer;
    }
}

PlaygroundPage.current.liveView = MyViewController()
