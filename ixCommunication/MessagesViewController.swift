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

    var channelRef: DatabaseReference?
    
    var channel: Channel? {
        didSet {
            title = channel?.name
        }
    }
    
    var messages = [JSQMessage]()
    
    var messageRef: DatabaseReference?
    var newMessageRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageRef = self.channelRef!.child("messages")

        self.senderId = Firebase.Auth.auth().currentUser?.uid
        self.senderDisplayName = Firebase.Auth.auth().currentUser?.uid
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.observeMessages()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.item]
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return setupOutgoingBubble()
        } else {
            return setupIncomingBubble()
        }
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let itemRef = messageRef?.childByAutoId()
        
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!
        ]
        
        itemRef?.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
    }
    
    private func observeMessages() {
        let messageQuery = messageRef?.queryLimited(toLast:25)
        
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery?.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!,
                let name = messageData["senderName"] as String!,
                let text = messageData["text"] as String!,
                text.characters.count > 0 {
                
                if let message = JSQMessage(senderId: id, displayName: name, text: text) {
                    self.messages.append(message)
                    self.finishReceivingMessage()
                }
                
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
}
