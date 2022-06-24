//
//  DetailViewController.swift
//  weather-app
//
//  Created by user on 20/6/22.
//

import UIKit
import SVProgressHUD

class DetailViewController: UIViewController {
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    var listItem: List?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUptViews()
    }
    
    func setUptViews() {
        SVProgressHUD.show()
        guard let listItem = listItem else { return }
        
        if let url = URL(string: "https://openweathermap.org/img/wn/\(listItem.weather[0].icon)@2x.png") {
            weatherImageView.image = ImageManager.shared.loadFromUrl(url: url)
        }
        
        if let url = URL(string: "https://countryflagsapi.com/png/\(listItem.sys.country)") {
            countryFlagImageView.image = ImageManager.shared.loadFromUrl(url: url)
        }
        
        countryLabel.text = "Country \(listItem.sys.country)"
        placeLabel.text = listItem.name
        temperatureLabel.text = "\(listItem.main.temp) F"
        weatherDescriptionLabel.text = listItem.weather[0].weatherDescription
        windLabel.text = "Speed: \(listItem.wind.speed), Degree: \(listItem.wind.deg)"
        SVProgressHUD.dismiss()
    }
}
