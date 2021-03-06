// MultiLineStringTests.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Raphaël Mor
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import XCTest
import GeoJSON

class MultiLineStringTests: XCTestCase {
	
	var geoJSON: GeoJSON!
	
	var twoLineMultiLineString: MultiLineString!
	
	override func setUp() {
		super.setUp()
		
		geoJSON = geoJSONfromString("{ \"type\": \"MultiLineString\", \"coordinates\": [ [[0.0, 0.0], [0.0, 1.0]], [[1.0, 0.0], [1.0, 1.0]] ] }")
		
		let firstPoint = Point(coordinates:[0.0, 0.0])!
		let secondPoint = Point(coordinates:[1.0, 1.0])!
		
		let firstLineString = LineString(points:[firstPoint,secondPoint])!
		let secondLineString = LineString(points:[secondPoint,firstPoint])!
		
		twoLineMultiLineString = MultiLineString(lineStrings:[firstLineString, secondLineString])
	}
	
	override func tearDown() {
		geoJSON = nil
		twoLineMultiLineString = nil
		
		super.tearDown()
	}
	
	// MARK: - Nominal cases
	// MARK: Decoding
	func testBasicMultiLineStringShouldBeRecognisedAsSuch() {
		XCTAssertEqual(geoJSON.type, GeoJSONType.MultiLineString)
	}
    
    func testMultiLineStringShouldBeAGeometry() {
        XCTAssertTrue(geoJSON.isGeometry())
    }
	
	func testEmptyMultiLineStringShouldBeParsedCorrectly() {
		geoJSON = geoJSONfromString("{ \"type\": \"MultiLineString\", \"coordinates\": [] }")
		
		if let geoMultiLineString = geoJSON.multiLineString {
			XCTAssertEqual(geoMultiLineString.lineStrings.count, 0)
		} else {
			XCTFail("MultiLineString not parsed Properly")
		}
	}
	
	func testBasicMultiLineStringShouldBeParsedCorrectly() {
		if let geoMultiLineString = geoJSON.multiLineString {
			XCTAssertEqual(geoMultiLineString.lineStrings.count, 2)
			XCTAssertEqualWithAccuracy(geoMultiLineString.lineStrings[0][0].longitude, 0.0, 0.000001)
			XCTAssertEqualWithAccuracy(geoMultiLineString.lineStrings[0][0].latitude, 0.0, 0.000001)
			XCTAssertEqualWithAccuracy(geoMultiLineString.lineStrings[0][1].longitude, 0.0, 0.000001)
			XCTAssertEqualWithAccuracy(geoMultiLineString.lineStrings[0][1].latitude, 1.0, 0.000001)
			XCTAssertEqualWithAccuracy(geoMultiLineString.lineStrings[1][0].longitude, 1.0, 0.000001)
			XCTAssertEqualWithAccuracy(geoMultiLineString.lineStrings[1][0].latitude, 0.0, 0.000001)
			XCTAssertEqualWithAccuracy(geoMultiLineString.lineStrings[1][1].longitude, 1.0, 0.000001)
			XCTAssertEqualWithAccuracy(geoMultiLineString.lineStrings[1][1].latitude, 1.0, 0.000001)
		} else {
			XCTFail("MultiLineString not parsed Properly")
		}
	}
	
	func testNonHomogeneousMultiLineStringShouldBeParsedCorrectly() {
		geoJSON = geoJSONfromString("{ \"type\": \"MultiLineString\", \"coordinates\": [ [[0.0, 0.0], [0.0, 1.0], [0.0, 2.0]], [[1.0, 0.0], [1.0, 1.0]] ] }")
		
		if let geoMultiLineString = geoJSON.multiLineString {
			XCTAssertEqual(geoMultiLineString.lineStrings.count, 2)
			XCTAssertEqual(geoMultiLineString.lineStrings[0].count, 3)
			XCTAssertEqual(geoMultiLineString.lineStrings[1].count, 2)
		} else {
			XCTFail("MultiLineString not parsed Properly")
		}
	}
	
	// MARK: Encoding
	func testBasicMultiLineStringShouldBeEncoded() {
		XCTAssertNotNil(twoLineMultiLineString,"Valid MultiPoint should be encoded properly")
		
		if let jsonString = stringFromJSON(twoLineMultiLineString.json()) {
			XCTAssertEqual(jsonString, "[[[0,0],[1,1]],[[1,1],[0,0]]]")
		} else {
			XCTFail("Valid MultiLineString should be encoded properly")
		}
	}
	
	func testEmptyMultiLineStringShouldBeEncoded() {
		let emptyMultiLineString = MultiLineString(lineStrings:[])!
		if let jsonString = stringFromJSON(emptyMultiLineString.json()) {
			XCTAssertEqual(jsonString, "[]")
		} else {
			XCTFail("Valid MultiLineString should be encoded properly")
		}
	}
	
	func testMultiLineStringShouldHaveTheRightPrefix() {
		XCTAssertEqual(twoLineMultiLineString.prefix,"coordinates")
	}
	
	func testBasicMultiLineStringInGeoJSONShouldBeEncoded() {
		let geoJSON = GeoJSON(multiLineString: twoLineMultiLineString)
		
		if let jsonString = stringFromJSON(geoJSON.json()) {
			
			checkForSubstring("\"coordinates\":[[[0,0],[1,1]],[[1,1],[0,0]]]", jsonString)
			checkForSubstring("\"type\":\"MultiLineString\"", jsonString)
		} else {
			XCTFail("Valid MultiLineString in GeoJSON  should be encoded properly")
		}
	}

	// MARK: - Error cases
	// MARK: Decoding
	func testMultiLineStringWithoutCoordinatesShouldRaiseAnError() {
		geoJSON = geoJSONfromString("{ \"type\": \"MultiLineString\"}")
		
		if let error = geoJSON.error {
			XCTAssertEqual(error.domain, GeoJSONErrorDomain)
			XCTAssertEqual(error.code, GeoJSONErrorInvalidGeoJSONObject)
		}
		else {
			XCTFail("Invalid MultiLineString should raise an invalid object error")
		}
	}
	
	func testMultiLineStringWithAnInvalidLineStringShouldRaiseAnError() {
		geoJSON = geoJSONfromString("{ \"type\": \"MultiLineString\", \"coordinates\": [ [[0.0, 0.0]] ] }")
		
		if let error = geoJSON.error {
			XCTAssertEqual(error.domain, GeoJSONErrorDomain)
			XCTAssertEqual(error.code, GeoJSONErrorInvalidGeoJSONObject)
		}
		else {
			XCTFail("Invalid MultiLineString should raise an invalid object error")
		}
	}
	
	func testIllFormedMultiLineStringShouldRaiseAnError() {
		geoJSON = geoJSONfromString("{ \"type\": \"MultiLineString\", \"coordinates\": [ [0.0, 1.0], {\"invalid\" : 2.0} ] }")
		
		if let error = geoJSON.error {
			XCTAssertEqual(error.domain, GeoJSONErrorDomain)
			XCTAssertEqual(error.code, GeoJSONErrorInvalidGeoJSONObject)
		}
		else {
			XCTFail("Invalid MultiLineString should raise an invalid object error")
		}
	}
}