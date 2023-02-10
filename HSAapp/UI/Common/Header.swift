//
//  Header.swift
//

import SwiftUI

struct Header: View {
    var body: some View {
        VStack(alignment: .center, spacing: nil) {
            Text(appString.hsaText()).font(.system(size: 56.0))
            Text(appString.getHealthyMeessage())
        }
        
    }
}

struct LogoHeader: View {
    var body: some View {
        VStack(alignment: .center, spacing: nil) {
            Image("logo").resizable().frame(width: 141, height: 136, alignment: .center)
        }
        
    }
}

struct LogoHeader_Previews: PreviewProvider {
    static var previews: some View {
        LogoHeader()
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header()
    }
}
