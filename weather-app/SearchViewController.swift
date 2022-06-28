//
//  ViewController.swift
//  weather-app
//
//  Created by user on 20/6/22.
//

import UIKit
import CoreData
import SVProgressHUD

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var list: [List] = []
    var currentListItem: List?
    var placeQuery: String?
    
    var emptyLabel: UILabel = {
        let el = UILabel()
        el.text = "No results found!"
        el.translatesAutoresizingMaskIntoConstraints = false

        return el
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpSearchBar()
        setUpEmptyLabel()
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
    
    func setUpEmptyLabel() {
        view.addSubview(emptyLabel)
        
        emptyLabel.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: searchBar.frame.height + 10).isActive = true
        emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        emptyLabel.isHidden = true
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
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

        if let place = placeQuery,
           !checkHistoryItemInCoreData(place: place, position: Int16(indexPath.row)) {
            saveHistoryInCoreData(place: place, position: Int16(indexPath.row))
        }
        
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

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        SVProgressHUD.show()
        guard let query = searchBar.text else { return }
        placeQuery = query
        
        FindWeatherNetworkManager.shared.getFind(query: query) { result in
            switch result {
            case.success(let find):
                self.list = find.list
                self.emptyLabel.removeFromSuperview()
            case.failure(let error):
                print("Error", error)
            }
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            
            self.emptyLabel.isHidden = false
            
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            list.removeAll()
            tableView.reloadData()
        }
    }
    
    func saveHistoryInCoreData(place: String, position: Int16) {
        let context = CoreDataManager.shared.getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "History", in: context) else { return }
        
        guard let history = NSManagedObject(entity: entity, insertInto: context) as? History else { return }
        
        history.id = Int16.random(in: 1...1000)
        history.place = place
        history.position = position
        
        let formater = DateFormatter()
        formater.dateFormat = "MMM d yyy - HH:mm:ss"
        formater.locale = Locale(identifier: Locale.current.identifier)
        let dateStr = formater.string(from: Date())
        
        history.createdAt = dateStr
        
        CoreDataManager.shared.saveContext()
    }
    
    func checkHistoryItemInCoreData(place: String, position: Int16) -> Bool {
        let context = CoreDataManager.shared.getContext()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "History")
        fetchRequest.fetchLimit =  1
        fetchRequest.predicate = NSPredicate(format: "position == %d AND place == %@", position, place)

        do {
            let count = try context.count(for: fetchRequest)
            return (count > 0)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
}
