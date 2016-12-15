//
//  ViewController.swift
//  Example
//
//  Created by kofktu on 2016. 12. 15..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit
import KUIDragStepperSlider

class ViewController: UIViewController {

    @IBOutlet weak var slider: KUIDragStepperSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        slider.onStepperValueRangeHandler = { [weak self] (min, max) in
            print("min : \(min), max : \(max)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onValueChanged() {
        print("value : \(slider.stepperValue)")
    }
    
}

