//
//  PostController.swift
//  Post
//
//  Created by Josh & Erica on 2/14/17.
//  Copyright © 2017 Josh McDonald. All rights reserved.
//

import Foundation


class PostController {
    
    
    // MARK: - Properties
    
    static var baseURL = URL(string: "https://devmtn-post.firebaseio.com/posts")
    static let getterEndpoint = baseURL?.appendingPathExtension("json")
    
    weak var delegate: PostControllerDelegate?
    
    var posts: [Post] = [] {
        didSet {
            delegate?.postsWereUpdatedTo(posts: posts, on: self)
        }
    }
    
    // MARK: - Functions
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts(reset: Bool = true, completion: (([Post]) -> Void)? = nil) {
        
        /*
         - Make and send network request
         - Wait for response as Data
         - Turn Data into JSON (serialize Data into JSON)
         - Get card dictionaries from that JSON
         - Turn those dictionaries into card objects
         - Return the cards (array, objects)
         */
        
        guard let url = PostController.getterEndpoint else {
            fatalError("URL optional is nil")
        }
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                completion?([])
                return
            }
            
            
            guard let data = data,
                let responseDataString = String(data: data, encoding: .utf8) else { completion?([]); return }
            
            guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String:Any]] else { NSLog("Unable to serialize JSON. Response: \(responseDataString)"); completion?([]); return }
            
            let posts = jsonDictionary.flatMap { Post(dictionary: $0.1, identifier: $0.0) }
            let sorted = posts.sorted(by: { $0.0.timestamp > $0.1.timestamp} )
            
            
            DispatchQueue.main.async {
                if reset {
                    self.posts.append(contentsOf: sorted)
                    completion?(sorted)
                } else {
                    completion?([])
                }
            }
            
        }
    }
    
    
    func addPostWith(username: String, text: String) {
        
        let post = Post(username: username, text: text)
        
        let identifier = post.identifier.uuidString
        
        guard let url = PostController.baseURL?.appendingPathComponent(identifier).appendingPathExtension("json") else { return }
        
        NetworkController.performRequest(for: url, httpMethod: .Put, body: post.json) { (data, error) in
            
            guard let data = data,
                let responseDataString = String(data: data, encoding: .utf8) else { return }
            
            if let error = error {
                print("There was an error putting the post to the database. Error: \(error.localizedDescription)")
            } else if
                responseDataString.contains("error") {
                print("Error: \(responseDataString)")
            } else {
                print("Successfully saved data to endpoint. \nReponse: \(responseDataString)")
                self.fetchPosts()
            }
        }
    }
}



protocol PostControllerDelegate: class {
    func postsWereUpdatedTo(posts: [Post], on postController: PostController)
}



