//
//  QueueManager.swift
//  RequestKits
//
//  Created by Nghia Nguyen on 4/16/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import Alamofire
import Foundation

public class QueueManager<RequestTask: Request, ResponseData> {
    private let operationQueue = OperationQueue()
    private var operationList: [String: WorkerOperation] = [:]

    init() {
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.qualityOfService = .utility
    }

    // MARK: Max Concurrent Count

    public var maxConcurrentRequest: Int {
        operationQueue.maxConcurrentOperationCount
    }

    public func updateMaxConcurrentOperationCount(_ newValue: Int) {
        operationQueue.maxConcurrentOperationCount = newValue
    }

    // MARK: Quality Of Service

    public var qualityOfService: QualityOfService {
        operationQueue.qualityOfService
    }

    public func updateQualityOfService(_ newValue: QualityOfService) {
        operationQueue.qualityOfService = newValue
    }

    // MARK: Suspend

    public var isSuspended: Bool {
        operationQueue.isSuspended
    }

    public func suspend() {
        operationQueue.isSuspended = true
    }

    public func resume() {
        operationQueue.isSuspended = false
    }

    // MARK: Cancel All Requests

    public func cancelAllRequest() {
        operationQueue.cancelAllOperations()
        operationList.removeAll()
    }

    // MARK: Remove Request

    public func remove(operationID: String) {
        operationList.removeValue(forKey: operationID)
    }

    // MARK: Operation Execute

    func addOperation(request: RequestTask, responseHandler: @escaping (ResponseData) -> Void) -> Cancellable {
        // 1. Create UUID for each Operation
        let operationID = UUID().uuidString
        log("New Download Operation (\(operationID))")
        // 2. Create DownloadOperator
        let operation = WorkerOperation(id: operationID, mainTask: { [weak self] finishBlock in
            self?.execute(request: request) { dataResponse in
                finishBlock()
                // 3. When Operation completed
                //      - Execute callback
                //      - Remove completed Operation
                responseHandler(dataResponse)
                self?.operationList.removeValue(forKey: operationID)
            }
        }, cancelTask: { [weak self] in
            self?.remove(operationID: operationID)
            request.cancel()
        })
        // 4. Add Operation into operationQueue
        operationQueue.addOperation(operation)
        // 5. Save Operation into operationList, using for cancel
        operationList[operationID] = operation
        return Cancellable(operation: operation)
    }

    func execute(request: RequestTask, responseHandler: @escaping (ResponseData) -> Void) {
        fatalError("Need implement in sub class!")
    }
}

public final class DownloadManager: QueueManager<DownloadRequest, AFDownloadResponse<URL?>> {
    public static let instance = DownloadManager()

    override func execute(request: DownloadRequest, responseHandler: @escaping (AFDownloadResponse<URL?>) -> Void) {
        request.response { dataResponse in
            responseHandler(dataResponse)
        }
    }
}

public final class RequestManager: QueueManager<DataRequest, AFDataResponse<Data?>> {
    public static let instance = RequestManager()

    override func execute(request: DataRequest, responseHandler: @escaping (AFDataResponse<Data?>) -> Void) {
        request.response { dataResponse in
            responseHandler(dataResponse)
        }
    }
}

public final class UploadManager: QueueManager<DataRequest, AFDataResponse<Data?>> {
    public static let instance = UploadManager()

    override func execute(request: DataRequest, responseHandler: @escaping (AFDataResponse<Data?>) -> Void) {
        request.response { dataResponse in
            responseHandler(dataResponse)
        }
    }
}
