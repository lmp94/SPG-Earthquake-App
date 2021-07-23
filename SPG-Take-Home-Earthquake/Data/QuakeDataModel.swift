//
//  EarthquakeDataModel.swift
//  SPG-Take-Home-Earthquake
//
//  Created by Larissa Perara on 7/23/21.
//

import Foundation

// Using code from a past project for a student on github that I wrote
// https://github.com/lmp94/iOS-API-Fetching-Basics/blob/larissa/end-to-end-fetch-using-codable/API%20Fetching%20Non%20Swift%20UI/API%20Fetching%20Non%20Swift%20UI/IACODataModel.swift
//

// Simply as an exercise to map out the query we inputted to the final result
typealias dataSummary = (query: String, list: [QuakeDataModel.dataCollection])

class QuakeDataModel {
    
    // MARK: - Public Variables
    
    // Singleton?
    static let shared = QuakeDataModel()
    let session = URLSession.shared
    public var dataCollection: QuakeFeatureDataCollection?
    
    // MARK: - Codable Structs for JSON Mapping
    
    /**
     We can use Codable to map a JSON data into a struct without much work if we keep to the supported types:
     String, Int, Double, URL, Date, Data, Array and Dictionary.
     As long as the variable name maps to the json key we don't have to do a custom mapping.
     
     This write up is not created as a testiment to my developer knowledge, but made for students to use, play around with, and learn. It is by no means the cleanest or most efficient, opmitized on the ability to students to find patterns to solidfy concepts.
     */
    
    /**
     Our data is a key, value pair of "data": [{"iaco": {}, "raw_text": {}}...]
     Therefore, we need to get the data as an array of subelements, those sub-elments
     can have any of the properties mentioned above.
     
     Cheat sheet:
     - If its contained by {} it is a Dictionary [String: String],
     - If it is contained by [] then you can use an Array of a new codable object, or another type listed above i.e. [String]
     - If its is simply "text": "..." then this is mapped to just a simple variable of one of the simplier types
     */
    
    
    // MARK: - Quake Data Feature Collection (i.e. holder earthquakes
            
    
    struct QuakeFeatureDataCollection: Codable {
        // Type: "FeatureCollection"
        // Metadata: {generated: Long Int, etc }
        var bbox: MinMaxCoordinateData // min & max: long, lat, depth
        var earthquakes: [QuakeFeatureData]
        
        enum CustomCodable: String, CodingKey {
            case bbox, earthquakes = "features"
        }
        
        // Init is only necessary if you want or need a custome mapping or complex mappings, i.e. features is the list of earthquakes >> lets make it more readable
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CustomCodable.self)
            bbox = try container.decode(MinMaxCoordinateData.self,
                                 forKey: .bbox)
            earthquakes = try container.decode([QuakeFeatureData].self,
                                               forKey: .earthquakes)
        }
        
        
    }
    
    struct MinMaxCoordinateData {
        
    }
}

// MARK: - Quake Data Feature Model (i.e. the model for each earthquake)
// TODO: Consider renaming and making seaprate

extension QuakeDataModel {
    
    // MARK: - Inital JSON Layer for each Quake
    
    /**
     This first layer of the data denoted by the keys:
        - Type: "Feature"
        - Properties: {mag: Decimal, etc}
        - Geometry: {type: "Point",
                     coordinates: [longitude, latitude, depth]}
        - id: String
     We do not need to save all the data at this moment in time
     */
    struct QuakeFeatureData: Codable {
        // "properties" : { mag: Decimal, etc}
        var properties: QuakeProperties
        
        // flatten gemetry: {} >> coordinates
        var coordinates: CoordinatesDataSet
        var id: String
        
        // Custom mapping needed
        enum QuakeFeatureCodingKeys: String, CodingKey {
            case properties, geometry
            
            /* "properties": { mag: Decimal, etc } */
            enum PropertiesCodingKeys: String, CodingKey {
                case mag, place, time, tz
            }

            enum GeometryCodingKeys: String, CodingKey {
                case coordinates
            }
        }

        // Init is only necessary if you want or need a custome mapping or complex mappings
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: QuakeFeatureCodingKeys.self)
            properties = try
                container.decode(String.self, forKey: .properties)
            geometry = try
                container.decode(String.self, forKey: .geometry)
           
            let geometryContainer = try decoder.container(keyedBy: QuakeFeatureCodingKeys.GeometryCodingKeys.self)
            coordinates = try
                geometryContainer.decode(CoordinatesDataSet,
                                 forKey: .coordiantes)
        }
