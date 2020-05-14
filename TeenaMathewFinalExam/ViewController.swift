//
//  ViewController.swift
//  TeenaMathewFinalExam
//
//  Created by Teena on 2020-04-19.
//  Copyright © 2020 Teena. All rights reserved.
//

import UIKit
import Charts
import CoreLocation

class ViewController: UIViewController,  CLLocationManagerDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var toggle: UIButton!

    
    @IBOutlet weak var labelRecovered: UILabel!
    @IBOutlet weak var labelTotel: UILabel!
    @IBOutlet weak var labelDeath: UILabel!
    @IBOutlet weak var labelRecoveredPercentage: UILabel!
    @IBOutlet weak var labelDeathPercentage: UILabel!
    @IBOutlet weak var labelNeighbourCountry: UILabel!
    @IBOutlet weak var labelDeathDelta: UILabel!
    @IBOutlet weak var labelRecoverDelta: UILabel!
    @IBOutlet weak var labelTotalDelta: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation?
    var closestCountry = ""
    var closestDistance = 0.0
    var closestTotal = 0
    var closestRecover = 0
    var closestDeath = 0
    var currentCountryString = ""

    //covid data API response
    struct CovidInformation:Codable {
        let totalConfirmed: Int
        let totalRecovered: Int
        let totalDeaths: Int
        let totalRecoveredDelta: Int
        let totalDeathsDelta: Int
        let totalConfirmedDelta : Int
        let areas: Array<Areas>
    }
    
    struct Areas:Codable {
        let displayName: String
        let id: String
        let lat: Double
        let long: Double
        let totalConfirmed: Int
        let areas: Array<CountryArea>
        let totalRecovered: Int?
        let totalDeaths: Int?
    }
    
    struct CountryArea:Codable {
        let lat: Double
        let long: Double
        let displayName: String
    }
    
    // country data API response
    struct CountryInformation:Codable {
        let country: String
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // find current country
        fetchCountry(urlString: "https://get.geojs.io/v1/ip/geo.json")
        
        //set to waterloo
        currentLocation = CLLocation(latitude: 43.466667, longitude: -80.516670)
        //location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    //refresh api data
    @IBAction func refresh(_ sender: Any) {
        fetchCountry(urlString: "https://get.geojs.io/v1/ip/geo.json")
        let urlString = "https://www.bing.com/covid/data"
        fetchData(urlString: urlString)
    }
    
    //toggle graphs
    @IBAction func changeView(_ sender: Any) {
        if(lineChartView.isHidden == true) {
            lineChartView.isHidden = false
            pieChartView.isHidden = true
        } else {
            lineChartView.isHidden = true
            pieChartView.isHidden = false
        }
    }
    
    func setPieChartData(_ d1_y1: Int,_ d1_y2: Int,_ d1_y3: Int )  {
        let dataEntries: [ChartDataEntry] = [
            PieChartDataEntry(value:  Double(d1_y1), label: "Total cases"),
               PieChartDataEntry(value:  Double(d1_y2), label: "Recovered cases"),
               PieChartDataEntry(value:  Double(d1_y3), label: "Death cases"),
               ]

        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "Covid19 Data")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.noDataText = "API NOT AVAILABLE! PLEASE TRY AGAIN LATER.. OR HIT ON THE REFRESH BUTTON."
        pieChartView.data = pieChartData
        pieChartView.entryLabelColor = .black
        pieChartView.backgroundColor = .white
        pieChartView.isUserInteractionEnabled = true
        pieChartDataSet.colors = [UIColor.yellow, UIColor.green, UIColor.gray]
        pieChartView.notifyDataSetChanged()
        let legend = pieChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.textColor = .black
        pieChartView.data?.setValueFont(UIFont(name: "Futura", size: 15)!)
        pieChartView.data?.setValueTextColor(UIColor.black)
        pieChartDataSet.colors =  [.yellow, .green, .gray]
        self.pieChartView.animate(yAxisDuration: 2.5)
    }
    
    func setLineGraphData(_ d1_y1: Int,_ d1_y2: Int,_ d1_y3: Int ) {
        let yValues: [ChartDataEntry] = [
            ChartDataEntry(x: 1, y: Double(d1_y1), data: "Total cases"),
            ChartDataEntry(x: 2, y: Double(d1_y2), data: "Recovered cases"),
            ChartDataEntry(x: 3, y: Double(d1_y3), data: "Death cases")
        ]
        
        let lineData = LineChartDataSet(entries: yValues, label: "country")
        lineData.drawCirclesEnabled = false
        lineData.mode = .cubicBezier
        lineData.lineWidth = 3
        lineData.setColor(.white)
        lineData.fill = Fill(color: .white)
        lineData.fillAlpha = 0.8
        lineData.drawFilledEnabled = true
        lineData.drawVerticalHighlightIndicatorEnabled = false
        lineData.highlightColor = .systemRed
        
        let data = LineChartData(dataSet: lineData)
        lineChartView.noDataText = "API NOT AVAILABLE! PLEASE TRY AGAIN LATER.. OR HIT ON THE REFRESH BUTTON."

        data.setDrawValues(false)
        self.lineChartView.backgroundColor = .black
        self.lineChartView.rightAxis.enabled = false
        self.lineChartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        //self.lineChartView.leftAxis.setLabelCount(6, force: false)
        self.lineChartView.leftAxis.labelTextColor = .white
        self.lineChartView.leftAxis.axisLineColor = .white
        self.lineChartView.leftAxis.labelPosition = .outsideChart
        self.lineChartView.xAxis.labelPosition = .bottom
        self.lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        self.lineChartView.xAxis.setLabelCount(3, force: false)
        self.lineChartView.xAxis.labelTextColor = .white
        self.lineChartView.xAxis.axisLineColor = .systemBlue
        self.lineChartView.animate(yAxisDuration: 2.5)
        self.lineChartView.data = data
    }
    
    
    func setBarChartData(_ d1_y1: Int,_ d1_y2: Int,_ d1_y3: Int ) {
        let d1_x = BarChartDataEntry(x: 1, y: Double(d1_y1), data: "Total cases")
        let d2_y = BarChartDataEntry(x: 2, y: Double(d1_y2), data: "Recovered cases")
        let d3_z = BarChartDataEntry(x: 3, y: Double(d1_y3), data: "Death cases")
        let dataSet = BarChartDataSet(entries: [d1_x,d2_y,d3_z], label: "Covid19 Data")
        dataSet.colors = [.yellow, .green, .gray]
        dataSet.valueColors = [.yellow, .green, .gray]
        dataSet.valueFont = .boldSystemFont(ofSize: 14)
        let chartData = BarChartData(dataSet: dataSet)
        self.barChartView.data = chartData
        self.barChartView.xAxis.labelPosition = .bottom
        self.barChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        self.barChartView.backgroundColor = .black

        self.barChartView.xAxis.labelTextColor = .white
        self.barChartView.xAxis.axisLineColor = .white
        

        self.barChartView.rightAxis.enabled = false
        self.barChartView.leftAxis.labelTextColor = .white
        self.barChartView.animate(yAxisDuration: 2.5)
        barChartView.noDataText = "API NOT AVAILABLE! PLEASE TRY AGAIN LATER.. OR HIT ON THE REFRESH BUTTON."

        
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           if let location = locations.last {
               currentLocation = location
                let urlString = "https://www.bing.com/covid/data"
                fetchData(urlString: urlString)
           }
       }
       
       func checkNearestCountry(lat: Double, long: Double) -> Bool {
           let location = CLLocation(latitude: lat, longitude: long)
           let distance = currentLocation!.distance(from: location)
           if(closestDistance > distance || closestDistance == 0.0) {
               closestDistance = distance
               return true
           }
           return false
       }
    
    func fetchCountry(urlString: String) {
        let urlSession = URLSession(configuration: .default)
        let url = URL(string: urlString)
        if let url = url {
            let dataTask = urlSession.dataTask(with: url) {
                (data, response, error) in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                        do {
                        let readableData = try jsonDecoder.decode(CountryInformation.self, from: data)
                            self.currentCountryString = readableData.country
                        }
                        catch {
                                print("Unable to decode")
                               }
                         }
                      }
                    dataTask.resume()
               }
    }

    //TO BE CHANGED
    func fetchData(urlString: String) {
       //var tempCountry : String = "";
       let urlSession = URLSession(configuration: .default)
       let url = URL(string: urlString)
       if let url = url {
           let dataTask = urlSession.dataTask(with: url) {
               (data, response, error) in
               if let data = data {
                   let jsonDecoder = JSONDecoder()
                       do {
                       let readableData = try jsonDecoder.decode(CovidInformation.self, from: data)
                           
                           for item in readableData.areas {
                               //print(item.displayName)
                            
                              /* if(item.areas.count > 0) {
                                   for i in item.areas {
                                       if(self.checkNearestCountry(lat: i.lat, long: i.long)) {
                                            tempCountry = item.displayName
                                            self.closestTotal = item.totalConfirmed
                                            self.closestRecover = item.totalRecovered!
                                            self.closestDeath = item.totalDeaths!
                                            print(self.closestTotal)
                                       }
                                   }
                               }
                               else {
                                   if(self.checkNearestCountry(lat: item.lat, long: item.long)) {
                                       tempCountry = item.id
                                       //print(tempCountry)
                                   }
                               }*/
                            if(item.displayName == self.currentCountryString) {
                                self.closestTotal = item.totalConfirmed
                                self.closestRecover = item.totalRecovered!
                                self.closestDeath = item.totalDeaths!
                                self.closestCountry = item.displayName
                            }
                            
                           }
                          
                           print(self.closestCountry)
                           
                           DispatchQueue.main.async {
                            self.assignUIData(readableData: readableData)
                           }
                       }
                       catch {
                           print("Unable to decode")
                       }
                   }
               }
           dataTask.resume()
       }
   }
    
    func assignUIData(readableData: CovidInformation)  {
        self.labelTotel.text = "Total cases : " + String(readableData.totalConfirmed)
        self.labelNeighbourCountry.text =  String(self.closestCountry) + " Statistics: "
        self.labelDeath.text = "Death cases : " + String(readableData.totalDeaths)
        self.labelRecovered.text = "Recovered cases : " + String(readableData.totalRecovered)
        self.labelTotalDelta.text = "+" + String(readableData.totalConfirmedDelta)
        self.labelRecoverDelta.text = "+" + String(readableData.totalRecoveredDelta)
        self.labelDeathDelta.text = "+" + String(readableData.totalDeathsDelta)
        
        var deathRate : Double = 0.0
        var recoveryRate : Double = 0.0

        deathRate = Double(readableData.totalDeaths) / Double(readableData.totalConfirmed) * 100.00
        recoveryRate = Double(readableData.totalRecovered) / Double(readableData.totalConfirmed) * 100.00
        
        self.labelRecoveredPercentage.text = "Recovered rate: \(String(format: "%.02f", recoveryRate)) %"
        self.labelDeathPercentage.text = "Death rate: \(String(format: "%.02f", deathRate)) %"
        self.setBarChartData(readableData.totalConfirmed, readableData.totalRecovered, readableData.totalDeaths);
        
        self.setLineGraphData(self.closestTotal, self.closestRecover, self.closestDeath);
        self.setPieChartData(self.closestTotal, self.closestRecover, self.closestDeath);
    }
    
}


