//
//  queryController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//


/*
 to-do:
 issue reverse-geocode query to Factual with coords of device to get closest addr
    if country == US
        issue queries
            issue restaurants nearby query to Factual to get 50 closest restaurants
                fill in all available info, and add all to _restaurants even if hours are unknown
            at same time, issue query to G for closest 20 restaurants
        check G results to see which are open
            if a restaurant is open,
                [self matchRestaurantWithName:(NSString *)fullName streetAddress:(NSString *)address]
                     parse restaurant full name to find first significant word (not “a”, “an,” or “the”)
                     get only the street number from the address
                     for each restaurant in _restaurants (added by Factual):
                     parse name
                     get street num
                     see if G restaurant nameBeginning IN explodedFactualName
                     see if G restaurant streetNum == first GRestaurantStreetNum.length chars of F restaurant
                     return the matched restaurant or nil
                if (matchRestaurant != nil)
                    if (r.isOpenNow == FALSE) //we only care about the G results if they give us info about an r that F didn’t know is currently open
                        r.isOpenNow = TRUE
                        facilitate the display to users that there is no hours info
                        [openNow addObject:restaurantObject];
        loop through _restaurants
            if r.isOpenNow == TRUE
                [openNow addObject:restaurantObject];
                continue
            else if (r.isOpenNow == FALSE && [r.openNext length] > 0)
                [openLater addObject:restaurantObject];
                continue
            else: continue
        at end of _restaurants loop, re-sort both arrays and notify VC to update tableview
 */


#import "queryController.h"

@implementation queryController
{
    locationServices *_locationService;
    listViewController *_listView;
    FactualAPIRequest *_activeRequest;    
    NSInteger _pageNum;
    CLLocationCoordinate2D _deviceLocation;
//    NSInteger _numberOfResultsToCheck;
    NSMutableArray *_restaurants;
//    NSInteger _nullQueryAttempts;
//    BOOL _waitForMoreResults;
}
@synthesize queryCategories;
@synthesize openNow;
@synthesize openLater;
@synthesize farthestPlaceString;

-(id)init
{
    _locationService = [[locationServices alloc]init];
    _listView = [[listViewController alloc]init];
    _restaurants = [[NSMutableArray alloc]init];
        
    return self;
}

-(void)getRestaurants
{
    _deviceLocation = [_locationService getCurrentLocation];
    
    //these categories are for Google
//    queryCategories = [NSArray arrayWithObjects:@"cafe", @"restaurant", @"bakery", nil];
    //    queryCategories = [NSArray arrayWithObjects:@"bar", nil];
    openNow = [[NSMutableArray alloc]init];
    openLater = [[NSMutableArray alloc]init];
    
    //set pg to 1 since initial Google Places query will pull the 1st page of results
//    _pageNum = 1;
    
//    _nullQueryAttempts = 0;
//    _numberOfResultsToCheck = 0;
//    _waitForMoreResults = FALSE;
    
    [self queryFactualForRestaurantsNearLatitude:_deviceLocation.latitude longitude:_deviceLocation.longitude];

//    [self queryGooglePlacesWithTypes:queryCategories nextPageToken:nil];
}

