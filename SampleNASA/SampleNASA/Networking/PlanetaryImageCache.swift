/*
 Copyright © 2020 Apple Inc.

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit
import Foundation

enum ImageCacheError: Error
{
    case nsURLConstructionError
    case invalidResponseError
}

typealias ImageDownloadCompletionBlock = (Result<UIImage, Error>)->()
protocol PlanetaryImageCaching
{
    func load(url: String, completion: @escaping ImageDownloadCompletionBlock)
}

public class PlanetaryImageCache : PlanetaryImageCaching
{
    public static let publicCache = PlanetaryImageCache()
    var placeholderImage = UIImage(systemName: "rectangle")!
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [ImageDownloadCompletionBlock]]()
    
    /// - Tag: cache
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    final func load(url: String, completion: @escaping ImageDownloadCompletionBlock)
    {
        guard let imageURL = NSURL(string: url) else
        {
            self.invokeCompletionOnMainThread(completion: completion, result:.failure(ImageCacheError.nsURLConstructionError))
            return
        }
        
        // Check for a cached image.
        if let cachedImage = self.image(url: imageURL)
        {
            self.invokeCompletionOnMainThread(completion: completion, result: .success(cachedImage))
        }
        else
        {
            // In case there are more than one requestor for the image, we append their completion block.
            if loadingResponses[imageURL] != nil
            {
                loadingResponses[imageURL]?.append(completion)
            }
            else
            {
                loadingResponses[imageURL] = [completion]
                self.downloadImage(from: imageURL)
            }
        }
    }
    
    private func image(url: NSURL) -> UIImage?
    {
        return cachedImages.object(forKey: url)
    }
    
    private func downloadImage(from url: NSURL)
    {
        let urlSession = URLSession.shared.dataTask(with: url as URL) { [weak self] (data, response, error) in
            guard let self = self, let blocks = self.loadingResponses[url] else { return }
            if let error = error {
                self.invokeBlocks(blocks: blocks, result: .failure(error))
            }
            else
            {
                guard let responseData = data, let image = UIImage(data: responseData) else {
                    self.invokeBlocks(blocks: blocks, result:.failure(ImageCacheError.invalidResponseError))
                    return
                }
                self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
                self.invokeBlocks(blocks: blocks, result: .success(image))
                self.loadingResponses.removeValue(forKey: url)
            }
        }
        urlSession.resume()
    }
    
    private func invokeBlocks(blocks: [ImageDownloadCompletionBlock], result: Result<UIImage,Error>)
    {
        for block in blocks
        {
            self.invokeCompletionOnMainThread(completion: block, result: result)
        }
    }
    
    private func invokeCompletionOnMainThread(completion: @escaping ImageDownloadCompletionBlock, result: Result<UIImage,Error>)
    {
        DispatchQueue.main.async {
            completion(result)
        }
    }
        
}
