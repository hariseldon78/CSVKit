//
//  CSVKitTests.m
//  bitcoinchartsDataPrepare
//
//  Created by Roberto Previdi on 18/11/13.
//  Copyright (c) 2013 roby. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CSVKit.h"
@interface CSVKitTests : XCTestCase

@end

@implementation CSVKitTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark Errors

- (void)testErrorDetails
{
    NSString *badString = [[NSString alloc] initWithBytes:"a,\0\0" length:4 encoding:NSASCIIStringEncoding];
	
    NSError *error = nil;
    [[CSVParser parser] rowsFromString:badString error:&error];
	
    XCTAssertEqualObjects([error domain], CSVErrorDomain, @"");
	
    NSDictionary *details = [error userInfo];
    XCTAssertEqual([[details objectForKey:CSVLineNumberKey] unsignedLongValue], 1UL, @"");
    XCTAssertEqual([[details objectForKey:CSVFieldNumberKey] longValue], 1L, @"");
	
}

#pragma mark Fields

- (void)testFields
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    __block BOOL sawSentinel = NO;
	
    NSError *error = nil;
    [[CSVParser parser] parseFieldsFromString:@"a,b,c\n" block:^(id value, NSUInteger index, BOOL *stop) {
        if (index == NSUIntegerMax)
        {
            sawSentinel = YES;
        }
        else if (value)
        {
            [array addObject:value];
        }
    } error:&error];
	
    XCTAssertNil(error, @"");
    XCTAssertTrue(sawSentinel, @"");
    XCTAssertEqual(array.count, (NSUInteger)3, @"");
}

#pragma mark Rows

- (void)testRows
{
    NSArray *array = [[CSVParser parser] rowsFromString:@"one,two,three\n1,2,3"];
    XCTAssertEqual(array.count, (NSUInteger)2, @"");
	
    NSArray *row = [array objectAtIndex:0];
    XCTAssertEqual(row.count, (NSUInteger)3, @"");
    XCTAssertEqualObjects([row objectAtIndex:0], @"one", @"");
}

#pragma mark Objects

- (void)testObjects
{
    NSArray *array = [[CSVObjectParser parser] objectsFromString:@"one,two,three\n1,2,3"];
    XCTAssertEqual(array.count, (NSUInteger)1, @"");
	
    NSDictionary *dict = [array objectAtIndex:0];
    XCTAssertEqual(dict.count, (NSUInteger)3, @"");
    XCTAssertEqualObjects([dict objectForKey:@"one"], @"1", @"");
}

@end
