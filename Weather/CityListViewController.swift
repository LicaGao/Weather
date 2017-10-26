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
import SnapKit

class CityListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var cityInfos : [CityInfo] = []
    var fc : NSFetchedResultsController<CityInfo>!

    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationCityLabel: UILabel!
    @IBOutlet weak var cityListTableView: UITableView!
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.locationCity != "" {
            locationCityLabel.text = appDelegate.locationCity
        }
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.isHeroEnabled = true
        cityListTableView.rowHeight = 40
        cityListTableView.delegate = self
        cityListTableView.dataSource = self
        cityListTableView.tableFooterView = UIView()
        cityListTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10)
        cityListTableView.separatorColor = UIColor(named: "w_lightGray")
        
        let bgImage = UIImageView(image: #imageLiteral(resourceName: "bg"))
        self.view.addSubview(bgImage)
        bgImage.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.centerX.equalTo(weatherSize.screen_w / 2)
            make.bottom.equalTo(self.view).offset(-10)
        }
        
        let addBtn = UIButton()
        addBtn.setImage(#imageLiteral(resourceName: "add"), for: .normal)
        addBtn.tag = 170
        addBtn.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        self.view.addSubview(addBtn)
        addBtn.snp.makeConstraints { (make) in
            make.size.equalTo(40)
            make.center.equalTo(bgImage)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(tapGesture:)))
        locationView.addGestureRecognizer(tapGesture)
        
        fetchAllCityInfos()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tapAction(tapGesture: UITapGestureRecognizer) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.cityInfo != "" {
            appDelegate.cityInfo = ""
        }
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let weatherView = view.instantiateViewController(withIdentifier: "weatherView")
        weatherView.heroModalAnimationType = .pageIn(direction: .down)
        self.present(weatherView, animated: true, completion: nil)
        
    }
    
    @objc func addAction(_ sender: UIButton) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let addView = view.instantiateViewController(withIdentifier: "addView")
        addView.heroModalAnimationType = .pageIn(direction: .up)
        self.present(addView, animated: true, completion: nil)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        cityListTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        cityListTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            cityListTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            cityListTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            cityListTableView.reloadRows(at: [indexPath!], with: .automatic)
        default:
            cityListTableView.reloadData()
        }
        
        if let object = controller.fetchedObjects {
            cityInfos = object as! [CityInfo]
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionDel = UIContextualAction(style: .destructive, title: "删除") { (action, view, finished) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            context.delete(self.fc.object(at: indexPath))
            appDelegate.saveContext()
            
            finished(true)
        }
        actionDel.backgroundColor = UIColor(named: "w_red")
        return UISwipeActionsConfiguration(actions: [actionDel])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let cityInfo = cityInfos[indexPath.row]
        appDelegate.cityInfo = cityInfo.id!
        
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let weatherView = view.instantiateViewController(withIdentifier: "weatherView")
        weatherView.heroModalAnimationType = .pageIn(direction: .down)
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
        let sortDescriptors = NSSortDescriptor(key: "order", ascending: true)
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
