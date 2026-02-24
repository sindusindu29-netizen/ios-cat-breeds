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
        
        // Added images
        raingsLabel.attributedText = makeRatingsSection()
        
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
    
    private func configureRatingImage(for value: Int?) -> UIImage? {
        guard let value else { return nil }
        
        let name: String
        switch value {
        case 1: name = "0-poor"
        case 2: name = "1-fair"
        case 3: name = "0-good"
        case 4: name = "3-very-good"
        case 5: name = "4-excellent"
        default: return nil
        }
        
        return UIImage(named: name)
    }
    
    func makeRatingsSection() -> NSAttributedString {
          let paragraph = NSMutableParagraphStyle()
          paragraph.lineSpacing = 3

          let result = NSMutableAttributedString()

          // Build list of rating fields (0–5)
          let items: [(String, Int?)] = [
              ("Intelligence", breed?.intelligence),
              ("Energy", breed?.energy_level),
              ("Affection", breed?.affection_level),
              ("Adaptability", breed?.adaptability),
              ("Child friendly", breed?.child_friendly),
              ("Dog friendly", breed?.dog_friendly),
              ("Grooming", breed?.grooming),
              ("Social needs", breed?.social_needs),
              ("Shedding", breed?.shedding_level)
          ]

          for (key, value) in items {
              // Key (regular)
              let keyAttrs: [NSAttributedString.Key: Any] = [
                  .font: UIFont.preferredFont(forTextStyle: .subheadline),
                  .foregroundColor: UIColor.label
              ]
              result.append(NSAttributedString(string: "\(key): ", attributes: keyAttrs))

              // Value as image (or fallback)
              if let img = configureRatingImage(for: value) {
                  let attachment = NSTextAttachment()
                  attachment.image = img

                  // Make image align nicely with text
                  let font = UIFont.preferredFont(forTextStyle: .subheadline)
                  let imgHeight = font.capHeight + 6 // tweak if needed
                  let ratio = img.size.width / max(img.size.height, 1)
                  attachment.bounds = CGRect(x: 0, y: (font.descender - 2), width: imgHeight * ratio, height: imgHeight)

                  result.append(NSAttributedString(attachment: attachment))
              } else {
                  // If nil / unexpected value
                  let valueAttrs: [NSAttributedString.Key: Any] = [
                      .font: UIFont.preferredFont(forTextStyle: .subheadline),
                      .foregroundColor: UIColor.secondaryLabel
                  ]
                  result.append(NSAttributedString(string: "—", attributes: valueAttrs))
              }

              result.append(NSAttributedString(string: "\n"))
          }

          result.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: result.length))
          return result
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
