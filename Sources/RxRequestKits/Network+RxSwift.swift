//
//  File.swift
//
//
//  Created by Nghia Nguyen on 31/03/2021.
//

import Alamofire
import Foundation
import RxSwift
import RequestKits

// MARK: Support RxSwift

public extension Network {
    func rxRequest<T>(requestable: T) -> Observable<T.Response> where T: Requestable, T.Response: Decodable {
        return Observable<T.Response>.create { (observer) -> Disposable in
            let cancelable = self.request(requestable: requestable) { (result: Result<T.Response, Error>) in
                switch result {
                case let .success(object):
                    observer.onNext(object)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                cancelable.cancel()
            }
        }
    }

    func rxDownload<T>(requestable: T, progress: Request.ProgressHandler? = nil) -> Observable<URL> where T: Requestable {
        return Observable<URL>.create { (observer) -> Disposable in
            let cancelable = self.download(requestable: requestable, progress: progress) { url, error in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(url!)
                    observer.onCompleted()
                }
            }
            return Disposables.create {
                cancelable.cancel()
            }
        }
    }

    func rxUpload<T>(requestable: T, progress: Request.ProgressHandler? = nil) -> Observable<T.Response> where T: Requestable, T.Response: Decodable {
        return Observable<T.Response>.create { (observer) -> Disposable in
            let cancelable = self.upload(requestable: requestable, progress: progress) { (result: Result<T.Response, Error>) in
                switch result {
                case let .success(object):
                    observer.onNext(object)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                cancelable.cancel()
            }
        }
    }
}
