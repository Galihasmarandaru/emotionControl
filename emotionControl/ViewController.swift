//
//  ViewController.swift
//  emotionControl
//
//  Created by Galih Asmarandaru on 20/05/19.
//  Copyright © 2019 Galih Asmarandaru. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var grSquare: UIView!
    
    var motion = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myGyroscope()
//        myAccelerometer()
    }
    
    func myGyroscope() {
        motion.gyroUpdateInterval = 1
        motion.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            print(data as Any)
            if let trueData = data {
                self.view.reloadInputViews()
                let x = trueData.rotationRate.x
                let y = trueData.rotationRate.y
                let z = trueData.rotationRate.z

                self.changeSize(x: x, y: y, z: z)
            }
        }
        return
    }
    
    func myAccelerometer() {
        motion.accelerometerUpdateInterval = 0.5
        motion.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            print(data as Any)
            if let trueData = data {
                self.view.reloadInputViews()
                let x = trueData.acceleration.x
                let y = trueData.acceleration.y
                let z = trueData.acceleration.z
                
                self.changeSize(x: x, y: y, z: z)
            }
        }
    }
    
    func changeSize(x: Double, y: Double, z: Double) {
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
        self.grSquare.transform = CGAffineTransform(scaleX: CGFloat(80), y: CGFloat(x))
            self.grSquare.transform = CGAffineTransform(rotationAngle: CGFloat(z))
        }) { (isFinished) in
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded()/divisor
    }
}


