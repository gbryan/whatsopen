//
//  queryController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//


/*
 to-do: future version of app will support international queries
 
-attempt Factual query first, and if there are no results, fall back to Google Places API.
    This will fix problem of international queries (for which Factual has no restaurant info currently)
    and will also make the app usable even if Factual fails for some reason, though we will have fewer results (20).
-check country of first result to see if it is U.S. or not, and set isInternational 
    accordingly (and tell VC to update this value in their instance so that they will 
    display Google attribution on tableview)
 
 to-do: check if it has overlapping blocks of hours: ["11:00","16:00"],["16:00","22:00"]
    //right now, it's saying that it will close at 16:00 even though it's really open until 22:00
 */


#import "queryController.h"

@implementation queryController
{
    FactualQuery* _queryObject;
    NSInteger _pageNum;
    NSInteger _totalResults;
    NSInteger _numFailedGoogleQueries;
    CLLocationCoordinate2D _deviceLocation;
    NSString* _queryPurpose;
}
@synthesize apiRequest;
@synthesize queryCategories;
@synthesize openNow;
@synthesize openLater;
@synthesize hoursUnknown;
@synthesize farthestPlaceString;
@synthesize detailRestaurant;
@synthesize noMoreResults;

-(id)init
{
    _totalResults = 0;
    _numFailedGoogleQueries = 0;
    _deviceLocation = CLLocationCoordinate2DMake(0.0, 0.0);
    _queryPurpose = @"";
    
    NSLog(@"initializing queryController");
    noMoreResults = FALSE;
    openNow = [[NSMutableArray alloc]init];
    openLater = [[NSMutableArray alloc]init];
    hoursUnknown = [[NSMutableArray alloc]init];
    
    return self;
}


-(NSString* )getFirstSignificantWordInRestaurantName:(NSString* )restaurantName
{
    //clean restaurant name from Google before using the name to search Factual
    NSString* queryString = restaurantName;
    queryString = [queryString lowercaseString];
//    queryString = [queryString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    queryString = [queryString stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    queryString = [queryString stringByReplacingOccurrencesOfString:@" & " withString:@" "];
    NSArray* restaurantNameExploded = [queryString componentsSeparatedByString:@" "];
    
    //use the first non "a", "an", or "the" word of the restaurant full name (from Google) to search Factual
    if (!([[restaurantNameExploded objectAtIndex:0] isEqualToString:@"a"] ||
          [[restaurantNameExploded objectAtIndex:0] isEqualToString:@"an"] ||
          [[restaurantNameExploded objectAtIndex:0] isEqualToString:@"the"]))
    {
        queryString = [restaurantNameExploded objectAtIndex:0];
    }
    else
    {
        queryString = [restaurantNameExploded objectAtIndex:1];
    }
    
    return queryString;
}

//This clears out existing restaurants in the arrays and issues a new query.
-(void)refreshRestaurants
{

    NSLog(@"queryC: refreshRestaurants");
    
    //Get notification when device location has been acquired
    _queryPurpose = @"refresh";
    locationServices* locationService = [UMAAppDelegate locationServiceShared];
    [locationService addObserver:self forKeyPath: @"deviceLocation"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [locationService getLocation];
}

-(void)appendNewRestaurants
{
    NSLog(@"append called");
    //to-do: make sure that when restaurants are appended to bottom of list in any tab, the data source array is sorted such that
    //all new results are added to the bottom of the list instead of somewhere else in the list in the listView
    
//    _deviceLocation = locationService.deviceLocation;
    
    //    [self queryGooglePlacesWithTypes:queryCategories nextPageToken:nil];
    
    NSInteger offset = _totalResults;
    
    //Don't run the query if there are already 500 restaurants acquired because Factual provides a max of 500, and the query will return an error.
    if (_totalResults < 500)
    {
        [self queryFactualForRestaurantsNearLatitude:_deviceLocation.latitude longitude:_deviceLocation.longitude withOffset:offset];
    }
    else
    {
        //Even if we don't run the query, we have to notify the VC to stop spinning the uiactivityindicator
        [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantsAcquired"
                                                            object:nil];
    }
}

//This will run when locationServices acquires a new lat/lng and changes its deviceLocation property value.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{    
    if ([keyPath isEqualToString:@"deviceLocation"] &&
             [_queryPurpose isEqualToString:@"refresh"])
    {
        locationServices* locationService = [UMAAppDelegate locationServiceShared];
        [locationService removeObserver:self forKeyPath:@"deviceLocation"];
        _deviceLocation = [UMAAppDelegate locationServiceShared].deviceLocation;
        
        _totalResults = 0;
        
        if (self.openNow.count > 0)
        {
            [self.openNow removeAllObjects];
        }
        if (self.openLater.count > 0)
        {
            [self.openLater removeAllObjects];
        }
        if (self.hoursUnknown.count > 0)
        {
            [self.hoursUnknown removeAllObjects];
        }
        
        [self queryFactualForRestaurantsNearLatitude:_deviceLocation.latitude longitude:_deviceLocation.longitude withOffset:0];
        
    }
    else if ([keyPath isEqualToString:@"deviceLocation"] &&
             [_queryPurpose isEqualToString:@"append"])
    {
        // intentially blank
    }
    else
    {
        NSLog(@"observeValueForKeyPath: invalid query purpose given");
    }
}

