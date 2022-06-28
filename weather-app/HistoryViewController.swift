//
//  HistoryViewController.swift
//  weather-app
//
//  Created by user on 20/6/22.
//

import UIKit
import CoreData
import SVProgressHUD

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var historyList: [History] = []
    var currentListItem: List?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadHistory()
    }

    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let uiNib = UINib(nibName: HistoryTableViewCell.identifier, bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: HistoryTableViewCell.identifier)
    }
    
    func loadHistory() {
        SVProgressHUD.show()
        let context = CoreDataManager.shared.getContext()
        
        let fetchRequest = NSFetchRequest<History>(entityName: "History")
        
        do {
            let dbHistory = try context.fetch(fetchRequest)
            historyList = dbHistory
            tableView.reloadData()
        } catch(let error) {
            print(error)
        }
        SVProgressHUD.dismiss()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier) as? HistoryTableViewCell ?? HistoryTableViewCell(style: .subtitle, reuseIdentifier: HistoryTableViewCell.identifier)
        let history = historyList[indexPath.row]
        
        cell.placeLabel.text = history.place
        
        if let createdAt = history.createdAt {
            cell.dateLabel.text = createdAt
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SVProgressHUD.show()
        let currentHistory = historyList[indexPath.row]
        
        FindWeatherNetworkManager.shared.getFind(query: currentHistory.place) { result in
            switch result {
            case.success(let find):
                self.currentListItem = find.list[Int(currentHistory.position)]
                self.performSegue(withIdentifier: "goToDetailViewController", sender: nil)
            case.failure(let error):
                print("Error", error)
            }
            SVProgressHUD.dismiss()
        }
        
    }

   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goToDetailViewController",
                let destination = segue.destination as? DetailViewController else { return }
        
        destination.listItem = currentListItem
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = historyList[indexPath.row]
        let removeAction = UIContextualAction(style: .destructive, title: "Remove") { _,_,_ in
            self.removePhoto(item: item)
        }
        
        removeAction.image = UIImage(systemName: "trash")
        
        let actions = [
            removeAction
        ]
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func removePhoto(item: History) {
        let context = CoreDataManager.shared.getContext()
        
        let alert = UIAlertController(title: "Remove Element", message: "¿Do you want to remove this element?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Remove", style: .default) { _ in
            guard let index = self.historyList.firstIndex(of: item) else { return }
            self.historyList.remove(at: index)
            context.delete(item)
            CoreDataManager.shared.saveContext()
            
            self.tableView.reloadData()

        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
}
