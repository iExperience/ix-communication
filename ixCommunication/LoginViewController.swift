//
//  ViewController.swift
//  ixCommunication
//
//  Created by Miki von Ketelhodt on 2017/07/18.
//  Copyright © 2017 RBG Applications. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func login(_ sender: Any) {
        
        Firebase
            .Auth
            .auth()
            .signInAnonymously(completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                
                self.performSegue(withIdentifier: "navToChannels", sender: nil)
        })
    }

}

