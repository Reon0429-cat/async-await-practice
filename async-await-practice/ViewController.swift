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
        
        // 同期的なメソッドの中でasyncなfuncを呼び出す
        Task {
            do {
                let user = try await fetchUser2(for: 100)
                let label = UILabel()
                label.text = user.name
            } catch {
                print(error)
            }
        }
        
    }
    
    func asyncFetchUserIcons(for ids: [Int]) async throws -> [Int: Data] {
        try await withThrowingTaskGroup(of: (Int, Data).self) { group in
            for id in ids {
                group.addTask {
                    let url = URL(string: "https://koherent.org/fake-service/data/user-icons/small/\(id).png")!
                    return try await (id, self.downloadData2(from: url))
                }
            }
            var icons = [Int: Data]()
            for try await (id, icon) in group {
                icons[id] = icon
            }
            return icons
        }
    }
    
    func fetchUserIcons(for ids: [Int],
                        completion: @escaping (Result<[Data], Error>) -> Void) {
        var results = [Data]()
        let group: DispatchGroup = .init()
        for id in ids {
            let url = URL(string: "https://koherent.org/fake-service/data/user-icons/small/\(id).png")!
            group.enter()
            downloadData(from: url) { icon in
                results.append(icon)
                group.leave()
            }
        }
        
        group.notify(queue: .global()) {
            do {
                let icons = try results.map { try $0.get() }
                completion(.success(icons))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // 並行処理 (async)
    func awaitFetchUserIcons(for id: Int) async throws -> (small: Data, large: Data) {
        let smallURL = URL(string: "https://koherent.org/fake-service/data/user-icons/small/\(id).png")!
        let largeURL = URL(string: "https://koherent.org/fake-service/data/user-icons/large/\(id).png")!
        // ダメな例
//        let smallIcon = try await downloadData2(from: smallURL)
//        let largeIcon = try await downloadData2(from: largeURL)
        async let smallIcon = downloadData2(from: smallURL)
        async let largeIcon = downloadData2(from: largeURL)
//        return (small: smallIcon, large: largeIcon)
        let icons = try await (small: smallIcon, large: largeIcon)
        return icons
    }
    
    // 並行処理 (call back)
    func fetchUserIcons(for id: Int,
                        completion: @escaping (Result<(small: Data, large: Data), Error>) -> Void) {
        let smallURL = URL(string: "https://koherent.org/fake-service/data/user-icons/small/\(id).png")!
        let largeURL = URL(string: "https://koherent.org/fake-service/data/user-icons/large/\(id).png")!
        let group: DispatchGroup = .init()
        var smallIcon: Data!
        group.enter()
        downloadData(from: smallURL) { icon in
            smallIcon = icon
            group.leave()
        }
        var largeIcon: Data!
        group.enter()
        downloadData(from: largeURL) { icon in
            largeIcon = icon
            group.leave()
        }
        group.notify(queue: .global()) {
            do {
                let icons = try (small: smallIcon.get(), large: largeIcon.get())
                completion(.success(icons))
            } catch {
                completion(.failure(error))
            }
        }
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