//Called by placeDetailVC when tapping a specific restaurant
-(void)getRestaurantDetail:(restaurant* )restaurantObject
{
    detailRestaurant = restaurantObject;
    [self getGoogleMatchForRestaurant:restaurantObject];
}

-(void)getGoogleMatchForRestaurant:(restaurant* )restaurantObject
{
    NSString* restaurantQueryName = [self getFirstSignificantWordInRestaurantName:restaurantObject.name];
    NSString* restaurantAddress = [restaurantObject.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString* restaurantAddress = [@"125 W Franklin St" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* googleURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=110&name=%@&vicinity=%@&sensor=true&key=%@",
                                 restaurantObject.latitude,
                                 restaurantObject.longitude,
                                 restaurantQueryName,
                                 restaurantAddress,
                                 GOOGLE_API_KEY];
    NSURL *googleRequestURL = [NSURL URLWithString:googleURLString];
    NSData* googleQueryData = [NSData dataWithContentsOfURL:googleRequestURL];
    
    if (!googleQueryData)
    {
        //occasionally, data is nil, and the app crashes if I don't check !data
        //just start the query over again if data is nil for some reason
        //        [self getRestaurants];
        NSLog(@"googleQueryData was invalid for some reason. Oops.");
        
        _numFailedGoogleQueries++;
        
        if (_numFailedGoogleQueries < 2)
        {
            [self getGoogleMatchForRestaurant:restaurantObject];
        }
    }
    else
    {
        [self fetchedGoogleRestaurantDetails:googleQueryData];
    }
}

- (void)fetchedGoogleRestaurantDetails:(NSData *)responseData
{
    //reset this since we successfully completed this query
    _numFailedGoogleQueries = 0;
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray* restaurantResults = [json objectForKey:@"results"];
    
//    NSLog(@"Google results: %@", restaurantResults);
    
    //if Google returned a result
    if ([restaurantResults count] > 0)
    {
        NSDictionary *restaurantDetails = [restaurantResults objectAtIndex:0];
        
        //Google's address information appears to be more accurate than Factual's in some cases, so I'll use it.
        //to-do: need to provide attribution to Google on placeDetailVC if I do this
//        detailRestaurant.address = [restaurantDetails objectForKey:@"vicinity"];
        detailRestaurant.googleID = [restaurantDetails objectForKey:@"reference"];
        
        
        //to-do: remove this and the test stuff at line 120ish
        //        [self queryGooglePlaces:detailRestaurant.googleID];
        
        
        //If there is a photo available for this restaurant, get the photo
        if ([restaurantDetails objectForKey:@"photos"] &&
            [[[restaurantDetails objectForKey:@"photos"]objectAtIndex:0]objectForKey:@"photo_reference"])
        {
            [self getGoogleImageForRestaurantWithReference:
             [[[restaurantDetails objectForKey:@"photos"]
               objectAtIndex:0]objectForKey:@"photo_reference"]];
        }
        else
        {
            //if we don't send notification to placeDetailVC, the view will never load
            [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantDetailsAcquired"
                                                                object:nil];
        }
    }
    else
    {
        //if we don't send notification to placeDetailVC, the view will never load
        [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantDetailsAcquired"
                                                            object:nil];
    }
}

-(void)getGoogleImageForRestaurantWithReference:(NSString* )photoReference
{
    NSString* url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=130&photoreference=%@&sensor=true&key=%@", photoReference, GOOGLE_API_KEY];
    
//    NSLog(@"photo request: %@", url);
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    NSData* restaurantImageRequestData = [NSData dataWithContentsOfURL: googleRequestURL];
    if (!restaurantImageRequestData)
    {
        //occasionally, data is nil, and the app crashes if I don't check !data
        //just start the query over again if data is nil for some reason
        //        [self getRestaurants];
        NSLog(@"googleQueryData was invalid for some reason. Oops.");
        
        _numFailedGoogleQueries++;
        
        if (_numFailedGoogleQueries < 2)
        {
            [self getGoogleImageForRestaurantWithReference:photoReference];
        }
    }
    else
    {
        [self acquiredGoogleRestaurantImage:restaurantImageRequestData];
    }
}

-(void)acquiredGoogleRestaurantImage:(NSData *)responseData
{
    //reset this since we successfully completed this query
    _numFailedGoogleQueries = 0;
    
    UIImage *restaurantImage = [UIImage imageWithData:(NSData *)responseData];
    detailRestaurant.image = restaurantImage;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantDetailsAcquired"
                                                        object:nil];
}


