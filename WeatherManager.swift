

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=3f8942cb8617d6209ed5c6fa97f09812&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        var urlString = "\(weatherUrl)&q=\(cityName)"
        //if urlString.contains(" ")
        urlString = urlString.replacingOccurrences(of: " ", with: "+")
        print(urlString)
        performRequest(urlString: urlString)
    }
    
    func fetchWeatherByCoordinates(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees) {
        let stringLat = String(lat)
        let stringLon = String(lon)
        let urlString = "\(weatherUrl)&lat=\(stringLat)&lon=\(stringLon)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let cityName = decodedData.name
            let temp = decodedData.main.temp
            print(id)
            let weather = WeatherModel(cityName: cityName, conditionId: id, temp: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
    
}
