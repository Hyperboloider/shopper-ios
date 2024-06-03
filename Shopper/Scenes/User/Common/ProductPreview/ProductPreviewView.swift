//
//  ProductPreviewView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import SwiftUI

struct ProductPreviewView: View {
    
    @StateObject var viewModel: ProductPreviewModel
    @Binding var item: ShoppingCartItem
    @Binding var isEditable: Bool
    @State var maxValue: Double = 0
    var isDeletable: Bool = false
    var onDelete: () -> Void = {}
    var onUpdateFinished: () -> Void = {}
    
    init(
        viewModel: ProductPreviewModel,
        item: Binding<ShoppingCartItem>,
        isEditable: Binding<Bool> = .constant(true),
        maxValue: Double = 30,
        isDeletable: Bool = true,
        onDelete: @escaping () -> Void,
        onUpdateFinished: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._item = item
        self._isEditable = isEditable
        self.maxValue = maxValue
        self.isDeletable = isDeletable
        self.onDelete = onDelete
        self.onUpdateFinished = onUpdateFinished
        
        viewModel.counterStep = self.item.product.isPricePerKilo ? 0.05 : 1
        viewModel.roundingRatio = self.item.product.isPricePerKilo ? 100 : 1
        viewModel.minimumValue = self.item.product.isPricePerKilo ? 0.05 : 1
        
        if self.item.product.isPricePerKilo {
            viewModel.canDelete = abs(self.item.amount - 0.1) < viewModel.counterStep / 2
        } else {
            viewModel.canDelete = self.item.amount == 1
        }
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let imageUrlString = item.product.imageUrl, let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(
                        url: imageUrl,
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 50, maxHeight: 50)
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                } else {
                    Image(systemName: "bag.badge.questionmark")
                        .scaleEffect(x: 2, y: 2)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.secondary)
                        .frame(width: 50, height:50)
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(item.product.name)
                            .font(.system(.title3))
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .fixedSize(horizontal: false, vertical: true) // :)
                        
                        Text(item.product.category)
                            .font(.system(.headline, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        UAHView(total: item.product.price)
                            .font(.system(.title3, weight: .bold))
                            .fixedSize()
                        
                        Text(item.product.isPricePerKilo ? "per kilo" : "per item")
                            .font(.system(.footnote))
                            .foregroundColor(.secondary)
                    }
                }
            }
            VStack {
                
                
                Spacer()
                
                HStack {
                    if item.amount > viewModel.minimumValue {
                        let total = item.product.price * Double(item.amount)
                        ViewThatFits {
                            Text("Sum: ")
                                .font(.system(.title3, weight: .regular))
                            +
                            UAHView(total: total)
                                .font(.system(.title3, weight: .bold))
                            
                            VStack {
                                Text("Sum: ")
                                    .font(.system(.title3, weight: .regular))
                                
                                UAHView(total: total)
                                    .font(.system(.title3, weight: .bold))
                            }
                        }
                        .frame(height: 40)

                    }
                    
                    Spacer()
                    
                    if isEditable {
                        StepperView()
                            .frame(height: 40)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical)
        .animation(.linear(duration: 0.04), value: item.amount)
    }
    
    @ViewBuilder
    private func StepperView() -> some View {
        HStack {
            if isDeletable, viewModel.canDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 45, height: 30)
                        .background { Color(red: 238 / 255, green: 238 / 255, blue: 239 / 255) }
                        .cornerRadius(7)
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
            } else {
                Image(systemName: "minus")
                    .frame(width: 45, height: 30)
                    .background { Color(red: 238 / 255, green: 238 / 255, blue: 239 / 255) }
                    .cornerRadius(7)
                    .foregroundColor(.black)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                viewModel.counterStep = abs(viewModel.counterStep) * -1
                                start()
                            }
                            .onEnded { _ in
                                stop()
                            }
                    )
            }
            
            if item.product.isPricePerKilo {
                Text(String(Double(round(viewModel.roundingRatio * item.amount) / viewModel.roundingRatio)))
                    .fixedSize()
                    .frame(width: 40)
            } else {
                Text(String(Int(item.amount)))
                    .fixedSize()
                    .frame(width: 40)
            }
            
            Image(systemName: "plus")
                .frame(width: 45, height: 30)
                .background { Color(red: 238 / 255, green: 238 / 255, blue: 239 / 255) }
                .cornerRadius(7)
                .foregroundColor(.black)
                .buttonStyle(.borderless)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            viewModel.counterStep = abs(viewModel.counterStep)
                            start()
                        }
                        .onEnded { _ in
                            stop()
                        }
                )
        }
    }
    
    private let updateSpeedThresholds = (maxUpdateSpeed: TimeInterval(0.08), minUpdateSpeed: TimeInterval(0.2))
    private let maxSpeedReachedInNumberOfSeconds = TimeInterval(2.5)

    @State var started = false

    @State private var timer: Timer?
    @State private var currentUpdateSpeed = TimeInterval(0.3)
    @State private var lastValueChangingDate: Date?
    @State private var startDate: Date?

    func start() {
        if item.amount + viewModel.counterStep > viewModel.minimumValue {
            viewModel.canDelete = false
        }
        
        if !started {
            started = true
            startDate = Date()
            startTimer()
        }
    }

    func stop() {
        timer?.invalidate()
        currentUpdateSpeed = updateSpeedThresholds.minUpdateSpeed
        lastValueChangingDate = nil
        started = false
        
        if item.amount + viewModel.counterStep < viewModel.minimumValue {
            viewModel.canDelete = true
        }
        
        onUpdateFinished()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: updateSpeedThresholds.maxUpdateSpeed, repeats: false) { _ in
            if viewModel.canDelete {
                stop()
                return
            }
            updateVal()
            updateSpeed()
            startTimer()
        }
    }

    private func updateVal() {
        if lastValueChangingDate == nil || Date().timeIntervalSince(lastValueChangingDate!) >= currentUpdateSpeed {
            guard item.amount + viewModel.counterStep >= viewModel.minimumValue, item.amount + viewModel.counterStep <= maxValue else {
                stop()
                return
            }
            lastValueChangingDate = Date()
            item.amount += viewModel.counterStep
        }
    }

    private func updateSpeed() {
        if currentUpdateSpeed < updateSpeedThresholds.maxUpdateSpeed {
            return
        }
        let timePassed = Date().timeIntervalSince(startDate!)
        currentUpdateSpeed = timePassed * (updateSpeedThresholds.maxUpdateSpeed - updateSpeedThresholds.minUpdateSpeed) / maxSpeedReachedInNumberOfSeconds + updateSpeedThresholds.minUpdateSpeed
    }
}

struct ProductPreviewView_Previews: PreviewProvider {
    
    struct Test: View {
        
        @State var items = [ShoppingCartItem(product: ProductResponse(
            id: "jknfwelkf",
            name: "Coca-Cola Zero",
            description: "Sugar-free Coke.",
            upc: "123445312345",
            pricePerKilo: 15.10, weightPerItem: 1,
            isPricePerKilo: false,
            caloriesPer100g: 0,
            protein: 0,
            fat: 0,
            carb: 0,
            category: "fuzzy drinks", imageUrl: ""))]
        
        var body: some View {
            List($items) { $item in
                ProductPreviewView(viewModel: ProductPreviewModel(), item: $item, onDelete: {}, onUpdateFinished: {})
                    .previewLayout(.fixed(width: 350, height: 150))
                    .buttonStyle(PlainButtonStyle())
            }
        }
        
    }
    
    static var previews: some View {
        Test()
    }
}