#pragma mark - Factual Query
- (void)queryFactualForRestaurantsNearLatitude:(float)lat longitude:(float)lng withOffset:(NSInteger)offset
{
    NSLog(@"7 queryC: set up Factual query params and execute query");
    //categoryID 347 is restaurants
    
    
    NSLog(@"lat/lng: %f,%f", lat, lng);
        _queryObject = [FactualQuery query];
        
        _queryObject.limit = 50;
    
        if (offset > 0) _queryObject.offset = offset;
    
        FactualSortCriteria* proximitySort = [[FactualSortCriteria alloc]
                                              initWithFieldName:@"$distance"
                                              sortOrder:FactualSortOrder_Ascending];
        [_queryObject setPrimarySortCriteria:proximitySort];
    
        [_queryObject addRowFilter:[FactualRowFilter fieldName:@"category_ids" equalTo:@"347"]];
    
        CLLocationCoordinate2D geoFilterCoords = {
            lat, lng
        };
        [_queryObject setGeoFilter:geoFilterCoords radiusInMeters:500000.0];
        
        //execute the Factual request
        self.apiRequest = [[UMAAppDelegate getAPIObject] queryTable:@"restaurants" optionalQueryParams:_queryObject withDelegate:self];
    }

# pragma mark - Factual request complete

