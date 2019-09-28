import Foundation
import PerfectHTTP
import StORM

class PopulateController {
    func populate(request: HTTPRequest, response: HTTPResponse, beer: Beer = Beer()) {
        try? beer.findOne(orderBy: "id")
        
        guard beer.rows().count == 0 else {
            response.completed(status: .notFound)
            return
        }

        getBeers() { success in
            switch success {
            case true:
                response.completed(status: .ok)
            case false:
                response.completed(status: .internalServerError)
            }
        }
    }
    
    private func getBeers(page: Int = 0, didComplete: @escaping (Bool) -> Void) {
        let urlString = "https://sandbox-api.brewerydb.com/v2/beers?key=\(Configuration.apiKey)&withBreweries=Y&p=\(page)"
        guard let url = URL(string: urlString) else { didComplete(false); return}

        URLSession.shared.dataTask(with: url) { (data, _, _) in
            do {
                guard let data = data,
                      let responseJson = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
                      let json = responseJson["data"] as? [[String: Any]],
                      let totalPages = responseJson["numberOfPages"] as? Int else { fatalError("Exited due to bad response.") }
                        
                guard page != totalPages, json.count > 0 else {
                    self.parse(beers: json)
                    didComplete(true)
                    return
                }
        
                self.getBeers(page: page + 1, didComplete: didComplete)
                self.parse(beers: json)
            } catch {
                return
            }
            
        }.resume()

    }
        
    private func parse(beers: [[String: Any]]) {
        for item in beers {
            guard let name = item["name"] as? String,
                let abv = item["abv"] as? String,
                let breweries = item["breweries"] as? [[String: Any]],
                let brewery = breweries.first, let breweryName = brewery["name"] as? String else { continue }
            
            let beer = Beer()
            beer.name = name
            beer.abv = Float(abv) ?? 0
            beer.brewer = breweryName
            
            try? beer.store { id in
                beer.id = id as! Int
            }
        }
    }
}
