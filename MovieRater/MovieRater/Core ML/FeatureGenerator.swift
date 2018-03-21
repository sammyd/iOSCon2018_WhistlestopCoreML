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
import CoreML

class FeatureGenerator {
  var sentimentFeatures: [SentimentFeature]?
  
  init() {
    loadSentimentFeatures()
  }
  
  func featureCount(for text: String) -> [SentimentFeature : Int] {
    guard let sentimentFeatures = sentimentFeatures else { fatalError("Cannot find sentiment features") }
    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
    tagger.string = text
    let options: NSLinguisticTagger.Options = [.omitWhitespace,
                                               .omitPunctuation,
                                               .omitOther,
                                               .joinNames]
    let range = NSRange(text.startIndex..., in: text)
    var featureCount = [SentimentFeature : Int]()
    tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { (tag, tokenRange, _) in
      guard tag != nil else { return }
      let word = String(text[Range(tokenRange, in: text)!])

      if let feature = sentimentFeatures.filter({ $0.word == word }).first {
        let count = featureCount[feature] ?? 0
        featureCount[feature] = count + 1
      }
    }
    return featureCount
  }
  
  func featureVector(for featureCount: [SentimentFeature : Int]) -> MLMultiArray {
    guard let sentimentFeatures = sentimentFeatures else { fatalError("Cannot find sentiment features") }
    let featureValues = tfidf(from: featureCount)
    let featureVector = try! MLMultiArray(shape: [1, NSNumber(value: sentimentFeatures.count)], dataType: .double)
    
    for i in 0 ..< featureVector.count {
      featureVector[i] = 0
    }
    
    for (feature, tfidf) in featureValues {
      featureVector[feature.index] = NSNumber(value: tfidf)
    }
    
    return featureVector
  }
  
  func featureVector(for text: String) -> MLMultiArray {
    let counts = featureCount(for: text)
    return featureVector(for: counts)
  }
  
  private func loadSentimentFeatures() {
    guard let url = Bundle.main.url(forResource: "features", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else { fatalError("Unable to load feature file") }
    
    let decoder = JSONDecoder()
    do {
      sentimentFeatures = try decoder.decode([SentimentFeature].self, from: data)
    } catch {
      fatalError("Unable to load sentiment features")
    }
  }
  
  private func sublinearTf(from count: Int) -> Double {
    return log(Double(count)) + 1
  }
  
  private func l2norm(_ array: [Double]) -> [Double] {
    let squares = array.map { $0 * $0 }
    let sum = squares.reduce(0, +)
    let denominator = sqrt(sum)
    return array.map { $0 / denominator }
  }
  
  func tfidf(from featureCount: [SentimentFeature : Int]) -> [SentimentFeature : Double] {
    let tfidf = featureCount.map { (feature, count) in
      return feature.idf * sublinearTf(from: count)
    }
    let normalised = l2norm(tfidf)
    return Dictionary(uniqueKeysWithValues: zip(featureCount.keys, normalised))
  }
}
