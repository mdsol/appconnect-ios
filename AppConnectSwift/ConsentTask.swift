//
//  ConsentTask.swift
//  AppConnectSwift
//
//  Created by Adam Godel on 9/30/16.
//  Copyright © 2016 Medidata Solutions. All rights reserved.
//

import ResearchKit

public var ConsentTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    var consentDocument = ConsentDocument
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    steps += [visualConsentStep]
    
    let signature = consentDocument.signatures!.first! as ORKConsentSignature
    
    let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, inDocument: consentDocument)
    
    reviewConsentStep.text = "Review Consent!"
    reviewConsentStep.reasonForConsent = "Consent to join study"
    
    steps += [reviewConsentStep]
    
    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
