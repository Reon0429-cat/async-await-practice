//
//  ViewController.swift
//  async-await-practice
//
//  Created by 大西玲音 on 2021/11/16.
//

import UIKit

struct User: Decodable {
    let name: String
}

enum SomeError: Error {
    case invalidURL(url: URL)
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    func fetchUser2(for id: Int) async throws -> User {
        do {
            let data = try await downloadData2(from: URL(string: ""))
            let user = try! JSONDecoder().decode(User.self, from: data)
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

