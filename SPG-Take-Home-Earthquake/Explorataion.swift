//
//  Explorataion.swift
//  SPG-Take-Home-Earthquake
//
//  Created by Larissa Perara on 7/23/21.
//

import Foundation


/**
 generated
 Data Type
 Long Integer
 Description
 Time when the feed was most recently updated. Times are reported in milliseconds since the epoch.
 count
 Data Type
 Integer
 Description
 Number of earthquakes in feed.
 */
//// https://earthquake.usgs.gov/fdsnws/event/1/[METHOD[?PARAMETERS]]

// Charts: https://github.com/danielgindi/Charts

//https://dev.socrata.com/

// https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson_detail.php
// JSON Detail

//{
//    type: "Feature",
//    properties: {
//        mag: Decimal,
//        place: String,
//        time: Long Integer,
//        updated: Long Integer,
//        tz: Integer,
//        url: String,
//        felt:Integer,
//        cdi: Decimal,
//        mmi: Decimal,
//        alert: String,
//        status: String,
//        tsunami: Integer,
//        sig:Integer,
//        net: String,
//        code: String,
//        ids: String,
//        sources: String,
//        types: String,
//        nst: Integer,
//        dmin: Decimal,
//        rms: Decimal,
//        gap: Decimal,
//        magType: String,
//        type: String,
//        products: {
//            <productType>: [
//            {
//            id: String,
//            type: String,
//            code: String,
//            source: String,
//            updateTime: Integer,
//            status: String,
//            properties: {
//            <key>: String,
//            …
//            },
//            preferredWeight: Integer,
//            contents: {
//            <path>: {
//            contentType: String,
//            lastModified: Long Integer,
//            length: Integer,
//            url: String
//            },
//            …
//            }
//            },
//            …
//            ],
//            …
//        }
//    },
//    geometry: {
//        type: "Point",
//        coordinates: [
//        longitude,
//        latitude,
//        depth
//        ]
//    },
//    id: String
//}

// JSON Summary format
// https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php
//{
//    type: "FeatureCollection",
//    metadata: {
//        generated: Long Integer,
//        url: String,
//        title: String,
//        api: String,
//        count: Integer,
//        status: Integer
//    },
//    bbox: [
//    minimum longitude,
//    minimum latitude,
//    minimum depth,
//    maximum longitude,
//    maximum latitude,
//    maximum depth
//    ],
//    features: [
//    {
//    type: "Feature",
//    properties: {
//    mag: Decimal,
//    place: String,
//    time: Long Integer,
//    updated: Long Integer,
//    tz: Integer,
//    url: String,
//    detail: String,
//    felt:Integer,
//    cdi: Decimal,
//    mmi: Decimal,
//    alert: String,
//    status: String,
//    tsunami: Integer,
//    sig:Integer,
//    net: String,
//    code: String,
//    ids: String,
//    sources: String,
//    types: String,
//    nst: Integer,
//    dmin: Decimal,
//    rms: Decimal,
//    gap: Decimal,
//    magType: String,
//    type: String
//    },
//    geometry: {
//    type: "Point",
//    coordinates: [
//    longitude,
//    latitude,
//    depth
//    ]
//    },
//    id: String
//    },
//    …
//    ]
//}
