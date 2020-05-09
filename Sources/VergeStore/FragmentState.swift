//
// Copyright (c) 2020 Hiroshi Kimura(Muukii) <muuki.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public protocol FragmentType {
  associatedtype State
  var version: UInt64 { get }
}

/**
 A structure that manages sub-state-tree from root-state-tree.
 
 When you create derived data for this sub-tree, you may need to activate memoization.
 The reason why it needs memoization, the derived data does not need to know if other sub-state-tree updated.
 Better memoization must know owning state-tree has been updated at least.
 To get this done, it's not always we need to support Equatable.
 It's easier to detect the difference than detect equals.
 
 Fragment is a wrapper structure and manages version number inside.
 It increments the version number each wrapped value updated.
 
 Memoization can use that version if it should pass new input.
 
 To activate this feature, you can check this method.
 `MemoizeMap.map(_ map: @escaping (Changes<Input.Value>) -> Fragment<Output>) -> MemoizeMap<Input, Output>`
 */
@propertyWrapper
public struct Fragment<State>: FragmentType {
  
  public var version: UInt64 {
    _read {
      yield counter.version
    }
  }
  
  private(set) public var counter: VersionCounter = .init()
  
  public init(wrappedValue: State) {
    self.wrappedValue = wrappedValue
  }
  
  public var wrappedValue: State {
    didSet {
      counter.markAsUpdated()
    }
  }
  
  public var projectedValue: Fragment<State> {
    self
  }
  
}

extension Comparer where Input : FragmentType {
  
  public static func versionEquals() -> Comparer<Input> {
    Comparer<Input>.init { $0.version == $1.version }
  }
}