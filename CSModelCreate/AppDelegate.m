//
//  AppDelegate.m
//  CSModelCreate
//
//  Created by hanxing on 2017/3/21.
//  Copyright © 2017年 hanxing. All rights reserved.
//

#import "AppDelegate.h"
#define PREFIX _prefixField.stringValue

NSString *const kBaseModelName = @"XMBaseModel";

@interface AppDelegate ()

@end

@implementation AppDelegate
//程序启动
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //测试-develop1-1
    //测试develop-0
}
- (IBAction)generate:(id)sender {
    //测试develop-2
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    NSString *folder = NSHomeDirectory();
    NSString * resultFolder = [folder stringByAppendingFormat:@"/Desktop/CSModelCreate/results/"];
    BOOL isDirectiry = NO;
    if (![fileManager fileExistsAtPath:resultFolder isDirectory:&isDirectiry]) {
        NSAlert * alert = [[NSAlert alloc] init];
        [alert setMessageText:@"路径错误,请把本工程放到桌面上!"];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];

        return;
    }
    NSArray * fileArrays = [fileManager subpathsOfDirectoryAtPath:resultFolder error:nil];
    for (NSString * path in fileArrays) {
        NSString * fullPath = [resultFolder stringByAppendingPathComponent:path];
        [fileManager removeItemAtPath:fullPath error:nil];
    }
    
    NSString * jsonString = _textView.string;
    NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (json) {
        [self generateFile:json withFileName:_modelNameField.stringValue];
        NSAlert * alert = [[NSAlert alloc] init];
        [alert setMessageText:@"导出完成"];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    }else{
        NSAlert * alert = [[NSAlert alloc] init];
        [alert setMessageText:@"json解析错误"];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
        
    }
    
}
-(NSString *)stringFirstUpcase:(NSString *)string{
    if (string.length<2) {
        return [string uppercaseString];
    }
    return [NSString stringWithFormat:@"%@%@",[[string substringToIndex:1] uppercaseString],[string substringFromIndex:1]];
}
-(NSData *)generateHFileData:(id)json withFileNmae:(NSString *)fileNmae{
    NSMutableString * string = [[NSMutableString alloc] initWithCapacity:0];
    if ([json isKindOfClass:[NSDictionary class]]) {
//        NSMutableString * defineString = [[NSMutableString alloc] initWithCapacity:0];
        NSMutableString * propertyString = [[NSMutableString alloc] initWithCapacity:0];
        NSMutableString * importString = [[NSMutableString alloc] initWithCapacity:0];
        [string appendString:[NSString stringWithFormat:@"#import \"%@.h\"\r\n",kBaseModelName]];
        for (NSString * key in [json allKeys]) {
            id value = [json objectForKey:key];
//            [defineString appendFormat:@"#define MODEL_KEY_%@_%@  @\"%@\"\r\n",[fileNmae uppercaseString],[key uppercaseString],key];
            if ([value isKindOfClass:[NSArray class]])
            {
//                [importString appendFormat:@"#import \"%@%@Models.h\"\r\n",PREFIX,[self stringFirstUpcase:key]];
            [propertyString appendFormat:@"@property (nonatomic, strong) NSArray *%@;\r\n",key];
            }
            else if ([value isKindOfClass:[NSDictionary class]])
            {
                [importString appendFormat:@"#import \"%@%@Model.h\"\r\n",PREFIX,[self stringFirstUpcase:key]];
                [propertyString appendFormat:@"@property (nonatomic, strong) %@%@Model *%@;\r\n",PREFIX,[self stringFirstUpcase:key],key];
            }
            else
            {
                NSString * className = @"NSString";
                if ([value isKindOfClass:[NSNumber class]])
                {
                    className = @"NSNumber";
                    [propertyString appendFormat:@"@property (nonatomic, strong) %@ *%@;\r\n",className,key];
                }
                else if([value isKindOfClass:[NSString class]])
                {
                    [propertyString appendFormat:@"@property (nonatomic, copy) %@ *%@;\r\n",className,key];
                }
                else
                {
                    [propertyString appendFormat:@"@property (nonatomic) %@ *%@;\r\n",className,key];
                }
            }
        }
        [string appendString:importString];
        [string appendString:@"\r\n"];
//        [string appendString:defineString];
        [string appendFormat:@"@interface %@ : %@\r\n",fileNmae,kBaseModelName];
        [string appendString:propertyString];
        [string appendString:@"@end\r\n"];
    }else if([json isKindOfClass:[NSArray class]]){
        [string appendString:[NSString stringWithFormat:@"#import \"%@.h\"\r\n",kBaseModelName]];
        [string appendFormat:@"#import \"%@.h\"\r\n\r\n",[fileNmae substringToIndex:fileNmae.length]];
        [string appendFormat:@"@end"];
    }
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSData *)generateMFileData:(id)json withFileNmae:(NSString *)fileNmae{
    NSMutableString * string = [[NSMutableString alloc] initWithCapacity:0];
    [string appendFormat:@"#import \"%@.h\"\r\n\r\n",fileNmae];
    [string appendFormat:@"@implementation %@\r\n\r\n",fileNmae];
    [string appendFormat:@"@end"];
    return [string dataUsingEncoding:NSUTF8StringEncoding];
    
}

-(void)generateFile:(id)json withFileName:(NSString *)fileName{
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    NSString *folder = NSHomeDirectory();
    NSString * hFilePath = [folder stringByAppendingFormat:@"/Desktop/CSModelCreate/results/%@.h",fileName];
    NSString * mFilePath = [folder stringByAppendingFormat:@"/Desktop/CSModelCreate/results/%@.m",fileName];
    NSData * hData = [self generateHFileData:json withFileNmae:fileName];
    if (![fileManager fileExistsAtPath:hFilePath]) {
        [fileManager createFileAtPath:hFilePath contents:hData attributes:NULL];
    }else{
        [hData  writeToFile:hFilePath atomically:YES];
    }
    //create .m file
    NSData * mData = [self generateMFileData:json withFileNmae:fileName];
    if (![fileManager fileExistsAtPath:mFilePath]) {
        [fileManager createFileAtPath:mFilePath contents:mData attributes:NULL];
    }else{
        [mData  writeToFile:mFilePath atomically:YES];
    }
    if ([json isKindOfClass:[NSDictionary class]]) {
        //create .h file
        
        for (NSString * key in [json allKeys]) {
            id value = [json objectForKey:key];
            if ([value isKindOfClass:[NSArray class]] || [value  isKindOfClass:[NSDictionary class]])
            {
                [self generateFile:value withFileName:[NSString stringWithFormat:@"%@%@Model",PREFIX,[self stringFirstUpcase:key]]];
            }
        }
        
    }
    else if([json isKindOfClass:[NSArray class]])
    {
        NSArray * jsonArray = json;
        if (jsonArray.count)
        {
            id model = [jsonArray objectAtIndex:0];
            [self generateFile:model withFileName:[fileName substringToIndex:fileName.length]];
        }
    }
}

@end
