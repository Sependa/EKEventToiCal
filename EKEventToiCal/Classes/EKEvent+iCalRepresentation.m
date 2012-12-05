//
//  Category.m
//  EKEventToiCal
//
//  Created by Dan Willoughby on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EKEvent+iCalRepresentation.h"

NSString *partstatParamForEKParticipantStatus(EKParticipantStatus status);

NSString *cutypeParamForEKParticipantType(EKParticipantType type);

NSString *roleParamForEKParticipantRole(EKParticipantRole role);

@implementation EKEvent (iCalRepresentation)

- (NSString *)genRandStringLength {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int len = 36;
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    
    for (int i = 0; i < len; i++) {
        [randomString appendFormat:@"%c", [letters characterAtIndex:(rand() % [letters length])]];
        
    }
    
    NSString *c = [randomString substringWithRange:NSMakeRange(0, 8)];
    NSString *d = [randomString substringWithRange:NSMakeRange(8, 4)];
    NSString *e = [randomString substringWithRange:NSMakeRange(12, 4)];
    NSString *f = [randomString substringWithRange:NSMakeRange(16, 4)];
    NSString *g = [randomString substringWithRange:NSMakeRange(20, 12)];
    
    NSMutableString *stringWithDashes = [NSMutableString string];
    
    [stringWithDashes appendFormat:@"%@-%@-%@-%@-%@", c, d, e, f, g];
    
    return stringWithDashes;
}

