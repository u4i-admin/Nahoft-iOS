//
//  SliderDetailView.swift
//  Nahoft
//
//  Created by Work Account on 14.08.2023.
//

import SwiftUI

struct SliderDetailView: View {
    @State var title: LocalizedStringKey
    @State var description: LocalizedStringKey
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
            
            ScrollView {
                Text(description)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.gray)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Close")
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
        }
    }
}

struct SliderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SliderDetailView(title: "Title", description: "Description")
    }
}
