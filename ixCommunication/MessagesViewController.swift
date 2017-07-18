//
//  MessagesViewController.swift
//  ixCommunication
//
//  Created by Miki von Ketelhodt on 2017/07/18.
//  Copyright © 2017 RBG Applications. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseAuth

class MessagesViewController: JSQMessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = Firebase.Auth.auth().currentUser?.uid
        self.senderDisplayName = Firebase.Auth.auth().currentUser?.uid
    }
    
}
