//
//  WeatherViewController.swift
//  Weather
//
//  Created by 高鑫 on 2017/10/23.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import SnapKit

class WeatherViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource  {

    var cityInfo: String = "446"
    var futureDateArray : [String] = []
    var futureWeatherArray : [String] = []
    var futureWeatherDictionary: Dictionary<String, [String]> = [:]
    
    @IBOutlet weak var weatherInfoScrollView: UIScrollView!
    @IBAction func menuBtn(_ sender: UIButton) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let cityListView = view.instantiateViewController(withIdentifier: "cityListView")
        self.present(cityListView, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.cityInfo == "" {
            cityInfo = "446"
        } else {
            cityInfo = appDelegate.cityInfo
        }
        weatherInfoScrollView.delegate = self
        setUI()
        getWeatherData()
        getFutureWeatherData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return futureWeatherDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(named: "w_lightblue")
        cell.selectionStyle = .none
        let sortedKeysAndValues = self.futureWeatherDictionary.sorted(by: { (d1, d2) -> Bool in
            return d1.0 < d2.0 ? true : false
        })
        let weekLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 40))
        if futureWeatherDictionary.count == 0 {
            weekLabel.text = "--"
        } else {
            weekLabel.text = sortedKeysAndValues[indexPath.row].value[0]
        }
        weekLabel.textAlignment = .left
        if indexPath.row == 0 {
            weekLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        } else {
            weekLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        }
        weekLabel.textColor = UIColor.white
        cell.contentView.addSubview(weekLabel)
        
        let tempLabel = UILabel(frame: CGRect(x: weatherSize.screen_w - 110, y: 0, width: 100, height: 40))
        if futureWeatherDictionary.count == 0 {
            tempLabel.text = "--℃/--℃"
        } else {
            tempLabel.text = sortedKeysAndValues[indexPath.row].value[2]
        }
        tempLabel.textAlignment = .right
        if indexPath.row == 0 {
            tempLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        } else {
            tempLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        }
        tempLabel.textColor = UIColor.white
        cell.contentView.addSubview(tempLabel)
        
        let weaImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        weaImg.center.x = weatherSize.screen_w / 2
        weaImg.center.y = cell.center.y
        let weaPy = sortedKeysAndValues[indexPath.row].value[1].transformToPinYin()
        let zhuanStr = "zhuan"
        let range = weaPy.range(of: zhuanStr)
        if range == nil {
            weaImg.image = UIImage(named: weaPy)
        } else {
            let position = weaPy.positionOf(sub: zhuanStr)
            let index = weaPy.index(weaPy.startIndex, offsetBy: position)
            let positionResult = weaPy[..<index]
            weaImg.image = UIImage(named: "\(positionResult)")
        }
        
        cell.contentView.addSubview(weaImg)
        
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleView = self.view.viewWithTag(100)
        let title = self.view.viewWithTag(101) as! UILabel
        let min : CGFloat = 0
        let max : CGFloat = 120
        let offset = scrollView.contentOffset.y

        let alpha = (offset - min) / (max - min)
        titleView?.alpha = alpha
        let width = weatherSize.screen_w - offset * 2
        if width <= 100 {
            title.frame.size.width = 100
        } else if width >= weatherSize.screen_w {
            title.frame.size.width = weatherSize.screen_w
        } else {
            title.frame.size.width = width
        }
    }
    
    func getWeatherData() {
        
        let path = "http://api.k780.com:88/?app=weather.today&weaid=\(cityInfo)&&appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSON(data: data!)
                    let name = json["result"]["citynm"].string!
                    let temp = json["result"]["temperature_curr"].string!
                    let tempAll = json["result"]["temperature"].string!
                    let weather = json["result"]["weather_curr"].string!
                    DispatchQueue.main.async {
                        self.updateUI(name: name, temp: temp, tempAll: tempAll, weather: weather)
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
    
    func getFutureWeatherData() {
        let path = "http://api.k780.com:88/?app=weather.future&weaid=\(cityInfo)&&appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSON(data: data!)
                    let count: Int = json["result"].count
                    for i in 0..<count {
                        let days = json["result"][i]["days"].string!
                        let week = json["result"][i]["week"].string!
                        let temperature = json["result"][i]["temperature"].string!
                        let weather = json["result"][i]["weather"].string!
                        self.futureDateArray.append(days)
                        self.futureWeatherArray.append(week)
                        self.futureWeatherArray.append(weather)
                        self.futureWeatherArray.append(temperature)
                        self.futureWeatherDictionary[days] = self.futureWeatherArray
                        self.futureWeatherArray = []
                    }
                    let sortedKeysAndValues = self.futureWeatherDictionary.sorted(by: { (d1, d2) -> Bool in
                        return d1.0 < d2.0 ? true : false
                    })
                    print(sortedKeysAndValues)
                    DispatchQueue.main.async {
                        self.updateFutureUI()
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
    
    func updateUI(name: String, temp: String, tempAll: String, weather: String) {
        let title = self.view.viewWithTag(101) as! UILabel
        let tempLabel = self.view.viewWithTag(102) as! UILabel
        let weatherLable = self.view.viewWithTag(103) as! UILabel
        let weatherImage = self.view.viewWithTag(104) as! UIImageView
        let tempTitleLable = self.view.viewWithTag(105) as! UILabel
        let tempAllTitleLable = self.view.viewWithTag(106) as! UILabel
        let tempAllLabel = self.view.viewWithTag(107) as! UILabel

        title.text = name
        tempLabel.text = temp
        tempTitleLable.text = temp
        weatherLable.text = weather
        let weaPy = weather.transformToPinYin()
        weatherImage.image = UIImage(named: weaPy)
        tempAllLabel.text = tempAll
        tempAllTitleLable.text = tempAll
    }
    
    func updateFutureUI() {
        (self.view.viewWithTag(200) as! UITableView).reloadData()
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

extension String {
    func transformToPinYin()->String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = range(of:sub) {
            if !range.isEmpty {
                pos = characters.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}

extension WeatherViewController{
    
    func setUI() {
        weatherInfoScrollView.contentSize = CGSize(width: weatherSize.screen_w, height: 1500)
        
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 70, width: weatherSize.screen_w, height: 100))
        tempLabel.tag = 102
        tempLabel.text = "--℃"
        tempLabel.textAlignment = .center
        tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 80)
        tempLabel.textColor = UIColor.white
        weatherInfoScrollView.addSubview(tempLabel)
        let tempAllLabel = UILabel()
        tempAllLabel.tag = 107
        tempAllLabel.frame.size = CGSize(width: weatherSize.screen_w, height: 30)
        tempAllLabel.text = "--℃/--℃"
        tempAllLabel.textAlignment = .center
        tempAllLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        tempAllLabel.textColor = UIColor.white
        weatherInfoScrollView.addSubview(tempAllLabel)
        tempAllLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(tempLabel).offset(30)
            make.centerX.equalTo(weatherInfoScrollView)
        }
        let weatherLabel = UILabel()
        weatherLabel.tag = 103
        weatherLabel.frame.size = CGSize(width: weatherSize.screen_w, height: 30)
        weatherLabel.text = "--"
        weatherLabel.textAlignment = .center
        weatherLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        weatherLabel.textColor = UIColor.white
        weatherInfoScrollView.addSubview(weatherLabel)
        weatherLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(tempAllLabel).offset(30)
            make.centerX.equalTo(weatherInfoScrollView)
        }
        let futureTableView = UITableView()
        futureTableView.tag = 200
        futureTableView.backgroundColor = self.view.backgroundColor
        futureTableView.delegate = self
        futureTableView.dataSource = self
        futureTableView.rowHeight = 40
        futureTableView.frame = CGRect(x: 0, y: 280, width: weatherSize.screen_w, height: 280)
        futureTableView.isScrollEnabled = false
        futureTableView.tableFooterView = UIView()
        futureTableView.separatorStyle = .none
        futureTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        weatherInfoScrollView.addSubview(futureTableView)
   
        let titleView = UIView()
        titleView.tag = 100
        titleView.backgroundColor = UIColor(named: "w_blue")
        titleView.frame = CGRect(x: 0, y: 0, width: weatherSize.screen_w, height: 100)
        titleView.alpha = 0
        let title = UILabel()
        title.text = "--"
        title.tag = 101
        title.frame.size = CGSize(width: weatherSize.screen_w, height: 80)
        title.textAlignment = .center
        title.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        title.textColor = UIColor.white
        title.center.x = titleView.center.x
        title.center.y = titleView.center.y + 15
        let weatherImage = UIImageView()
        weatherImage.tag = 104
        self.view.addSubview(titleView)
        self.view.addSubview(title)
        self.view.addSubview(weatherImage)
        weatherImage.snp.makeConstraints { (make) in
            make.size.equalTo(50)
            make.right.equalTo(self.view).offset(-10)
            make.centerY.equalTo(title)
        }
        let tempTitleLable = UILabel()
        tempTitleLable.tag = 105
        tempTitleLable.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        tempTitleLable.textColor = UIColor.white
        tempTitleLable.textAlignment = .right
        titleView.addSubview(tempTitleLable)
        tempTitleLable.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(25)
            make.top.equalTo(weatherImage)
            make.right.equalTo(weatherImage).offset(-70)
        }
        let tempAllTitleLable = UILabel()
        tempAllTitleLable.tag = 106
        tempAllTitleLable.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        tempAllTitleLable.textColor = UIColor.white
        tempAllTitleLable.textAlignment = .right
        titleView.addSubview(tempAllTitleLable)
        tempAllTitleLable.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(20)
            make.bottom.equalTo(weatherImage)
            make.right.equalTo(weatherImage).offset(-70)
        }
    }
}