//#pragma mark - Google Places Query
//-(void)queryGooglePlacesWithTypes:(NSArray *)googleTypes nextPageToken:(NSString *)nextPageToken
//{
//    _deviceLocation = [_locationService getCurrentLocation];
//    
//    /* queryGooglePlaces is potentially called multiple times with different
//     pageTokens for a full refresh of the restaurant data in the table. Here, I test whether
//     this is the initial query in a full refresh of the data or part way through a refresh.
//     */
//    if (nextPageToken.length < 1)
//    {        
//        _pageNum = 1;
//        
//        //If queryGooglePlaces is called multiple times with nextPageToken of nil, then stop attempting the query because there are no nearby open restaurants (or the device cannot get a valid location).
//        _nullQueryAttempts++;
//        
//        if ([openNow count] > 0)
//        {
//            [openNow removeAllObjects];
//        }
//        if ([openLater count] > 0)
//        {
//            [openLater removeAllObjects];
//        }
//    }
//    
//    NSLog(@"query executing");
//    
//    //Google Places API allows searching by "types," which we specify in the queryCategories array in this app.
//    //Here, we build a string of all categories ("types") we want to search with Google Places API.
//    NSString *googleTypesString = [[NSString alloc]initWithString:[googleTypes objectAtIndex:0]];
//    
//    //if more than 1 type is supplied
//    if ([googleTypes count] >1 )
//    {
//        googleTypesString = [googleTypesString stringByAppendingString:@"%7C"];
//        
//        for (int i=1; i<[googleTypes count]; i++)
//        {
//            googleTypesString = [googleTypesString stringByAppendingString:[googleTypes objectAtIndex:i]];
//            
//            //add | character to end of googleTypesString if this is not the last string in the googleTypes array
//            if (i!=[googleTypes count]-1)
//            {
//                googleTypesString = [googleTypesString stringByAppendingString:@"%7C"];
//            }
//        }
//    }
//    
//    NSString *url = [[NSString alloc]init];
//    
//    //Google Places will return up to 3 pages of results.
//    if ( [nextPageToken length] == 0)
//    {
//        url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&rankby=distance&sensor=true&key=%@&hasNextPage=true&nextPage()=true", _deviceLocation.latitude, _deviceLocation.longitude, googleTypesString, GOOGLE_API_KEY];
//    }
//    else
//    {
//        url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&rankby=distance&sensor=true&key=%@&hasNextPage=true&nextPage()=true&pagetoken=%@", _deviceLocation.latitude, _deviceLocation.longitude, googleTypesString, GOOGLE_API_KEY, nextPageToken];
//    }
//    
//    NSURL *googleRequestURL=[NSURL URLWithString:url];
//    
//    
//    /* to-do: remove this
//     // Retrieve the results of the query
//     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//     NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
//     [self performSelectorOnMainThread:@selector(fetchedGoogleData:) withObject:data waitUntilDone:YES];
//     });
//     */
//    NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
//    
//    if (!data)
//    {
//        //occasionally, data is nil, and the app crashes if I don't check !data
//        //just start the query over again if data is nil for some reason
//        [self getRestaurants];
//    }
//    else
//    {
//        [self fetchedGoogleData:data];
//    }
//    
//}
//
//
//- (void)fetchedGoogleData:(NSData *)responseData
//{
//    NSError* error;
//    NSDictionary* json = [NSJSONSerialization
//                          JSONObjectWithData:responseData
//                          options:kNilOptions
//                          error:&error];
//    NSString *nextPageToken = [json objectForKey:@"next_page_token"];
//    
//    NSMutableArray *placesArray = [json objectForKey:@"results"];
//    
//    NSLog(@"all Google results: %@", placesArray);
//    
//    //get the number of results so that we can check whether we've looked at the hours for all of them
//    _numberOfResultsToCheck = _numberOfResultsToCheck + placesArray.count;
//    
//    //to-do: if < 1 open place, set value for "name" key for object 0 of openNow to @"None open within %@", farthestPlaceString
//    // to-do: if all places are open, there are none "open later today", so check for count of 0
//    
//    int numOpenNow = 0;
//    
//    /*Look at each restaurant from Google to see if it's open. If open, add to openNow, which displays in the table
//     under the section "Open Now".  If not currently open (or if Google doesn't make it clear whether or not it's open),
//     find the restaurant in Factual's database to see if it's open (or open later today, in which case we'll add it to
//     the openLater array to display under the section "Open Later Today.")
//     */
//    for (int i=0; i<placesArray.count; i++)
//    {
//        NSDictionary *place = [[NSDictionary alloc]initWithDictionary:[placesArray objectAtIndex:i]];
//        
//        restaurant *restaurantObject = [[restaurant alloc]init];
//        
//        //to-do: in factual query, don't reset lat/lng if already set by Google (make sure whichever one used for detailview.text is same as the one in the details page for the restaurant
//        
//        restaurantObject.name = [place objectForKey:@"name"];
//        restaurantObject.googleID = [place objectForKey:@"reference"];
//        restaurantObject.latitude = [[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
//        restaurantObject.longitude = [[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
//        
//        //calculate the proximity of the mobile device to the establishment
//        float placeLat = [restaurantObject.latitude floatValue];
//        float placeLng = [restaurantObject.longitude floatValue];
//        float deviceLatitude = [[NSString stringWithFormat:@"%f", _deviceLocation.latitude]floatValue];
//        float deviceLongitude = [[NSString stringWithFormat:@"%f", _deviceLocation.longitude]floatValue];
//        NSString *distanceString = [NSString stringWithFormat:@"%.2f miles",
//                               [self calculateDistanceFromDeviceLatitudeInMiles:deviceLatitude
//                                                                deviceLongitude:deviceLongitude
//                                                                toPlaceLatitude:placeLat
//                                                                 placeLongitude:placeLng]];
//        NSString *proximity = [@"Distance: " stringByAppendingString:distanceString];
//        restaurantObject.proximity = proximity;
//        //to-do: make sure I don't set proximity elsewhere, too
//        
//        //to-do: set other info that Google acquired about the restaurant
//        
//        //Get distance of farthest place in the results. Since results are ordered by distance, we'll look at the last result.
//        if (i == (placesArray.count - 1))
//        {
//            farthestPlaceString = [NSString stringWithFormat:@"Restaurants within %@:",distanceString];
//        }
//        
//        restaurantObject.isOpenNow = FALSE;
//        
//        //make sure opening_hours key and open_now key exist for this restaurant, and then put currently open restaurants into openNow array
//        if ([place objectForKey:@"opening_hours"])
//        {
//            if ([[place objectForKey:@"opening_hours"] objectForKey:@"open_now"])
//            {
//                BOOL isOpen = [[[place objectForKey:@"opening_hours"] objectForKey:@"open_now"]boolValue];
//                
//                if (isOpen == TRUE)
//                {
//                    //to-do: increment this also based on results from Factual
//                    numOpenNow++;
//                    restaurantObject.isOpenNow = TRUE;
//                }
//            }
//        }
//        
//        [_restaurants addObject:restaurantObject];
//        [self queryFactualWithRestaurantName:[place objectForKey:@"name"]
//                               streetAddress:[place objectForKey:@"vicinity"]
//                                    latitude:placeLat
//                                   longitude:placeLng];    
//    }//end for loop
//    
//    //to-do: move this elsewhere so that we can take into account the number of open places that Factual finds, too
//    //if <9 restaurants are currently open, get next 20 results (unless we've already fetched page 3 of 3)
//    //to-do: change to <9 becuase 9 is the max number that can be displayed in one screen on iPhone 4
//    //to-do: make sure there aren't strange duplicate cell issues after changing it to <9
//    if ((numOpenNow <20) &&
//        (_pageNum <3) &&
//        (_nullQueryAttempts < 3))
//    {
//        _waitForMoreResults = TRUE;
//        
//        
//        NSLog(@"getting more results");
//        
//        
//        
//        //to-do: need to pause notifications so that listVC cannot be notified that the query is finished until the entire set of pages (1, 2, or 3) has been acquired
//        
//        //to-do: Factual burst limit is 300 queries per minute.  Not reasonable to check each 
//        
//        
//        
////        [_listView startListeningForCompletedQuery];
//        
//        //the Google pageToken doesn't become valid for some unspecified period of time after requesting the first page, so we have to delay the next request
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self queryGooglePlacesWithTypes:queryCategories nextPageToken:nextPageToken];
//        });
//        
//        //increment with each new set of 20 results fetched from Google
//        _pageNum++;
//    }
//    else
//    {
//        _waitForMoreResults = FALSE;
//    }
//    
//    //to-do: add a listener for _nullQueryAttempts being > 2 and then notify the user that there are no open restaurants nearby
//    
//} //end fetchedGoogleData

