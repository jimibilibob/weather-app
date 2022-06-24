//
//  ViewController.swift
//  weather-app
//
//  Created by user on 20/6/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var list: [List] = []
    var currentListItem: List?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpSearchBar()
    }
    
    func setUpSearchBar() {
        searchBar.delegate = self
    }

    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let uiNib = UINib(nibName: WeatherTableViewCell.identifier, bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: WeatherTableViewCell.identifier)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier) as? WeatherTableViewCell ?? WeatherTableViewCell(style: .subtitle, reuseIdentifier: WeatherTableViewCell.identifier)
        
        let listItem = list[indexPath.row]
        
        if let url = URL(string: "https://openweathermap.org/img/wn/\(listItem.weather[0].icon)@2x.png") {
            cell.weatherImageView.image = ImageManager.shared.loadFromUrl(url: url)
        }
        
        cell.placeLabel.text = listItem.name
        cell.statusLabel.text = listItem.weather[0].weatherDescription
        cell.temperatureLabel.text = "\(listItem.main.temp) F"
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentListItem = list[indexPath.row]

        performSegue(withIdentifier: "goToDetailViewController", sender: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 400.0
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goToDetailViewController",
                let destination = segue.destination as? DetailViewController else { return }
        
        destination.listItem = currentListItem
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        
        FindNetworkManager.shared.getFind(query: query) { result in
            switch result {
            case.success(let find):
                self.list = find.list
                self.tableView.reloadData()
            case.failure(let error):
                print("Error", error)
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            /*filteredPhotos = photos
            collectionView.reloadData()
            return*/
        }
    }
}
