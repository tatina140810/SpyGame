import UIKit

class CircularTimerView: UIView {
    var onTimerFinished: (() -> Void)?
    private let shapeLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private var timer: Timer?
    private var duration: TimeInterval = 60
    private var elapsed: TimeInterval = 0
    
    private var secondsRemaining: Int = 0
    private(set) var isPaused = false
    var onSecondTick: ((Int) -> Void)?
    
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        addSubview(timeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timeLabel.frame = bounds
        configureCircularPath()
    }
    
    private func setupLayers() {
        trackLayer.strokeColor = UIColor.darkGray.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 10
        layer.addSublayer(trackLayer)
        
        shapeLayer.strokeColor = UIColor.midleBlue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
        layer.addSublayer(shapeLayer)
    }
    
    private func configureCircularPath() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 10
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        trackLayer.path = circularPath.cgPath
        shapeLayer.path = circularPath.cgPath
    }
    
    func start(duration: TimeInterval) {
        self.duration = duration
        self.elapsed = 0
        self.secondsRemaining = Int(duration)
        shapeLayer.strokeEnd = 0
        updateLabel()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    func paused(){
        guard !isPaused else {return}
        timer?.invalidate()
        isPaused = true
    }
    func resume() {
        guard isPaused else { return } 
        isPaused = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        elapsed += 1
        secondsRemaining -= 1
        
        let progress = elapsed / duration
        shapeLayer.strokeEnd = CGFloat(progress)
        updateLabel()
        
        onSecondTick?(secondsRemaining) 
        if secondsRemaining <= 0 {
            timer?.invalidate()
            onTimerFinished?()
        }
    }
    
    
    private func updateLabel() {
        let remaining = max(Int(duration - elapsed), 0)
        let minutes = remaining / 60
        let seconds = remaining % 60
        timeLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        
    }
}
