// import Foundation

// public enum RestMethod: String {
//     case GET = "GET"
//     case POST = "POST"
//     case DELETE = "DELETE"
//     case PUT = "PUT"
//     case PATCH = "PATCH"
// }

// public enum RestError: Error {
//     case anyerror(description: String)
// }

// public final class Rest: NSObject, URLSessionDelegate {
//     private let urlSessionConfiguration: URLSessionConfiguration

//     private lazy var session: URLSession = {
//         URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
//     }()

//     public init(urlSessionConfiguration: URLSessionConfiguration) {
//         self.urlSessionConfiguration = urlSessionConfiguration
//         super.init()
//     }

//     func run(method: RestMethod, url: String, data: String?, completion: @escaping (Result<Dictionary<String, Any>, RestError>) -> Void) {
//         guard let url = URL(string: url) else { return }

//         var request = URLRequest(url: url)
//         request.httpMethod = method.rawValue

//         if let data = data {
//             request.httpBody = data.data(using: .utf8)
//         }

        
// //        if let object = json as? [String: Any] {
// //            // json is a dictionary
// //            print(object)
// //        }
        
//         let task = session.dataTask(with: request) { data, _, error in
//             if let error = error {
//                 completion(.failure(.anyerror(description: error.localizedDescription)))
//             } else {
//                 if let data = data {
//                     do {
//                         let json = try JSONSerialization.jsonObject(with: data, options: [])
//                         completion(.success(["body": json]))
//                     } catch {
//                         completion(.failure(.anyerror(description: "invalid json returned from api")))
//                     }
//                 } else {
//                     completion(.failure(.anyerror(description: "no data returned")))
//                 }
//             }
//         }

//         task.resume()
//     }
// }