//The result of a correction submission comes here.
-(void)requestComplete:(FactualAPIRequest *)request receivedRawResult:(NSDictionary *)result
{
    NSLog(@"requestComplete:receivedRawResult type:%d    result: %@", request.requestType, result);
}
-(void) requestComplete:(FactualAPIRequest *)request receivedQueryResult:(FactualQueryResult *)queryResultObj
{
    NSLog(@"8 queryC: got results from Factual - %@", request.requestId);
    NSLog(@"array count totals: %d, %d, %d", openNow.count, openLater.count, hoursUnknown.count);
    
    /*
     If I need to test the type of query (whether this is a crosswalk vs read vs match query), use request.requestType (enum).
     
     Here are the request types (starting from 0): 
     FactualRequestType_RowQuery,
     FactualRequestType_RowUpdate,
     FactualRequestType_SchemaQuery,
     FactualRequestType_PlacesQuery,
     FactualRequestType_ResolveQuery,
     FactualRequestType_MatchQuery,
     FactualRequestType_RawRequest,
     FactualRequestType_FacetQuery,
     FactualRequestType_FlagBadRowRequest
     */
    
    _queryResult = queryResultObj;
    _totalResults = _totalResults + _queryResult.rowCount;
    
    if (_queryResult.rowCount < 50)
    {
        noMoreResults = TRUE;
    }
    else
    {
        noMoreResults = FALSE;
    }
    
    //check each restaurant retrieved from Factual
    for (int i=0; i < _queryResult.rowCount; i++)
    {
        restaurant* restaurantObject = [[restaurant alloc]init];
        
        //run only if we have a valid response from Factual
        if ((_queryResult != nil) &&
            ([_queryResult.rows objectAtIndex:i] != nil))
        {
            FactualRow *row = [_queryResult.rows objectAtIndex:i];           
            
            //The "status" key tells whether or not the restaurant has gone out of business.
            if ([row valueForName:@"status"])
            {
                if ([@"0" isEqualToString:[NSString stringWithFormat:@"%@", [row valueForName:@"status"]]])
                {
                    continue;
                }
            }
            
            //calculate proximity of mobile device to the restaurant
            float lat = [[row valueForName:@"latitude"]floatValue];
            float lng = [[row valueForName:@"longitude"]floatValue];
            NSString* proximity = [NSString stringWithFormat:@"%.2f miles",
                                   [self calculateDistanceFromDeviceLatitudeInMiles:_deviceLocation.latitude
                                                                    deviceLongitude:_deviceLocation.longitude
                                                                    toPlaceLatitude:lat placeLongitude:lng]];
            
            restaurantObject.factualID = [row rowId];
            restaurantObject.name = [row valueForName:@"name"];
            restaurantObject.latitude = [row valueForName:@"latitude"];
            restaurantObject.longitude = [row valueForName:@"longitude"];
            restaurantObject.proximity = proximity;
            if ([row valueForName:@"rating"])
            {
                restaurantObject.ratingSort = [NSString stringWithFormat:@"%.1f",[[row valueForName:@"rating"]floatValue]];
                
                //Select the appropriate image with correct number of stars
                if ([restaurantObject.ratingSort isEqualToString:@"0.0"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating0.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"0.5"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating0point5.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"1.0"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating1.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"1.5"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating1point5.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"2.0"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating2.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"2.5"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating2point5.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"3.0"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating3.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"3.5"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating3point5.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"4.0"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating4.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"4.5"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating4point5.png"];
                }
                else if ([restaurantObject.ratingSort isEqualToString:@"5.0"])
                {
                    restaurantObject.ratingImage = [UIImage imageNamed:@"rating5.png"];
                }
            }
            else
            {
                restaurantObject.ratingSort = @"";
                restaurantObject.ratingImage = [UIImage imageNamed:@"ratingnone.png"];
            }
            if ([row valueForName:@"price"])
            {
                restaurantObject.priceLevel = [[row valueForName:@"price"]integerValue];
                
                //Select the appropriate image and $$$ representation to show for price
                NSString* priceLevelImageName = [[NSString alloc]init];
                NSString* priceLevelDisplay = [[NSString alloc]init];
                switch (restaurantObject.priceLevel) {
                    case 1:
                        priceLevelImageName = @"dollar.png";
                        priceLevelDisplay = @"$";
                        break;
                    case 2:
                        priceLevelImageName = @"dollar2.png";
                        priceLevelDisplay = @"$$";                        
                        break;
                    case 3:
                        priceLevelImageName = @"dollar3.png";
                        priceLevelDisplay = @"$$$";                        
                        break;
                    case 4:
                        priceLevelImageName = @"dollar4.png";
                        priceLevelDisplay = @"$$$$";                        
                        break;
                    case 5:
                        priceLevelImageName = @"dollar5.png";
                        priceLevelDisplay = @"$$$$$";                        
                        break;
                    default:
                        //to-do: image for no pricing info available
                        priceLevelImageName = @"";
                        priceLevelDisplay = @"";                        
                        break;
                }
                restaurantObject.priceIcon = [UIImage imageNamed:priceLevelImageName];
                restaurantObject.priceLevelDisplay = priceLevelDisplay;
            }
            if ([row valueForName:@"region"]) restaurantObject.region = [row valueForName:@"region"];
            if ([row valueForName:@"country"]) restaurantObject.country = [row valueForName:@"country"];
            if ([row valueForName:@"locality"]) restaurantObject.locality = [row valueForName:@"locality"];
            if ([row valueForName:@"tel"])
            {
                NSString* phoneNumber = [row valueForName:@"tel"];
                NSString* numbersOnly = [[phoneNumber componentsSeparatedByCharactersInSet:
                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                       componentsJoinedByString:@""];
                restaurantObject.phone = numbersOnly;
            }
            if ([row valueForName:@"accessible_wheelchair"]) restaurantObject.wheelchair = [row valueForName:@"accessible_wheelchair"];
            if ([row valueForName:@"alcohol"]) restaurantObject.servesAlcohol = [row valueForName:@"alcohol"];
            if ([row valueForName:@"alcohol_bar"]) restaurantObject.hasFullBar = [row valueForName:@"alcohol_bar"];
            if ([row valueForName:@"address_extended"])
            {
                restaurantObject.address = [[[row valueForName:@"address"]
                                                 stringByAppendingString:@" "]
                                                stringByAppendingString:[row valueForName:@"address_extended"]];
            }
            else
            {
                restaurantObject.address = [row valueForName:@"address"];
            }
            if ([row valueForName:@"parking"]) restaurantObject.parking = [row valueForName:@"parking"];
            if ([row valueForName:@"attire"]) restaurantObject.attire = [row valueForName:@"attire"];
            if ([row valueForName:@"meal_takeout"]) restaurantObject.takeout = [row valueForName:@"meal_takeout"];
            if ([row valueForName:@"open_24hrs"]) restaurantObject.open24Hours = [row valueForName:@"open_24hrs"];
            if ([row valueForName:@"seating_outdoor"]) restaurantObject.outdoorSeating = [row valueForName:@"seating_outdoor"];
            if ([row valueForName:@"reservations"]) restaurantObject.reservations = [row valueForName:@"reservations"];
            if ([row valueForName:@"website"]) restaurantObject.website = [row valueForName:@"website"];
            if ([row valueForName:@"payment_cashonly"]) restaurantObject.cashOnly = [row valueForName:@"payment_cashonly"];
            if ([row valueForName:@"cuisine"])
            {
                restaurantObject.cuisine = [row valueForName:@"cuisine"];
                
                NSArray* cuisineItems = [[NSArray alloc]init];
                if ([restaurantObject.cuisine count] > 2)
                {
                    cuisineItems = [NSArray arrayWithObjects:[restaurantObject.cuisine objectAtIndex:0], [restaurantObject.cuisine objectAtIndex:1], [restaurantObject.cuisine objectAtIndex:2], nil];
                    restaurantObject.cuisineLabel = [cuisineItems componentsJoinedByString:@", "];
                }
                else if ([restaurantObject.cuisine count] > 1)
                {
                    cuisineItems = [NSArray arrayWithObjects:[restaurantObject.cuisine objectAtIndex:0], [restaurantObject.cuisine objectAtIndex:1], nil];
                    restaurantObject.cuisineLabel = [cuisineItems componentsJoinedByString:@", "];
                }
                else
                {
                    restaurantObject.cuisineLabel = [restaurantObject.cuisine objectAtIndex:0];
                }
            }
            
            NSLog(@"%@ hours: %@", restaurantObject.name, [row valueForName:@"hours"]);
            
            if ([row valueForName:@"open_24hrs"])
            {
                restaurantObject.open24Hours = [[row valueForName:@"open_24hrs"]stringValue];
                if ([restaurantObject.open24Hours isEqualToString:@"1"])
                {
                    restaurantObject.isOpenNow = TRUE;
                    restaurantObject.openHours = @"Open 24 hours :)";
                    restaurantObject.openingSoon = FALSE;
                    restaurantObject.openNextDisplay = @"Open 24 Hours";
                    restaurantObject.closingNextDisplay = @"Open 24 Hours";
                    [openNow addObject:restaurantObject];
                    
                    NSLog(@"%@ is open 24 hours", restaurantObject.name);
                    continue;
                }
            }
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
                    //Get hours in pretty format to display in detail modal view
                    restaurantObject.openHours = [self getStringFromFacualHoursFormat:hours];
                    
                    //Calculate opening and closing times of restaurant and determine whether it's open now or later
                    restaurantObject = [self calculateOpenHoursForRestaurant:restaurantObject withHours:hours];
                    
                    if ([restaurantObject.whichTab isEqualToString:@"openNow"])
                    {
                        [openNow addObject:restaurantObject];
                    }
                    else if ([restaurantObject.whichTab isEqualToString:@"openLater"])
                    {
                        [openLater addObject:restaurantObject];
                    }
                    else if (![restaurantObject.whichTab isEqualToString:@"closed"])
                    {
                        [hoursUnknown addObject:restaurantObject];
                    }
                }
            }
            else
            {
                //No value for Factual "hours" key
                
                [hoursUnknown addObject:restaurantObject];
            }
        } //end if !empty query result
    } //end for loop to check each restaurant result

    //Re-sort by proximity
    NSSortDescriptor *sortByProximity = [NSSortDescriptor sortDescriptorWithKey:@"proximity" ascending:YES];
    [openNow sortUsingDescriptors:[NSArray arrayWithObject:sortByProximity]];
    
    //re-sort by opening soonest
    NSSortDescriptor *sortByOpeningSoonest = [NSSortDescriptor sortDescriptorWithKey:@"openNextSort" ascending:YES];
    [openLater sortUsingDescriptors:[NSArray arrayWithObject:sortByOpeningSoonest]];
    
    NSLog(@"9 queryC: send notification to openNowVC that restaurants were acquired \n");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantsAcquired"
                                                            object:nil];
    NSLog(@"number open now: %i", [openNow count]);
    NSLog(@"number open later: %i", [openLater count]);
    NSLog(@"number unknown hours: %i", [hoursUnknown count]);
    NSLog(@"total acquired: %i", _totalResults);
}


