//
//  CityListViewController.swift
//  Weather
//
//  Created by 高鑫 on 2017/10/23.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import Hero
import CoreData

class CityListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var cityInfos : [CityInfo] = []
    var fc : NSFetchedResultsController<CityInfo>!
    
    @IBAction func addBtn(_ sender: UIBarButtonItem) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let addView = view.instantiateViewController(withIdentifier: "addView")
        addView.heroModalAnimationType = .zoomSlide(direction: .left)
        self.present(addView, animated: true, completion: nil)
    }
    @IBOutlet weak var cityListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHeroEnabled = true
        cityListTableView.rowHeight = 40
        cityListTableView.delegate = self
        cityListTableView.dataSource = self
        cityListTableView.tableFooterView = UIView()
        cityListTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10)
        cityListTableView.separatorColor = UIColor(named: "w_lightGray")
        
        fetchAllCityInfos()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let cityInfo = cityInfos[indexPath.row]
        appDelegate.cityInfo = cityInfo.id!
        
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let weatherView = view.instantiateViewController(withIdentifier: "weatherView")
        weatherView.heroModalAnimationType = .pull(direction: .down)
        self.present(weatherView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityListTableViewCell
        let cityInfo = cityInfos[indexPath.row]
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor(named: "w_lightGray")
        cell.nameLabel.text = cityInfo.city
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

extension CityListViewController: NSFetchedResultsControllerDelegate {
    func fetchAllCityInfos() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<CityInfo> = CityInfo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptors]
        
        fc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fc.delegate = self
        
        do {
            
            try fc.performFetch()
            if let object = fc.fetchedObjects {
                cityInfos = object
                print ("取回成功")
            }
            
        } catch {
            print ("取回失败")
        }
        
        cityListTableView.reloadData()
    }
}

class CityListTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
}
