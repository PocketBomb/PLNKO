
import SwiftUI

struct CustomTextShadow2: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

import SwiftUI

struct CustomTextShadow: View {
    let text: String
    let width: CGFloat
    let color: Color = Color(red: 0.027, green: 0.031, blue: 0.192).opacity(0.23)
    
    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:0, y:  width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}