- (NSString* )getStringFromFacualHoursFormat:(NSDictionary *)hours
{
    NSArray* daysOfWeek = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
    NSString* hoursFormattedForTextView = [[NSString alloc]init];
    for (NSString* day in daysOfWeek)
    {
        NSString* hoursStringForDay = [[NSString alloc]init];
        
        NSString* dayToSearch = [day lowercaseString];
        if ([hours objectForKey:dayToSearch])
        {
            NSString* dayInfoToAdd = [NSString stringWithFormat:@"%@:\r",[day capitalizedString]];
            NSString* allOpenTimes = [[NSString alloc]init];
            NSArray* hoursArraysThisDay = [hours objectForKey:dayToSearch];
            // hoursArray is something like ["10:00","14:00", "BRUNCH"]
            for (NSArray* hoursArray in hoursArraysThisDay)
            {
                NSDateFormatter *dateFormatterOriginal = [[NSDateFormatter alloc]init];
                [dateFormatterOriginal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [dateFormatterOriginal setDateFormat:@"HH:mm"];
                NSDate *openTimeDate = [dateFormatterOriginal dateFromString:[hoursArray objectAtIndex:0]];
                NSDate *closeTimeDate = [dateFormatterOriginal dateFromString:[hoursArray objectAtIndex:1]];
                
                NSDateFormatter *dateFormatterDisplay = [[NSDateFormatter alloc]init];
                [dateFormatterDisplay setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [dateFormatterDisplay setDateFormat:@"hh:mm a"];
                NSString* open = [dateFormatterDisplay stringFromDate:openTimeDate];
                NSString* close = [dateFormatterDisplay stringFromDate:closeTimeDate];
                NSString* openTimes = [NSString stringWithFormat:@"\t %@ - %@", open, close];
                
                //If there's a comment such as "BRUNCH" above
                if (hoursArray.count > 2)
                {
                    NSString* comment = [[hoursArray objectAtIndex:2]capitalizedString];
                    openTimes = [NSString stringWithFormat:@"%@ (%@)\r", openTimes, comment];
                }
                else
                {
                    openTimes = [NSString stringWithFormat:@"%@\r", openTimes];
                }
                
                //Add another line break if this is the last set of hours in the day
                if (hoursArray == [hoursArraysThisDay lastObject])
                {
                    openTimes = [NSString stringWithFormat:@"%@\r", openTimes];
                }
                
                allOpenTimes = [allOpenTimes stringByAppendingString:openTimes];
                
            }
            hoursStringForDay = [dayInfoToAdd stringByAppendingString:allOpenTimes];
        }
        hoursFormattedForTextView = [hoursFormattedForTextView stringByAppendingString:hoursStringForDay];
    }
    return hoursFormattedForTextView;
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
-(NSArray* ) getHoursWithOpenTime:(NSString* )openTimeString closeTime:(NSString* )closeTimeString onDate:(NSDate *)date
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
    
    NSArray* openAndCloseHours = [NSArray arrayWithObjects:openTimeDate, closeTimeDate, nil];
    
    return openAndCloseHours;
}

-(void)requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    NSLog(@"Factual request FAILED with error: ");
    NSLog(@"%@", [error localizedDescription]);
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

-(restaurant *)calculateOpenHoursForRestaurant:(restaurant *)restaurantObject withHours:(NSDictionary *)hours
{
    NSLog(@"%@ hours: %@", restaurantObject.name, hours);
    
    restaurantObject.whichTab = @"closed";
    
    NSDate* GMTDate = [NSDate date];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    NSInteger deviceGMTOffset = [systemTimeZone secondsFromGMTForDate:GMTDate];
    NSDate* now = [[NSDate alloc]initWithTimeInterval:deviceGMTOffset
                                             sinceDate:GMTDate];
    
    NSLog(@"now: %@", now);
    
    //Get today's name (e.g. "monday")
    NSDateFormatter* dayFormatter = [[NSDateFormatter alloc]init];
    [dayFormatter setDateFormat:@"EEEE"];
    [dayFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSString* todayDay = [[dayFormatter stringFromDate:now] lowercaseString];
    
    //Get yesterday's name (e.g. "sunday")
    NSDateComponents* yesterdayComponents = [[NSDateComponents alloc]init];
    [yesterdayComponents setDay:-1];
    NSDate* yesterdayDate = [[NSCalendar currentCalendar]
                             dateByAddingComponents:yesterdayComponents
                             toDate:now
                             options:0];
    NSString* yesterdayDay = [[dayFormatter stringFromDate:yesterdayDate]lowercaseString];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"hh:mm a"];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    if ([hours objectForKey:yesterdayDay])
    {
        //See if restaurant is open within last night's hour range
            //example: it's now 1:30am, and yesterday's hours go through 2am
        NSArray* lastHourRangeYesterday = [[hours objectForKey:yesterdayDay]lastObject];
        NSString* yesterdayLastOpen = [lastHourRangeYesterday objectAtIndex:0];
        NSString* yesterdayLastClose = [lastHourRangeYesterday objectAtIndex:1];
        NSDate* yesterdayLastOpenDate = [[self getHoursWithOpenTime:yesterdayLastOpen
                                                          closeTime:yesterdayLastClose
                                                             onDate:yesterdayDate]objectAtIndex:0];
        NSDate* yesterdayLastCloseDate = [[self getHoursWithOpenTime:yesterdayLastOpen
                                                           closeTime:yesterdayLastClose
                                                              onDate:yesterdayDate]objectAtIndex:1];
        
        if (([now compare:yesterdayLastOpenDate] == NSOrderedDescending) &&
            ([now compare:yesterdayLastCloseDate] == NSOrderedAscending))
        {
            restaurantObject.isOpenNow = TRUE;
            restaurantObject.closingNextSort = yesterdayLastCloseDate;
            restaurantObject.closingNextDisplay = [df stringFromDate:yesterdayLastCloseDate];
            
            NSTimeInterval timeUntilClose = abs([restaurantObject.closingNextSort timeIntervalSinceDate:now]);
            if (timeUntilClose < 1800)
            {
                //closing in < 30 mins
                restaurantObject.closingSoon = TRUE;
            }
            
            restaurantObject.whichTab = @"openNow";
            return restaurantObject;
        }
    }
    
    //See if restaurant is open during today's hour ranges (whether right now or later today)
    if ([hours objectForKey:todayDay])
    {
        NSArray* todayHourRanges = [hours objectForKey:todayDay];
        
        for (int i = 0; i < todayHourRanges.count; i++)
        {
            NSString* thisOpen = [[todayHourRanges objectAtIndex:i]objectAtIndex:0];
            NSString* thisClose = [[todayHourRanges objectAtIndex:i]objectAtIndex:1];
            NSDate* thisOpenDate = [[self getHoursWithOpenTime:thisOpen closeTime:thisClose onDate:now]objectAtIndex:0];
            NSDate* thisCloseDate = [[self getHoursWithOpenTime:thisOpen closeTime:thisClose onDate:now]objectAtIndex:1];
            
            //[11:00, 14:00],[14:00,17:00],[17:00,22:00],[22:00,2:00] it's now 15:00
            
            if ([now compare:thisCloseDate] == NSOrderedAscending)
            {
                if ([now compare:thisOpenDate] == NSOrderedDescending)
                {
                    //It's open now.
                    restaurantObject.isOpenNow = TRUE;
                    restaurantObject.closingNextSort = thisCloseDate;
                    restaurantObject.closingNextDisplay = [NSString stringWithFormat:@"Closing at %@",
                                                           [df stringFromDate:thisCloseDate]];
                    restaurantObject.whichTab = @"openNow";
                    
                    //See if the next opening time overlaps this closing time
                        //example: [["8:00","11:00","breakfast"],["11:00","14:00","lunch"]]
                        //Since 11:00 overlaps, we should not display that the restaurant is closing
                        //at 11am since it is really open still until 2pm.
                    for (int j = i; j < todayHourRanges.count; j++)
                    {
                        //As long as this isn't the last hour range for today
                        if (j < todayHourRanges.count - 1)
                        {
                            NSArray* thisRange = [todayHourRanges objectAtIndex:j];
                            NSString* thisRangeClose = [thisRange objectAtIndex:1];
                            
                            //Check whether closing time for this range == opening time for next range
                                //example: ["8:00","11:00","breakfast"],["11:00","14:00","lunch"] - 11:00 overlaps
                            NSArray* nextRange = [todayHourRanges objectAtIndex:j+1];
                            NSString* nextRangeOpen = [nextRange objectAtIndex:0];
                            NSString* nextRangeClose = [nextRange objectAtIndex:1];
                            
                            if ([thisRangeClose isEqualToString:nextRangeOpen])
                            {
                                restaurantObject.closingNextSort = [[self getHoursWithOpenTime:nextRangeOpen
                                                                                     closeTime:nextRangeClose
                                                                                        onDate:now]objectAtIndex:1];
                                restaurantObject.closingNextDisplay = [NSString stringWithFormat:@"Closing at %@",
                                                                       [df stringFromDate:restaurantObject.closingNextSort]];
                            }
                        }
                    }
                    
                    //See if it's closing within 30 mins
                    //to-do: make sure this is right time zone
                    NSTimeInterval timeUntilClose = abs([restaurantObject.closingNextSort timeIntervalSinceDate:now]);
                    if (timeUntilClose < 1800)
                    {
                        //closing in < 30 mins
                        restaurantObject.closingSoon = TRUE;
                    }
                    break;
                }
                else
                {
                    //It's not open now, but it's opening later today.
                    restaurantObject.isOpenNow = FALSE;
                    restaurantObject.openNextSort = thisOpenDate;                    
                    restaurantObject.openNextDisplay = [NSString stringWithFormat:@"Opening at %@", [df stringFromDate:thisOpenDate]];
                    restaurantObject.whichTab = @"openLater";
                    
                    //See if it's opening within 30 mins
                    //to-do: make sure this is right time zone
                    NSTimeInterval timeUntilOpen = abs([restaurantObject.openNextSort timeIntervalSinceDate:now]);
                    if (timeUntilOpen < 1800)
                    {
                        //opening in < 30 mins
                        restaurantObject.openingSoon = TRUE;
                    }
                    break;
                }
            }
        }
    }
    else
    {
        //not open at all during today's hour ranges (but may be open within last night's last hour range)
    }
    
    return restaurantObject;
}
@end
