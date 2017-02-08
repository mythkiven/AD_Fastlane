//
//  ViewControllerS.swift
//  AD_Demo
//
//  https://github.com/mythkiven/AD_Fastlane


import UIKit

class ViewControllerSecond: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func pop(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

