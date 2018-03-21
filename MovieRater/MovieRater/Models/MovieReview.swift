/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

struct MovieReview: Codable {
  let movie: String
  let review: String
  let rating: Int
}

extension MovieReview: Hashable {
  var hashValue: Int {
    return review.hashValue
  }
  
  static func ==(lhs: MovieReview, rhs: MovieReview) -> Bool {
    return lhs.review == rhs.review
  }
}

extension MovieReview {
  static func loadReviews() -> [String : [MovieReview]] {
    guard let url = Bundle.main.url(forResource: "reviews", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else { fatalError("Unable to load reviews file") }
    
    let decoder = JSONDecoder()
    do {
      let reviews = try decoder.decode([MovieReview].self, from: data)
      return Dictionary(grouping: reviews, by: { $0.movie })
    } catch let e {
      print(e.localizedDescription)
      fatalError("Unable to load movie reviews")
    }
  }
}
