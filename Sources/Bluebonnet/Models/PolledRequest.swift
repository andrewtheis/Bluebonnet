//
//  Copyright © 2024 mlee, Inc. All rights reserved.
//

import Foundation


@MainActor
public class PolledRequest<SR: ServiceRequest> {
    
    // MARK: Private
    
    private let interval: UInt64
    private let maxAttempts: Int
    private let request: SR
    private var pollingTask: Task<SR.ServiceResponseContent, Error>?
    
    // MARK: Lifecycle
    
    public init(with request: SR, interval: UInt64, maxAttempts: Int) {
        self.request = request
        self.interval = interval
        self.maxAttempts = maxAttempts
    }
    
    // MARK: Actions
    
    public func startAwaitingResponse() async throws -> SR.ServiceResponseContent {
        cancelPolling()
        pollingTask = Task {
            var attempts: Int = 0
            
            while true {
                do {
                    let response = try await request.start()
                    return response
                } catch BluebonnetError.unexpectedStatusCode(let code) where code == .preconditionRequired {
                    attempts += 1
                    if attempts >= maxAttempts {
                        throw BluebonnetError.polledRequestMaxAttemptsExceeded
                    }
                } catch {
                    throw error
                }
                try await Task.sleep(nanoseconds: interval * 1_000_000_000)
            }
        }
        guard let pollingTask else {
            throw BluebonnetError.polledRequestFailed
        }
        return try await pollingTask.value
    }
    
    public func cancelPolling() {
        pollingTask?.cancel()
    }
}