- (NSMutableString *)iCalRepresentation {
    
    
    NSMutableString *iCalRepresentationString = [NSMutableString string];
    
    
    //The first line must be "BEGIN:VCALENDAR"
    [iCalRepresentationString appendString:@"BEGIN:VCALENDAR"];
    [iCalRepresentationString appendString:@"\r\nVERSION:2.0"];
    
    
    
    //calendar
    
    if (self.calendar.title) {
        //[iCalRepresentationString appendFormat:@"\r\nX-WR-CALNAME:%@",self.calendar.title];
    }
    
    
    //  CGColorRef blah = self.calendar.CGColor;
    // NSLog(@"********************* = %@",blah);
    
    
    //X-WR-CALNAME:Untitled 2 -----calendar's Title ical
    //X-APPLE-CALENDAR-COLOR:#F57802 -----calendar color ical
    
    
    
    
    
    //Event Start Date
    [iCalRepresentationString appendString:@"\r\nBEGIN:VEVENT"];
    
    //allDay
    if (self.allDay) {
        
        NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
        [format1 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [format1 setDateFormat:@"yyyyMMdd"];
        NSString *allDayDate = [format1 stringFromDate:self.startDate];
        
        [iCalRepresentationString appendFormat:@"\r\nDTSTART;VALUE=DATE:%@", allDayDate];
        
        //get startdate and add 1 day for the end date.
        NSDate *addDay = [self.startDate dateByAddingTimeInterval:86400];
        NSString *allDayEnd = [format1 stringFromDate:addDay];
        
        [iCalRepresentationString appendFormat:@"\r\nDTEND;VALUE=DATE:%@", allDayEnd];
        [format1 release];
        
        
    }
    
    else {
        
        if (self.startDate && self.endDate) {
            [iCalRepresentationString appendString:@"\r\nDTSTART;TZID=Etc/UTC:"];
            
            NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
            [format2 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [format2 setDateFormat:@"yyyyMMdd'T'HHmmss"];
            
            NSString *dateAsString = [format2 stringFromDate:self.startDate];
            [iCalRepresentationString appendString:dateAsString];
            //end date
            
            [iCalRepresentationString appendString:@"\r\nDTEND;TZID=Etc/UTC:"];
            
            NSString *dateAsString1 = [format2 stringFromDate:self.endDate];
            
            [iCalRepresentationString appendString:dateAsString1];
            
            [format2 release];
            
        }
        else {
            NSLog(@"****Error****Missing one of needed values: startDate or endDate");
        }
    }
    
    NSDateFormatter *format3 = [[NSDateFormatter alloc] init];
    [format3 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [format3 setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    
    if (self.creationDate) {
        [iCalRepresentationString appendString:@"\r\nDTSTAMP:"];    //date the event was created
        
        NSString *dateAsString2 = [format3 stringFromDate:self.creationDate];
        [iCalRepresentationString appendString:dateAsString2];
    }
    
    //lastModifiedDate
    if (self.lastModifiedDate) {
        
        [iCalRepresentationString appendString:@"\r\nLAST-MODIFIED:"];
        
        NSString *dateAsString2 = [format3 stringFromDate:self.lastModifiedDate];
        [iCalRepresentationString appendString:dateAsString2];
        
    }
    [format3 release];
    //UID is generated randomly
    NSString *a = [self genRandStringLength];
    [iCalRepresentationString appendFormat:@"\r\nUID:%@0000000000000000000", a];
    
    
    
    //attendees @TODO: The property is read-only and cannot be modified so this is not complete or tested
    
    for (EKParticipant *attend in self.attendees) {
        [iCalRepresentationString appendString:@"\r\nATTENDEE"];
        [self appendParticipant:attend toICalString:iCalRepresentationString];
    }
    
    //availability @TODO:    The property is read-only and cannot be modified so this is not complete or tested
    if (self.availability == EKEventAvailabilityFree) {
        [iCalRepresentationString appendString:@"\r\nTRANSP:TRANSPARENT"];
    }
    else {
        [iCalRepresentationString appendString:@"\r\nTRANSP:OPAQUE"];
    }
    
    //eventIdentifier @TODO: The property is read-only and cannot be modified so this is not complete or tested
    
    //isDetached @TODO: The property is read-only and cannot be modified so this is not complete or tested
    
    //location
    if (self.location) {
        [iCalRepresentationString appendFormat:@"\r\nLOCATION:%@", self.location];
    }
    
    //organizer @TODO: The property is read-only and cannot be modified so this is not complete or tested
    if (self.organizer != nil) {
        [iCalRepresentationString appendString:@"\r\nORGANIZER"];
        [self appendParticipant:self.organizer toICalString:iCalRepresentationString];
    }
    
    //recurrenceRule
    if ([self respondsToSelector:@selector(recurrenceRules)]) {
        for (EKRecurrenceRule *rule in self.recurrenceRules) {
            NSString *recurrenceString = [rule description];
            NSArray *partsArray = [recurrenceString componentsSeparatedByString:@"RRULE "];
            
            if ([partsArray count] > 1) {
                NSString *secondHalf = [partsArray objectAtIndex:1];
                // int loc = [secondHalf rangeOfString:@"Z"].location;
                //if (loc > 0) {
                //   return [secondHalf substringToIndex:loc];
                [iCalRepresentationString appendFormat:@"\r\nRRULE:%@", secondHalf];
            }
        }
    }
    
    //When a calendar component is created, its sequence number is zero
    [iCalRepresentationString appendString:@"\r\nSEQUENCE:0"];
    
    //status
    if (self.status == 1) {
        [iCalRepresentationString appendString:@"\r\nSTATUS:CONFIRMED"];
    }
    if (self.status == 2) {
        [iCalRepresentationString appendString:@"\r\nSTATUS:TENTATIVE"];
    }
    if (self.status == 3) {
        [iCalRepresentationString appendString:@"\r\nSTATUS:CANCELLED"];
    }
    
    //Event Title
    if (self.title) {
        [iCalRepresentationString appendFormat:@"\r\nSUMMARY:%@", self.title];
    }
    
    //Notes
    if (self.notes) {
        [iCalRepresentationString appendFormat:@"\r\nDESCRIPTION:%@", self.notes];
    }
    
    //Alarm
    for (EKAlarm *alarm in self.alarms) {
        [iCalRepresentationString appendString:@"\r\nBEGIN:VALARM"];
        [iCalRepresentationString appendString:@"\r\nACTION:DISPLAY"];//a message(usually the title of the event) will be displayed
        //        [iCalRepresentationString appendString:@"\r\nDESCRIPTION:event reminder"]; //notes with the alarm--not the message.
        
        if (alarm.absoluteDate) {
            
            NSDateFormatter *format3 = [[NSDateFormatter alloc] init];
            [format3 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [format3 setDateFormat:@"yyyyMMdd'T'HHmmss"];
            
            NSString *dateAsString3 = [format3 stringFromDate:alarm.absoluteDate];
            [format3 release];
            
            [iCalRepresentationString appendFormat:@"\r\nTRIGGER;VALUE=DATE-TIME:%@", dateAsString3];
            
        }
        if (alarm.relativeOffset) {
            
            //converts offset to D H M S then appends it to iCalRepresentationString
            NSInteger offset = alarm.relativeOffset;
            int i = offset * -1;
            
            int day = i / (24 * 60 * 60);
            i = i % (24 * 60 * 60);
            
            int hour = i / (60 * 60);
            i = i % (60 * 60);
            
            int minute = i / 60;
            i = i % 60;
            
            int second = i;
            
            [iCalRepresentationString appendFormat:@"\r\nTRIGGER:-P"];
            
            if (day != 0) {
                
                [iCalRepresentationString appendFormat:@"%dD", day];
                
            }
            if (hour || minute || second != 0) {
                [iCalRepresentationString appendString:@"T"];
                
                if (hour != 0) {
                    
                    [iCalRepresentationString appendFormat:@"%dH", hour];
                    
                }
                if (minute != 0) {
                    
                    [iCalRepresentationString appendFormat:@"%dM", minute];
                    
                }
                if (second != 0) {
                    
                    [iCalRepresentationString appendFormat:@"%dS", second];
                    
                }
            }
        }
        NSString *b = [self genRandStringLength];
        
        [iCalRepresentationString appendFormat:@"\r\nX-WR-ALARMUID:%@", b];
        
        [iCalRepresentationString appendString:@"\r\nEND:VALARM"];
        
    }
    
    [iCalRepresentationString appendString:@"\r\nEND:VEVENT"];
    
    //The last line must be "END:VCALENDAR"
    [iCalRepresentationString appendString:@"\r\nEND:VCALENDAR"];
    
    return [[iCalRepresentationString copy] autorelease];
}

- (void)appendParticipant:(EKParticipant *)participant toICalString:(NSMutableString *)iCalString {
    if (participant.name) {
        [iCalString appendFormat:@";CN=%@", participant.name];
    }
    
    //@TODO:this is not complete
    NSString *participantStatus = partstatParamForEKParticipantStatus(self.organizer.participantStatus);
    if (participantStatus) {
        [iCalString appendFormat:@";PARTSTAT=%@", participantStatus];
    }
    
    //@TODO:this is not complete
    NSString *participantType = cutypeParamForEKParticipantType(self.organizer.participantType);
    if (participantType) {
        [iCalString appendFormat:@";CUTYPE=%@", participantType];
    }
    
    //@TODO:this is not complete
    NSString *participantRole = roleParamForEKParticipantRole(self.organizer.participantRole);
    if (participantRole) {
        [iCalString appendFormat:@";ROLE=%@", participantRole];
    }
    
    if (participant.URL) {
        NSString *participantURL = [participant.URL absoluteString];
        if ([participantURL hasPrefix:@"mailto:"]) {
            NSString *emailString = [participantURL stringByReplacingOccurrencesOfString:@"mailto:"
                                                                              withString:@""];
            [iCalString appendFormat:@";MAILTO=%@", emailString];
        }
    }
}

#pragma mark - Helpers

NSString *partstatParamForEKParticipantStatus(EKParticipantStatus status) {
    NSString *partstatParam = nil;
    switch (status) {
        case EKParticipantStatusUnknown:
            partstatParam = nil;
            break;
        case EKParticipantStatusPending:
            partstatParam = @"NEEDS-ACTION";
            break;
        case EKParticipantStatusAccepted:
            partstatParam = @"ACCEPTED";
            break;
        case EKParticipantStatusDeclined:
            partstatParam = @"DECLINED";
            break;
        case EKParticipantStatusTentative:
            partstatParam = @"TENTATIVE";
            break;
        case EKParticipantStatusDelegated:
            partstatParam = @"DELEGATED";
            break;
        case EKParticipantStatusCompleted:
            partstatParam = @"COMPLETED";
            break;
        case EKParticipantStatusInProcess:
            partstatParam = @"IN-PROCESS";
            break;
    }
    return partstatParam;
}

NSString *cutypeParamForEKParticipantType(EKParticipantType type) {
    NSString *cutypeParam = nil;
    switch (type) {
        case EKParticipantTypeUnknown:
            cutypeParam = @"UNKNOWN";
            break;
        case EKParticipantTypePerson:
            cutypeParam = @"INDIVIDUAL";
            break;
        case EKParticipantTypeRoom:
            cutypeParam = @"ROOM";
            break;
        case EKParticipantTypeResource:
            cutypeParam = @"RESOURCE";
            break;
        case EKParticipantTypeGroup:
            cutypeParam = @"GROUP";
            break;
    }
    return cutypeParam;
}

NSString *roleParamForEKParticipantRole(EKParticipantRole role) {
    NSString *roleParam = nil;
    switch (role) {
        case EKParticipantRoleUnknown:
            roleParam = nil;
            break;
        case EKParticipantRoleRequired:
            roleParam = @"REQ-PARTICIPANT";
            break;
        case EKParticipantRoleOptional:
            roleParam = @"OPT-PARTICIPANT";
            break;
        case EKParticipantRoleChair:
            roleParam = @"CHAIR";
            break;
        case EKParticipantRoleNonParticipant:
            roleParam = @"NON-PARTICIPANT";
            break;
    }
    return roleParam;
}

@end
