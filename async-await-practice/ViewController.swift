//
//  ViewController.swift
//  async-await-practice
//
//  Created by 大西玲音 on 2021/11/16.
//

import UIKit

struct User: Decodable {
    let name: String
    let iconURL: URL
}

enum SomeError: Error {
    case invalidURL(url: URL)
}

extension Data {
    
    func get() throws -> Data {
        return Data()
    }
    
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    func asyncDownloadData(from url: URL) async throws -> Data {
        // throwがない場合は->withCheckedContinuation { }
        try await withCheckedThrowingContinuation { continuation in
            callbackDownloadData(from: url) { result in
//                switch result {
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    case .success(let data):
//                        continuation.resume(returning: data)
//                }
                continuation.resume(with: result)
            }
        }
    }
    
    func callbackDownloadData(from url: URL,
                              completion: @escaping (Result<Data, Error>) -> Void) {
        
    }
    
    func fetchUserIcon(for id: Int) async throws -> Data {
        let url = URL(string: "https://koherent.org/fake-service/api/user?id=\(id)")!
        let data = try await downloadData2(from: url)
        let user = try JSONDecoder().decode(User.self, from: data)
        let icon = try await downloadData2(from: user.iconURL)
        return icon
    }
    
    func fetchUserIcon(for id: Int,
                       completion: @escaping (Result<Data, Error>) -> Void) {
        let url = URL(string: "https://koherent.org/fake-service/api/user?id=\(id)")!
        downloadData(from: url) { data in
            do {
                let data = try data.get()
                let user = try JSONDecoder().decode(User.self, from: data)
                self.downloadData(from: user.iconURL) { icon in
                    do {
                        let icon = try icon.get()
                        completion(.success(icon))
                    } catch {
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchUser2(for id: Int) async throws -> User {
        do {
            let data = try await downloadData2(from: URL(string: ""))
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            throw error
        }
    }
    
    func downloadData2(from url: URL?) async throws -> Data {
        if let url = url {
            throw SomeError.invalidURL(url: url)
        }
        return Data()
    }
    
    func fetchUser(for id: Int) async -> User {
        let url = URL(string: "https://koherent.org/fake-service/api/user?id=\(id)")!
        let data = await downloadData(from: url)
        let user = try! JSONDecoder().decode(User.self, from: data)
        return user
    }
    
    func downloadData(from url: URL) async -> Data {
        return Data()
    }
    
    func fetchUser(for id: Int,
                   completion: @escaping (User) -> Void) {
        let url = URL(string: "https://koherent.org/fake-service/api/user?id=\(id)")!
        downloadData(from: url) { data in
            let user = try! JSONDecoder().decode(User.self, from: data)
            completion(user)
        }
    }
    
    func downloadData(from url: URL,
                      completion: @escaping (Data) -> Void) {
        completion(Data())
    }
    
}

