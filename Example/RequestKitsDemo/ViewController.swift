//
//  ViewController.swift
//  RequestKitsDemo
//
//  Created by Nghia Nguyen on 4/23/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import Alamofire
import RequestKits
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    private let network = Network(config: .init(retriers: [RetryPolicy()], monitors: [NetworkLogger(level: .info)]))

    let exampleTitle = ["Download", "Download -> Cancel before success", "Normal Request"]

    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkQueueManager.instance.config(.default)

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

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
        default:
            break
        }
    }
}
