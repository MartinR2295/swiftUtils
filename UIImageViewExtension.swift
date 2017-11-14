//
//  UIImageViewExtension.swift
//
//  Created by Martin Rader on 13.11.17.
//  Copyright © 2017 Martin Rader. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageFromUrl(url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}