//            let stationContaniter = try container.nestedContainer(keyedBy: StationCodingKeys.self, forKey: .station)
//            stationName = try stationContaniter.decode(String.self, forKey: .name)
    }
    
    struct QuakeProperties: Codeable {
        var mag: Decimal
        var place: String
        var time: CLong // Check if CLong == Long Int
        var tz: Integer // Timezone offset from UTC in min at even epiccenter
        
        init(from decoder: Decoder) throws {
        }

    }
    
    /* "coordinates":
     [ longitue (Decimal, neg ),
     latitude,
     depth] */
    
    struct CoordinatesDataSet: Codable {
        /// Type: "Point"
        var longtidue: Decimal
        var latitude: Decimal
        var depth: Decimal
        
        init(from decoder: Decoder) throws {
            //            let container = try
            //                decoder.container(keyedBy: QuakeFeatureCodingKeys.self)
        }
    }
    
    
    
    
    /** We can still map things that are in a sub **array** within the json as shown below.
     Note that we have to in the decoder above (if we need a customer
     
     Example: "clouds": [{"code": "CLR", "text": "Clear skies"}]
     Some other from the data set that this sort of setup would be applicable to are: coordinates
     */
    struct CloudDataSet: Codable {
        var code: String
        var description: String
        
        enum CustomMapping: String, CodingKey {
            case code, description = "text"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CustomMapping.self)
            code = try container.decode(String.self, forKey: .code)
            description = try container.decode(String.self, forKey: .description)
        }
    }
    
    // MARK: - Initializers
    
    init() {
        // Not the proper way to do this, but is fine for this example
        print("CheckWXDataManager Instantiated")
    }
    
    // MARK: - Public APIs for Data Fetching
    
    // For simplicity's sake for htis demo, the expected input is a string following this format:
    // "KMHR,KMCC,KAUN,KPVF"
    public func requestIACOData(_ icao: String, completion: @escaping ((_ data: String?) -> Void)) {
        // Check to see if the data is already loaded, if it is, pass back the previously saved entry
        // Note: This should really be done in a manager class or some class that will persist between sessions
        // and is invoked in bootstrap
        //        if dataSummary != nil {
        //            completion(dataSummaryToString())
        //        }
        //        else {
        loadJSONData(getAPIRequest(icao)) { data in
            guard let requestedData = data else {
                completion(nil)
                return
            }
            
            completion(requestedData)
            return
        }
        //   } For right now: As you debug and learn, I am turing off the "save" feature
    }
    
}

// MARK: - Private API & Data Handling Helper Functions
extension IACODataModel {
    
    private func dataSummaryToString() -> String {
        guard let list = dataSummary?.list else {
            return "No data list"
        }
        
        let iacoMap: [String] = list.map { $0.singleLine }
        let aggregatedLine = iacoMap.joined(separator: "\n\n\n")
        return aggregatedLine
        
        /* This can actually be turned into simply a single line.
         But I have variables for you to see the different parts and be able to
         debug to deermine what each step is doing and what that looks like. */
        // return list.map { $0.singleLine }.joined(separator: ",")
    }
    
    private func getFullData() -> String {
        guard let list = dataSummary?.list else {
            print("list is DNE")
            return ""
        }
        
        var returnString = String()
        for airport in list {
            returnString.append(printAirportData(airport))
        }
        
        return returnString
    }
    
    private func printAirportData(_ subset: DataSubsetContainer) -> String {
        var stringToPrint = String()
        stringToPrint.append("----\(subset.stationName)-----\n")
        stringToPrint.append("\(subset.icao): \(subset.singleLine) \n")
        stringToPrint.append(" Weather: \(subset.clouds[0].code), \(subset.clouds[0].description)\n\n")
        return stringToPrint
    }
    
    private func getAPIRequest(_ iacos: String) -> URLRequest? {
        let urlString = "https://api.checkwx.com/metar/" + iacos + "/decoded/"
        // print("URL String: \(urlString)")
        
        // Better way to write it, however, this lets us print out the end point for learning purposes
        //  guard let endpoint = URL("https://api.checkwx.com/metar/" + iacos + "/decoded/") else
        
        guard let endpoint = URL(string: urlString) else {
            print("Could not make a URL")
            return nil
        }
        
        var request = URLRequest(url: endpoint)
        request.addValue("76703a416bca4a9c88f21e67ef", forHTTPHeaderField: "X-API-Key")
        request.httpMethod = "GET"
        return request
    }
    
    
    private func loadJSONData(_ request: URLRequest?, completion: @escaping ((_ data: String?) -> Void)) {
        guard let request = request else {
            completion(nil)
            return
        }
        
        session.dataTask(with: request) { [weak self, completion, request] data, response, error in
            guard let strongSelf = self else {
                print("Lost self")
                completion(nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  error == nil,
                  let taskData = data else {
                print("Task Failed: response - \(String(describing: response)), error - \(String(describing: error))")
                completion(nil)
                return
            }
            do {
                let dataArray = try JSONDecoder().decode(DataSetContainer.self, from: taskData)
                
                // print("We have decoded a data array with count: \(dataArray.data.count)")
                
                strongSelf.dataSummary = IACODataSummary(query: request.description, list: dataArray.data)
                
                // let string = strongSelf.dataSummaryToString() - This will aggregate the IACO raw text into a string
                //print("String we are passing back to the front end: \(string)")
                
                completion(strongSelf.getFullData()) // Same thing here, these variables are not truly needed, but created for learning and exploration.
                
            } catch {
                print("Error: decoded json")
                completion(nil)
                return
            }
        }.resume()
    }
}
