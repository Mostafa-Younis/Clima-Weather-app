//
//  ViewController.swift
//  WeatherApp
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, CanGetWeatherForSelectedCity {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a030ef28f9d033e35584bf853d7d0b21"
    
    

    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        //after setting the delegate, now we have to set the required permissions on app startup
        locationManager.requestWhenInUseAuthorization()
        // now set up the accuracy then start finding location
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //Write the didUpdateLocations method here[i.e What to do when location is updated]:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
   
    //We tend to use the last location in the array of locations since this is the most accurate one.
       let userLocation = locations.last!
   
    //Now we have to check if the userLocation is valid so we use the horizontal accuracy.
       if userLocation.horizontalAccuracy > 0 {
            //so we stop updating location to retain accuracy and also for power saving.
                   locationManager.stopUpdatingLocation()
                   locationManager.delegate = nil
            
            let longitude = "\(userLocation.coordinate.longitude)"
            let latitude = "\(userLocation.coordinate.latitude)"
            let params : [String:String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
                   getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    //Write the didFailWithError method here:
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print(error)
         cityLabel.text = "Location Unavailable"
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String:String]) {
       
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success, Got Weather Data")
        // create a constant in which we pour the recieved JSON data.
                let recievedWeatherJSON : JSON = JSON(response.result.value!)
                
                // after JSON parsing:
                self.updateWeatherData(recievedJsonData: recievedWeatherJSON)
            }
            else {
                self.cityLabel.text = "Connection Problems"
                print("Error \(response.result.error!)")
            }
            
        }
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    //Write the updateWeatherData method here:[after recieving JSON data here we make a function to use these imported values
    func updateWeatherData(recievedJsonData : JSON) {
        
        if let tempRecieved = recievedJsonData["main"]["temp"].double {
            
            weatherDataModel.temperature = Int(tempRecieved - 273.15)
            weatherDataModel.city = recievedJsonData["name"].string!
            weatherDataModel.condition = recievedJsonData["weather"][0]["id"].int!
            
            updateUIData()
    }
        else {
            cityLabel.text = "Weather Data Unavailable"
        }
    }
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(Int(weatherDataModel.temperature))˚C"
        weatherIcon.image = UIImage(named: weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition))
    }
    
    
    
    
   
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the getWeatherForCity Delegate method here:
    
    func getWeatherForCity(cityName: String) {
        
        let params : [String:String] = ["appid" : APP_ID , "q" : cityName]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
   
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "changeCityName" {
          
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
    }
    
    
    @IBAction func tempSwitchPress(_ sender: UISwitch) {
        
        if sender.isOn == true {
            let temp˚F = weatherDataModel.temperature*(9/5)+32
            temperatureLabel.text = "\(Int(temp˚F))˚F"
        }
        else {
            temperatureLabel.text = "\(Int(weatherDataModel.temperature))˚C"
        }
    }
    
}



