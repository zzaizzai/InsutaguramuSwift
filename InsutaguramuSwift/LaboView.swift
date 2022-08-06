//
//  LaboView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/06.
//

import SwiftUI
import RefreshableScrollView


struct LaboView: View {
    @State var numbers = 0
    var body: some View {
        RefreshableScrollView {
            Text(numbers.description)
        }
        .refreshable {
            self.numbers += 1
        }

        
    }
}

struct LaboView_Previews: PreviewProvider {
    static var previews: some View {
        LaboView()
    }
}
