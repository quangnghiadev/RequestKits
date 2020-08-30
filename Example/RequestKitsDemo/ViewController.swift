//
//  ViewController.swift
//  RequestKitsDemo
//
//  Created by Nghia Nguyen on 4/23/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import Alamofire
import RequestKits
import RxSwift
import UIKit
import DevelopKits

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private let network = Network(config: NetworkConfig())

    let exampleTitle = ["Download", "Download -> Cancel before success", "Normal Request", "Requestable", "Reactive"]

    override func viewDidLoad() {
        super.viewDidLoad()
        RequestManager.instance.updateMaxConcurrentOperationCount(2)
        RequestManager.instance.updateQualityOfService(.background)

        DownloadManager.instance.updateMaxConcurrentOperationCount(2)
        DownloadManager.instance.updateQualityOfService(.background)

        UploadManager.instance.updateMaxConcurrentOperationCount(2)
        UploadManager.instance.updateQualityOfService(.background)

        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exampleTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = exampleTitle[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            _ = network.download(URLRequest(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/2d/Snake_River_%285mb%29.jpg")!), validationType: .customCodes([100]),
                                 progress: { progress in print(progress.fractionCompleted) }) { url, _ in
                print(url as Any)
            }
        case 1:
            let cancel = network.download(URLRequest(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/2d/Snake_River_%285mb%29.jpg")!), validationType: .customCodes([100]),
                                          progress: { progress in print(progress.fractionCompleted) }) { url, _ in
                print(url as Any)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                cancel.cancel()
            }
        case 2:
            var request = URLRequest(url: URL(string: "https://httpbin.org/get")!)
            request.method = .get
            request.addValue("Helo", forHTTPHeaderField: UUID().uuidString)
            network.request(request, validationType: .successCodes) { data, error in
                print(data as Any)
                print(error as Any)
            }
            network.request(request, validationType: .successCodes) { data, error in
                print(data as Any)
                print(error as Any)
            }
            network.request(request, validationType: .successCodes) { data, error in
                print(data as Any)
                print(error as Any)
            }
        case 3:
            network.request(requestable: GetAllPostsRequest()) { data, error in
                print(data as Any)
                print(error as Any)
            }
        case 4:
            let request: Observable<HeaderResponse> = network.rxRequest(requestable: HeaderRequest())
            request.subscribe(onNext: { response in
                print(response)
            }).disposed(by: disposeBag)
        default:
            break
        }
    }
}

struct EmptyEntity: Codable {}

struct GetAllPostsRequest: Requestable {
    var baseURL: URL {
        return URL(string: "http://httpbin.org/")!
    }

    var path: String {
        return "headers"
    }

    var method: HTTPMethod {
        return .get
    }

    var task: Task {
        .requestPlain
    }
}

struct HeaderRequest: Requestable {
    var baseURL: URL {
        return URL(string: "http://httpbin.org/")!
    }

    var path: String {
        return "headers"
    }

    var method: HTTPMethod {
        return .get
    }

    var task: Task {
        .requestPlain
    }

    var keyPath: String? {
        return "headers"
    }
}

struct HeaderResponse: Decodable {
    let acceptType: AcceptType

    enum CodingKeys: String, CodingKey {
        case acceptType = "Accept"
    }
}

enum AcceptType: String, Decodable, UnknownCase {
    static let unknownCase: AcceptType = .unknown

    case json = "application/json"
    case unknown
}
