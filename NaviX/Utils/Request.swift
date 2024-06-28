//
//  Request.swift
//  NaviX
//
//  Created by Helloyunho on 6/2/24.
//

import Foundation
@preconcurrency import SwiftFetch

class Request {
    protocol Response: Sendable {
        var status: Int { get }
        var statusText: String { get }
        var headers: [String: String] { get }
        var ok: Bool { get }

        func data() async throws -> Data
        func text() async throws -> String?
        func json() async throws -> Any
        func json<T>(_ type: T.Type) async throws -> T where T: Decodable
    }
    
    struct FileResponse: Response {
        let status: Int
        let statusText: String = ""
        let url: URL
        var headers: [String: String] = [
            "Content-Type": "text/plain"
        ]
        var ok: Bool { status >= 200 && status <= 299 }
        
        func data() async throws -> Data {
            try Data(contentsOf: url)
        }
        
        func text() async throws -> String? {
            try String(contentsOf: url)
        }
        
        func json() async throws -> Any {
            try JSONSerialization.jsonObject(with: await data())
        }
        
        func json<T>(_ type: T.Type) async throws -> T where T: Decodable {
            let decoder = JSONDecoder()
            
            return try decoder.decode(type, from: await data())
        }
    }
    
    struct FetchResponse: Response {
        var status: Int { resp.status }
        var statusText: String { resp.statusText }
        let resp: SwiftFetch.FetchResponse
        var headers: [String: String] { resp.headers.all() }
        var ok: Bool { resp.ok }
        
        func data() async throws -> Data {
            try await resp.data()
        }
        
        func text() async throws -> String? {
            try await resp.text()
        }
        
        func json() async throws -> Any {
            try await resp.json()
        }
        
        func json<T>(_ type: T.Type) async throws -> T where T: Decodable {
            try await resp.json(type)
        }
    }
}

extension Request {
    static func getDNSResolvedURL(_ url: URL) async throws -> URL {
        let separated = url.host?.split(separator: ".")
        guard let separated, separated.count >= 2 else {
            throw AddressError.domainNotFound
        }

        var dnsURL = URL(string: "https://api.buss.lol/domain/")!
        for separate in separated {
            dnsURL.appendPathComponent(String(separate))
        }
        let resp = try await fetch(dnsURL)
        if resp.status == 404 {
            throw AddressError.domainNotFound
        }
        let ip = try await resp.json(DNSResponsePayload.self).ip
        return URL(string: url.absoluteString.replacingOccurrences(of: "\(url.scheme!)://\(url.host!)", with: ip))!
    }
    
    static func fetch(_ url: URL) async throws -> Response {
        let scheme = url.scheme ?? "buss"
        switch scheme {
        case "file":
            let path = url.path
            var status = 200
            if !FileManager.default.fileExists(atPath: path) {
                status = 404
            } else if !FileManager.default.isReadableFile(atPath: path) {
                status = 403
            }
            return FileResponse(status: status, url: url)
        case "bus", "buss":
            let fetchedURL = try await getDNSResolvedURL(url)
            return try await Request.fetch(fetchedURL)
        case "http", "https":
            var url = url
            if url.host == "github.com" {
                let branch = url.pathComponents.contains("tree") ? url.pathComponents[4] : "main"
                let paths = url.pathComponents.contains("tree") ? url.pathComponents[5...] : url.pathComponents[3...]
                url = URL(string: "https://raw.githubusercontent.com/\(url.pathComponents[1])/\(url.pathComponents[2])/\(branch)/\(paths.joined(separator: "/"))")!
            }
            let resp = try await SwiftFetch.fetch(url)
            return FetchResponse(resp: resp)
        default:
            throw AddressError.unsupportedScheme
        }
    }
}
