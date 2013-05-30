//
//  NSObject+Introspector.m
//  Introspector
//
//  Created by Danis Tazetdinov on 30.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "NSObject+Introspector.h"
#import <objc/runtime.h>

@implementation NSObject (Introspector)

-(NSString*)stringForType:(const char*)type parentheses:(BOOL)parentheses
{
    NSString *typeDescription;
    switch (type[0])
    {
        case '@':
        {
            if (strlen(type) > 1)
            {
                typeDescription = [[NSString stringWithFormat:@"%s *", (type + 1)] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else
            {
                typeDescription = @"id";
            }
            break;
            
        }
            
        case 'c':
            typeDescription = @"char";
            break;
            
        case 'i':
            typeDescription = @"int";
            break;
            
        case 's':
            typeDescription = @"short";
            break;
            
        case 'l':
            typeDescription = @"long";
            break;
            
        case 'q':
            typeDescription = @"long long";
            break;
            
        case 'C':
            typeDescription = @"unsigned char";
            break;
            
        case 'I':
            typeDescription = @"unsigned int";
            break;
            
        case 'S':
            typeDescription = @"unsigned short";
            break;
            
        case 'L':
            typeDescription = @"unsigned long";
            break;
            
        case 'Q':
            typeDescription = @"unsigned long long";
            break;
            
        case 'f':
            typeDescription = @"float";
            break;
            
        case 'd':
            typeDescription = @"double";
            break;
            
        case 'B':
            typeDescription = @"bool";
            break;
            
        case '*':
            typeDescription = @"char *";
            break;
            
        case '#':
            typeDescription = @"Class";
            break;
            
        case ':':
            typeDescription = @"SEL";
            break;
            
        case 'v':
            typeDescription = @"void";
            break;
            
        case '[':
        case '{':
        case '(':
            typeDescription = [NSString stringWithFormat:@"%s", type];
            break;
            
        case 'b':
            typeDescription = [NSString stringWithFormat:@"%s", type];
            break;
            
        case '^':
            typeDescription = [NSString stringWithFormat:@"%@ *", [self stringForType:(type + 1) parentheses:NO]];
            break;
            
        default:
            typeDescription = [NSString stringWithFormat:@"?%s", type];
            break;
    }
    return parentheses ? [NSString stringWithFormat:@"(%@)", typeDescription] : typeDescription;
}

-(NSString*)stringForMethod:(Method)method
{
    NSString *methodName = NSStringFromSelector(method_getName(method));
    NSMutableString *decoratedName = [NSMutableString string];
    char returnType[255];
    method_getReturnType(method, returnType, sizeof(returnType));
    [decoratedName appendString:[self stringForType:returnType parentheses:YES]];
    
    int argNum = method_getNumberOfArguments(method);
    if (argNum > 2)
    {
        
        int position = 0;
        NSArray *methodParts = [methodName componentsSeparatedByString:@":"];
        for (int i = 2; i < argNum; i++)
        {
            [decoratedName appendString:@" "];
            char *type = method_copyArgumentType(method, i);
            if (position < methodParts.count)
            {
                [decoratedName appendString:methodParts[position]];
                position++;
            }
            [decoratedName appendString:@":"];
            [decoratedName appendString:[self stringForType:type parentheses:YES]];
            
            free(type);
        }
    }
    else
    {
        [decoratedName appendString:methodName];
    }
    
    return decoratedName;
}

-(NSString*)objectDescription
{
    Class objectClass = [self class];
    NSMutableDictionary *protocolsDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *classMethodsDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *instanceMethodsDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *ivarsDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertiesDict = [NSMutableDictionary dictionary];
    
    NSMutableString *result = [NSMutableString string];
    
    do
    {
        NSUInteger classCount, methodCount, ivarCount, protocolCount, propertyCount;
        Method *classMethods = class_copyMethodList(object_getClass(objectClass), &classCount);
        Method *methods = class_copyMethodList(objectClass, &methodCount);
        Ivar *ivars = class_copyIvarList(objectClass, &ivarCount);
        Protocol * __unsafe_unretained *protocols = class_copyProtocolList(objectClass, &protocolCount);
        objc_property_t *properties = class_copyPropertyList(objectClass, &propertyCount);
        
        // class methods
        for (int i = 0; i < classCount; i++)
        {
            NSString *key = NSStringFromSelector(method_getName(classMethods[i]));
            
            if (![classMethodsDict.allKeys containsObject:key])
            {
                classMethodsDict[key] = [NSString stringWithFormat:@"+%@; // %@",
                                         [self stringForMethod:classMethods[i]],
                                         NSStringFromClass(objectClass)];
            }
        }
        
        // instance methods
        for (int i = 0; i < methodCount; i++)
        {
            NSString *key = NSStringFromSelector(method_getName(methods[i]));
            
            if (![instanceMethodsDict.allKeys containsObject:key])
            {
                instanceMethodsDict[key] = [NSString stringWithFormat:@"-%@; // %@",
                                            [self stringForMethod:methods[i]],
                                            NSStringFromClass(objectClass)];
            }
        }
        
        // ivars
        for (int i = 0; i < ivarCount; i++)
        {
            NSString *key = [NSString stringWithFormat:@"%s", ivar_getName(ivars[i])];
            
            if (![ivarsDict.allKeys containsObject:key])
            {
                ivarsDict[key] = [NSString stringWithFormat:@"%@ %s; // %@",
                                  [self stringForType:ivar_getTypeEncoding(ivars[i]) parentheses:NO],
                                  ivar_getName(ivars[i]),
                                  NSStringFromClass(objectClass)];
            }
        }
        
        // properties
        for (int i = 0; i < propertyCount; i++)
        {
            NSString *key = [NSString stringWithFormat:@"%s", property_getName(properties[i])];
            
            if (![propertiesDict.allKeys containsObject:key])
            {
                NSUInteger attributeCount;
                objc_property_attribute_t *attributes = property_copyAttributeList(properties[i], &attributeCount);
                
                NSMutableString *attrs = [NSMutableString string];
                NSString *type = @"";
                [attrs appendString:@"("];
                for (int j = 0; j < attributeCount; j++)
                {
                    if (attributes[j].name[0] == 'T')
                    {
                        type = [self stringForType:attributes[j].value parentheses:NO];
                    }
                    else
                    {
                        if (attrs.length > 1)
                        {
                            [attrs appendString:@", "];
                        }
                        
                        switch (attributes[j].name[0])
                        {
                            case 'N':
                                [attrs appendString:@"nonatomic"];
                                break;
                                
                            case '&':
                                [attrs appendString:@"strong"];
                                break;
                            case 'C':
                                [attrs appendString:@"copy"];
                                break;
                                
                            case 'W':
                                [attrs appendString:@"weak"];
                                break;
                                
                            case 'R':
                                [attrs appendString:@"readonly"];
                                break;
                                
                            case 'D':
                                [attrs appendString:@"dymanic"];
                                break;
                                
                            case 'V':
                                [attrs appendFormat:@"ivar=%s", attributes[j].value];
                                break;
                                
                            case 'G':
                                [attrs appendFormat:@"getter=%s", attributes[j].value];
                                break;
                                
                            case 'S':
                                [attrs appendFormat:@"setter=%s", attributes[j].value];
                                break;
                                
                            default:
                                [attrs appendFormat:@"%s=%s", attributes[j].name, attributes[j].value];
                        }
                    }
                }
                [attrs appendString:@")"];
                
                propertiesDict[key] = [NSString stringWithFormat:@"@property %@ %@ %s; // %@",
                                       attrs,
                                       type,
                                       property_getName(properties[i]),
                                       NSStringFromClass(objectClass)];
            }
        }
        
        // protocols
        for (int i = 0; i < protocolCount; i++)
        {
            NSString *key = NSStringFromProtocol(protocols[i]);
            
            if (![protocolsDict.allKeys containsObject:key])
            {
                protocolsDict[key] = key;
            }
        }
        
        free(classMethods);
        free(methods);
        free(ivars);
        free(protocols);
        free(properties);
        
        // now getting upper in hierarchy
        objectClass = [objectClass superclass];
    } while (objectClass);
    
    // now, let's build human readable description
    
    [result appendFormat:@"@interface %@ : %@", [self class], [[self class] superclass]];
    if (protocolsDict.count)
    {
        [result appendFormat:@"<%@>", [protocolsDict.allValues componentsJoinedByString:@", "]];
    }
    [result appendString:@"\n"];
    
    if (ivarsDict.count)
    {
        [result appendString:@"{\n"];
        for (NSString *ivar in ivarsDict.allValues)
        {
            [result appendFormat:@"    %@\n", ivar];
        }
        [result appendString:@"}\n\n"];
    }
    
    [result appendString:[classMethodsDict.allValues componentsJoinedByString:@"\n"]];
    if (classMethodsDict.count)
    {
        [result appendString:@"\n\n"];
    }
    
    [result appendString:[propertiesDict.allValues componentsJoinedByString:@"\n"]];
    if (propertiesDict.count)
    {
        [result appendString:@"\n\n"];
    }
    
    [result appendString:[instanceMethodsDict.allValues componentsJoinedByString:@"\n"]];
    if (instanceMethodsDict.count)
    {
        [result appendString:@"\n\n"];
    }
    
    [result appendString:@"@end\n"];
    
    
    return result;
}

@end
