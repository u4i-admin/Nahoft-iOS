//
//  SliderView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 11.08.2023.
//

import SwiftUI

struct SliderView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.layoutDirection) var direction
    @State private var index = 0
    @State var slides: [Slide]
    
    @State private var showDetail = false
    
    var body: some View {
        VStack {
            ZStack {
                TabView(selection: $index) {
                    ForEach($slides.indices, id: \.self) { i in
                        VStack {
                            if slides[i].image.starts(with: "StatusIcon") {
                                Circle()
                                    .foregroundColor(Color(slides[i].image))
                                    .frame(width: 100, height: 100)
                            } else {
                                Image(systemName: slides[i].image)
                                    .font(.system(size: 100))
                            }
                            
                            Text(slides[i].title)
                                .font(.system(size: 40, weight: .bold))
                                .padding(.top, 50)
                                .padding(.bottom, 10)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                            
                            Text(slides[i].description)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 35)
                                .multilineTextAlignment(.center)
                            
                            if slides[i].fullDescription != nil {
                                Button {
                                    showDetail.toggle()
                                } label: {
                                    Text("read more")
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .sheet(isPresented: $showDetail, content: {
                                    NavigationStack {
                                        SliderDetailView(title: slides[i].title, description: slides[i].fullDescription!)
                                    }
                                })
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                if index > 0 {
                    HStack {
                        Button {
                            withAnimation() {
                                index -= 1
                            }
                        } label: {
                            Image(systemName: direction == .leftToRight ? "chevron.compact.left" : "chevron.compact.right")
                                .font(.largeTitle)
                                .foregroundColor(Color("StatusIconRequested"))
                                .padding(.leading)
                        }
                        
                        Spacer()
                    }
                }
                
                if index < slides.count - 1 {
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation() {
                                index += 1
                            }
                        } label: {
                            Image(systemName: direction == .leftToRight ? "chevron.compact.right" : "chevron.compact.left")
                                .font(.largeTitle)
                                .foregroundColor(Color("StatusIconRequested"))
                                .padding(.trailing)
                        }
                    }
                }
            }
            
            HStack {
                ForEach(slides.indices, id: \.self) { index in
                    Circle()
                        .frame(width: 15)
                        .foregroundColor((direction == .leftToRight && index == self.index) ? Color("StatusIconRequested") : (direction == .rightToLeft && slides.count - 1 - index == self.index) ? Color("StatusIconRequested") : .gray)
                }
            }
            .padding(.bottom, 50)
            
            Button {
                dismiss()
            } label: {
                Text(slides[index].buttonText)
                    .foregroundColor(slides[index].showButtonAsLink ? .blue : .white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: slides[index].showButtonAsLink ? .leading : .center)
            .background(slides[index].showButtonAsLink ? Color.white : Color.blue)
            .cornerRadius(10)
            .padding()
        }
    }
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        SliderView(slides: Slides.messageListSlides)
    }
}
