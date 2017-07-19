//
//  ChannelsTableViewController.swift
//  ixCommunication
//
//  Created by Miki von Ketelhodt on 2017/07/18.
//  Copyright © 2017 RBG Applications. All rights reserved.
//

import UIKit
import Firebase

class ChannelsTableViewController: UITableViewController {

    var channels: [Channel] = []
    
    private var channelRef: DatabaseReference?
    private var channelRefHandle: DatabaseHandle?
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelRef = Database
            .database()
            .reference()
            .child("channels")
        
        observeChannels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        let chatVc = segue.destination as! MessagesViewController
        
        chatVc.channel = channels[(indexPath?.row)!]
        chatVc.channelRef = channelRef?.child(channels[(indexPath?.row)!].id)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = channels[indexPath.row].name

        return cell
    }
    
    private func observeChannels() {
        channelRefHandle = channelRef?.observe(.childAdded, with: { (snapshot) -> Void in
            
            if let channelData = snapshot.value as? Dictionary<String, AnyObject> {
            
                let id = snapshot.key
                if let name = channelData["name"] as? String, name.characters.count > 0 {
                    self.channels.append(Channel(id: id, name: name))
                    self.tableView.reloadData()
                } else {
                    print("Error! Could not decode channel data")
                }
            } else {
                print("Error! No data.")
            }
        })
    }

}
