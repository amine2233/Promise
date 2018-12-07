//
//  Future.swift
//  Promise
//
//  Created by Amine Bensalah on 06/12/2018.
//

import Foundation
import Result

public struct Future<T,E: Error> {
    
    public typealias Completion = (Result<T,E>) -> Void
    public typealias AsyncOperation = (@escaping Completion) -> Void
    public typealias FailureCompletion = (E) -> Void
    public typealias SuccessCompletion = (T) -> Void
    
    private let operation: AsyncOperation
    
    public init(result: Result<T,E>) {
        self.init { completion in
            completion(result)
        }
    }
    
    public init(value: T) {
        self.init(result: .success(value))
    }
    
    public init(error: E) {
        self.init(result: .failure(error))
    }
    
    public init(operation: @escaping (_ completion:@escaping Completion) -> Void) {
        self.operation = operation
    }
    
    public func execute(completion: @escaping Completion) {
        self.operation() { value in
            completion(value)
        }
    }
    
    public func execute(onSuccess: @escaping SuccessCompletion, onFailure: FailureCompletion? = nil) {
        self.operation() { result in
            switch result {
            case .success(let value):
                onSuccess(value)
            case .failure(let error):
                onFailure?(error)
            }
        }
    }
}

extension Future {
    
    public func andThen<U>(_ transform: @escaping (_ value: T) -> Future<U,E>) -> Future<U,E> {
        return Future<U,E>(operation: { completion in
            self.execute(onSuccess: { value in
                transform(value).execute(completion: completion)
            }, onFailure: { error in
                completion(.failure(error))
            })
        })
    }
    
    public func map<U>(_ transform: @escaping (_ value: T) -> U) -> Future<U,E> {
        return Future<U,E>(operation: { completion in
            self.execute(onSuccess: { value in
                completion(.success(transform(value)))
            }, onFailure: { error in
                completion(.failure(error))
            })
        })
    }
}
