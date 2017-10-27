//
//  ContactTableViewCell.swift
//  AddressBookSwift4
//
//  Created by Thomas on 25/10/2017.
//  Copyright © 2017 Thomas. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageViewAvatar: UIImageView!
    
    var task : URLSessionDataTask?
    var avatarUrl : String? {
        didSet {
            task?.cancel()                  // Helps with scrolling too quickly and having to load too many images
            self.downloadImage()
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }
        task.resume()
        self.task = task
    }
    // Image Loading
    func downloadImage() {
        
        guard let urlString = avatarUrl,  let url = URL(string: urlString) else {
            return
        }
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.imageViewAvatar.image = UIImage(data: data)        // Assign image to image view
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}


