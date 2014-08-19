//
//  PayPalConfig.m
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/5/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "PayPalConfig.h"

static NSString *kSandboxClientId = @"ARmjaBDYxJcXYErMEQdaCnvE5h4vgYxtS9XJo7OTi_ZohebxT7qvMsC-1Vml";
static NSString *kProductionClientId = @"Add Production key here for ASha";

@implementation PayPalConfig

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (id)sharedConfig {
    static PayPalConfig *sharedMyConfig = nil;
    @synchronized(self) {
        if (sharedMyConfig == nil)
            sharedMyConfig = [[self alloc] init];
    }
    return sharedMyConfig;
}

- (void) setupForTakingPayments{
    
    
    self.payPalConfig = [[PayPalConfiguration alloc] init];
    self.payPalConfig.acceptCreditCards = YES;
    self.payPalConfig.languageOrLocale = @"en";
    self.payPalConfig.merchantName = @"AshaNet.Org";
    self.payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    self.payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    self.payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    // use default environment, should be Production in real life
    self.environment = kPayPalEnvironment;
    
    NSDictionary *keys =  @{PayPalEnvironmentProduction : kProductionClientId,
                            PayPalEnvironmentSandbox : kSandboxClientId};
    
    [PayPalMobile initializeWithClientIdsForEnvironments:keys];
    
    // Preconnect to PayPal early
    [PayPalMobile preconnectWithEnvironment:self.environment];

}


@end
