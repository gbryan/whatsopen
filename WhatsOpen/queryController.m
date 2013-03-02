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
            at same time, issue query to G for closest 40 restaurants (2 pages) (this can run in background while Factual results are displayed to user)
        check G results to see which are open
            if a restaurant is open,
                [self matchRestaurantWithName:(NSString *)fullName streetAddress:(NSString *)address]
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
    if outside the US, issue restaurants query to Google to get 20 closest restaurants
        show which are open now (can’t show open later since G doesn’t give hours)
        show only G supplied details since F has no international data in restaurants table
 
 Why do we need data from both Factual and Google?
 - bc only Google has photos
 - bc Google may know that some are open that F doesn't know are open
 - bc Google has international data, whereas F doesn't for restaurants
 
 We get the Factual results immediately (for closest 50 restaurants, filtering those results by the ones that are open now or later today). When should we get Google results?
 - Several options:
        - Simultaneously. Load F results into one array and G results into another. Compare the arrays to match results and see if G's list has any known to be open that F doesn't know are open (G won't have any hours for most restaurants but will have the open_now value for most).
            - problems: G is pulling only 20 results, so there are already a lot that won't match Factual. We only have G data for maybe 12-15 of the F results (maybe 25-30 with known hours).
        - Simultaneously. Load F results into one array. Query G and get all 3 pages of available nearby restaurants, which will take 5 seconds (need to wait 2.5 seconds to be sure the page_token is active). Load these into separate array. Match up the F and G restaurantObjects and fill in the openNow and openLater arrays with the combination of F and G data (use F data if available, and use G to fill in only the missing F data. If F says it's closed but G says it's open, then it's open. Use G's photo reference to add to F restaurantObject so that we can load photo in the detail view).
            -problems: 5 seconds (plus at least 1 more second to process the matches and fill in additional info) is a really long time to wait.  Also, we don't need the majority of the data from Google (only open_now if the key exists for that restaurant and == TRUE) until the user taps on a restaurant and needs to see the detailed info.  
        - Simultaneously. Load F results into the only array that we'll use (_restaurants), but specify isOpenNow == TRUE or == FALSE. Change listVC's tableview to display based on this.   Display the tableview for the user to see the results.  Meanwhile, Google's query (all 3 pages) is running in the background (best performance while running that on another thread so as to not make user interaction with scrolling the tableview results slow???).  G results are loaded into separate array and compared with F results.  Since all of this is happening with the instances of _restaurants and _googleResults that were initialized by queryController instead of listViewController, the changing data will be separate in memory than the data from Factual that the user is currently viewing in the tableview.  The combined results are loaded into _restaurants.  queryController notifies listViewController to update its instance of _restaurants array. It does so, which causes a problem bc we now have a mismatch bw the data in the tableview data source and the actual results displaying in the tableview (we haven't reloaded the tableview results, only the array that provides the data for the tableview). If the user taps the restaurant in row 3 (for example) of the tableview, row 3 may not be Top of the Hill anymore (since the array was updated); it may be Pepper's Pizza, so they will then see the details page for Pepper's Pizza.
            -problems: this is getting ugly really fast...
        - Only when a user taps on an individual restaurant listing from Factual.  All results in tableview are solely Factual results (if within U.S.). Tapping on an individual listing initiates a query to Google Places to find that restaurant (
 
 New idea:
 - Since I don't have many results after filtering by which are open now or later (my results have to have data for the hours key), I could use Factual's paging (offset param) to get up to 500 results (each set of 50 results costs 1 access, and I have 10,000 per day and 300 per minute).
 - Split open now and open later into tabs instead of tableview sections. When a user scrolls to the bottom of the results in either tab, the next 50 results are requested from Factual to add more rows to the table with fadeIn animation.
 - Once user clicks/taps a specific row, I still need to request photo(s) from Google to display in the detailview.
 
 if user wants food of a particular cuisine or something, we can issue a more specific query by cuisine, sorted by proximity, and then check which are open now and later to display new results.  Better to issue new query than filter only my small number of existing results.

 Google's "reference" parameter for a given restaurant is not necessarily the same in subsequent requests!
 
 
 to-do: determine whether restaurants are closing or opening "soon" (maybe within 30 mins since Factual doesn't seem to be more granular than 30 mins)
 
 
 Does Google really return the closest 20 restaurants to wherever you are, or does it give you only those within some radius (even when you don't specify radius)?  If it really searches for closest 20, I should fall back to Google query if Factual doesn't find any results within 500 meters).
 
 With each Factual query, save included_rows value and check if it is < 50.  If < 50, there is not another set of results to acquire.
 
 */


#import "queryController.h"

@implementation queryController
{
    locationServices *_locationService;
    FactualAPIRequest *_activeRequest;
    FactualQuery *_queryObject;
    NSInteger _pageNum;
    CLLocationCoordinate2D _deviceLocation;
    NSMutableArray *_restaurants;
}
@synthesize queryCategories;
@synthesize openNow;
@synthesize openLater;
@synthesize hoursUnknown;
@synthesize farthestPlaceString;
@synthesize detailRestaurant;
@synthesize lastResultWasNull;

-(id)init
{
    NSLog(@"initializing queryController");
    _locationService = [[locationServices alloc]init];
    _restaurants = [[NSMutableArray alloc]init];
    lastResultWasNull = FALSE;
    
    //We initialize these only on queryController init (not with each run of a query) so that we can append newly acquired results to these arrays when running the arrays subsequent times.  Since queryController is re-initialized each time I click a different listView tab, arrays will be cleaned out when switching from one tab to the other, but scrolling to the bottom of the list in one tab will trigger a query for more results in queryController, which will APPEND new results to the already initialized arrays.
    openNow = [[NSMutableArray alloc]init];
    openLater = [[NSMutableArray alloc]init];
    hoursUnknown = [[NSMutableArray alloc]init];
    
    return self;
}

-(restaurant *)matchRestaurantWithName:(NSString *)fullName streetAddress:(NSString *)address
{
    /*
     parse restaurant full name to find first significant word (not “a”, “an,” or “the”)
     get only the street number from the address
     for each restaurant in _restaurants (added by Factual):
     parse name
     get street num
     see if G restaurant nameBeginning IN explodedFactualName
     see if G restaurant streetNum == first GRestaurantStreetNum.length chars of F restaurant
     return the matched restaurant or nil
     */
    
    
    
    //filter Factual results by the street number of the Google-supplied address
}

-(NSString *)getStreetNumberFromFullAddress:(NSString *)address
{
    NSArray *addressParts = [address componentsSeparatedByString:@" "];
    NSString *streetNumber = [addressParts objectAtIndex:0];
    return streetNumber;
}

-(NSString *)getFirstSignificantWordInRestaurantName:(NSString *)restaurantName
{
    //clean restaurant name from Google before using the name to search Factual
    NSString *queryString = restaurantName;
    queryString = [queryString lowercaseString];
    queryString = [queryString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    queryString = [queryString stringByReplacingOccurrencesOfString:@" & " withString:@" "];
    NSArray *restaurantNameExploded = [queryString componentsSeparatedByString:@" "];
    
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

-(void)refreshRestaurants
{
    _deviceLocation = [_locationService getCurrentLocation];
    
    //these categories are for Google
//    queryCategories = [NSArray arrayWithObjects:@"cafe", @"restaurant", @"bakery", nil];
    //    queryCategories = [NSArray arrayWithObjects:@"bar", nil];
    _restaurants = [[NSMutableArray alloc]init];
    openNow = [[NSMutableArray alloc]init];
    openLater = [[NSMutableArray alloc]init];
    hoursUnknown = [[NSMutableArray alloc]init];
    
    //set pg to 1 since initial Google Places query will pull the 1st page of results
//    _pageNum = 1;
    
//    _numberOfResultsToCheck = 0;
//    _waitForMoreResults = FALSE;
    
    [self queryFactualForRestaurantsNearLatitude:_deviceLocation.latitude longitude:_deviceLocation.longitude withOffset:0];

//    [self queryGooglePlacesWithTypes:queryCategories nextPageToken:nil];
}

-(void)appendNewRestaurants
{
    //to-do: make sure that when restaurants are appended to bottom of list in any tab, the data source array is sorted such that
    //all new results are added to the bottom of the list instead of somewhere else in the list in the listView
    
    //If the last Factual query had 50 results, we can assume it's safe to query for the next set of 50. If < 50 returned last time, then there are no more results to acquire.
    //to-do: what if Factual has exactly some multiple of 50 # of results? This will eval to true, but there are still no results to get.  Do I really need to check this, or can I just run the query anyway and then let it return 0 rows?
    
    //We will not re-initialize the arrays becuase we want to just add more restaurants to the lists
    _deviceLocation = [_locationService getCurrentLocation];
    
    NSInteger offset = [_restaurants count];
    
    //Don't run the query if there are already 500 restaurants acquired because Factual provides a max of 500, and the query will return an error.
    if (offset < 500)
    {
        [self queryFactualForRestaurantsNearLatitude:_deviceLocation.latitude longitude:_deviceLocation.longitude withOffset:offset];
    }
    //    [self queryGooglePlacesWithTypes:queryCategories nextPageToken:nil];
}

-(void)getGoogleMatchForRestaurant:(restaurant *)restaurantObject
{
    NSString *restaurantQueryName = [self getFirstSignificantWordInRestaurantName:restaurantObject.name];
    NSString *restaurantAddress = [restaurantObject.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *googleURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=110&name=%@&vicinity=%@&sensor=true&key=%@",
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
    }
    else
    {
        [self fetchedGoogleRestaurantDetails:googleQueryData];
    }
}

-(void)getRestaurantDetail:(restaurant *)restaurantObject
{
    detailRestaurant = restaurantObject;
    [self getGoogleMatchForRestaurant:restaurantObject];
}

-(void)getGoogleImageForRestaurantWithReference:(NSString *)photoReference
{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=150&photoreference=%@&sensor=true&key=%@", photoReference, GOOGLE_API_KEY];
    
    NSLog(@"photo request: %@", url);
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    NSData* restaurantImageRequestData = [NSData dataWithContentsOfURL: googleRequestURL];
    if (!restaurantImageRequestData)
    {
        //occasionally, data is nil, and the app crashes if I don't check !data
        //just start the query over again if data is nil for some reason
        //        [self getRestaurants];
        NSLog(@"googleQueryData was invalid for some reason. Oops.");
    }
    else
    {
        [self acquiredGoogleRestaurantImage:restaurantImageRequestData];
    }
}

-(void)acquiredGoogleRestaurantImage:(NSData *)responseData
{
    UIImage *restaurantImage = [UIImage imageWithData:(NSData *)responseData];
    detailRestaurant.image = restaurantImage;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantDetailsAcquired"
                                                        object:nil];
}

- (void)fetchedGoogleRestaurantDetails:(NSData *)responseData
{
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray *restaurantResults = [json objectForKey:@"results"];
    
    //if Google returned a result
    if ([restaurantResults count] > 0)
    {
        NSDictionary *restaurantDetails = [restaurantResults objectAtIndex:0];
    
        //Google's address information appears to be more accurate than Factual's in some cases, so I'll use it.
        //to-do: need to provide attribution to Google on placeDetailVC if I do this
        detailRestaurant.address = [restaurantDetails objectForKey:@"vicinity"];
        detailRestaurant.googleID = [restaurantDetails objectForKey:@"reference"];
        
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
- (void)queryFactualForRestaurantsNearLatitude:(float)lat longitude:(float)lng withOffset:(NSInteger)offset
{        
        _queryObject = [FactualQuery query];
        
        _queryObject.limit = 50;
    
        if (offset > 0) _queryObject.offset = offset;
    
        FactualSortCriteria* proximitySort = [[FactualSortCriteria alloc]
                                              initWithFieldName:@"$distance"
                                              sortOrder:FactualSortOrder_Ascending];
        [_queryObject setPrimarySortCriteria:proximitySort];
    
//        [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" search:@"bar"]];
    
        CLLocationCoordinate2D geoFilterCoords = {
            lat, lng
        };
        [_queryObject setGeoFilter:geoFilterCoords radiusInMeters:500.0];
        
        //execute the Factual request
        _activeRequest = [[UMAAppDelegate getAPIObject] queryTable:@"restaurants" optionalQueryParams:_queryObject withDelegate:self];
    }

# pragma mark - Factual request complete
-(void) requestComplete:(FactualAPIRequest *)request receivedQueryResult:(FactualQueryResult *)queryResultObj
{
    _queryResult = queryResultObj;
    
    if (_queryResult.rowCount < 1)
    {
        lastResultWasNull = TRUE;
    }
    else
    {
        lastResultWasNull = FALSE;
    }
    
    //check each restaurant retrieved from Factual
    for (int i=0; i < _queryResult.rowCount; i++)
    {
        restaurant *restaurantObject = [[restaurant alloc]init];
        BOOL addedAlready = FALSE;
        
        //run only if we have a valid response from Factual
        if ((_queryResult != nil) &&
            ([_queryResult.rows objectAtIndex:i] != nil))
        {
            FactualRow *row = [_queryResult.rows objectAtIndex:i];
            
            //calculate proximity of mobile device to the restaurant
            float lat = [[row valueForName:@"latitude"]floatValue];
            float lng = [[row valueForName:@"longitude"]floatValue];
            NSString *proximity = [NSString stringWithFormat:@"%.2f miles",
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
                restaurantObject.rating = [NSString stringWithFormat:@"%.1f",[[row valueForName:@"rating"]floatValue]];
            }
            else
            {
                restaurantObject.rating = @"";
            }
            if ([row valueForName:@"price"]) restaurantObject.priceLevel = [[row valueForName:@"price"]integerValue];
            if ([row valueForName:@"tel"])
            {
                NSString *phoneNumber = [row valueForName:@"tel"];
                NSString *numbersOnly = [[phoneNumber componentsSeparatedByCharactersInSet:
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
                    //Get hours in pretty format to display in detail modal view
                    NSArray *daysOfWeek = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
                    NSString *hoursFormattedForTextView = [[NSString alloc]init];
                    for (NSString *day in daysOfWeek)
                    {
                        NSString *hoursStringForDay = [[NSString alloc]init];
                        
                        NSString *dayToSearch = [day lowercaseString];
                        if ([hours objectForKey:dayToSearch])
                        {
                            NSString *dayInfoToAdd = [NSString stringWithFormat:@"%@:\r",[day capitalizedString]];
                            NSString *allOpenTimes = [[NSString alloc]init];
                            NSArray *hoursArraysThisDay = [hours objectForKey:dayToSearch];
                            // hoursArray is something like ["10:00","14:00", "BRUNCH"]
                            for (NSArray *hoursArray in hoursArraysThisDay)
                            {                                
                                NSDateFormatter *dateFormatterOriginal = [[NSDateFormatter alloc]init];
                                [dateFormatterOriginal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                                [dateFormatterOriginal setDateFormat:@"HH:mm"];
                                NSDate *openTimeDate = [dateFormatterOriginal dateFromString:[hoursArray objectAtIndex:0]];
                                NSDate *closeTimeDate = [dateFormatterOriginal dateFromString:[hoursArray objectAtIndex:1]];

                                NSDateFormatter *dateFormatterDisplay = [[NSDateFormatter alloc]init];
                                [dateFormatterDisplay setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                                [dateFormatterDisplay setDateFormat:@"hh:mm a"];
                                NSString *open = [dateFormatterDisplay stringFromDate:openTimeDate];
                                NSString *close = [dateFormatterDisplay stringFromDate:closeTimeDate];
                                NSString *openTimes = [NSString stringWithFormat:@"\t %@ - %@", open, close];
                                
                                //If there's a comment such as "BRUNCH" above
                                if (hoursArray.count > 2)
                                {
                                    NSString *comment = [[hoursArray objectAtIndex:2]capitalizedString];
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
                                
                            }// end for each set of hours this day
                            hoursStringForDay = [dayInfoToAdd stringByAppendingString:allOpenTimes];
                        }
                        hoursFormattedForTextView = [hoursFormattedForTextView stringByAppendingString:hoursStringForDay];
                    }
                    restaurantObject.openHours = hoursFormattedForTextView;
                    
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
                        BOOL restaurantIsOpen = [self restaurantWithOpeningHoursRange:lastHourRangeFromYesterday
                                                                               onDate:yesterdayDate
                                                                         isOpenAtTime:dateTimeInSystemLocalTimezone];
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
                            [_restaurants addObject:restaurantObject];
                            addedAlready = TRUE;
                            //Don't check any more hours for this restaurant becuase we already know that it's open from last night
                            break;
                        }
                    } //end if open yesterday
                    
                    // Is the restaurant open today? (not just from yesterday's hours carrying over to today)
                    NSArray *todayHours = [hours objectForKey:dayToday];
                    
                    // If we know it's open from last night still, don't bother checking if it's open now based on today's hours
                    if ((todayHours.count > 0) &&
                        (addedAlready == FALSE))
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
                                [_restaurants addObject:restaurantObject];
                                addedAlready = TRUE;
                                break;
                            }
                            else if (restaurantIsOpen == FALSE)
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
                                    restaurantObject.openNextDisplay = [NSString stringWithFormat:@"Opens %@", openNextString];
                                    restaurantObject.openNextSort = openTimeDate;
                                    [openLater addObject:restaurantObject];
                                 
                                    //to-do: does sorting work now with custom object?
                                                                        
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
//                NSLog(@"%@ has no value for hours key", restaurantObject.name);
            }
            if (addedAlready == FALSE)
            {
                [_restaurants addObject:restaurantObject];
            }
        } //end if !empty query result
    } //end for loop to check each restaurant result

    //Re-sort by proximity
    NSSortDescriptor *sortByProximity = [NSSortDescriptor sortDescriptorWithKey:@"proximity" ascending:YES];
    [openNow sortUsingDescriptors:[NSArray arrayWithObject:sortByProximity]];
    
    //re-sort by opening soonest
    NSSortDescriptor *sortByOpeningSoonest = [NSSortDescriptor sortDescriptorWithKey:@"openNextSort" ascending:YES];
    [openLater sortUsingDescriptors:[NSArray arrayWithObject:sortByOpeningSoonest]];

    [self calculateFarthestRestaurant];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantsAcquired"
                                                            object:nil];
    NSLog(@"number open now: %i", [openNow count]);
    NSLog(@"number open later: %i", [openLater count]);
    NSLog(@"number of _restaurants: %i", [_restaurants count]);
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

-(void)calculateFarthestRestaurant
{
    //Find farthest restaurant to display message to user: "Restaurants within x.x miles"
    
    //Re-sort _restaurants, which has all restaurants in query results (even those not open).
    NSSortDescriptor *sortByDistance = [NSSortDescriptor sortDescriptorWithKey:@"proximity" ascending:YES];
    [_restaurants sortUsingDescriptors:[NSArray arrayWithObject:sortByDistance]];
    
    //Currently in this format: x.xx miles
    NSString *farthest = [[_restaurants lastObject] proximity];
    
    farthestPlaceString = [NSString stringWithFormat:@"Restaurants within %@", farthest];
}
@end
