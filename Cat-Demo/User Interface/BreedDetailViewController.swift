//
//  BreedDetailViewController.swift
//  Cat-Demo
//
//  Created by Sukesh Boggavarapu on 2/21/26.
//

import Foundation
import UIKit

final class BreedDetailViewController: UIViewController {
    
    var breed: CatBreed?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lifeSpanLabel: UILabel!
    @IBOutlet weak var temperamentLabel: UILabel!
    @IBOutlet weak var wikipediaButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var raingsLabel: UILabel!
    
    @IBOutlet weak var traitsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let breed = breed else { return }
        title = breed.name ?? "Breed"
        populate()
        loadImage()
    }
    
    private func populate() {
        let lifeValue = breed?.life_span.map { "\($0) years" } ?? "—"
        lifeSpanLabel.attributedText = makeKeyValueText(key: "Lifespan", value: lifeValue)
        
        let tempValue = breed?.temperament ?? "—"
        temperamentLabel.attributedText = makeKeyValueText(key: "Temperament", value: tempValue)
        
        setDescription(breed?.description)
        
        traitsLabel.attributedText = makeSection(
            items: [
                ("Indoor", yesNo(breed?.indoor)),
                ("Hypoallergenic", yesNo(breed?.hypoallergenic)),
                ("Hairless", yesNo(breed?.hairless)),
                ("Rare", yesNo(breed?.rare)),
                ("Lap cat", yesNo(breed?.lap)),
                ("Natural", yesNo(breed?.natural)),
                ("Experimental", yesNo(breed?.experimental))
            ]
        )
        
        // Ratings section (0–5 values)
        raingsLabel.attributedText = makeSection(
            items: [
                ("Intelligence", rating(breed?.intelligence)),
                ("Energy", rating(breed?.energy_level)),
                ("Affection", rating(breed?.affection_level)),
                ("Adaptability", rating(breed?.adaptability)),
                ("Child friendly", rating(breed?.child_friendly)),
                ("Dog friendly", rating(breed?.dog_friendly)),
                ("Grooming", rating(breed?.grooming)),
                ("Social needs", rating(breed?.social_needs)),
                ("Shedding", rating(breed?.shedding_level))
            ]
        )
        
        wikipediaButton.isHidden = (breed?.wikipedia_url == nil)
    }
    private func loadImage() {
        guard let id = breed?.id else { return }
        
        Network.fetchCatImage(breedId: id) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let img) = result {
                    self?.imageView.image = img
                }
            }
        }
    }
    
    @IBAction func buttontapped(_ sender: Any) {
        guard let urlString = breed?.wikipedia_url,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
}

private extension BreedDetailViewController {
    
    func makeKeyValueText(key: String, value: String) -> NSAttributedString {
        let keyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .headline).withTraits(.traitBold),
            .foregroundColor: UIColor.label
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let result = NSMutableAttributedString(string: "\(key): ", attributes: keyAttrs)
        result.append(NSAttributedString(string: value, attributes: valueAttrs))
        return result
    }
    
    func makeSection(items: [(String, String)]) -> NSAttributedString {
        
        let keyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .subheadline),
            .foregroundColor: UIColor.label
        ]
        
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .subheadline),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        
        let result = NSMutableAttributedString()
        
        for (k, v) in items {
            result.append(NSAttributedString(string: "\(k): ", attributes: keyAttrs))
            result.append(NSAttributedString(string: "\(v)\n", attributes: valueAttrs))
        }
        
        result.addAttribute(.paragraphStyle,
                            value: paragraph,
                            range: NSRange(location: 0, length: result.length))
        
        return result
    }
    
    func setDescription(_ text: String?) {
        let desc = (text?.isEmpty == false) ? text! : "—"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.paragraphSpacing = 8
        
        descriptionLabel.attributedText = NSAttributedString(
            string: desc,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: paragraph
            ]
        )
    }
    
    func yesNo(_ value: Int?) -> String {
        guard let v = value else { return "—" }
        return v == 1 ? "Yes" : "No"
    }
    
    func rating(_ value: Int?) -> String {
        guard let v = value else { return "—" }
        return "\(v)/5"
    }
}

// MARK: - UIFont helper
private extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
