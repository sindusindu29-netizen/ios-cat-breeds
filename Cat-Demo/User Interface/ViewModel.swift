// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation
import UIKit

/// Basic Delegate interface to send messages
protocol CatDataDelegate {
    func breedsChangedNotification()
    func imageChangedNotification()
}

/// View model
class ViewModel {
    var catDataDelegate: CatDataDelegate?
    
    private var allBreeds: [CatBreed] = []
    
    /// Array of cat breeds
    var catBreeds: [CatBreed]? {
        didSet {
            //self.catDataDelegate?.breedsChangedNotification()
        }
    }
    
    var filteredBreeds: [CatBreed] = [] {
        didSet {
            self.catDataDelegate?.breedsChangedNotification()
        }
    }
    
    /// Image of the cat
    var catImage: UIImage? {
        didSet {
            self.catDataDelegate?.imageChangedNotification()
        }
    }
    
    /// Get the breeds
    func getBreeds() {
        Network.fetchCatBreeds { (result) in
            switch result
            {
            case .success(let breeds):
                let sorted = breeds.sorted { ($0.name ?? "") < ($1.name ?? "") }
                self.allBreeds = sorted
                self.filteredBreeds = sorted
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func filterBreeds(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            filteredBreeds = allBreeds
            return
        }
        
        filteredBreeds = allBreeds.filter {
            ($0.name ?? "").range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }
    
    func getCatImage(breedId: String) {
        Network.fetchCatImage(breedId: breedId) { (result) in
            switch result
            {
            case .success(let image):
                self.catImage = image
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
