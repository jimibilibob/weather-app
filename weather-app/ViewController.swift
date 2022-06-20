//
//  ViewController.swift
//  weather-app
//
//  Created by user on 20/6/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
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
        15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier) as? WeatherTableViewCell ?? WeatherTableViewCell(style: .subtitle, reuseIdentifier: WeatherTableViewCell.identifier)
        
        cell.placeLabel.text = "Cochabamba"
        cell.statusLabel.text = "Clear Sky"
        cell.temperatureLabel.text = "19 C"
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // guard let currentCell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as? WeatherTableViewCell else { return }

        performSegue(withIdentifier: "goToDetailViewController", sender: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 400.0
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goToDetailViewController",
                let destination = segue.destination as? DetailViewController else { return }
        // let cell = currentCell else { return }
        
        //destination.character = character
    }
}
