//
//  CityListViewController.swift
//  Weather
//
//  Created by 高鑫 on 2017/10/23.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit

class CityListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cityNames = ["北京","大连"]
    let cityDictionary = ["北京":"1", "大连":"446"]
    
    @IBOutlet weak var cityListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityListTableView.delegate = self
        cityListTableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let cityName = cityNames[indexPath.row]
        appDelegate.cityInfo = cityDictionary[cityName]!

        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let weatherView = view.instantiateViewController(withIdentifier: "weatherView")
        self.present(weatherView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityListTableViewCell
        cell.cityNameLabel.text = cityNames[indexPath.row]
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class CityListTableViewCell: UITableViewCell {
    @IBOutlet weak var cityNameLabel: UILabel!
    
}