#pragma mark - Factual Query
- (void)queryFactualForRestaurantsNearLatitude:(float)lat longitude:(float)lng
{        
        FactualQuery* queryObject = [FactualQuery query];
        
        queryObject.limit = 50;
    
        FactualSortCriteria* proximitySort = [[FactualSortCriteria alloc] initWithFieldName:@"$distance" sortOrder:FactualSortOrder_Ascending];
        [queryObject setPrimarySortCriteria:proximitySort];
    
//        [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" search:@"bar"]];
    
        //filter by restaurants within 110 meters of Google's claimed restaurant location
        CLLocationCoordinate2D geoFilterCoords = {
            lat, lng
        };
        [queryObject setGeoFilter:geoFilterCoords radiusInMeters:500.0];
        
        //execute the Factual request
        _activeRequest = [[UMAAppDelegate getAPIObject] queryTable:@"restaurants" optionalQueryParams:queryObject withDelegate:self];
//        [[_restaurants lastObject] setRequestId:[NSString stringWithFormat:@"%@", _activeRequest.requestId]];
    }

# pragma mark - Factual request complete
-(void) requestComplete:(FactualAPIRequest *)request receivedQueryResult:(FactualQueryResult *)queryResultObj
{
    _queryResult = queryResultObj;

    
    //check each restaurant retrieved from Factual
    for (int i=0; i < _queryResult.rowCount; i++)
    {
        restaurant *restaurantObject = [[restaurant alloc]init];
//        BOOL addedAlready = FALSE;
        
        NSLog(@"row #%i in loop: %@", i, [_queryResult.rows objectAtIndex:i]);
        
        //run only if we have a valid response from Factual
        if ((_queryResult != nil) &&
            ([_queryResult.rows objectAtIndex:i] != nil))
        {
            FactualRow *row = [_queryResult.rows objectAtIndex:i];
            
            //calculate proximity of mobile device to the restaurant
            float lat = [[row valueForName:@"latitude"]floatValue];
            float lng = [[row valueForName:@"longitude"]floatValue];
            NSString *proximity = [NSString stringWithFormat:@"Distance: %.2f miles",
                                   [self calculateDistanceFromDeviceLatitudeInMiles:_deviceLocation.latitude
                                                                    deviceLongitude:_deviceLocation.longitude
                                                                    toPlaceLatitude:lat placeLongitude:lng]];
            
            restaurantObject.factualID = [row rowId];
            restaurantObject.name = [row valueForName:@"name"];
            NSLog(@"name is %@", restaurantObject.name);
            restaurantObject.latitude = [row valueForName:@"latitude"];
            restaurantObject.longitude = [row valueForName:@"longitude"];
            restaurantObject.proximity = proximity;
            if ([row valueForName:@"rating"])
            {
                restaurantObject.rating = [NSString stringWithFormat:@"%.1f/5",[[row valueForName:@"rating"]floatValue]];
            }
            if ([row valueForName:@"price"])
            {
                int price = [[row valueForName:@"price"]integerValue];
                NSString *dollarSymbols = [[NSString alloc]init];
                
                switch (price) {
                    case 1:
                        dollarSymbols = @"$";
                        break;
                    case 2:
                        dollarSymbols = @"$$";
                        break;
                    case 3:
                        dollarSymbols = @"$$$";
                        break;
                    case 4:
                        dollarSymbols = @"$$$$";
                        break;
                    case 5:
                        dollarSymbols = @"$$$$$";
                        break;
                    default:
                        break;
                }
                restaurantObject.priceLevel = [NSString stringWithFormat:@"Price Level: %@", dollarSymbols];
            }
            if ([row valueForName:@"tel"]) restaurantObject.phone = [row valueForName:@"tel"];
            if ([row valueForName:@"accessible_wheelchair"]) restaurantObject.wheelchair = [row valueForName:@"accessible_wheelchair"];
            if ([row valueForName:@"alcohol"]) restaurantObject.servesAlcohol = [row valueForName:@"alcohol"];
            if ([row valueForName:@"alcohol_bar"]) restaurantObject.hasFullBar = [row valueForName:@"alcohol_bar"];
            if ([row valueForName:@"address_extended"])
            {
                restaurantObject.address = [[[[[[[row valueForName:@"address"]
                                                 stringByAppendingString:@" "]
                                                stringByAppendingString:[row valueForName:@"address_extended"]]
                                               stringByAppendingString:@" "]
                                              stringByAppendingString:[row valueForName:@"locality"]]
                                             stringByAppendingString:@", "]
                                            stringByAppendingString:[row valueForName:@"region"]];
            }
            else
            {
                restaurantObject.address = [[[[[row valueForName:@"address"]
                                               stringByAppendingString:@" "]
                                              stringByAppendingString:[row valueForName:@"locality"]]
                                             stringByAppendingString:@", "]
                                            stringByAppendingString:[row valueForName:@"region"]];
                
            }
            if ([row valueForName:@"parking"]) restaurantObject.parking = [row valueForName:@"parking"];
            if ([row valueForName:@"attire"]) restaurantObject.attire = [row valueForName:@"attire"];
            if ([row valueForName:@"meal_takeout"]) restaurantObject.takeout = [row valueForName:@"meal_takeout"];
            if ([row valueForName:@"open_24hrs"]) restaurantObject.open24Hours = [row valueForName:@"open_24hrs"];
            if ([row valueForName:@"seating_outdoor"]) restaurantObject.outdoorSeating = [row valueForName:@"seating_outdoor"];
            if ([row valueForName:@"reservations"]) restaurantObject.reservations = [row valueForName:@"reservations"];
            if ([row valueForName:@"website"]) restaurantObject.website = [row valueForName:@"website"];
            if ([row valueForName:@"payment_cashonly"]) restaurantObject.cashOnly = [row valueForName:@"payment_cashonly"];
            if ([row valueForName:@"cuisine"]) restaurantObject.cuisine = [row valueForName:@"cuisine"];
            if ([row valueForName:@"hours"])
            {
                NSData *hoursData = [[row valueForName:@"hours"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *hours = [NSJSONSerialization JSONObjectWithData:hoursData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:nil];
                if (!hours)
                {
                    NSLog(@"Error parsing hours JSON from Factual");
                }
                else
                {
                    
                    
                    //to-do: get hours in pretty format and save to restaurantObject.openHours
                    //to-do: put the optional label (described below) in array of openHours and deal with display in VC
                    
                    
                    //to-do: how should I display to users the optional string after the pair of hours? Example: ["11:00","16:00","Lunch"]. Factual says that these are just a guess if they say "lunch," "dinner," "breakfast," etc.  In their documentation, they also say that some say things like "only after Labor Day." How to display that to user? Show that it's open now (or later today), but if it has a message, display that message prominently on the details page?
                    
                                    NSLog(@"----------------------------------");
                    //                NSLog(@"the response id: %@", request.requestId);
                    //                NSLog(@"factual response:%@", [queryResultObj rows]);
//                                    NSLog(@"hours for %@:%@", restaurantObject.name, hours);
                    
                    NSDate* GMTDate = [NSDate date];
                    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
                    NSInteger deviceGMTOffset = [systemTimeZone secondsFromGMTForDate:GMTDate];
                    NSDate* dateTimeInSystemLocalTimezone = [[NSDate alloc]
                                                             initWithTimeInterval:deviceGMTOffset
                                                             sinceDate:[NSDate date]];
                    
                    //get current day of week
                    NSDateFormatter *dayOfWeekFormatter = [[NSDateFormatter alloc]init];
                    [dayOfWeekFormatter setDateFormat:@"EEEE"];
                    NSString *dayToday = [[dayOfWeekFormatter stringFromDate:[NSDate date]]lowercaseString];
                    
                    //to-do: will this work with [self getDate....]?
                    //get previous day
                    int daysToSet = -1;
                    NSDateComponents *yesterdayComponents = [[NSDateComponents alloc] init];
                    [yesterdayComponents setDay:daysToSet];
                    NSDate *yesterdayDate = [[NSCalendar currentCalendar]
                                             dateByAddingComponents:yesterdayComponents
                                             toDate:dateTimeInSystemLocalTimezone
                                             options:0];
                    NSString *dayYesterday = [[dayOfWeekFormatter stringFromDate:yesterdayDate]lowercaseString];
                    
                    //See if it's open right now
//                    NSLog(@"checking if %@ is open", restaurantObject.name);
                    //Is restaurant still open within last night's hour range?
                    NSArray *yesterdayHours = [hours objectForKey:dayYesterday];
                    
                    if (yesterdayHours.count > 0)
                    {
                        NSArray *lastHourRangeFromYesterday = [yesterdayHours lastObject];
                        
                        //                        NSLog(@"last yesterday hours: %@", lastHourRangeFromYesterday);
//                        NSLog(@"current time is %@", dateTimeInSystemLocalTimezone);
//                        NSLog(@"yesterday time was %@", yesterdayDate);
                        
                        //See if the restaurant is still open right now within last night's last hour range
//                        NSLog(@"see if open now from last night's hours");
                        BOOL restaurantIsOpen = [self restaurantWithOpeningHoursRange:lastHourRangeFromYesterday
                                                                               onDate:yesterdayDate
                                                                         isOpenAtTime:dateTimeInSystemLocalTimezone];
                        
//                        NSLog(@"done checking last night's hours");
                        
                        if (restaurantIsOpen == TRUE)
                        {
//                            NSLog(@"%@ IS OPEN from last night. Hours:%@", restaurantObject.name, [yesterdayHours lastObject]);
                            
                            //Get the time comment (if any) for this range of hours for this restaurant
                            //http://developer.factual.com/display/docs/Places+API+-+Restaurants#PlacesAPI-Restaurants-OpeningHoursJSON.1
                            if ([lastHourRangeFromYesterday count] > 2)
                            {
                                //to-do: display this somehow to users - maybe highlight the cell some color if there's a comment to indicate that there's a qualifier (the comment might say that it's only open at this time on special occasions, for example)
                                
                                //this is an optional value that may not exist for most restaurants
                                NSString *optionalTimeComment = [lastHourRangeFromYesterday objectAtIndex:2];
                                NSLog(@"time comment: %@", optionalTimeComment);
                            }
                            
                            restaurantObject.isOpenNow = TRUE;
                            [openNow addObject:restaurantObject];
//                            addedAlready = TRUE;
                            continue;
                            
                            //Re-sort by proximity
                            NSSortDescriptor *sortByProximity = [NSSortDescriptor sortDescriptorWithKey:@"proximity" ascending:YES];
                            [openNow sortUsingDescriptors:[NSArray arrayWithObject:sortByProximity]];
                        }
                    } //end if open yesterday
                    
                    // Is the restaurant open today? (not just from yesterday's hours carrying over to today)
                    NSArray *todayHours = [hours objectForKey:dayToday];
                    
                    // If we know it's open from last night still, don't bother checking if it's open now based on today's hours
                    if (todayHours.count > 0)
                    {
                        //check each set of opening hours today for the restaurant
                        for (int i=0; i < todayHours.count; i++)
                        {
//                            NSLog(@"checking hours TODAY");
                            BOOL restaurantIsOpen = [self restaurantWithOpeningHoursRange:[todayHours objectAtIndex:i]
                                                                                   onDate:dateTimeInSystemLocalTimezone
                                                                             isOpenAtTime:dateTimeInSystemLocalTimezone];
                            
                            //Get the time comment (if any) for this range of hours for this restaurant
                            //http://developer.factual.com/display/docs/Places+API+-+Restaurants#PlacesAPI-Restaurants-OpeningHoursJSON.1
                            if ([[todayHours objectAtIndex:i] count] > 2)
                            {
                                //to-do: display this somehow to users - maybe highlight the cell some color if there's a comment to indicate that there's a qualifier (the comment might say that it's only open at this time on special occasions, for example)
                                
                                //this is an optional value that may not exist for most restaurants
                                NSString *optionalTimeComment = [[todayHours objectAtIndex:i]objectAtIndex:2];
                                NSLog(@"time comment: %@", optionalTimeComment);
                            }
                            
                            if (restaurantIsOpen == TRUE)
                            {
//                                NSLog(@"%@ IS OPEN. Hours:%@", restaurantObject.name, todayHours);
                                
                                restaurantObject.isOpenNow = TRUE;
                                [openNow addObject:restaurantObject];
                                
                                //Re-sort by proximity
                                NSSortDescriptor *sortByProximity = [NSSortDescriptor sortDescriptorWithKey:@"proximity" ascending:YES];
                                [openNow sortUsingDescriptors:[NSArray arrayWithObject:sortByProximity]];
                                break;
                            }
                            else
                            {
//                                NSLog(@"%@ is CLOSED. Hours:%@", restaurantObject.name, todayHours);
                                
                                //get date objects for when restaurant is open and closed
                                NSString *openTimeString = [[todayHours objectAtIndex:i]objectAtIndex:0];
                                NSString *closeTimeString = [[todayHours objectAtIndex:i]objectAtIndex:1];
                                NSDate *openTimeDate = [[self getHoursWithOpenTime:openTimeString
                                                                         closeTime:closeTimeString
                                                                            onDate:dateTimeInSystemLocalTimezone]objectAtIndex:0];
                                
//                                NSLog(@"now:%@    open:%@    close:%@", dateTimeInSystemLocalTimezone, openTimeDate, closeTimeString);
                                
                                // See if it's open later today
                                if ([dateTimeInSystemLocalTimezone compare:openTimeDate] == NSOrderedAscending)
                                {
//                                    NSLog(@"%@ is open LATER today.", restaurantObject.name);
                                    
                                    //Format openNextDisplay to a string like "Opening at 7:00 pm"
                                    NSDateFormatter *openNextFormatter = [[NSDateFormatter alloc]init];
                                    [openNextFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                                    [openNextFormatter setDateFormat:@"h:mm a"];
                                    NSString *openNextString = [openNextFormatter stringFromDate:openTimeDate];
                                    
                                    restaurantObject.isOpenNow = FALSE;
                                    restaurantObject.openNextDisplay = [NSString stringWithFormat:@"Opening at %@", openNextString];
                                    restaurantObject.openNextSort = openTimeDate;
                                    [openLater addObject:restaurantObject];
                                    
                                    //to-do: does sorting work now with custom object?
                                    //re-sort by opening soonest
                                    NSSortDescriptor *sortByOpeningSoonest = [NSSortDescriptor sortDescriptorWithKey:@"openNextSort" ascending:YES];
                                    [openLater sortUsingDescriptors:[NSArray arrayWithObject:sortByOpeningSoonest]];
                                    
                                    // Do not test other times for this restaurant since we already know it's open later.
                                    break;
                                }
                            } //end else (see if it's open later today)
                        } //end for loop of all opening hour ranges today
                    } //if open at all today
                } //end else (hours key successfully converted to JSON)
            } //end if it has a value for the hours key
            else
            {
                NSLog(@"%@ has no value for hours key", restaurantObject.name);
            }
        } //end if !empty query result
    } //end for loop to check each restaurant result

    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantsAcquired"
                                                            object:nil];
    NSLog(@"number open now: %i", [openNow count]);
    NSLog(@"number open later: %i", [openLater count]);
}



-(NSDate *) getDateWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second onDate:(NSDate *)date withDayOffset:(NSInteger)dayOffset
{
//    NSLog(@"date passed in %@", date);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *timeComponents = [calendar components:NSUIntegerMax fromDate:date];
    [timeComponents setHour:hour];
    [timeComponents setMinute:minute];
    [timeComponents setSecond:second];
    NSDate *timeDate = [calendar dateFromComponents:timeComponents];
    
    if (dayOffset != 0)
    {
        NSDateComponents *dayOffsetComponent = [[NSDateComponents alloc]init];
        [dayOffsetComponent setDay:dayOffset];
        timeDate = [calendar dateByAddingComponents:dayOffsetComponent toDate:timeDate options:0];
    }
    
    return timeDate;
}

//Returns an array with two elements: open time date object and a close time date object
-(NSArray *) getHoursWithOpenTime:(NSString *)openTimeString closeTime:(NSString *)closeTimeString onDate:(NSDate *)date
{
    //Get integer values for the opening and closing hour/minute of the restaurant
    NSInteger openHour;
    NSInteger openMinute;
    NSInteger closeHour;
    NSInteger closeMinute;
    
    if ([openTimeString length] > 4)
    {
        //it's after 9:59, so it's HH:mm instead of H:mm
        openHour = [[openTimeString substringToIndex:2]integerValue];
        openMinute = [[openTimeString substringWithRange:NSMakeRange(3, 2)]integerValue];
    }
    else
    {
        //it's before 10:00, so it's H:mm
        openHour = [[openTimeString substringToIndex:1]integerValue];
        openMinute = [[openTimeString substringWithRange:NSMakeRange(2, 2)]integerValue];
    }
    if ([closeTimeString length] > 4)
    {
        //it's after 9:59, so it's HH:mm instead of H:mm
        closeHour = [[closeTimeString substringToIndex:2]integerValue];
        closeMinute = [[closeTimeString substringWithRange:NSMakeRange(3, 2)]integerValue];
    }
    else
    {
        //it's before 10:00, so it's H:mm
        closeHour = [[closeTimeString substringToIndex:1]integerValue];
        closeMinute = [[closeTimeString substringWithRange:NSMakeRange(2, 2)]integerValue];
    }
    
    //Create a date object representing the opening time of the restaurant
    NSDate *openTimeDate = [self getDateWithHour:openHour
                                          minute:openMinute
                                          second:0
                                          onDate:date
                                   withDayOffset:0];
    
    //Create a date object representing the closing time of the restaurant
    NSDate *closeTimeDate = [self getDateWithHour:closeHour
                                           minute:closeMinute
                                           second:0
                                           onDate:date
                                    withDayOffset:0];
    
    //If the restaurant closes after midnight, set the close date to the close hour on the NEXT day
    //example: ["11:00","2:00"] opens at 11am, closes at 2am the next day
    if (closeHour < openHour)
    {
        closeTimeDate = [self getDateWithHour:closeHour
                                       minute:closeMinute
                                       second:0
                                       onDate:date
                                withDayOffset:1];
    }
    
    NSArray *openAndCloseHours = [NSArray arrayWithObjects:openTimeDate, closeTimeDate, nil];
    
    return openAndCloseHours;
}

//Answers questions like this: Is restaurant with hours ["11:00","4:00"] on Thursday open now (Friday early morning at 2:30)?
-(BOOL) restaurantWithOpeningHoursRange:(NSArray *)hours onDate:(NSDate *)dateOfSpecifiedHours isOpenAtTime:(NSDate *)dateToCheck
{
    BOOL isOpen;
    
    //Get opening hours of restaurant
    //Example open time: "10:00"     Example close time: "2:00"
    NSString *openTimeString = [hours objectAtIndex:0];
    NSString *closeTimeString = [hours objectAtIndex:1];
    
    //Get date objects for open and close times
    NSDate *openTimeDate = [[self getHoursWithOpenTime:openTimeString
                                             closeTime:closeTimeString
                                                onDate:dateOfSpecifiedHours]
                            objectAtIndex:0];
    NSDate *closeTimeDate = [[self getHoursWithOpenTime:openTimeString
                                              closeTime:closeTimeString
                                                 onDate:dateOfSpecifiedHours]
                             objectAtIndex:1];
    
    //Is the restaurant still open now (hasn't closed since it opened yesterday)?
    if (([dateToCheck compare:closeTimeDate] == NSOrderedAscending) &&
        ([dateToCheck compare:openTimeDate] == NSOrderedDescending))
    {
        isOpen = TRUE;
    }
    else
    {
        isOpen = FALSE;
    }
    
    return  isOpen;
}

-(void)requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    NSLog(@"Factual request FAILED with error: ");
    NSLog(@"%@", error);
}

-(float)calculateDistanceFromDeviceLatitudeInMiles:(float)deviceLatitude deviceLongitude:(float)deviceLongitude toPlaceLatitude:(float)placeLat placeLongitude:(float)placeLng
{
    float latDiff = deviceLatitude - placeLat;
    float lngDiff = deviceLongitude - placeLng;
    float latSquared = powf(latDiff, 2);
    float lngSquared = powf(lngDiff, 2);
    float distanceInMiles = sqrtf(latSquared + lngSquared) * (10000/90) * .621371;
    float distance = [[NSString stringWithFormat:@"%.2f", distanceInMiles] floatValue];
    return distance;
}

@end
