//
//  AddViewController.swift
//  Weather
//
//  Created by 高鑫 on 2017/10/25.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var cityInfo : CityInfo!
    var cityInfosMO : [CityInfo] = []
    var fc : NSFetchedResultsController<CityInfo>!
    var citynms : [String] = []
    var cityInfos : Dictionary<String, String> = [:]
    let todayDate = Date()
    let formatter = DateFormatter()
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let cityView = view.instantiateViewController(withIdentifier: "cityView")
        cityView.heroModalAnimationType = .pageOut(direction: .down)
        self.present(cityView, animated: true, completion: nil)
    }
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func searchBtn(_ sender: UIButton) {
        getCityData()
    }
    @IBOutlet weak var addTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTableView.delegate = self
        addTableView.dataSource = self
        addTableView.tableFooterView = UIView()
        addTableView.rowHeight = 40
        addTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10)
        addTableView.separatorColor = UIColor(named: "w_lightGray")
        
        searchTextField.placeholder = "请输入城市名"
        searchTextField.setValue(UIColor.lightGray, forKeyPath: "_placeholderLabel.textColor")
        searchTextField.textAlignment = .left
        searchTextField.contentVerticalAlignment = .center
        searchTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        searchTextField.returnKeyType = UIReturnKeyType.done
        searchTextField.delegate = self
        
        let noneView = UIView()
        noneView.tag = 130
        noneView.frame = addTableView.frame
        noneView.backgroundColor = addTableView.backgroundColor
        noneView.isHidden = true
        self.view.addSubview(noneView)
        let noneLabel = UILabel(frame: CGRect(x: 0, y: 0, width: weatherSize.screen_w, height: 100))
        noneLabel.text = "没有找到结果"
        noneLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        noneLabel.textColor = UIColor.lightGray
        noneLabel.textAlignment = .center
        noneView.addSubview(noneLabel)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        getCityData()
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let isHad = fetHadCityInfos(resultCity: citynms[indexPath.row])
        if isHad == true {
            alertAction()
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            cityInfo = CityInfo(context: appDelegate.persistentContainer.viewContext)
            cityInfo.city = citynms[indexPath.row]
            cityInfo.id = cityInfos[citynms[indexPath.row]]
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cityInfo.order = formatter.string(from: todayDate)
            appDelegate.saveContext()
            
            let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let cityView = view.instantiateViewController(withIdentifier: "cityView")
            cityView.heroModalAnimationType = .zoomSlide(direction: .right)
            self.present(cityView, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citynms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddTableViewCell
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor(named: "w_lightGray")
        cell.addCityLabel.text = citynms[indexPath.row]
        return cell
    }
    
    func getCityData() {
        searchTextField.resignFirstResponder()
        
        let path = "http://api.k780.com/?app=weather.city%20&&%20appkey=29082&sign=7034102070325f406c7de00fb38a90c1&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let searchStr = self.searchTextField.text
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSON(data: data!)
                    let count: Int = json["result"].count
                    let jsonDic = json["result"].dictionary!
                    let sortedKeysAndValues = jsonDic.sorted(by: { (d1, d2) -> Bool in
                        return d1 < d2 ? true : false
                    })
                    self.citynms = []
                    self.cityInfos = [:]
                    for i in 0..<count {
                        let city = sortedKeysAndValues[i].value["citynm"].string!
                        let id = sortedKeysAndValues[i].value["weaid"].string!
                        if city == searchStr! {
                            self.citynms.append(city)
                            self.cityInfos[city] = id
                        }
                    }
                    print(self.citynms)
                    print(self.cityInfos)
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                } catch {
                    print("Error creating the database")
                }
            } else {
                print(error!)
            }
        }
        task.resume()
    }
    
    func updateUI() {
        self.addTableView.reloadData()
        let noneView = self.view.viewWithTag(130)
        if citynms == [] {
            noneView?.isHidden = false
        } else {
            noneView?.isHidden = true
        }
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

extension AddViewController: NSFetchedResultsControllerDelegate {
    
    func fetHadCityInfos(resultCity: String)->Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        var hadCityArray: [String] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityInfo")
        
        do {
            let citysList = try context.fetch(fetchRequest)
            
            for city in citysList as! [CityInfo] {
                hadCityArray.append(city.city!)
            }
        } catch {
            print(error)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
        return hadCityArray.contains(resultCity)
        
    }
    
    func alertAction() {
        let alertController = UIAlertController(title: "提示",message: "列表中已存在该城市", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "好的", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

class AddTableViewCell: UITableViewCell {
    @IBOutlet weak var addCityLabel: UILabel!
    
}
