//
//  CarouselScrollView.swift
//
//
//  Created by O'Brien, Patrick on 3/23/21.
//

import SwiftUI

struct CarouselScrollView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable, Data.Index == Int, Data: Equatable {
    @Environment(\.carouselOptions) var options
    
    private let data: Data
    private let content: (Data.Element) -> Content
    
    @State private var containerSize: CGSize = .zero
    @State private var scrollOffset: CGFloat
    @State private var isDragging: Bool = false
    @State private var startPosition: CGPoint = .zero
    
    private var itemWidth: CGFloat {
        (self.containerSize.width - (self.options.itemSpacing * (CGFloat(self.data.count) - 1))) / CGFloat(self.data.count)
    }
    
    @Binding var currentIndex: Int
    @GestureState private var dragOffset: CGFloat
    
    init(_ data: Data, currentIndex: Binding<Int>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self._currentIndex = currentIndex
        self._dragOffset = GestureState(initialValue: 0)
        self._scrollOffset = State(initialValue: 0)
        self.content = content
    }
    
    var body: some View {
        HStack(alignment: options.alignment, spacing: options.itemSpacing) {
            ForEach(data) { element in
                content(element)
            }
        }
        .readSize { size in
            containerSize = size
        }
        .frame(width: UIScreen.main.bounds.width, height: options.carouselHeight)
        .offset(x: dragOffset + scrollOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if !self.isDragging {
                        self.startPosition = gesture.location
                        self.isDragging.toggle()
                    }
                }
                .onEnded { gesture in
                    let xDistance = abs(gesture.location.x - self.startPosition.x)
                    let yDistance = abs(gesture.location.y - self.startPosition.y)
                    
                    if self.startPosition.x > gesture.location.x, yDistance < xDistance {
                        guard currentIndex < data.count - 1 else { return }
                        currentIndex += 1
                        
                    } else if self.startPosition.x < gesture.location.x, yDistance < xDistance {
                        guard currentIndex > 0 else { return }
                        currentIndex -= 1
                    }
                    isDragging.toggle()
                }
        )
        .onChange(of: currentIndex, perform: { newIndex in
            withAnimation(Animation.interpolatingSpring(mass: 1, stiffness: 800, damping: 60)) {
                scrollTo(index: newIndex)
            }
        })
        .onAppear {
            scrollTo(index: 0)
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: { newContainerSize in
            containerSize = newContainerSize
            scrollTo(index: currentIndex)
        })
    }
    
    func scrollTo(index: Int) {
        let newOffset = self.calculateNewOffset(index: CGFloat(index))
        self.scrollOffset = newOffset
    }
    
    func calculateNewOffset(index: CGFloat) -> CGFloat {
        -(self.itemWidth + self.options.itemSpacing) * index + (self.containerSize.width - self.itemWidth) / 2
    }
}

/**
 Options to modify the behavior of the Carousel
 */
public struct CarouselOptions {
    var itemSpacing: CGFloat
    var carouselHeight: CGFloat?
    var alignment: VerticalAlignment

    /// Initializer
    /// - Parameters:
    ///   - itemSpacing: Spacing between the Carousel child views
    ///   - carouselHeight: Height of the carousel
    ///   - alignment: Vertical Alignment of the Carousel child views
    public init(itemSpacing: CGFloat, carouselHeight: CGFloat? = nil, alignment: VerticalAlignment) {
        self.itemSpacing = itemSpacing
        self.carouselHeight = carouselHeight
        self.alignment = alignment
    }
}
