//
//  ColorPalette.swift
//  LessonPlan
//
//  Created by Christopher Fouts on 2/1/22.
//

import SwiftUI

struct ColorPalette: View {
    
    @Binding var selection: Color
    let colors: [Color] = [.red, .green, .blue, .orange, .purple]
    let rows = [GridItem()]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a Color")
            HStack {
                LazyHGrid(rows: rows) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .frame(width: 30)
                            .foregroundColor(color)
                            .opacity(0.5)
                            .onTapGesture {
                                selection = color
                            }
                    }
                }
                Spacer()
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 3)
                    .frame(width: 30)
                    .background(Circle().fill(selection).opacity(0.5))
            }
        }
        .frame(height: 65)
    }
}

//struct ColorPalette_Previews: PreviewProvider {
//    static var previews: some View {
//        static var color = Color.red
//        ColorPalette(selection: $color)
//    }
//}
