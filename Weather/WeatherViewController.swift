//
//  WeatherViewController.swift
//  Weather
//
//  Created by 高鑫 on 2017/10/23.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import SnapKit
import Hero

class WeatherViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var cityInfo: String = "446"
    var futureDateArray : [String] = []
    var futureWeatherArray : [String] = []
    var futureWeatherDictionary: Dictionary<String, [String]> = [:]
    let todayDate = Date()
    let formatter = DateFormatter()
    var isNight : Bool?
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var weatherInfoScrollView: UIScrollView!
    @IBAction func menuBtn(_ sender: UIButton) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let cityView = view.instantiateViewController(withIdentifier: "cityView")
        cityView.heroModalAnimationType = .push(direction: .up)
        self.present(cityView, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isHeroEnabled = true
        timeDayNight()
        self.view.backgroundColor = isNight! ? UIColor(named: "w_nightblue") : UIColor(named: "w_lightblue")
        bottomView.backgroundColor = self.view.backgroundColor
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
        getLifeData()
        getPMData()

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
    
    func timeDayNight() {

        let todayStr = "\(todayDate)"
        let index = todayStr.index(todayStr.startIndex, offsetBy: 10)
        let todayStrResult = todayStr[...index]
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let earlierDate = formatter.date(from: todayStrResult+" 19:00")! as NSDate
        print(earlierDate)
        let calculatedDate = Calendar.current.date(byAdding: .day, value: 1, to: todayDate)
        let tomorrowStr = String(describing: calculatedDate!)
        let tomorrowIndex = tomorrowStr.index(tomorrowStr.startIndex, offsetBy: 10)
        let tomorrowStrResult = tomorrowStr[...tomorrowIndex]
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let laterDate = formatter.date(from: tomorrowStrResult+" 06:00")! as NSDate
        print(laterDate)
        let early = earlierDate.laterDate(todayDate)
        let late = laterDate.earlierDate(todayDate)
        
        print("\(todayDate)")
        print(early)
        print(late)
        
        if early == late {
            isNight = true
        } else {
            isNight = false
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = self.view.backgroundColor
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
            let daoStr = "-"
            let daoRange = weaPy.range(of: daoStr)
            if daoRange == nil {
                weaImg.image = UIImage(named: weaPy)
            } else {
                let daoPosition = weaPy.positionOf(sub: zhuanStr)
                let daoIndex = weaPy.index(weaPy.startIndex, offsetBy: daoPosition)
                let daoPositionResult = weaPy[daoIndex...]
                weaImg.image = UIImage(named: "\(daoPositionResult)")
            }
        } else {
            let position = weaPy.positionOf(sub: zhuanStr)
            let index = weaPy.index(weaPy.startIndex, offsetBy: position+5)
            let positionResult = weaPy[index...]
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
        
        let path = "http://api.k780.com:88/?app=weather.today&weaid=\(cityInfo)&&appkey=29082&sign=7034102070325f406c7de00fb38a90c1&format=json"
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
                    let humidity = json["result"]["humidity"].string!
                    let wind = json["result"]["wind"].string!
                    let winp = json["result"]["winp"].string!
                    DispatchQueue.main.async {
                        self.updateUI(name: name, temp: temp, tempAll: tempAll, weather: weather, humidity: humidity, wind: wind, winp: winp)
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
        let path = "http://api.k780.com:88/?app=weather.future&weaid=\(cityInfo)&&appkey=29082&sign=7034102070325f406c7de00fb38a90c1&format=json"
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
    
    func getLifeData() {
        
        let path = "http://api.k780.com/?app=weather.lifeindex&weaid=\(cityInfo)&&appkey=29082&sign=7034102070325f406c7de00fb38a90c1&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    self.formatter.dateFormat = "yyyy-MM-dd"
                    let todayDateStr = self.formatter.string(from: self.todayDate)
                    let json = try JSON(data: data!)
                    let uv = json["result"][todayDateStr]["lifeindex_uv_attr"].string!
                    let ct = json["result"][todayDateStr]["lifeindex_ct_attr"].string!
                    DispatchQueue.main.async {
                        self.updateLifeUI(uv: uv, ct: ct)
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
    
    func getPMData() {
        
        let path = "http://api.k780.com:88/?app=weather.pm25&weaid=\(cityInfo)&appkey=29082&sign=7034102070325f406c7de00fb38a90c1&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSON(data: data!)
                    let aqi = json["result"]["aqi"].string!
                    let aqi_scope = json["result"]["aqi_scope"].string!
                    let aqi_levid = json["result"]["aqi_levid"].string!
                    let aqi_levnm = json["result"]["aqi_levnm"].string!
                    DispatchQueue.main.async {
                        self.updatePMUI(aqi: aqi, aqi_scope: aqi_scope, aqi_levid: aqi_levid, aqi_levnm: aqi_levnm)
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
    
    func updateUI(name: String, temp: String, tempAll: String, weather: String, humidity: String, wind: String, winp: String) {
        let title = self.view.viewWithTag(101) as! UILabel
        let tempLabel = self.view.viewWithTag(102) as! UILabel
        let weatherLable = self.view.viewWithTag(103) as! UILabel
        let weatherImage = self.view.viewWithTag(104) as! UIImageView
        let tempTitleLable = self.view.viewWithTag(105) as! UILabel
        let tempAllTitleLable = self.view.viewWithTag(106) as! UILabel
        let tempAllLabel = self.view.viewWithTag(107) as! UILabel
        let humidityLabel = self.view.viewWithTag(201) as! UILabel
        let windLabel = self.view.viewWithTag(202) as! UILabel

        title.text = name
        tempLabel.text = temp
        tempTitleLable.text = temp
        weatherLable.text = weather
        let weaPy = weather.transformToPinYin()
        let weaPynight = weaPy + "wan"
        if weaPy == "qing" || weaPy == "duoyun" || weaPy == "zhenyu" || weaPy == "wu" {
            weatherImage.image = isNight! ? UIImage(named: weaPynight) : UIImage(named: weaPy)
        } else {
            weatherImage.image = UIImage(named: weaPy)
        }
        tempAllLabel.text = tempAll
        tempAllTitleLable.text = tempAll
        humidityLabel.text = "湿度: " + humidity
        windLabel.text = "风向: " + wind + ", 风力: " + winp
    }
    
    func updateFutureUI() {
        (self.view.viewWithTag(200) as! UITableView).reloadData()
    }
    
    func updateLifeUI(uv: String, ct: String) {
        let uvLabel = self.view.viewWithTag(203) as! UILabel
        let ctLabel = self.view.viewWithTag(204) as! UILabel
        
        uvLabel.text = "紫外线指数: " + uv
        ctLabel.text = "穿衣指数: " + ct
    }
    
    func updatePMUI(aqi: String, aqi_scope: String, aqi_levid: String, aqi_levnm: String) {
        let aqiLabel = self.view.viewWithTag(206) as! UILabel
        let levnmLabel = self.view.viewWithTag(207) as! UILabel
        
        aqiLabel.text = "PM2.5指数: " + aqi + " (\(aqi_scope))"
        levnmLabel.text = "空气质量: \(aqi_levid)级 \(aqi_levnm)"
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

//extension WeatherViewController: UIViewControllerTransitioningDelegate {
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return Present()
//    }
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return Dismiss()
//    }
//}

extension WeatherViewController{
    
    func setUI() {
        weatherInfoScrollView.contentSize = CGSize(width: weatherSize.screen_w, height: 850)
        
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
        
        let lineView = UIView(frame: CGRect(x: 0, y: 570, width: weatherSize.screen_w, height: 0.5))
        lineView.backgroundColor = isNight! ? UIColor(named: "w_darkblue") : UIColor(named: "w_blue")
        weatherInfoScrollView.addSubview(lineView)
        let otherInfoView = UIView()
        otherInfoView.backgroundColor = self.view.backgroundColor
        otherInfoView.frame = CGRect(x: 0, y: 580, width: weatherSize.screen_w, height: 240)
        weatherInfoScrollView.addSubview(otherInfoView)
        
        let otherLabel_1 = UILabel()
        otherLabel_1.tag = 201
        let otherLabel_2 = UILabel()
        otherLabel_2.tag = 202
        let otherLabel_3 = UILabel()
        otherLabel_3.tag = 203
        let otherLabel_4 = UILabel()
        otherLabel_4.tag = 204
        let otherLabel_6 = UILabel()
        otherLabel_6.tag = 206
        let otherLabel_7 = UILabel()
        otherLabel_7.tag = 207
        var labelY: CGFloat = 0
        let otherLables : [UILabel] = [otherLabel_1, otherLabel_2, otherLabel_3, otherLabel_4, otherLabel_6, otherLabel_7]
        for i in otherLables {
            i.frame = CGRect(x: 10, y: labelY, width: weatherSize.screen_w - 10, height: 40)
            i.text = ""
            i.font = UIFont(name: "HelveticaNeue-Light", size: 17)
            i.textAlignment = .left
            i.textColor = UIColor.white
            otherInfoView.addSubview(i)
            
            labelY += 40
        }
        
//——————————————————————————————————————————
        let titleView = UIView()
        titleView.tag = 100
        titleView.backgroundColor = isNight! ? UIColor(named: "w_darkblue") : UIColor(named: "w_blue")
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
