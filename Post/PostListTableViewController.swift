//
//  PostListTableViewController.swift
//  Post
//
//  Created by Josh & Erica on 2/14/17.
//  Copyright © 2017 Josh McDonald. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, PostControllerDelegate {
    
    
    
    // MARK: - Properties
    
    var postController = PostController()
    
    
    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        postNewPostAlert()
    }
    
    @IBAction func refreshControl(_ sender: UIRefreshControl) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    // MARK: - Functions
    
    func postNewPostAlert() {
        let alertController = UIAlertController(title: "Enter your name first.", message: "Then nter a message to post below your name:", preferredStyle: .alert)
        
        var usernameTextField: UITextField?
        var messageTextField: UITextField?
        
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Enter your name please..."
            usernameTextField = textfield }
        
        alertController.addTextField { (message) in
            message.placeholder = "Enter your messsage please..."
            messageTextField = message }
        
        
        let submitAction = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let name = usernameTextField?.text,
                let message = messageTextField?.text, !name.isEmpty && !message.isEmpty else { self.presentErrorAlert(); return }
            
            self.postController.addPostWith(username: name, text: message)
            
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func presentErrorAlert() {
        
        let alertController = UIAlertController(title: "Warning", message: "No data has been entered. Please try again.", preferredStyle: .alert)
        
        
        let tryAction = UIAlertAction(title: "Try Again", style: .default) { (_) in self.postNewPostAlert()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(tryAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func postsWereUpdatedTo(posts: [Post], on postController: PostController) {
        tableView.reloadData()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        postController.delegate = self
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postController.posts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > postController.posts.count {
            fet
        }
    }
    
}
