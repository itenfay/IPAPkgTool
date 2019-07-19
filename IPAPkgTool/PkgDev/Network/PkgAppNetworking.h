//
//  PkgAppNetworking.h
//
//  Created by dyf on 16/6/30.
//  Copyright © 2016 dyf. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

/** PNKMethod */
typedef NS_ENUM(NSUInteger, PNKMethod) {
    /** GET Method */
    PNK_GET_Method = 1,
    
    /** POST Method */
    PNK_POST_Method = 2
};

/**
 *  PNKCallbackHandler
 *
 *  @param response       URL Response
 *  @param responseObject 返回数据
 *  @param error          错误
 */
typedef void (^PNKCallbackHandler)(NSURLResponse *response, id responseObject, NSError *error);

/**
 *  PNKUploadProgressBlock
 *
 *  @param uploadProgress A block object to be executed when the upload progress is updated. Note this block is called on the session queue, not the main queue.
 */
typedef void (^PNKUploadProgressBlock)(NSProgress *uploadProgress);

/**
 *  PNKDownloadProgressBlock
 *
 *  @param downloadProgress A block object to be executed when the download progress is updated. Note this block is called on the session queue, not the main queue.
 */
typedef void (^PNKDownloadProgressBlock)(NSProgress *downloadProgress);

/**
 *  PNKDestinationBlock
 *
 *  @param targetPath 目标路径
 *  @param response   URL response
 *
 *  @return An `NSURL` object
 */
typedef NSURL *(^PNKDestinationBlock)(NSURL *targetPath, NSURLResponse *response);

@interface PkgAppNetworking : NSObject

/**
 *  是否允许无效证书
 *
 *  @param allowed YES or NO
 */
+ (void)allowInvalidCertificates:(BOOL)allowed;

/**
 *  Request Serialization
 *
 *  @param method     请求方法
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *
 *  @return An `NSMutableURLRequest` object
 */
- (NSMutableURLRequest *)requestWithMethod:(PNKMethod)method URLString:(NSString *)URLString parameters:(id)parameters;

/**
 *  Request Serialization
 *
 *  @param method          请求方法
 *  @param URLString       请求地址
 *  @param parameters      请求参数
 *  @param timeoutInterval 请求超时
 *
 *  @return An `NSMutableURLRequest` object
 */
- (NSMutableURLRequest *)requestWithMethod:(PNKMethod)method URLString:(NSString *)URLString parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 *  Creating a Data Task
 *
 *  @param request           URL请求
 *  @param completionHandler 完成回调
 *
 *  @return An `NSURLSessionDataTask` object
 */
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(PNKCallbackHandler)completionHandler;

/**
 *  Creating a Data Task
 *
 *  @param request               URL请求
 *  @param uploadProgressBlock   上传进度Block
 *  @param downloadProgressBlock 下载进度Block
 *  @param completionHandler     完成回调
 *
 *  @return An `NSURLSessionDataTask` object
 */
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(PNKUploadProgressBlock)uploadProgressBlock
                             downloadProgress:(PNKDownloadProgressBlock)downloadProgressBlock
                            completionHandler:(PNKCallbackHandler)completionHandler;

/**
 *  Creates an `NSURLSessionUploadTask` with the specified request for a local file.
 *
 *  @param request             URL请求
 *  @param fileURL             文件URL地址
 *  @param uploadProgressBlock 上传进度Block
 *  @param completionHandler   完成回调
 *
 *  @return An `NSURLSessionUploadTask` object
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(PNKUploadProgressBlock) uploadProgressBlock
                                completionHandler:(PNKCallbackHandler)completionHandler;

/**
 *  Creates an `NSURLSessionDownloadTask` with the specified request.
 *
 *  @param request               URL请求
 *  @param downloadProgressBlock 下载进度Block
 *  @param destination           目的地Block
 *  @param completionHandler     完成回调
 *
 *  @return An `NSURLSessionDownloadTask` object
 */
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(PNKDownloadProgressBlock)downloadProgressBlock
                                          destination:(PNKDestinationBlock)destination
                                    completionHandler:(PNKCallbackHandler)completionHandler;
@end
