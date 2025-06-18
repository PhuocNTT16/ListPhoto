//
//  Entity.swift
//  ListPhoto
//
//  Created by Phuoc's MAc on 17/6/25.
//

struct Photo: Decodable{
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let download_url: String
}
