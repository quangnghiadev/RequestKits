<p align="center">
  <img src="https://raw.githubusercontent.com/quangnghiadev/RequestKits/master/Assets/logo.png" title="RequestKits">
</p>

[![Build Status](https://github.com/quangnghiadev/RequestKits/workflows/CI/badge.svg?branch=main)](https://github.com/quangnghiadev/RequestKits/actions)
[![SPM compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager/)
[![Swift](https://img.shields.io/badge/Swift-5.3-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-11.6-blue.svg)](https://developer.apple.com/xcode)
[![MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)

**RequestKits** is a framework for network request (API Request, Upload/Download Task)

## Requirements

- **iOS** 11.0+
- Swift 5.0+

## Dependency

- RxSwift
- Alamofire

## Installation

### Swift Package Manager
You can use The Swift Package Manager to install RequestKits by adding https://github.com/quangnghiadev/RequestKits.git to Swift Package of your XCode project

## Usage

Define your Network instance

```swift
private let network = Network(config: NetworkConfig())
```

Make a request with:
- Pure

```swift
var request = URLRequest(url: URL(string: "https://httpbin.org/get")!)
request.method = .get
network.request(request, validationType: .successCodes) { data, error in
    print(data as Any)
    print(error as Any)
}
```

- Requestable

```swift

struct GetAllPostsRequest: Requestable {
    var baseURL: URL {
        return URL(string: "https://httpbin.org/")!
    }

    var path: String {
        return "get"
    }

    var method: HTTPMethod {
        return .get
    }

    var task: Task {
        .requestPlain
    }
}

network.request(requestable: GetAllPostsRequest()) { data, error in
    print(data as Any)
    print(error as Any)
}
```

- RxSwift and Requestable

```swift
let request: Observable<EmptyEntity> = network.rxRequest(requestable: GetAllPostsRequest())
request.subscribe(onNext: { response in
    print(response)
}).disposed(by: disposeBag)
```

## Pluggin

- RequestAdapter
-- [Authentication](https://github.com/quangnghiadev/RequestKits/blob/main/Sources/RequestKits/Plugins/AuthenticationAdapter.swift)
-- [ParamKeyAdapter](https://github.com/quangnghiadev/RequestKits/blob/main/Sources/RequestKits/Plugins/ParamKeyAdapter.swift)

- EventMonitor
--[NetworkLogger](https://github.com/quangnghiadev/RequestKits/blob/main/Sources/RequestKits/Plugins/NetworkLogger.swift)


## License

- RequestKits is using [Alamofire](https://github.com/Alamofire/Alamofire). See  [LICENSE](https://github.com/Alamofire/Alamofire/blob/master/LICENSE) for more information.
- RequestKits is using [RxSwift](https://github.com/ReactiveX/RxSwift). See  [LICENSE](https://github.com/ReactiveX/RxSwift/blob/master/LICENSE.md) for more information.
- RequestKits is using source code from [Moya](https://github.com/Moya/Moya). See  [LICENSE](https://github.com/Moya/Moya/blob/master/License.md) for more information.
- RequestKits is released under the MIT license. See [LICENSE](https://github.com/quangnghiadev/RequestKits/blob/master/LICENSE) for more information.
