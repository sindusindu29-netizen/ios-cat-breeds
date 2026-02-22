// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let viewModel = ViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cat Breeds"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.viewModel.catDataDelegate = self
        setupSearch()
        self.viewModel.getBreeds()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    private func setupSearch() {
        
        tableView.tableHeaderView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Filter breeds by name"
        
        definesPresentationContext = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBreedDetail",
           let detailVC = segue.destination as? BreedDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            
            let selectedBreed = viewModel.filteredBreeds[indexPath.row]
            detailVC.breed = selectedBreed
        }
    }
}

// MARK: -
// MARK: TableView Delegate Methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredBreeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "catBreed") else {
            return UITableViewCell()
        }
        
        let breed = viewModel.filteredBreeds[indexPath.row]
        
        cell.textLabel?.text = breed.name
        cell.detailTextLabel?.text = breed.description
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        cell.accessoryType = .disclosureIndicator
        
        return cell
        
    }
    
}

// MARK: -
// MARK: Cat Data Model Delegate Methods
extension ViewController: CatDataDelegate {
    func breedsChangedNotification() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func imageChangedNotification() {
        //        DispatchQueue.main.async {
        //            guard let row = self.tableView.indexPathForSelectedRow?.row else {
        //                return
        //            }
        //
        //            guard let cat = self.viewModel.catBreeds?[row] else {
        //                return
        //            }
        //
        //            let alert = UIAlertController(title: cat.name, message: nil, preferredStyle: .alert)
        //            let imageView = UIImageView(frame: CGRect(x: 10.0, y: 50.0, width: 225, height: 225))
        //            imageView.contentMode = .scaleAspectFit
        //            imageView.image = self.viewModel.catImage
        //
        //            alert.view.addSubview(imageView)
        //
        //            let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        //            let width = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        //
        //            alert.view.addConstraint(height)
        //            alert.view.addConstraint(width)
        //            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        //                alert.dismiss(animated: true, completion: nil)
        //                self.tableView.reloadData()
        //            }))
        //
        //            self.present(alert, animated: true, completion: nil)
        //        }
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterBreeds(query: searchController.searchBar.text ?? "")
    }
}
