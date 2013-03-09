//
//  factualCorrectionsController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/9/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "factualCorrectionsController.h"

@implementation factualCorrectionsController
{
    NSString *username;
    NSString *table;
}

@synthesize problemTypeRowLabels;


-(id)init
{
    username = @"gbryan";
    table = @"restaurants";
    
    //These are the problem types that users can flag entries with in selectProblemVC
    problemTypeRowLabels = [[NSArray alloc]initWithObjects:
                            @"Out of Business",
                            @"Duplicate Entry",
                            @"Classified Wrong",
                            @"Fictitious Entry",
                            @"Spam",
                            @"Inaccurate Information",
                            @"Other",
                            nil];
    return self;
}

-(void)flagRestaurantWithID:(NSString *)factualID problemType:(NSInteger)problemType comment:(NSString *)comment reference:(NSString *)reference
{
    NSLog(@"begin submitting correction");
    NSLog(@"--------------------------");
    NSLog(@"id: %@    comment:%@    reference:%@", factualID, comment, reference);
    
    NSInteger factualProblemType = -1;
    
    //Translate my problem type labels to Factual's problem types
    switch (problemType)
    {
        case 0:
            //submit to factual that the restaurant is out of business
            [self submitClosedRestaurantWithID:factualID comment:comment reference:reference];
            break;
        case 1:
            factualProblemType = FactualFlagType_Duplicate;
            break;
        case 2:
            factualProblemType = FactualFlagType_Inappropriate;
            break;
        case 3:
            factualProblemType = FactualFlagType_Nonexistent;
            break;
        case 4:
            factualProblemType = FactualFlagType_Spam;
            break;
        case 5:
            factualProblemType = FactualFlagType_Inaccurate;
            break;
        case 6:
            factualProblemType = FactualFlagType_Spam;
            break;
    }
    
    NSLog(@"problem: %d", factualProblemType);
    
    if (factualProblemType != -1)
    {
        FactualRowMetadata *flagMetadata = [FactualRowMetadata metadata:username];
        if ([comment length] > 0) flagMetadata.comment = comment;
        if ([reference length] > 0) flagMetadata.reference = reference;
        self.apiRequest = [[UMAAppDelegate getAPIObject] flagProblem:FactualFlagType_Inaccurate tableId:table factualId:factualID metadata:flagMetadata withDelegate:self];
        //Even though the request hasn't completed, the user can't do anything about it if it fails,
        //so just thank them for trying.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"correctionSubmitted"
                                                            object:nil];
    }
}

//Some problem types can be submitted to Factual as flags, but if a business is closed/out of business,
//you must submit it to Factual as status=0 instead of flagging it.
-(void)submitClosedRestaurantWithID:(NSString *)factualId comment:(NSString *)comment reference:(NSString *)reference
{
    FactualRowMetadata *metadata = [FactualRowMetadata metadata:username];
    if ([comment length] > 0) metadata.comment = comment;
    if ([reference length] > 0) metadata.reference = reference;
    
    //setting status=0 for a business on Factual means that it's closed/out of business
    NSMutableDictionary *values = [[NSMutableDictionary alloc]init];
    [values setValue:@"0" forKey:@"status"];
    
    self.apiRequest = [[UMAAppDelegate getAPIObject] submitRowWithId:factualId tableId:table withValues:values withMetadata:metadata withDelegate:self];
    
    //Even though the request hasn't completed, the user can't do anything about it if it fails,
    //so just thank them for trying.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"correctionSubmitted"
                                                        object:nil];
}

-(void)requestComplete:(FactualAPIRequest *)request receivedRawResult:(NSDictionary *)result
{
    NSLog(@"requestComplete: %@", result);
}

-(void)requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    NSLog(@"Factual request FAILED with error: ");
    NSLog(@"%@", [error localizedDescription]);
    
}

@end
